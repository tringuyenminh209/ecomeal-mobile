import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ecomeal_mobile/core/app_version.dart';
import 'package:ecomeal_mobile/features/notifications/notification_inbox.dart';
import 'package:ecomeal_mobile/features/notifications/push_registration.dart';
import 'package:ecomeal_mobile/features/store/store_gateway.dart';
import 'package:ecomeal_mobile/features/store/store_inquiry_page.dart';
import 'package:ecomeal_mobile/features/store/store_ratings_page.dart';
import 'package:ecomeal_mobile/features/store/store_settings_page.dart';
import 'package:ecomeal_mobile/features/store/store_settlement_page.dart';
import '../../helpers/fake_inbox_gateway.dart';
import '../../helpers/fake_store_gateway.dart';
import '../../helpers/test_app.dart';

StoreRestaurant _restaurant() => StoreRestaurant(
  id: 'r-1',
  name: 'キッチン青葉',
  address: '大阪市北区梅田1-2-3',
  closingTime: '21:30:00',
  isApproved: true,
  rejectedAt: null,
  rejectionReason: null,
  appliedAt: DateTime.utc(2026, 10, 1),
  applicantName: '青葉 太郎',
);

final _confirmed = StoreSettlement(
  id: '11111111-2222-3333-4444-555566660a1f',
  periodMonth: '2026-09-01',
  orders: 72,
  sales: 51560,
  payout: 10312,
  confirmedAt: DateTime.utc(2026, 10, 7, 23), // JST 10/8
  paidAt: null,
);
final _paid = StoreSettlement(
  id: '99999999-2222-3333-4444-5555666600b2',
  periodMonth: '2026-08-01',
  orders: 65,
  sales: 47100,
  payout: 9420,
  confirmedAt: DateTime.utc(2026, 9, 8),
  paidAt: DateTime.utc(2026, 9, 29, 16), // JST 9/30
);

Widget _app(Widget home, {FakeStoreGateway? store, FakeInboxGateway? inbox, List<Override> extra = const []}) => ProviderScope(
  overrides: [
    storeGatewayProvider.overrideWithValue(store ?? FakeStoreGateway()),
    notificationInboxGatewayProvider.overrideWithValue(inbox ?? FakeInboxGateway()),
    ...extra,
  ],
  child: testApp(home),
);

void main() {
  group('inbox', () {
    setUpAll(() => initializeDateFormatting('ja'));

    test('inboxTimeLabel: たった今 → n分前 → 今日の時刻 → 昨日 → 日付（JST）', () {
      final now = DateTime.utc(2026, 10, 10, 11); // JST 20:00
      expect(inboxTimeLabel(now.subtract(const Duration(seconds: 20)), now, l10nJa, 'ja'), l10nJa.inboxJustNow);
      expect(inboxTimeLabel(now.subtract(const Duration(minutes: 5)), now, l10nJa, 'ja'), l10nJa.inboxMinutesAgo(5));
      expect(inboxTimeLabel(DateTime.utc(2026, 10, 10, 1, 31), now, l10nJa, 'ja'), '10:31');
      expect(inboxTimeLabel(DateTime.utc(2026, 10, 9, 9, 2), now, l10nJa, 'ja'), l10nJa.inboxYesterday('18:02'));
      expect(inboxTimeLabel(DateTime.utc(2026, 10, 7, 23), now, l10nJa, 'ja'), '10月8日');
    });

    test('inboxContent: 種類ごとの文面、未知の種類でも壊れない', () {
      expect(inboxContent('settlement_confirmed', l10nJa).title, l10nJa.noticeSettlementConfirmedTitle);
      expect(inboxContent('batch_collected', l10nJa).title, l10nJa.noticeBatchCollectedTitle);
      expect(inboxContent('something_new', l10nJa).title, l10nJa.noticeGenericTitle);
    });

    test('inboxContent: 新しい予約は件数と販売期限（JST）、payload が壊れていれば件数なし（0066）', () {
      const p = {'surplus_batch_id': 'b1', 'new_count': 3, 'total_count': 8, 'sell_by_at': '2026-10-10T12:00:00+00:00'};
      expect(inboxContent('reservation_received', l10nJa, payload: p).body, l10nJa.noticeReservationReceivedBody('21:00', 3, 8));
      expect(inboxContent('reservation_received', l10nJa, payload: {...p, 'new_count': '3'}).body,
          l10nJa.noticeReservationReceivedFallback);
      expect(inboxContent('reservation_received', l10nJa).title, l10nJa.noticeReservationReceivedTitle);
    });

    testWidgets('S07: 一覧を表示して、すべて既読にする（1回だけ）', (tester) async {
      final inbox = FakeInboxGateway(items: [
        InboxNotification(id: 'n1', type: 'batch_collected', stopName: null, isRead: false, createdAt: DateTime.now()),
        InboxNotification(id: 'n2', type: 'settlement_paid', stopName: null, isRead: true, createdAt: DateTime.now()),
        InboxNotification(
          id: 'n3',
          type: 'reservation_received',
          stopName: null,
          isRead: false,
          createdAt: DateTime.now(),
          payload: const {'new_count': 2, 'total_count': 5, 'sell_by_at': '2026-10-10T12:30:00Z'},
        ),
      ]);
      await tester.pumpWidget(_app(const NotificationInboxPage(userId: 'u-1'), inbox: inbox));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.noticeBatchCollectedTitle), findsOneWidget);
      expect(find.text(l10nJa.noticeSettlementPaidTitle), findsOneWidget);
      expect(find.text(l10nJa.noticeReservationReceivedBody('21:30', 2, 5)), findsOneWidget);
      expect(inbox.markedAll, 1);
    });

    testWidgets('S07: 何もなければ空の状態、既読の呼び出しもしない', (tester) async {
      final inbox = FakeInboxGateway();
      await tester.pumpWidget(_app(const NotificationInboxPage(userId: 'u-1'), inbox: inbox));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.inboxEmptyTitle), findsOneWidget);
      expect(inbox.markedAll, 0);
    });

    testWidgets('ベル: 未読があれば印、開いて戻ると消える', (tester) async {
      final inbox = FakeInboxGateway(items: [
        InboxNotification(id: 'n1', type: 'rating_received', stopName: null, isRead: false, createdAt: DateTime.now()),
      ]);
      await tester.pumpWidget(_app(const Scaffold(body: InboxBellButton(userId: 'u-1')), inbox: inbox));
      await tester.pumpAndSettle();
      expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isTrue);
      await tester.tap(find.byKey(const Key('inboxBell')));
      await tester.pumpAndSettle();
      expect(find.byType(NotificationInboxPage), findsOneWidget);
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
      expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isFalse);
    });
  });

  group('SCR-S04', () {
    testWidgets('精算書: 確定（確定日）と振込済み（振込日）、金額は桁区切り', (tester) async {
      await tester.pumpWidget(_app(Scaffold(body: StoreSettlementPage(restaurant: _restaurant())),
          store: FakeStoreGateway(settlements: [_confirmed, _paid])));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.storeSettlementRowConfirmed('10月8日', 72)), findsOneWidget);
      expect(find.text(l10nJa.storeSettlementRowPaid('9月30日', 65)), findsOneWidget);
      expect(find.text('¥10,312'), findsOneWidget);
      expect(find.text('¥9,420'), findsOneWidget);
      expect(find.text(l10nJa.storeSettlementEstimate('¥10,664')), findsOneWidget); // 今月（集計中）
    });

    testWidgets('支払通知書: 未振込、精算番号、Web で印刷', (tester) async {
      final opened = <String>[];
      await tester.pumpWidget(_app(
        Scaffold(body: StoreSettlementPage(restaurant: _restaurant())),
        store: FakeStoreGateway(settlements: [_confirmed]),
        extra: [openSettlementOnWebProvider.overrideWithValue((id) async {
          opened.add(id);
          return true;
        })],
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('settlement-${_confirmed.id}')));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(find.byKey(const Key('noticePayout'))).data, '¥10,312');
      expect(tester.widget<Text>(find.byKey(const Key('noticePaidAt'))).data, l10nJa.storeNoticeUnpaid);
      expect(find.text('ST-2026-09-0A1F'), findsOneWidget);
      await tester.tap(find.byKey(const Key('noticePrintOnWeb')));
      await tester.pump();
      expect(opened, [_confirmed.id]);
    });

    testWidgets('精算書なし → 空の状態', (tester) async {
      await tester.pumpWidget(_app(Scaffold(body: StoreSettlementPage(restaurant: _restaurant()))));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.storeSettlementEmptyTitle), findsOneWidget);
    });
  });

  group('SCR-S05', () {
    testWidgets('平均・件数・分布（ひとことは匿名）', (tester) async {
      await tester.pumpWidget(_app(const StoreRatingsPage(restaurantId: 'r-1')));
      await tester.pumpAndSettle();
      expect(find.text('4.3'), findsOneWidget);
      expect(find.text(l10nJa.storeRatingsCount(28)), findsOneWidget);
      expect(find.text('16'), findsOneWidget); // ★5 の件数
      expect(find.text(l10nJa.storeRatingsAnonymous), findsOneWidget);
    });
  });

  group('SCR-S06', () {
    testWidgets('空のまま送信 → エラー、送らない', (tester) async {
      final store = FakeStoreGateway();
      await tester.pumpWidget(_app(const StoreInquiryPage(userId: 'u-1'), store: store));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('storeInquirySend')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.storeInquiryEmpty), findsOneWidget);
      expect(store.sentInquiries, isEmpty);
    });

    testWidgets('送信できる、成功すると入力を空に', (tester) async {
      final store = FakeStoreGateway();
      await tester.pumpWidget(_app(const StoreInquiryPage(userId: 'u-1'), store: store));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('storeInquiryField')), '明日は臨時休業です');
      await tester.tap(find.byKey(const Key('storeInquirySend')));
      await tester.pumpAndSettle();
      expect(store.sentInquiries, ['明日は臨時休業です']);
      expect(tester.widget<TextField>(find.byKey(const Key('storeInquiryField'))).controller!.text, '');
    });

    testWidgets('送信に失敗 → エラーを出し、入力は残す', (tester) async {
      final store = FakeStoreGateway(inquiryError: Exception('network'));
      await tester.pumpWidget(_app(const StoreInquiryPage(userId: 'u-1'), store: store));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('storeInquiryField')), '問い合わせ');
      await tester.tap(find.byKey(const Key('storeInquirySend')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.storeInquirySendFailed), findsOneWidget);
      expect(tester.widget<TextField>(find.byKey(const Key('storeInquiryField'))).controller!.text, '問い合わせ');
    });

    testWidgets('これまでのお問い合わせ: 状態ラベル', (tester) async {
      final store = FakeStoreGateway(inquiries: [
        StoreInquiry(id: 'q1', message: '精算書の振込先を変更したい', status: InquiryStatus.done, createdAt: DateTime.utc(2026, 10, 3)),
        StoreInquiry(id: 'q2', message: 'PL保険の証書を更新しました', status: InquiryStatus.inProgress, createdAt: DateTime.utc(2026, 9, 28)),
      ]);
      await tester.pumpWidget(_app(const StoreInquiryPage(userId: 'u-1'), store: store));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.storeInquiryStatusDone), findsOneWidget);
      expect(find.text(l10nJa.storeInquiryStatusInProgress), findsOneWidget);
    });
  });

  group('SCR-S08', () {
    Widget settings() => _app(
      Scaffold(body: StoreSettingsPage(restaurant: _restaurant(), userId: 'u-1')),
      extra: [
        appVersionProvider.overrideWith((ref) async => '1.0.0'),
        pushStatusProvider.overrideWith((ref) async => PushStatus.unavailable),
      ],
    );

    testWidgets('店舗情報（住所・閉店時刻）とバージョン、ログアウト', (tester) async {
      await tester.pumpWidget(settings());
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.storeSettingsAddress('大阪市北区梅田1-2-3', '21:30')), findsOneWidget);
      expect(find.text(l10nJa.storeSettingsVersion('1.0.0')), findsOneWidget);
      expect(find.byKey(const Key('logoutButton')), findsOneWidget);
    });

    testWidgets('アカウントの削除を依頼 → お問い合わせ（内容を入れた状態）', (tester) async {
      await tester.pumpWidget(settings());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('storeSettingsDeleteAccount')));
      await tester.pumpAndSettle();
      expect(find.byType(StoreInquiryPage), findsOneWidget);
      expect(tester.widget<TextField>(find.byKey(const Key('storeInquiryField'))).controller!.text, l10nJa.storeAccountDeletionMessage);
    });

    testWidgets('提携契約について → 説明（お客様向けの利用規約は出さない） → お問い合わせ', (tester) async {
      await tester.pumpWidget(settings());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('storeSettingsContract')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.storeContractBody), findsOneWidget);
      await tester.tap(find.byKey(const Key('storeContractInquiry')));
      await tester.pumpAndSettle();
      expect(find.byType(StoreInquiryPage), findsOneWidget);
      expect(find.text(l10nJa.storeContractBody), findsNothing);
    });

    testWidgets('お客様の評価 → S05', (tester) async {
      await tester.pumpWidget(settings());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('storeSettingsRatings')));
      await tester.pumpAndSettle();
      expect(find.byType(StoreRatingsPage), findsOneWidget);
    });
  });
}
