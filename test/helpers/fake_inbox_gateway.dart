import 'package:ecomeal_mobile/features/notifications/notification_inbox.dart';

// Hộp「お知らせ」giả: trả danh sách cố định, đếm số lần đánh dấu đã đọc
class FakeInboxGateway implements NotificationInboxGateway {
  FakeInboxGateway({this.items = const []});
  List<InboxNotification> items;
  int markedAll = 0;

  @override
  Future<InboxPage> fetch({int limit = 50}) async =>
      InboxPage(items: items.take(limit).toList(), unreadCount: items.where((n) => !n.isRead).length);

  @override
  Future<void> markAllRead() async {
    markedAll++;
    items = [
      for (final n in items)
        InboxNotification(id: n.id, type: n.type, stopName: n.stopName, isRead: true, createdAt: n.createdAt),
    ];
  }
}
