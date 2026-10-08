import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Session, AuthState;
import '../../core/supabase_client.dart';
import 'auth_gateway.dart';
import 'locale_controller.dart';
import 'package:flutter/widgets.dart' show Locale;

// supabase_flutter cũng có 1 class tên AuthState (sự kiện của onAuthStateChange) — đặt tên khác
// cho state của app để không đụng nhau.
class AppAuthState {
  const AppAuthState({
    required this.session,
    required this.role,
    required this.isInitializing,
    this.isRecoveringPassword = false,
  });
  const AppAuthState.initial()
    : session = null,
      role = null,
      isInitializing = true,
      isRecoveringPassword = false;

  final Session? session;
  final AppRole? role;
  final bool isInitializing;
  // UC-28: mã khôi phục đúng thì Supabase tạo session NGAY, trước khi người dùng đặt mật khẩu mới.
  // Cờ này bảo RoleGate giữ SCR-M02 (màn đặt lại) cho tới khi updatePassword xong hoặc huỷ.
  final bool isRecoveringPassword;

  AppAuthState copyWith({bool? isRecoveringPassword}) => AppAuthState(
    session: session,
    role: role,
    isInitializing: isInitializing,
    isRecoveringPassword: isRecoveringPassword ?? this.isRecoveringPassword,
  );
}

enum AppRole { customer, driver, restaurantOwner, admin }

AppRole _roleFromDb(String value) {
  switch (value) {
    case 'customer':
      return AppRole.customer;
    case 'driver':
      return AppRole.driver;
    case 'restaurant_owner':
      return AppRole.restaurantOwner;
    case 'admin':
      return AppRole.admin;
    default:
      throw ArgumentError('unknown role from DB: $value');
  }
}

class AuthController extends StateNotifier<AppAuthState> {
  AuthController(this._gateway, {this.onLanguageChanged})
    : super(const AppAuthState.initial());

  final Future<void> Function(String)? onLanguageChanged;

  final AuthGateway _gateway;
  StreamSubscription<AuthState>? _subscription;

  // Gọi đúng 1 lần từ authControllerProvider (bước dưới) — KHÔNG gọi trong constructor, để test
  // có thể tạo AuthController(mockGateway) rồi tự quyết định lúc nào initialize() (tránh side
  // effect ngoài ý muốn ngay khi khởi tạo object trong lúc test setUp()).
  //
  // Thứ tự quan trọng (xem box-warn ngay dưới): SUBSCRIBE TRƯỚC, đọc snapshot SAU. Làm ngược lại
  // thì sự kiện auth xảy ra giữa lúc đọc currentSession và lúc listen() sẽ bị mất vĩnh viễn.
  Future<void> initialize() async {
    _subscription = _gateway.onAuthStateChange.listen((data) {
      unawaited(_syncSession(data.session));
    });
    await _syncSession(_gateway.currentSession);
  }

  // Mỗi lần sync được cấp 1 số thứ tự tăng dần. fetchRole() là async — nếu session A còn đang chờ
  // fetchRole thì user đăng xuất (hoặc session B tới), lượt sync mới hơn sẽ tăng _syncGeneration;
  // khi fetchRole của A trả về muộn, nó thấy mình không còn là lượt mới nhất và BỎ kết quả, không
  // được ghi đè state của B/đăng xuất.
  int _syncGeneration = 0;

  Future<void> _syncSession(Session? session) async {
    final generation = ++_syncGeneration;
    if (session == null) {
      state = AppAuthState(
        session: null,
        role: null,
        isInitializing: false,
        isRecoveringPassword: state.isRecoveringPassword,
      );
      return;
    }
    try {
      final profile = await _gateway.fetchProfile(session.user.id);
      if (!mounted || generation != _syncGeneration) {
        return;
      }
      final role = _roleFromDb(profile.role);
      // UC-02: áp dụng ngôn ngữ server chỉ khi session này vẫn là lượt mới nhất.
      // Đồng bộ ngôn ngữ chỉ là phụ: lỗi (vd ghi SharedPreferences) không được làm mất role → kẹt ở màn hình "role null".
      try {
        await onLanguageChanged?.call(profile.languageCode);
      } catch (_) {}
      if (!mounted || generation != _syncGeneration) return;
      state = AppAuthState(
        session: session,
        role: role,
        isInitializing: false,
        isRecoveringPassword: state.isRecoveringPassword,
      );
    } catch (err) {
      if (!mounted || generation != _syncGeneration) return;
      // Đăng nhập đã thành công (có session) — chỉ riêng bước đọc role lỗi (mất mạng, v.d.).
      // Vẫn phải kết thúc isInitializing, nếu không màn hình loading treo mãi (cùng bài học đã
      // rút ra khi sửa deadlock ở Web Admin, dù nguyên nhân kỹ thuật ở đây khác hẳn).
      state = AppAuthState(
        session: session,
        role: null,
        isInitializing: false,
        isRecoveringPassword: state.isRecoveringPassword,
      );
    }
  }

  Future<void> signIn({required String email, required String password}) {
    return _gateway.signInWithPassword(email: email, password: password);
  }

  // languageCode đến từ LocaleController (bước 5) — xem box-warn đầu chương: đây là nơi DUY NHẤT
  // preferred_language của 1 user MỚI được lưu, qua raw_user_meta_data, không qua API-023.
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String languageCode,
  }) {
    return _gateway.signUp(
      email: email,
      password: password,
      data: {'name': name, 'preferred_language': languageCode},
    );
  }

  Future<void> signOut() => _gateway.signOut();

  // ── UC-28 Đặt lại mật khẩu (API-028/029/030) ──────────────────────────────────────
  Future<void> requestPasswordReset(String email) => _gateway.requestPasswordReset(email);

  // Bật cờ TRƯỚC khi gọi: sự kiện signedIn có thể tới trước khi await này trả về.
  Future<void> verifyRecoveryCode({required String email, required String code}) async {
    state = state.copyWith(isRecoveringPassword: true);
    try {
      await _gateway.verifyRecoveryCode(email: email, code: code);
    } catch (_) {
      if (mounted) state = state.copyWith(isRecoveringPassword: false);
      rethrow;
    }
  }

  // Lỗi (vd trùng mật khẩu cũ) → giữ cờ: mã đã dùng hết, người dùng chỉ cần nhập lại mật khẩu.
  Future<void> updatePassword(String password) async {
    await _gateway.updatePassword(password);
    if (mounted) state = state.copyWith(isRecoveringPassword: false);
  }

  // Bỏ ngang sau khi mã đã đúng: đăng xuất để không vào app bằng mật khẩu chưa ai biết.
  Future<void> cancelPasswordRecovery() async {
    try {
      if (state.session != null) await _gateway.signOut();
    } finally {
      if (mounted) state = state.copyWith(isRecoveringPassword: false);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final authGatewayProvider = Provider<AuthGateway>((ref) {
  return SupabaseAuthGateway(SupabaseClientHolder.instance);
});

final authControllerProvider = StateNotifierProvider<AuthController, AppAuthState>((
  ref,
) {
  final controller = AuthController(
    ref.watch(authGatewayProvider),
    onLanguageChanged: (languageCode) async {
      if (ref.read(localeControllerProvider).languageCode != languageCode) {
        await ref
            .read(localeControllerProvider.notifier)
            .setLocale(Locale(languageCode));
      }
    },
  );
  // Gọi initialize() ngay khi provider được đọc lần đầu — tương đương useEffect(() => {...}, [])
  // đã dùng ở App.tsx (Chương 10), nhưng theo đúng idiom Riverpod: hàm khởi tạo provider chỉ
  // chạy đúng 1 lần, không cần lifecycle hook riêng.
  unawaited(controller.initialize());
  return controller;
});
