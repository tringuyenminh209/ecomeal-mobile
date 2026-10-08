import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 12_アーキテクチャ設計 §2 gọi lớp này là "LIFF連携" — nhưng LIFF là SDK cho web app chạy trong
// LINE, app Flutter native không chạy được. Tương đương native là LINE Login SDK trên CÙNG LINE Login
// channel chứa LIFF app: ID token cấp ra có aud = channel ID đó, nên Edge Function link-line-account
// (Chương 09, verify với client_id = LINE_LIFF_CHANNEL_ID) chấp nhận y hệt token từ LIFF.
abstract class LineLoginBridge {
  Future<String> obtainIdToken();
}

class LineSdkLoginBridge implements LineLoginBridge {
  @override
  Future<String> obtainIdToken() async {
    // 'openid' là bắt buộc — thiếu scope này LINE chỉ cấp access token, không có ID token để verify.
    // botPrompt 'aggressive': sau màn đồng ý, LINE mở thêm màn mời kết bạn với Official Account đã liên kết
    // với channel (@939hqcxi, チャネル基本設定 → 友だち追加オプション). LINE CHỈ gửi tin push cho người đã kết
    // bạn — thiếu bước này thì liên kết thành công nhưng thông báo "xe sắp tới" (UC-24, send-proximity-notification)
    // không bao giờ tới được khách, và Edge Function gửi thất bại trong im lặng.
    final result = await LineSDK.instance.login(
      scopes: const ['profile', 'openid'],
      option: LoginOption(false, 'aggressive'),
    );
    final idToken = result.accessToken.idTokenRaw;
    if (idToken == null) {
      throw StateError('LINE Login không trả về ID token (kiểm tra scope openid của channel)');
    }
    return idToken;
  }
}

final lineLoginBridgeProvider = Provider<LineLoginBridge>((ref) => LineSdkLoginBridge());
