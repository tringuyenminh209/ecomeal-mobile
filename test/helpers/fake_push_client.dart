import 'dart:async';

import 'package:ecomeal_mobile/core/push_notifications.dart';

// Máy giả cho thông báo đẩy: quyền hiện tại + kết quả sau khi hỏi quyền (push_test, favorite_stops_test)
class FakePushClient implements PushClient {
  FakePushClient(this.current, {this.afterRequest = PushPermission.granted});
  PushPermission current;
  final PushPermission afterRequest;
  int requests = 0;
  final refresh = StreamController<String>.broadcast();
  final foreground = StreamController<({String title, String body})>.broadcast();
  final opened = StreamController<OpenedPush>.broadcast();
  // app được mở từ trạng thái đã tắt bằng cách chạm thông báo này (null: mở thường)
  OpenedPush? initial;

  @override
  String get platform => 'android';
  @override
  Future<PushPermission> permission() async => current;
  @override
  Future<PushPermission> requestPermission() async {
    requests++;
    return current = afterRequest;
  }

  @override
  Future<String?> token() async => 'device-token-1';
  @override
  Stream<String> get onTokenRefresh => refresh.stream;
  @override
  Stream<({String title, String body})> get onForegroundMessage => foreground.stream;
  @override
  Stream<OpenedPush> get onOpened => opened.stream;
  @override
  Future<OpenedPush?> openedFromTerminated() async => initial;
}
