import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mfa_http_client.dart';

// 16_セキュリティ設計 §1/§3: session nằm trong Keychain/Keystore, không trong preferences.
class SecureSessionStorage extends LocalStorage {
  const SecureSessionStorage({this.storage = const FlutterSecureStorage()});
  final FlutterSecureStorage storage;
  static const _key = 'ecomeal.auth.session';

  @override
  Future<void> initialize() async {}
  @override
  Future<bool> hasAccessToken() => storage.containsKey(key: _key);
  @override
  Future<String?> accessToken() => storage.read(key: _key);
  @override
  Future<void> persistSession(String persistSessionString) =>
      storage.write(key: _key, value: persistSessionString);
  @override
  Future<void> removePersistedSession() => storage.delete(key: _key);
}

// iOS: Keychain KHÔNG bị xoá khi gỡ app, còn SharedPreferences thì có. Cài lại → app tự đăng nhập bằng phiên của lần cài
// trước (người dùng không hề đăng nhập), bỏ qua SCR-M01, và nếu refresh token cũ đã hết hạn thì lần mở sau lại bị đăng
// xuất — đã gặp trên iPhone 2026-10-12: màn đồng ý điều khoản hiện ra rồi mở lại thì vào thẳng SCR-M02.
// Lần chạy đầu của 1 lần cài (chưa có dấu trong preferences) → xoá phiên cũ trong Keychain trước khi Supabase đọc nó.
const installMarkerKey = 'ecomeal.install.marker';

Future<void> clearSessionFromPreviousInstall(SharedPreferences prefs, {SecureSessionStorage storage = const SecureSessionStorage()}) async {
  if (prefs.getBool(installMarkerKey) == true) return;
  // Cập nhật từ bản cũ (chưa có dấu nhưng preferences đã có dữ liệu, vd ngôn ngữ đã chọn) → cùng lần cài, giữ phiên
  if (prefs.getKeys().isEmpty) await storage.removePersistedSession();
  await prefs.setBool(installMarkerKey, true);
}

class SupabaseClientHolder {
  static late SupabaseClient instance;
}

Future<void> initSupabase() async {
  final response = await Supabase.initialize(
    url: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'http://10.0.2.2:54321',
    ),
    // supabase_flutter 2.15 đổi tên tham số anonKey → publishableKey (anonKey đã deprecated). Giá trị vẫn là
    // key công khai in ra bởi `supabase start` (ANON_KEY hoặc PUBLISHABLE_KEY — cả 2 đều dùng được ở đây).
    publishableKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    // 2 bước xác thực của app 運営 phải đi cùng 1 IP (mfa_http_client.dart)
    httpClient: MfaStickyHttpClient(),
    authOptions: const FlutterAuthClientOptions(
      localStorage: SecureSessionStorage(),
    ),
  );
  SupabaseClientHolder.instance = response.client;
}
