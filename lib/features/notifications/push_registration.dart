import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_flavor.dart';
import '../../core/push_notifications.dart';
import '../../core/supabase_client.dart';

// API-056: lưu / xoá token thiết bị (push_tokens, 0048). Test thay bằng bản giả.
abstract class PushTokenGateway {
  Future<void> register(String token, String platform);
  Future<void> unregister(String token);
}

// API-056 v2 (0059): gửi kèm app của token — server chỉ nhận app khớp với role, và send-push chỉ gửi tới token của app
// đích, nên thông báo của app nhà hàng không hiện trên app khách của cùng người (và ngược lại).
class SupabasePushTokenGateway implements PushTokenGateway {
  SupabasePushTokenGateway(this._client, this._flavor);
  final SupabaseClient _client;
  final AppFlavor _flavor;

  @override
  Future<void> register(String token, String platform) => _client.rpc(
    'register_push_token',
    params: {'p_token': token, 'p_platform': platform, 'p_app': _flavor.pushApp},
  );

  @override
  Future<void> unregister(String token) => _client.rpc('unregister_push_token', params: {'p_token': token});
}

final pushTokenGatewayProvider = Provider<PushTokenGateway>(
  (ref) => SupabasePushTokenGateway(SupabaseClientHolder.instance, ref.watch(appFlavorProvider)),
);

// Trạng thái thẻ「アプリの通知」ở SCR-M07 (Figma 436:1053 オフ / 470:1400 オン / 436:1223 許可されていない).
enum PushStatus { unavailable, off, on, denied }

final pushStatusProvider = FutureProvider.autoDispose<PushStatus>((ref) async {
  final client = ref.watch(pushClientProvider);
  if (client == null) return PushStatus.unavailable;
  return switch (await client.permission()) {
    PushPermission.granted => PushStatus.on,
    PushPermission.denied => PushStatus.denied,
    PushPermission.notDetermined => PushStatus.off,
  };
});

Future<void> _registerCurrentToken(WidgetRef ref, PushClient client) async {
  final token = await client.token();
  if (token != null) await ref.read(pushTokenGatewayProvider).register(token, client.platform);
}

// 「通知をオンにする」: hỏi quyền (Android 13+ / iOS) → được cho phép thì lưu token. Trả về trạng thái mới.
Future<PushStatus> enablePush(WidgetRef ref) async {
  final client = ref.read(pushClientProvider);
  if (client == null) return PushStatus.unavailable;
  final permission = await client.requestPermission();
  if (permission == PushPermission.granted) await _registerCurrentToken(ref, client);
  ref.invalidate(pushStatusProvider);
  return permission == PushPermission.granted ? PushStatus.on : PushStatus.denied;
}

// Quyền thông báo bị từ chối → mở trang Cài đặt của app; quay lại app thì đọc lại quyền (SCR-M07, thẻ ☆ của SCR-M04)
Future<void> openPushSettings(WidgetRef ref) async {
  await Geolocator.openAppSettings();
  ref.invalidate(pushStatusProvider);
}

// Gọi TRƯỚC khi đăng xuất (lúc còn JWT): máy này thôi nhận thông báo của tài khoản cũ. Lỗi thì bỏ qua — không được chặn
// việc đăng xuất; người đăng nhập tiếp theo trên máy này sẽ nhận lại token (register_push_token gán lại chủ).
Future<void> unregisterPush(WidgetRef ref) async {
  final client = ref.read(pushClientProvider);
  if (client == null) return;
  try {
    final token = await client.token();
    if (token != null) await ref.read(pushTokenGatewayProvider).unregister(token);
  } catch (_) {}
}

typedef PushCallback = void Function(BuildContext context, WidgetRef ref);
typedef PushOpenCallback = void Function(BuildContext context, WidgetRef ref, OpenedPush push);

// Bọc shell của app có thông báo (khách: CustomerShell, nhà hàng: StoreShell): khi đã được phép thì đăng ký token (mỗi lần mở
// app + khi Firebase đổi token), hiện thông báo lúc app đang mở bằng SnackBar rồi gọi [onMessage] (tải lại dữ liệu liên quan),
// chạm vào thông báo thì gọi [onOpened] kèm loại + data (mỗi app mở màn theo loại, giống khi chạm ở お知らせ).
// Widget này chỉ có sau khi đăng nhập xong (nằm trong shell) → app mở từ thông báo cũng chỉ chuyển màn sau bước đăng nhập.
class PushRegistrar extends ConsumerStatefulWidget {
  const PushRegistrar({super.key, required this.child, required this.onMessage, required this.onOpened});
  final Widget child;
  final PushCallback onMessage;
  final PushOpenCallback onOpened;

  @override
  ConsumerState<PushRegistrar> createState() => _PushRegistrarState();
}

class _PushRegistrarState extends ConsumerState<PushRegistrar> {
  final _subscriptions = <StreamSubscription<Object?>>[];

  @override
  void initState() {
    super.initState();
    final client = ref.read(pushClientProvider);
    if (client != null) unawaited(_start(client));
  }

  Future<void> _start(PushClient client) async {
    try {
      if (await client.permission() == PushPermission.granted) await _registerCurrentToken(ref, client);
    } catch (_) {
      // Thông báo là phụ: lỗi mạng lúc đăng ký không được làm hỏng màn hình chính
    }
    if (!mounted) return;
    _subscriptions
      ..add(client.onTokenRefresh.listen((token) {
        ref.read(pushTokenGatewayProvider).register(token, client.platform).catchError((_) {});
      }))
      ..add(client.onForegroundMessage.listen((m) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${m.title}\n${m.body}')));
        widget.onMessage(context, ref);
      }))
      ..add(client.onOpened.listen(_opened));
    final initial = await client.openedFromTerminated();
    if (initial != null) _opened(initial);
  }

  void _opened(OpenedPush push) {
    if (mounted) widget.onOpened(context, ref, push);
  }

  @override
  void dispose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
