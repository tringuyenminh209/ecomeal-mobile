import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ecomeal_mobile/core/directions.dart';
import 'package:ecomeal_mobile/features/driver/driver_gateway.dart';
import 'package:ecomeal_mobile/features/driver/pickup_confirm_page.dart';
import 'package:ecomeal_mobile/features/driver/pickup_done_page.dart';
import 'package:ecomeal_mobile/features/driver/pickup_stop_page.dart';
import '../../helpers/test_app.dart';
import 'driver_test_data.dart';

class MockDriverGateway extends Mock implements DriverGateway {}

void main() {
  late MockDriverGateway gateway;
  late List<(double, double)> navigations;

  setUp(() {
    gateway = MockDriverGateway();
    navigations = [];
    when(() => gateway.fetchTonightRoute()).thenAnswer((_) async => routeFixture);
  });

  Future<void> pump(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(1080, 2600);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        driverGatewayProvider.overrideWithValue(gateway),
        openDirectionsProvider.overrideWithValue((lat, lng) async {
          navigations.add((lat, lng));
          return true;
        }),
      ],
      child: testApp(page),
    ));
    await tester.pumpAndSettle();
  }

  group('SCR-D07 集荷先の詳細', () {
    testWidgets('các lô của quán: số dự kiến, giờ ngừng bán (sớm trước), nút nhận từng lô', (tester) async {
      await pump(tester, const PickupStopPage(routeStopId: 'rB'));

      expect(find.text('Stop rB'), findsOneWidget);
      expect(find.text('集荷 2/2 ・ 19:00 着く予定'), findsOneWidget);
      expect(find.text('受け取る料理（2つ）'), findsOneWidget);
      expect(find.text('約10食'), findsOneWidget);
      expect(find.text('お店の販売終了 18:30'), findsOneWidget);
      // bB1 (18:30) đứng trước bB2 (18:45) dù dữ liệu trả về ngược lại
      final y1 = tester.getTopLeft(find.byKey(const Key('pickupBatch_bB1'))).dy;
      final y2 = tester.getTopLeft(find.byKey(const Key('pickupBatch_bB2'))).dy;
      expect(y1 < y2, isTrue);
      expect(find.byKey(const Key('pickUpBatch_bB1')), findsOneWidget);
    });

    testWidgets('lô đã nhận → nhãn 受け取り済み, không còn nút nhận', (tester) async {
      await pump(tester, const PickupStopPage(routeStopId: 'rA'));
      expect(find.text('受け取り済み・12食'), findsOneWidget);
      expect(find.byKey(const Key('pickUpBatch_bA1')), findsNothing);
    });

    testWidgets('ナビで行く → mở dẫn đường tới toạ độ của điểm thu gom', (tester) async {
      await pump(tester, const PickupStopPage(routeStopId: 'rB'));
      await tester.tap(find.byKey(const Key('navigateButton')));
      expect(navigations, [(34.69, 135.50)]);
    });

    testWidgets('この料理を受け取る → mở SCR-D02 với đúng lô', (tester) async {
      await pump(tester, const PickupStopPage(routeStopId: 'rB'));
      await tester.tap(find.byKey(const Key('pickUpBatch_bB2')));
      await tester.pumpAndSettle();
      final page = tester.widget<PickupConfirmPage>(find.byType(PickupConfirmPage));
      expect(page.batch.id, 'bB2');
      expect(find.text('概算 6食'), findsOneWidget);
    });
  });

  group('SCR-D02 受け取り完了', () {
    const outcome = PickupOutcome(
      batchId: 'bB1',
      confirmedQty: 10,
      celsius: 5.2,
      result: ConfirmResult(allocatedOrderCount: 5, refundedOrderCount: 1),
    );

    testWidgets('số đã chất, đơn giữ / hoàn, lô đi tới điểm nào bao nhiêu (số của server)', (tester) async {
      when(() => gateway.fetchBatchDrops('bB1')).thenAnswer((_) async => const [
            BatchDrop(routeStopId: 'p2', qty: 6, reservedCount: 4),
            BatchDrop(routeStopId: 'p3', qty: 4, reservedCount: 1),
          ]);
      await pump(tester, PickupDonePage(collectionStop: routeFixture.stops[2], outcome: outcome));

      expect(find.text('10食を積みました'), findsOneWidget);
      expect(find.text('Stop rB ・ 中心温度 5.2℃'), findsOneWidget);
      expect(find.text('5件'), findsOneWidget);
      expect(find.text('1件'), findsOneWidget);
      expect(find.byKey(const Key('drop_p2')), findsOneWidget);
      expect(find.text('6食'), findsOneWidget);
      expect(find.text('19:20 ・ うち予約 4件'), findsOneWidget); // p2: 10:20Z = 19:20 JST
      expect(find.text('4食'), findsOneWidget);
    });

    testWidgets('quán vẫn còn lô chưa nhận → việc kế tiếp ở chính quán này, không dẫn đường', (tester) async {
      when(() => gateway.fetchBatchDrops('bB1')).thenAnswer((_) async => const []);
      await pump(tester, PickupDonePage(collectionStop: routeFixture.stops[2], outcome: outcome));

      expect(find.text('このお店にまだ受け取る料理があります。'), findsOneWidget);
      expect(find.byKey(const Key('doneNavigateButton')), findsNothing);
      expect(find.text('戻る'), findsOneWidget);
    });

    testWidgets('hết lô ở quán → việc kế tiếp là điểm bán, ナビで行く dẫn tới đó', (tester) async {
      // Quán B đã rời (server đặt actual_departure_at khi chốt lô cuối) → điểm kế tiếp là p2
      final departedB = TonightRoute(
        truck: routeFixture.truck,
        routeId: routeFixture.routeId,
        stops: [
          for (final s in routeFixture.stops)
            s.routeStopId == 'rB'
                ? stopFixture('rB', type: 'restaurant', sequence: 3, departed: true, restaurantId: 'rest-B')
                : s,
        ],
      );
      when(() => gateway.fetchTonightRoute()).thenAnswer((_) async => departedB);
      when(() => gateway.fetchBatchDrops('bB1')).thenAnswer((_) async => const []);
      await pump(tester, PickupDonePage(collectionStop: routeFixture.stops[2], outcome: outcome));

      expect(find.text('Stop p2 でお客様に渡す'), findsOneWidget);
      expect(find.text('集荷はすべて終わりました。料理が冷えたままか確認して出発してください。'), findsOneWidget);
      await tester.tap(find.byKey(const Key('doneNavigateButton')));
      expect(navigations, [(34.69, 135.50)]);
    });
  });
}
