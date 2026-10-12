import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/features/orders/active_order_page.dart';
import 'package:ecomeal_mobile/features/orders/order_gateway.dart';
import 'package:ecomeal_mobile/features/orders/order_helpers.dart';
import '../../helpers/test_app.dart';

// 20:10 JST = 11:10 UTC
final _planned = DateTime.utc(2026, 10, 11, 11, 10);

OrderSummary _order({DateTime? departedAt}) => OrderSummary(
      id: 'a1b2c3d4-0000-0000-0000-000000000001',
      status: 'allocated',
      pricePaid: 650,
      createdAt: DateTime.utc(2026, 10, 11, 9),
      plannedPickupTime: _planned,
      stopName: '大阪学生寮前',
      taxRate: 8,
      taxAmount: 48,
      stopDepartedAt: departedAt,
    );

void main() {
  group('pickupStage', () {
    test('予定の前 → before、予定から20分の間 → window、過ぎたら over', () {
      expect(pickupStage(now: _planned.subtract(const Duration(minutes: 12)), plannedTime: _planned), PickupStage.before);
      expect(pickupStage(now: _planned.add(const Duration(minutes: 5)), plannedTime: _planned), PickupStage.window);
      expect(pickupStage(now: _planned.add(const Duration(minutes: 21)), plannedTime: _planned), PickupStage.over);
    });
    test('トラックが出発済みなら、時間内でも over', () {
      expect(pickupStage(now: _planned.add(const Duration(minutes: 5)), plannedTime: _planned, departedAt: _planned), PickupStage.over);
    });
  });

  testWidgets('受け取りの案内: あと何分、場所・時間、QR と手入力コード', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(testApp(ActiveOrderPage(order: _order(), now: _planned.subtract(const Duration(minutes: 12)))));
    await tester.pumpAndSettle();
    expect(find.text(l10nJa.activeOrderBefore('20:10', 12)), findsOneWidget);
    expect(find.text('大阪学生寮前'), findsOneWidget);
    expect(find.text('20:10–20:30'), findsOneWidget);
    expect(find.text(l10nJa.manualCodeLabel(pickupManualCode(_order().id))), findsOneWidget);
    expect(find.text(l10nJa.activeOrderFindTitle), findsOneWidget);
  });

  testWidgets('出発済み → 停車は終わった旨と連絡方法', (tester) async {
    await tester.pumpWidget(testApp(ActiveOrderPage(order: _order(departedAt: _planned), now: _planned)));
    await tester.pumpAndSettle();
    expect(find.text(l10nJa.activeOrderOver), findsOneWidget);
  });
}
