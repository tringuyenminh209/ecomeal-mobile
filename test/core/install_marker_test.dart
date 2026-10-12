import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecomeal_mobile/core/supabase_client.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

// iOS giữ Keychain sau khi gỡ app: cài lại thì phiên của lần cài trước phải bị xoá trước khi Supabase đọc
void main() {
  late MockSecureStorage keychain;

  setUp(() {
    keychain = MockSecureStorage();
    when(() => keychain.delete(key: any(named: 'key'))).thenAnswer((_) async {});
  });

  test('vừa cài (preferences trống) → xoá phiên còn sót trong Keychain, ghi dấu', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await clearSessionFromPreviousInstall(prefs, storage: SecureSessionStorage(storage: keychain));
    verify(() => keychain.delete(key: 'ecomeal.auth.session')).called(1);
    expect(prefs.getBool(installMarkerKey), isTrue);
  });

  test('đã có dấu (mở lại app) → giữ phiên', () async {
    SharedPreferences.setMockInitialValues({installMarkerKey: true});
    final prefs = await SharedPreferences.getInstance();
    await clearSessionFromPreviousInstall(prefs, storage: SecureSessionStorage(storage: keychain));
    verifyNever(() => keychain.delete(key: any(named: 'key')));
  });

  test('cập nhật từ bản cũ (chưa có dấu nhưng đã chọn ngôn ngữ) → giữ phiên, chỉ ghi dấu', () async {
    SharedPreferences.setMockInitialValues({'locale': 'ja'});
    final prefs = await SharedPreferences.getInstance();
    await clearSessionFromPreviousInstall(prefs, storage: SecureSessionStorage(storage: keychain));
    verifyNever(() => keychain.delete(key: any(named: 'key')));
    expect(prefs.getBool(installMarkerKey), isTrue);
  });
}
