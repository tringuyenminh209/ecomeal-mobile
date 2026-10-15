import 'package:ecomeal_mobile/core/mfa_http_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

// 2026-10-15: app 運営 trên iPhone/iPad không qua được 2 bước xác thực — Supabase Auth trả mfa_ip_address_mismatch
// vì challenge và verify ra Internet bằng 2 IP khác nhau
void main() {
  test('chỉ request /auth/v1/factors/… đi qua kết nối riêng', () async {
    final seen = <String>[];
    MockClient recorder(String name) => MockClient((r) async {
      seen.add('$name ${r.url.path}');
      return http.Response('{}', 200);
    });
    final client = MfaStickyHttpClient(inner: recorder('inner'), mfa: recorder('mfa'));
    const base = 'https://x.supabase.co';
    await client.post(Uri.parse('$base/auth/v1/factors/f1/challenge'));
    await client.post(Uri.parse('$base/auth/v1/factors/f1/verify'));
    await client.post(Uri.parse('$base/auth/v1/token?grant_type=password'));
    await client.get(Uri.parse('$base/rest/v1/orders'));
    expect(seen, [
      'mfa /auth/v1/factors/f1/challenge',
      'mfa /auth/v1/factors/f1/verify',
      'inner /auth/v1/token',
      'inner /rest/v1/orders',
    ]);
  });

  group('retryOnMfaIpMismatch', () {
    const mismatch = AuthException('Challenge and verify IP addresses mismatch.', code: 'mfa_ip_address_mismatch');

    test('lệch IP rồi qua → thử lại (cùng mã), trả kết quả', () async {
      var calls = 0;
      final result = await retryOnMfaIpMismatch(() async {
        calls++;
        if (calls < 3) throw mismatch;
        return 'aal2';
      });
      expect(result, 'aal2');
      expect(calls, 3);
    });

    test('lệch IP cả 3 lần → báo lỗi lệch IP (không thử mãi)', () async {
      var calls = 0;
      await expectLater(
        retryOnMfaIpMismatch(() async {
          calls++;
          throw mismatch;
        }),
        throwsA(predicate(isMfaIpMismatch)),
      );
      expect(calls, 3);
    });

    test('mã sai / lỗi khác → không thử lại', () async {
      var calls = 0;
      await expectLater(
        retryOnMfaIpMismatch(() async {
          calls++;
          throw const AuthException('Invalid TOTP code entered', code: 'mfa_verification_failed');
        }),
        throwsA(isA<AuthException>()),
      );
      expect(calls, 1);
    });
  });
}
