import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ecomeal_mobile/features/driver/driver_gateway.dart';
import 'package:ecomeal_mobile/features/driver/driver_route_map.dart';
import 'package:ecomeal_mobile/features/driver/gps_reporter.dart';
import 'package:ecomeal_mobile/widgets/driver_shell.dart';
import '../../helpers/test_app.dart';
import 'driver_test_data.dart';

class _MockDriverGateway extends Mock implements DriverGateway {}

// Audit D08 bước 1 (Figma 966:1785 / 967:1785): bản đồ toàn màn hình theo tuyến được giao. Test không có key Maps nên
// GoogleMap không dựng — kiểm phần quanh bản đồ: mở/đóng, tiêu đề, chú thích nét đứt, thẻ việc, chọn điểm từ danh sách.
Widget _app(TonightRoute route) => ProviderScope(
  overrides: [
    tonightRouteProvider.overrideWith((ref) async => route),
    gpsReporterProvider.overrideWith((ref) => GpsReporter(_MockDriverGateway(), () async => (lat: 0.0, lng: 0.0))),
  ],
  child: testApp(const DriverShell()),
);

Future<void> _openMap(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const Key('openRouteMap')));
  await tester.tap(find.byKey(const Key('openRouteMap')));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    // Màn cao: sheet dưới (42%) đủ chỗ cho thẻ việc + danh sách
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(1170, 2532);
    binding.platformDispatcher.views.first.devicePixelRatio = 3;
  });
  tearDown(() => TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.views.first.reset());

  testWidgets('D08: nút phóng to ở bản đồ ホーム → trang ルートの地図 (tiêu đề, việc kế tiếp, chú thích nét đứt); quay lại về ホーム', (tester) async {
    await tester.pumpWidget(_app(routeFixture));
    await tester.pumpAndSettle();
    await _openMap(tester);

    expect(find.byType(DriverRouteMapPage), findsOneWidget);
    expect(find.text(l10nJa.routeMapTitle), findsOneWidget);
    // 5 điểm, điểm kế tiếp = rB (thứ 3 trên tuyến)
    expect(find.text(l10nJa.routeMapSubtitle(5, 3)), findsOneWidget);
    expect(find.text(l10nJa.routeMapLegend), findsOneWidget);
    expect(find.text(l10nJa.nextTaskLabel), findsOneWidget);
    expect(find.byKey(const Key('routeMapFitAll')), findsOneWidget);

    await tester.tap(find.byKey(const Key('routeMapBack')));
    await tester.pumpAndSettle();
    expect(find.byType(DriverRouteMapPage), findsNothing);
    expect(find.byKey(const Key('openRouteMap')), findsOneWidget);
  });

  testWidgets('D08: chạm 1 điểm trong danh sách → thẻ 「選んだ地点」 + 「この地点を開く」 của điểm đó', (tester) async {
    await tester.pumpWidget(_app(routeFixture));
    await tester.pumpAndSettle();
    await _openMap(tester);

    // Kéo sheet lên như người dùng (「上に引くと全部の地点」) rồi chạm dòng
    await tester.drag(find.text(l10nJa.routeMapListHint), const Offset(0, -500));
    await tester.pumpAndSettle();
    final row = find.descendant(of: find.byType(DriverRouteMapPage), matching: find.byKey(const Key('stop_p3')));
    await tester.tap(row);
    await tester.pumpAndSettle();

    expect(find.text(l10nJa.routeMapSelectedStop), findsOneWidget);
    expect(find.text(l10nJa.routeMapOpenStop), findsOneWidget);
    expect(find.text(l10nJa.nextTaskLabel), findsNothing);
  });

  testWidgets('D08: đã rời mọi điểm → 「すべて完了」, không có thẻ việc', (tester) async {
    final done = TonightRoute(
      truck: routeFixture.truck,
      routeId: routeFixture.routeId,
      stops: [
        for (final s in routeFixture.stops)
          stopFixture(s.routeStopId, type: s.type, sequence: s.sequence, departed: true, restaurantId: s.restaurantId),
      ],
    );
    await tester.pumpWidget(_app(done));
    await tester.pumpAndSettle();
    await _openMap(tester);

    expect(find.text(l10nJa.routeMapAllDone(5)), findsOneWidget);
    expect(find.byKey(const Key('nextTaskCard')), findsNothing);
  });
}
