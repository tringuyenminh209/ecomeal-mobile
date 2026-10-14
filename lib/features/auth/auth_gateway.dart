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
  // Phiên lưu trên máy còn được server nhận không: true / false (server từ chối: 401/403, vd session_not_found) /
  // null (không biết — mất mạng, hoặc access token vừa hết hạn và SDK đang tự làm mới). Chỉ false mới được đăng xuất.
  Future<bool?> isSessionAlive();
  Future<AuthProfile> fetchProfile(String userId);
  // UC-28 đặt lại mật khẩu bằng mã trong mail (API-028/029/030).
  Future<void> requestPasswordReset(String email);
  Future<void> verifyRecoveryCode({required String email, required String code});
  Future<void> updatePassword(String password);
  // UC-45 (0057, ADR-013). LINE: Edge Function line-login (API-076) xác minh ID token → token dùng 1 lần → verifyOTP lấy phiên.
  Future<void> signInWithLineIdToken({required String idToken, required String languageCode});
  // Apple: provider Apple của Supabase Auth. fullName chỉ có ở lần đầu (Apple không gửi lại) → lưu làm tên hiển thị.
  Future<void> signInWithAppleIdToken({required String idToken, required String rawNonce, String? fullName});
}

// Tài khoản tạo bằng LINE (0057) có email nội bộ không nhận thư — cùng miền với lineLoginEmail() của Edge Function line-login.
// Màn hình không hiện địa chỉ này mà hiện「LINEでログイン中」.
bool isLineOnlyEmail(String email) => email.endsWith('@line.ecomeal.invalid');

// Lỗi có mã do line-login trả (envelope của Edge Function), vd E-AUTH-403 (tài khoản không phải khách).
class SocialLoginException implements Exception {
  const SocialLoginException(this.code);
  final String code;
  @override
  String toString() => 'SocialLoginException($code)';
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

  @override
  Future<bool?> isSessionAlive() async {
    final session = _client.auth.currentSession;
    if (session == null) return false;
    if (session.isExpired) return null; // SDK tự làm mới; làm mới thất bại thì SDK tự phát signedOut
    try {
      await _client.auth.getUser();
      return true;
    } on AuthException catch (e) {
      return e.statusCode == '401' || e.statusCode == '403' ? false : null;
    } catch (_) {
      return null;
    }
  }

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
  Future<void> signInWithLineIdToken({required String idToken, required String languageCode}) async {
    final String tokenHash;
    try {
      final res = await _client.functions.invoke('line-login', body: {'id_token': idToken, 'language': languageCode});
      final data = res.data;
      final hash = data is Map && data['data'] is Map ? (data['data'] as Map)['token_hash'] : null;
      if (hash is! String) throw const SocialLoginException('E-INTERNAL');
      tokenHash = hash;
    } on FunctionException catch (e) {
      final details = e.details;
      final code = details is Map && details['error'] is Map ? (details['error'] as Map)['code'] : null;
      throw SocialLoginException(code is String ? code : 'E-INTERNAL');
    }
    await _client.auth.verifyOTP(type: OtpType.magiclink, tokenHash: tokenHash);
  }

  @override
  Future<void> signInWithAppleIdToken({required String idToken, required String rawNonce, String? fullName}) async {
    final res = await _client.auth.signInWithIdToken(provider: OAuthProvider.apple, idToken: idToken, nonce: rawNonce);
    final name = fullName?.trim();
    final userId = res.user?.id;
    if (name == null || name.isEmpty || userId == null) return;
    // Chỉ thay tên mặc định của trigger 0057 — không ghi đè tên người dùng đã tự sửa. Lỗi ở đây không chặn đăng nhập.
    try {
      await _client.from('users').update({'name': name}).eq('id', userId).eq('name', 'EcoMealユーザー');
    } catch (_) {}
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
