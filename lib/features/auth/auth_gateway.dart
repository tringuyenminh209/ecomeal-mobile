import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/web_admin.dart';

// Bọc đúng những gì AuthController cần (9 method) — KHÔNG để AuthController biết tới
// SupabaseClient. Xem box-why đầu chương: mock thẳng SupabaseClient không ổn định
// (supabase-flutter#714, TimeoutException), mock 1 interface tự định nghĩa thì luôn an toàn.
typedef AuthProfile = ({String role, String languageCode});

// Đích của link xác thực trong mail (SCR-W10 trên Web Admin). Không truyền thì Supabase đưa về Site URL = màn
// đăng nhập quản trị, khách mobile tưởng nhầm. Phải nằm trong Authentication → URL Configuration → Redirect URLs.
const emailConfirmedUrl = '$webAdminUrl/email-confirmed';

abstract class AuthGateway {
  Session? get currentSession;
  Stream<AuthState> get onAuthStateChange;
  Future<void> signInWithPassword({
    required String email,
    required String password,
  });
  Future<void> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  });
  Future<void> signOut();
  Future<AuthProfile> fetchProfile(String userId);
  // UC-28 đặt lại mật khẩu bằng mã trong mail (API-028/029/030).
  Future<void> requestPasswordReset(String email);
  Future<void> verifyRecoveryCode({required String email, required String code});
  Future<void> updatePassword(String password);
}

class SupabaseAuthGateway implements AuthGateway {
  SupabaseAuthGateway(this._client);
  final SupabaseClient _client;

  @override
  Session? get currentSession => _client.auth.currentSession;

  @override
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: data,
      emailRedirectTo: emailConfirmedUrl,
    );
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  // Supabase trả thành công kể cả khi email chưa đăng ký — không để lộ email nào có tài khoản.
  @override
  Future<void> requestPasswordReset(String email) {
    return _client.auth.resetPasswordForEmail(email);
  }

  // Mã đúng → Supabase tạo session (đã đăng nhập) — AuthController giữ người dùng ở màn đặt lại
  // cho tới khi updatePassword xong (isRecoveringPassword).
  @override
  Future<void> verifyRecoveryCode({required String email, required String code}) {
    return _client.auth.verifyOTP(email: email, token: code, type: OtpType.recovery);
  }

  @override
  Future<void> updatePassword(String password) {
    return _client.auth.updateUser(UserAttributes(password: password));
  }

  // users.role không nằm trong JWT mặc định (giống lý do đã giải thích ở authStore.ts, Chương 10)
  // — phải tự SELECT lại từ public.users sau khi có session.
  @override
  Future<AuthProfile> fetchProfile(String userId) async {
    final row = await _client
        .from('users')
        .select('role, preferred_language')
        .eq('id', userId)
        .single();
    return (
      role: row['role'] as String,
      languageCode: row['preferred_language'] as String,
    );
  }
}
