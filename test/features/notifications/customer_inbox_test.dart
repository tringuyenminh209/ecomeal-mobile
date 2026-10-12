import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/features/notifications/notification_inbox.dart';
import '../../helpers/fake_inbox_gateway.dart';
import '../../helpers/test_app.dart';

// SCR-M20 お知らせ（app khách）: chuông nổi trên bản đồ SCR-M03 → danh sách → chạm 1 mục mở màn liên quan
Widget _app(Widget home, FakeInboxGateway inbox) => ProviderScope(
  overrides: [notificationInboxGatewayProvider.overrideWithValue(inbox)],
  child: testApp(home),
);

InboxNotification _n(String id, String type, {String? stop, bool read = false}) =>
    InboxNotification(id: id, type: type, stopName: stop, isRead: read, createdAt: DateTime.now());

void main() {
  test('inboxContent: 4 loại của app khách cùng câu với thông báo đẩy; không có tên điểm → câu chung', () {
    expect(inboxContent('truck_approaching', l10nJa, stopName: '大阪学生寮前').body, l10nJa.noticeTruckApproachingBody('大阪学生寮前'));
    expect(
      inboxContent('truck_approaching', l10nJa).body,
      l10nJa.noticeTruckApproachingBody(l10nJa.noticeTruckApproachingPlace),
    );
    expect(inboxContent('new_batch', l10nJa, stopName: '梅田駅前').body, l10nJa.noticeNewBatchBody('梅田駅前'));
    expect(inboxContent('issue_resolved', l10nJa).title, l10nJa.noticeIssueResolvedTitle);
    expect(inboxContent('refunded', l10nJa).title, l10nJa.noticeRefundedTitle);
  });

  testWidgets('chuông nổi: chấm khi chưa đọc → mở SCR-M20; chạm mục → đóng trang và báo loại đã chạm', (tester) async {
    final inbox = FakeInboxGateway(items: [_n('n1', 'truck_approaching', stop: '大阪学生寮前'), _n('n2', 'refunded', read: true)]);
    InboxNotification? opened;
    await tester.pumpWidget(
      _app(Scaffold(body: InboxBellButton(userId: 'u-1', floating: true, onOpen: (n) => opened = n)), inbox),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isTrue);

    await tester.tap(find.byKey(const Key('inboxBell')));
    await tester.pumpAndSettle();
    expect(find.text(l10nJa.noticeTruckApproachingBody('大阪学生寮前')), findsOneWidget);
    expect(find.text(l10nJa.noticeRefundedTitle), findsOneWidget);

    await tester.tap(find.text(l10nJa.noticeTruckApproachingTitle));
    await tester.pumpAndSettle();
    expect(find.byType(NotificationInboxPage), findsNothing);
    expect(opened?.type, 'truck_approaching');
    expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isFalse, reason: 'mở danh sách là đã đọc');
  });

  testWidgets('SCR-M20 trống: câu dành cho người dùng (không phải câu của app nhà hàng)', (tester) async {
    await tester.pumpWidget(
      _app(
        NotificationInboxPage(userId: 'u-1', emptyBody: l10nJa.inboxEmptyBodyCustomer, onOpen: (_) {}),
        FakeInboxGateway(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(l10nJa.inboxEmptyBodyCustomer), findsOneWidget);
    expect(find.text(l10nJa.inboxEmptyBody), findsNothing);
  });
}
