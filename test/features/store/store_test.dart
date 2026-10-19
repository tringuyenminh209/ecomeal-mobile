import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/core/app_version.dart';
import 'package:ecomeal_mobile/core/yen.dart';
import 'package:ecomeal_mobile/features/store/store_batch_detail_page.dart';
import 'package:ecomeal_mobile/features/store/store_gate.dart';
import 'package:ecomeal_mobile/features/store/store_gateway.dart';
import 'package:ecomeal_mobile/features/store/store_register_logic.dart' show storeClock;
import 'package:ecomeal_mobile/widgets/status_badge.dart';
import 'package:ecomeal_mobile/widgets/store_shell.dart';
import 'package:ecomeal_mobile/features/notifications/notification_inbox.dart';
import '../../helpers/fake_inbox_gateway.dart';
import '../../helpers/fake_store_gateway.dart';
import '../../helpers/test_app.dart';

StoreRestaurant restaurant({bool approved = true, DateTime? rejectedAt, String? reason}) => StoreRestaurant(
  id: 'r-1',
  name: 'キッチン青葉',
  address: '大阪市北区梅田1-2-3',
  closingTime: '21:30:00',
  isApproved: approved,
  rejectedAt: rejectedAt,
  rejectionReason: reason,
  appliedAt: DateTime.utc(2026, 10, 7, 23), // JST 2026-10-08 08:00
  applicantName: '青葉 太郎',
);

StoreBatch batch({
  String id = 'b-1',
  bool confirmed = false,
  Duration sellByIn = const Duration(hours: 3),
  List<StoreStop> stops = const [],
}) => StoreBatch(
  id: id,
  isConfirmed: confirmed,
  estimatedQty: 12,
  confirmedQty: confirmed ? 10 : null,
  unitPrice: 780,
  sellByAt: DateTime.now().add(sellByIn),
  serviceDate: '2026-10-10',
  photoUrl: null,
  registeredAt: DateTime.utc(2026, 10, 10, 6, 42),
  collectionPlannedAt: DateTime.utc(2026, 10, 10, 10, 30),
  collectedAt: confirmed ? DateTime.utc(2026, 10, 10, 10, 31) : null,
  temperatureCelsius: confirmed ? 5.2 : null,
  collectedByName: confirmed ? '佐藤' : null,
  allergens: const ['卵', '乳'],
  reservedCount: 8,
  pickedUpCount: 3,
  stops: stops,
);

Widget app(FakeStoreGateway gateway, Widget home) => ProviderScope(
  overrides: [
    storeGatewayProvider.overrideWithValue(gateway),
    notificationInboxGatewayProvider.overrideWithValue(FakeInboxGateway()),
    appVersionProvider.overrideWith((ref) async => '1.0.0'),
  ],
  child: testApp(home),
);

void main() {
  group('StoreBatch.statusAt', () {
    test('概算 → 販売中（確定・期限前）→ 終了（期限後）', () {
      final now = DateTime.now();
      expect(batch().statusAt(now), StoreBatchStatus.estimated);
      expect(batch(confirmed: true).statusAt(now), StoreBatchStatus.onSale);
      expect(batch(confirmed: true, sellByIn: const Duration(minutes: -1)).statusAt(now), StoreBatchStatus.ended);
    });

    test('残り = 各地点の残りの合計', () {
      final b = batch(confirmed: true, stops: [
        StoreStop(name: 'A', plannedTime: DateTime.now(), departed: false, allocatedQty: 4, remainingQty: 1),
        StoreStop(name: 'B', plannedTime: DateTime.now(), departed: false, allocatedQty: 3, remainingQty: 2),
      ]);
      expect(b.remainingQty, 3);
    });
  });

  test('formatYen: 桁区切り', () {
    expect(formatYen(53320), '¥53,320');
    expect(formatYen(780), '¥780');
    expect(formatYen(0), '¥0');
  });

  group('SCR-S00', () {
    testWidgets('審査中: 店舗名・申請日（JST）・申請者、ログアウトだけ', (tester) async {
      await tester.pumpWidget(app(FakeStoreGateway(restaurant: restaurant(approved: false)), const StoreGate(userId: 'u-1')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.storeReviewPendingTitle), findsOneWidget);
      expect(find.text('キッチン青葉'), findsOneWidget);
      expect(find.text('2026年10月8日'), findsOneWidget);
      expect(find.text('青葉 太郎'), findsOneWidget);
      expect(find.byKey(const Key('logoutButton')), findsOneWidget);
      expect(find.byKey(const Key('openWebAdminButton')), findsNothing);
      expect(find.byType(StoreShell), findsNothing);
    });

    testWidgets('却下: 理由と「Web 管理画面を開く」', (tester) async {
      await tester.pumpWidget(app(
        FakeStoreGateway(restaurant: restaurant(approved: false, rejectedAt: DateTime.utc(2026, 10, 9), reason: 'PL保険の証書の有効期限が切れています。')),
        const StoreGate(userId: 'u-1'),
      ));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.storeReviewRejectedTitle), findsOneWidget);
      expect(find.text('PL保険の証書の有効期限が切れています。'), findsOneWidget);
      expect(find.byKey(const Key('openWebAdminButton')), findsOneWidget);
    });

    testWidgets('店舗の登録がまだ → Web で申し込む案内', (tester) async {
      await tester.pumpWidget(app(FakeStoreGateway(), const StoreGate(userId: 'u-1')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.storeNotRegisteredTitle), findsOneWidget);
      expect(find.byType(StoreShell), findsNothing);
    });
  });

  group('SCR-S01 ホーム', () {
    testWidgets('承認済み → StoreShell、ロット・売上（桁区切り）・評価', (tester) async {
      final gateway = FakeStoreGateway(restaurant: restaurant(), batches: [batch(), batch(id: 'b-2', confirmed: true)]);
      await tester.pumpWidget(app(gateway, const StoreGate(userId: 'u-1')));
      await tester.pumpAndSettle();
      expect(find.byType(StoreShell), findsOneWidget);
      expect(find.text('キッチン青葉'), findsOneWidget);
      expect(find.text(l10nJa.storeBatchQtyEstimated(12)), findsOneWidget);
      expect(find.text(l10nJa.storeBatchReserved(8)), findsOneWidget);
      expect(find.text(l10nJa.storeBatchQtyConfirmed(12, 10)), findsOneWidget);
      expect(find.text(l10nJa.storeBatchCounts(8, 3)), findsOneWidget);
      await tester.scrollUntilVisible(find.byKey(const Key('storeRatingsRow')), 200);
      expect(find.text('¥53,320'), findsOneWidget);
      expect(find.text('¥10,664'), findsOneWidget);
      expect(find.text(l10nJa.storeSharePct('20')), findsOneWidget);
      expect(find.text(l10nJa.storeRatingsRow('4.3')), findsOneWidget);
    });

    testWidgets('ロットなし → 空の状態', (tester) async {
      await tester.pumpWidget(app(FakeStoreGateway(restaurant: restaurant()), const StoreGate(userId: 'u-1')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.storeNoBatchesTitle), findsOneWidget);
    });

    testWidgets('読み込み失敗 → エラーと再読み込み、成功すれば一覧', (tester) async {
      final gateway = FakeStoreGateway(restaurant: restaurant(), batches: [batch()], batchesError: true);
      await tester.pumpWidget(app(gateway, const StoreGate(userId: 'u-1')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.storeLoadErrorTitle), findsOneWidget);
      gateway.batchesError = false;
      await tester.tap(find.text(l10nJa.storeReload));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.storeBatchQtyEstimated(12)), findsOneWidget);
    });

    testWidgets('写真が外された → お知らせ、確認しましたで消える', (tester) async {
      final gateway = FakeStoreGateway(restaurant: restaurant(), removals: const [PhotoRemoval(id: 'p-1', reason: '店名が写っていたため。')]);
      await tester.pumpWidget(app(gateway, const StoreGate(userId: 'u-1')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('storePhotoRemovalNotice')), findsOneWidget);
      await tester.tap(find.byKey(const Key('storePhotoRemovalAck')));
      await tester.pumpAndSettle();
      expect(gateway.acknowledged, 1);
      expect(find.byKey(const Key('storePhotoRemovalNotice')), findsNothing);
    });

    testWidgets('「今日の余剰を登録」→ 登録タブ', (tester) async {
      await tester.pumpWidget(app(FakeStoreGateway(restaurant: restaurant()), const StoreGate(userId: 'u-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('storeRegisterCta')));
      await tester.pumpAndSettle();
      // tab 登録 đang chọn: viên thuốc của thanh tab nằm dưới mục 登録
      final pill = find.descendant(of: find.byKey(const Key('pillTabBar')), matching: find.byKey(const Key('slidingPill')));
      expect(tester.getCenter(pill).dx, closeTo(tester.getCenter(find.byKey(const Key('storeNavRegister'))).dx, 0.5));
    });

    testWidgets('ロットをタップ → ロット詳細', (tester) async {
      await tester.pumpWidget(app(FakeStoreGateway(restaurant: restaurant(), batches: [batch()]), const StoreGate(userId: 'u-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10nJa.storeBatchQtyEstimated(12)));
      await tester.pumpAndSettle();
      expect(find.byType(StoreBatchDetailPage), findsOneWidget);
    });
  });

  group('SCR-S03 ロット詳細', () {
    Widget detail(StoreBatch b) => app(FakeStoreGateway(batches: [b]), StoreBatchDetailPage(restaurantId: 'r-1', batchId: b.id));

    testWidgets('回収前: 概算・回収予定、受取地点の代わりに返金の説明', (tester) async {
      await tester.pumpWidget(detail(batch()));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.storeStepCollectedHint), findsOneWidget);
      expect(find.text(l10nJa.storeEstimatedNote), findsOneWidget);
      expect(find.text(l10nJa.storeStopsRemaining), findsNothing);
      expect(find.text('19:30'), findsOneWidget); // 回収（JST）
    });

    testWidgets('販売中: 温度・ドライバー・受取地点ごとの残り', (tester) async {
      await tester.pumpWidget(detail(batch(confirmed: true, stops: [
        StoreStop(name: '大阪学生寮前', plannedTime: DateTime.utc(2026, 10, 10, 10, 45), departed: false, allocatedQty: 4, remainingQty: 1),
      ])));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.storeTemperature('5.2')), findsOneWidget);
      expect(find.text(l10nJa.storeStepCollectedBy('佐藤')), findsOneWidget);
      expect(find.text('大阪学生寮前'), findsOneWidget);
      expect(find.text(l10nJa.storeStopRemaining(1)), findsOneWidget);
      expect(find.text(l10nJa.storeStopAllocated(4)), findsOneWidget);
      expect(find.text(l10nJa.storeAutoUpdate), findsOneWidget);
    });

    testWidgets('他店・存在しないロット → 見つかりません', (tester) async {
      await tester.pumpWidget(app(FakeStoreGateway(), const StoreBatchDetailPage(restaurantId: 'r-1', batchId: 'x')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.storeBatchNotFound), findsOneWidget);
    });

    // Huy hiệu trạng thái của lô (chữ 「販売中」「終了」 còn có ở dòng tiến trình — không dùng find.text)
    Finder badge(String label) => find.byWidgetPredicate((w) => w is StatusBadge && w.label == label);

    // Audit S03 (2026-10-19): trước đây chỉ tải lại khi 販売中 → lô 概算 không biết tài xế đã xác nhận
    testWidgets('概算のまま開いている間にドライバーが確定 → 30秒後の読み直しで販売中に変わる', (tester) async {
      final gateway = FakeStoreGateway(batches: [batch()]);
      await tester.pumpWidget(app(gateway, const StoreBatchDetailPage(restaurantId: 'r-1', batchId: 'b-1')));
      await tester.pumpAndSettle();
      expect(badge(l10nJa.storeBatchStatusEstimated), findsOneWidget);

      gateway.batches = [batch(confirmed: true)];
      await tester.pump(storeBatchRefreshInterval);
      await tester.pumpAndSettle();
      expect(badge(l10nJa.storeBatchStatusOnSale), findsOneWidget);
      expect(badge(l10nJa.storeBatchStatusEstimated), findsNothing);
    });

    // Audit S03: 販売終了の時刻を過ぎたら、画面に触らなくても表示が「終了」に変わる
    testWidgets('販売中のまま販売終了の時刻を過ぎる → 触らなくても「終了」に変わる', (tester) async {
      addTearDown(() => storeClock = DateTime.now);
      await tester.pumpWidget(detail(batch(confirmed: true)));
      await tester.pumpAndSettle();
      expect(badge(l10nJa.storeBatchStatusEnded), findsNothing);

      storeClock = () => DateTime.now().add(const Duration(hours: 4)); // sellByIn mặc định 3 giờ
      await tester.pump(storeBatchRefreshInterval);
      await tester.pumpAndSettle();
      expect(badge(l10nJa.storeBatchStatusEnded), findsOneWidget);
    });
  });
}
