import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ecomeal_mobile/features/orders/active_order_page.dart';
import 'package:ecomeal_mobile/features/orders/order_gateway.dart';
import 'package:ecomeal_mobile/features/orders/order_helpers.dart';
import 'package:ecomeal_mobile/widgets/animated_check.dart';
import '../../helpers/test_app.dart';

// 20:10 JST = 11:10 UTC
final _planned = DateTime.utc(2026, 10, 11, 11, 10);

OrderSummary _order({DateTime? departedAt, int? rating}) => OrderSummary(
  id: 'a1b2c3d4-0000-0000-0000-000000000001',
  status: 'allocated',
  pricePaid: 650,
  createdAt: DateTime.utc(2026, 10, 11, 9),
  plannedPickupTime: _planned,
  stopName: '大阪学生寮前',
  taxRate: 8,
  taxAmount: 48,
  stopDepartedAt: departedAt,
  rating: rating,
);

OrderSummary _withStatus(OrderSummary o, String status) => OrderSummary(
  id: o.id,
  status: status,
  pricePaid: o.pricePaid,
  createdAt: o.createdAt,
  plannedPickupTime: o.plannedPickupTime,
  stopName: o.stopName,
  taxRate: o.taxRate,
  taxAmount: o.taxAmount,
);

// Trạng thái đơn "sống" do test điều khiển (thay cho việc hỏi server mỗi 15 giây)
Widget _page(OrderSummary order, {required DateTime now, Stream<String>? status}) => ProviderScope(
  overrides: [activeOrderStatusProvider.overrideWith((ref, _) => status ?? Stream.value(order.status))],
  child: testApp(ActiveOrderPage(order: order, now: now)),
);

class MockOrderGateway extends Mock implements OrderGateway {}

void main() {
  group('activeOrderStatusProvider', () {
    testWidgets('15秒ごとに注文を読み直し、picked_up になったら止める。閉じたらタイマーも残さない', (tester) async {
      final gateway = MockOrderGateway();
      final answers = [_order(), _order(), _withStatus(_order(), 'picked_up')];
      var calls = 0;
      when(() => gateway.fetchMyOrders()).thenAnswer((_) async => [answers[calls++]]);
      final container = ProviderContainer(overrides: [orderGatewayProvider.overrideWithValue(gateway)]);
      final seen = <String>[];
      final sub = container.listen(activeOrderStatusProvider(_order().id), (_, next) {
        if (next.valueOrNull case final s?) seen.add(s);
      });
      await tester.pump();
      expect(seen, ['allocated']);
      await tester.pump(const Duration(seconds: 15));
      await tester.pump(const Duration(seconds: 15));
      expect(seen, ['allocated', 'allocated', 'picked_up']);
      await tester.pump(const Duration(seconds: 60));
      expect(calls, 3, reason: '受け取り後は問い合わせない');
      sub.close();
      await tester.pump(const Duration(milliseconds: 1)); // Riverpod gỡ provider autoDispose bằng hẹn giờ 0 ms
      container.dispose();
    });
  });

  group('pickupStage', () {
    test('予定の前 → before、予定から20分の間 → window、過ぎたら over', () {
      expect(
        pickupStage(now: _planned.subtract(const Duration(minutes: 12)), plannedTime: _planned),
        PickupStage.before,
      );
      expect(pickupStage(now: _planned.add(const Duration(minutes: 5)), plannedTime: _planned), PickupStage.window);
      expect(pickupStage(now: _planned.add(const Duration(minutes: 21)), plannedTime: _planned), PickupStage.over);
    });
    test('トラックが出発済みなら、時間内でも over', () {
      expect(
        pickupStage(now: _planned.add(const Duration(minutes: 5)), plannedTime: _planned, departedAt: _planned),
        PickupStage.over,
      );
    });
  });

  testWidgets('受け取りの案内: あと何分、場所・時間、QR と手入力コード', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_page(_order(), now: _planned.subtract(const Duration(minutes: 12))));
    await tester.pumpAndSettle();
    expect(find.text(l10nJa.activeOrderBefore('20:10', 12)), findsOneWidget);
    expect(find.text('大阪学生寮前'), findsOneWidget);
    expect(find.text('20:10–20:30'), findsOneWidget);
    expect(find.text(l10nJa.manualCodeLabel(pickupManualCode(_order().id))), findsOneWidget);
    expect(find.text(l10nJa.activeOrderFindTitle), findsOneWidget);
    expect(find.byKey(const Key('pickupComplete')), findsNothing);
  });

  testWidgets('出発済み → 停車は終わった旨と連絡方法', (tester) async {
    await tester.pumpWidget(_page(_order(departedAt: _planned), now: _planned));
    await tester.pumpAndSettle();
    expect(find.text(l10nJa.activeOrderOver), findsOneWidget);
  });

  testWidgets('開いている間にドライバーが QR を読み取った → QR が「受け取り完了」+ ✓ + 評価のお願いに替わる', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final status = StreamController<String>();
    addTearDown(status.close);
    await tester.pumpWidget(_page(_order(), now: _planned, status: status.stream));
    status.add('allocated');
    await tester.pumpAndSettle();
    expect(find.text(l10nJa.pickupQrTitle), findsOneWidget);

    status.add('picked_up');
    await tester.pumpAndSettle();
    expect(find.text(l10nJa.activeOrderPickedUp), findsOneWidget);
    expect(find.text(l10nJa.pickupCompleteTitle), findsOneWidget);
    expect(find.byType(AnimatedCheck), findsOneWidget);
    expect(find.byKey(const Key('ratingPrompt')), findsOneWidget);
    expect(find.text(l10nJa.pickupQrTitle), findsNothing, reason: '受け取り後は QR を出さない');
    expect(find.text(l10nJa.activeOrderFindTitle), findsNothing);
  });

  testWidgets('受け取り済みで評価も済み → 評価のお願いではなく「あなたの評価」', (tester) async {
    await tester.pumpWidget(_page(_order(rating: 4), now: _planned, status: Stream.value('picked_up')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ratedNote')), findsOneWidget);
    expect(find.byKey(const Key('ratingPrompt')), findsNothing);
  });
}
