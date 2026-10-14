import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/core/app_version.dart';
import 'package:ecomeal_mobile/features/notifications/notification_inbox.dart';
import 'package:ecomeal_mobile/features/store/store_batch_detail_page.dart';
import 'package:ecomeal_mobile/features/store/store_gateway.dart';
import 'package:ecomeal_mobile/features/store/store_register_page.dart';
import 'package:ecomeal_mobile/features/store/store_settlement_page.dart';
import 'package:ecomeal_mobile/widgets/ecomeal_logo.dart';
import 'package:ecomeal_mobile/widgets/store_shell.dart';
import '../../helpers/fake_inbox_gateway.dart';
import '../../helpers/fake_store_gateway.dart';
import '../../helpers/test_app.dart';

StoreRestaurant _restaurant() => StoreRestaurant(
  id: 'r-1',
  name: 'キッチン青葉',
  address: '大阪市',
  closingTime: '21:30:00',
  isApproved: true,
  rejectedAt: null,
  rejectionReason: null,
  appliedAt: DateTime.utc(2026, 10, 1),
  applicantName: '青葉 太郎',
);

StoreSettlement _settlement(String id, String month, int payout) => StoreSettlement(
  id: id,
  periodMonth: month,
  orders: 10,
  sales: payout * 5,
  payout: payout,
  confirmedAt: DateTime.utc(2026, 10, 7),
  paidAt: null,
);

StoreBatch _onSale() => StoreBatch(
  id: 'b-1',
  isConfirmed: true,
  estimatedQty: 12,
  confirmedQty: 10,
  unitPrice: 780,
  sellByAt: DateTime.now().add(const Duration(hours: 2)),
  serviceDate: '2026-10-10',
  photoUrl: null,
  registeredAt: DateTime.utc(2026, 10, 10, 6),
  collectionPlannedAt: DateTime.utc(2026, 10, 10, 10),
  collectedAt: DateTime.utc(2026, 10, 10, 10),
  temperatureCelsius: 5.2,
  collectedByName: '佐藤',
  allergens: const [],
  reservedCount: 8,
  pickedUpCount: 3,
  stops: [StoreStop(name: '梅田駅前', plannedTime: DateTime.utc(2026, 10, 10, 11), departed: false, allocatedQty: 3, remainingQty: 2)],
);

// iPad 11インチ 横（Figma 559:1328）
void _ipad(WidgetTester tester) {
  tester.view.physicalSize = const Size(1194, 834);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Widget _app(Widget home, FakeStoreGateway store) => ProviderScope(
  overrides: [
    storeGatewayProvider.overrideWithValue(store),
    notificationInboxGatewayProvider.overrideWithValue(FakeInboxGateway()),
    appVersionProvider.overrideWith((ref) async => '1.0.0'),
  ],
  child: testApp(home),
);

void main() {
  testWidgets('iPad: 縦のナビゲーション（下のタブなし）、ホームは2列（ロットと今月の売上が同時に見える）', (tester) async {
    _ipad(tester);
    await tester.pumpWidget(_app(StoreShell(restaurant: _restaurant(), userId: 'u-1'), FakeStoreGateway(batches: [_onSale()])));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sideRail')), findsOneWidget);
    expect(find.byKey(const Key('pillTabBar')), findsNothing);
    // rail chỉ có cái bát 40×40 (Figma 179:85), không phải logo ngang có chữ
    final logo = tester.widget<EcoMealLogo>(find.descendant(of: find.byKey(const Key('sideRail')), matching: find.byType(EcoMealLogo)));
    expect(logo.symbolOnly, isTrue);
    expect(tester.getSize(find.descendant(of: find.byKey(const Key('sideRail')), matching: find.byType(Image))).width, 40);
    expect(find.text(l10nJa.storeBatchQtyConfirmed(12, 10)), findsOneWidget);
    expect(find.byKey(const Key('storeMonthSales')), findsOneWidget);
    final cta = tester.getRect(find.byKey(const Key('storeRegisterCta')));
    final sales = tester.getRect(find.byKey(const Key('storeMonthSales')));
    expect(sales.left, greaterThan(cta.right)); // 右の列
  });

  testWidgets('iPad: 縦のナビゲーションで精算へ', (tester) async {
    _ipad(tester);
    await tester.pumpWidget(_app(StoreShell(restaurant: _restaurant(), userId: 'u-1'), FakeStoreGateway()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('storeNavSettlement')));
    await tester.pumpAndSettle();
    expect(find.text(l10nJa.storeSettlementEmptyTitle), findsOneWidget);
    // nền của mục đang chọn (khối trượt dọc) đã nằm sau 精算
    final pill = find.descendant(of: find.byKey(const Key('sideRail')), matching: find.byKey(const Key('slidingPill')));
    expect(tester.getRect(pill), tester.getRect(find.byKey(const Key('storeNavSettlement'))));
  });

  testWidgets('iPad: 精算は一覧と支払通知書を並べて表示、選んだ月に切り替わる（画面遷移しない）', (tester) async {
    _ipad(tester);
    final store = FakeStoreGateway(settlements: [
      _settlement('aaaaaaaa-0000-0000-0000-00000000000a', '2026-09-01', 10312),
      _settlement('bbbbbbbb-0000-0000-0000-00000000000b', '2026-08-01', 9420),
    ]);
    await tester.pumpWidget(_app(Scaffold(body: StoreSettlementPage(restaurant: _restaurant())), store));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const Key('noticePayout'))).data, '¥10,312'); // 最新を表示
    await tester.tap(find.byKey(const Key('settlement-bbbbbbbb-0000-0000-0000-00000000000b')));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const Key('noticePayout'))).data, '¥9,420');
    expect(find.byType(StoreSettlementNoticePage), findsNothing);
  });

  testWidgets('iPad: ロット詳細は2列（受取地点の残りが右）', (tester) async {
    _ipad(tester);
    await tester.pumpWidget(_app(const StoreBatchDetailPage(restaurantId: 'r-1', batchId: 'b-1'), FakeStoreGateway(batches: [_onSale()])));
    await tester.pumpAndSettle();
    final progress = tester.getRect(find.text(l10nJa.storeProgress));
    final stops = tester.getRect(find.text(l10nJa.storeStopsRemaining));
    expect(stops.left, greaterThan(progress.right));
  });

  testWidgets('iPad: 余剰登録は写真と確認ボタンが左、入力欄が右（下のボタン欄なし）', (tester) async {
    _ipad(tester);
    await tester.pumpWidget(_app(StoreRegisterPage(restaurant: _restaurant(), onRegistered: (_) {}), FakeStoreGateway()));
    await tester.pumpAndSettle();
    final button = tester.getRect(find.byKey(const Key('storeReviewButton')));
    final price = tester.getRect(find.byKey(const Key('storePriceField')));
    expect(price.left, greaterThan(button.right));
    expect(tester.widget<Scaffold>(find.byType(Scaffold).first).bottomNavigationBar, isNull);
  });
}
