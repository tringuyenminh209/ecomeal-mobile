import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
    authOptions: const FlutterAuthClientOptions(
      localStorage: SecureSessionStorage(),
    ),
  );
  SupabaseClientHolder.instance = response.client;
}
