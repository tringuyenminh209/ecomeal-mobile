import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_flavor.dart';

// Thông báo app bằng Firebase Cloud Messaging (0048, ADR-009). Cấu hình Firebase lấy từ env.json (dart-define), không
// commit google-services.json / GoogleService-Info.plist — thiếu khoá thì app chạy bình thường, chỉ ẩn thẻ「アプリの通知」.
const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
const _senderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
// Mỗi app (package / bundle ID) là 1 Firebase app riêng trong cùng project (ADR-015). Thiếu ID của app nào thì app đó
// không có thông báo (các app khác không bị ảnh hưởng).
const _androidAppIds = {
  AppFlavor.customer: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
  AppFlavor.store: String.fromEnvironment('FIREBASE_ANDROID_APP_ID_STORE'),
  AppFlavor.admin: String.fromEnvironment('FIREBASE_ANDROID_APP_ID_ADMIN'),
};
const _iosAppIds = {
  AppFlavor.customer: String.fromEnvironment('FIREBASE_IOS_APP_ID'),
  AppFlavor.store: String.fromEnvironment('FIREBASE_IOS_APP_ID_STORE'),
  AppFlavor.admin: String.fromEnvironment('FIREBASE_IOS_APP_ID_ADMIN'),
};

bool _initialized = false;

Future<void> initPush(AppFlavor flavor) async {
  final appId = (defaultTargetPlatform == TargetPlatform.iOS ? _iosAppIds : _androidAppIds)[flavor] ?? '';
  if (kIsWeb || _apiKey.isEmpty || _projectId.isEmpty || _senderId.isEmpty || appId.isEmpty) return;
  await Firebase.initializeApp(
    options: FirebaseOptions(apiKey: _apiKey, appId: appId, messagingSenderId: _senderId, projectId: _projectId),
  );
  _initialized = true;
}

enum PushPermission { notDetermined, granted, denied }

// Thông báo người dùng vừa chạm: loại + data của FCM (send-push gửi `type`, có lô thì thêm `surplus_batch_id`).
// Giữ lại để app mở đúng màn (audit C05/S05/A06) — trước đây lớp bọc chỉ báo "có chạm" nên app mở cùng một chỗ.
typedef OpenedPush = ({String type, Map<String, dynamic> data});

OpenedPush openedPushFrom(Map<String, dynamic> data) =>
    (type: data['type'] is String ? data['type'] as String : '', data: data);

// Bọc firebase_messaging — widget test thay bằng bản giả (không có Firebase trong test).
abstract class PushClient {
  String get platform; // 'android' | 'ios' — cột push_tokens.platform
  Future<PushPermission> permission();
  Future<PushPermission> requestPermission();
  Future<String?> token();
  Stream<String> get onTokenRefresh;
  Stream<({String title, String body})> get onForegroundMessage; // app đang mở: hệ điều hành không tự hiện
  Stream<OpenedPush> get onOpened; // người dùng chạm vào thông báo
  Future<OpenedPush?> openedFromTerminated(); // app được mở từ trạng thái đã tắt bằng cách chạm thông báo (null: mở thường)
}

class FirebasePushClient implements PushClient {
  final _messaging = FirebaseMessaging.instance;

  @override
  String get platform => defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

  static PushPermission _map(AuthorizationStatus s) => switch (s) {
        AuthorizationStatus.authorized || AuthorizationStatus.provisional => PushPermission.granted,
        AuthorizationStatus.denied || AuthorizationStatus.deniedPermanently => PushPermission.denied,
        AuthorizationStatus.notDetermined => PushPermission.notDetermined,
      };

  @override
  Future<PushPermission> permission() async => _map((await _messaging.getNotificationSettings()).authorizationStatus);

  @override
  Future<PushPermission> requestPermission() async => _map((await _messaging.requestPermission()).authorizationStatus);

  @override
  Future<String?> token() => _messaging.getToken();

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Stream<({String title, String body})> get onForegroundMessage => FirebaseMessaging.onMessage
      .where((m) => m.notification != null)
      .map((m) => (title: m.notification!.title ?? '', body: m.notification!.body ?? ''));

  @override
  Stream<OpenedPush> get onOpened => FirebaseMessaging.onMessageOpenedApp.map((m) => openedPushFrom(m.data));

  @override
  Future<OpenedPush?> openedFromTerminated() async {
    final m = await _messaging.getInitialMessage();
    return m == null ? null : openedPushFrom(m.data);
  }
}

// null = chưa cấu hình Firebase → không có thông báo app (UI ẩn thẻ).
final pushClientProvider = Provider<PushClient?>((ref) => _initialized ? FirebasePushClient() : null);
