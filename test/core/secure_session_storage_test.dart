import 'package:ecomeal_mobile/core/supabase_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('session được lưu, đọc lại và xóa trong secure storage', () async {
    FlutterSecureStorage.setMockInitialValues({});
    const storage = SecureSessionStorage();
    await storage.initialize();
    expect(await storage.hasAccessToken(), isFalse);
    await storage.persistSession('test-session');
    expect(await storage.hasAccessToken(), isTrue);
    expect(await storage.accessToken(), 'test-session');
    await storage.removePersistedSession();
    expect(await storage.accessToken(), isNull);
  });
}
