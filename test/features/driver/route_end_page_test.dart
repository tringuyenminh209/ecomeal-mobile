import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ecomeal_mobile/features/driver/driver_gateway.dart';
import 'package:ecomeal_mobile/features/driver/handoff_gateway.dart';
import 'package:ecomeal_mobile/features/driver/route_end_page.dart';
import '../../helpers/test_app.dart';
import 'driver_test_data.dart';

class MockDriverGateway extends Mock implements DriverGateway {}

class MockHandoffGateway extends Mock implements HandoffGateway {}

// Cùng tuyến mẫu nhưng tài xế đã 出発 khỏi MỌI điểm bán (p2, p3) — điều kiện để được ghi tặng.
final endedRoute = TonightRoute(
  truck: routeFixture.truck,
  routeId: routeFixture.routeId,
  stops: [
    for (final s in routeFixture.stops)
      s.type == 'public' && s.departedAt == null
          ? stopFixture(s.routeStopId, type: s.type, sequence: s.sequence, departed: true, pickedUp: s.pickedUpCount)
          : s,
  ],
);

void main() {
  late MockDriverGateway driverGateway;
  late MockHandoffGateway handoffGateway;

  setUp(() {
    driverGateway = MockDriverGateway();
    handoffGateway = MockHandoffGateway();
    when(() => driverGateway.fetchTonightRoute()).thenAnswer((_) async => endedRoute);
    when(() => handoffGateway.fetchConfirmedBatches('route-1'))
        .thenAnswer((_) async => const [DonationBatch(id: 'batch-1', restaurantId: 'rest-B', confirmedQty: 28)]);
  });

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [driverGatewayProvider.overrideWithValue(driverGateway), handoffGatewayProvider.overrideWithValue(handoffGateway)],
      child: testApp(const RouteEndPage()),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> fillDonation(WidgetTester tester, String qty) async {
    await tester.tap(find.byKey(const Key('donationBatchField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stop rB（確定 28食）').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('donationQtyField')), qty);
    await tester.enterText(find.byKey(const Key('donationNoteField')), 'しぶやフードサポート');
    await tester.ensureVisible(find.byKey(const Key('handedOverCheckbox')));
    await tester.tap(find.byKey(const Key('handedOverCheckbox')));
    await tester.pump();
  }

  // レビュー第30回: tặng giữa tuyến rồi quay lại bán → sold + donated vượt confirmed_qty. Form khoá cho tới khi
  // mọi điểm bán đã 出発 (server cũng tự chặn bằng E-INV-004).
  testWidgets('còn điểm bán chưa 出発 → cảnh báo + form tặng bị khoá', (tester) async {
    when(() => driverGateway.fetchTonightRoute()).thenAnswer((_) async => routeFixture);
    await pumpPage(tester);

    expect(find.text('18食'), findsOneWidget); // picked_up chỉ có ở p1 trong dữ liệu mẫu
    expect(find.text('1 / 3'), findsOneWidget); // 3 điểm bán p1/p2/p3, mới rời p1 — điểm thu gom không tính
    expect(find.byKey(const Key('openStopsWarning')), findsOneWidget);
    expect(find.byKey(const Key('donationLockedNotice')), findsOneWidget);
    expect(tester.widget<TextField>(find.byKey(const Key('donationQtyField'))).enabled, isFalse);
    expect(tester.widget<FilledButton>(find.byKey(const Key('recordDonationButton'))).onPressed, isNull);
  });

  testWidgets('đã rời mọi điểm bán → ghi tặng: chọn lô + số lượng + nơi nhận + xác nhận → record_donation', (tester) async {
    when(() => handoffGateway.recordDonation(batchId: 'batch-1', quantity: 6, note: 'しぶやフードサポート')).thenAnswer((_) async => 0);
    await pumpPage(tester);
    expect(find.text('3 / 3'), findsOneWidget);
    expect(find.byKey(const Key('openStopsWarning')), findsNothing);
    expect(tester.widget<FilledButton>(find.byKey(const Key('recordDonationButton'))).onPressed, isNull);

    await fillDonation(tester, '6');
    await tester.tap(find.byKey(const Key('recordDonationButton')));
    await tester.pumpAndSettle();

    verify(() => handoffGateway.recordDonation(batchId: 'batch-1', quantity: 6, note: 'しぶやフードサポート')).called(1);
    expect(find.text('寄付を記録しました（この料理の残り 0食）'), findsOneWidget);
  });

  testWidgets('tặng vượt số còn lại → câu lỗi E-INV-001 của API-016', (tester) async {
    when(() => handoffGateway.recordDonation(batchId: any(named: 'batchId'), quantity: any(named: 'quantity'), note: any(named: 'note')))
        .thenThrow(Exception('E-INV-001: quantity exceeds remaining stock'));
    await pumpPage(tester);
    await fillDonation(tester, '99');
    await tester.tap(find.byKey(const Key('recordDonationButton')));
    await tester.pumpAndSettle();

    expect(find.text('寄付数量が残り在庫を超えています'), findsOneWidget);
  });
}
