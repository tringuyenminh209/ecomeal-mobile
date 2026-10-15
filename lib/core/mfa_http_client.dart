import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

// Supabase Auth từ chối mã 2 bước khi bước challenge và bước verify đến từ 2 IP khác nhau (mfa_ip_address_mismatch).
// Trên iPhone/iPad (2026-10-15, app 運営) mỗi kết nối mới có thể ra Internet bằng IP khác — log Auth: challenge từ
// 60.56.x, verify từ 126.113.x — nên không bao giờ đăng nhập được; Web trên PC đi 1 IP nên vẫn qua.
// → Request /auth/v1/factors/… đi qua 1 kết nối duy nhất (giữ sống giữa challenge và verify), các request khác như cũ.
bool isMfaFactorRequest(Uri url) => url.path.contains('/auth/v1/factors/');

class MfaStickyHttpClient extends http.BaseClient {
  MfaStickyHttpClient({http.Client? inner, http.Client? mfa})
    : _inner = inner ?? http.Client(),
      _mfa =
          mfa ??
          IOClient(
            HttpClient()
              ..maxConnectionsPerHost = 1
              ..idleTimeout = const Duration(seconds: 60),
          );
  final http.Client _inner;
  final http.Client _mfa;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      isMfaFactorRequest(request.url) ? _mfa.send(request) : _inner.send(request);

  @override
  void close() {
    _inner.close();
    _mfa.close();
  }
}

bool isMfaIpMismatch(Object error) => error is AuthException && error.code == 'mfa_ip_address_mismatch';

// Kết nối vẫn có thể bị đóng giữa 2 bước (đổi Wi-Fi ↔ 4G) → tạo challenge mới và thử lại. Mã TOTP chưa bị dùng vì
// server từ chối trước khi kiểm mã, nên thử lại cùng mã được.
Future<T> retryOnMfaIpMismatch<T>(Future<T> Function() attempt, {int attempts = 3}) async {
  for (var i = 1; ; i++) {
    try {
      return await attempt();
    } catch (e) {
      if (!isMfaIpMismatch(e) || i >= attempts) rethrow;
    }
  }
}
