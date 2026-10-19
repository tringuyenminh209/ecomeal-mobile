import 'dart:async';
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

// API-090 trả rỗng (không còn đoạn nào) → bản đồ giữ nét đứt như bước 1
const _noRoad = RoadRoute(polyline: null, distanceMeters: 0, durationSeconds: 0, secondsToStop: {});
// Còn rB → p2 → p3: 5 / 15 / 30 phút tính từ xe, tổng 12.4km
const _road = RoadRoute(
  polyline: '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
  distanceMeters: 12400,
  durationSeconds: 1800,
  secondsToStop: {'rB': 300, 'p2': 900, 'p3': 1800},
);

// Audit D08 bước 1 (Figma 966:1785 / 967:1785) + bước 2 (978:1833 / 978:1899 / 978:1965): bản đồ toàn màn hình theo tuyến
// được giao. Test không có key Maps nên GoogleMap không dựng — kiểm phần quanh bản đồ: mở/đóng, tiêu đề, chú thích nét
// đứt / đường thật, thẻ việc, chọn điểm từ danh sách. Gateway giả trả API-090; roadRouteProvider thật chạy (khoá, 5 phút).
Widget _app(TonightRoute route, {_MockDriverGateway? gateway}) => ProviderScope(
  overrides: [
    tonightRouteProvider.overrideWith((ref) async => route),
    driverGatewayProvider.overrideWithValue(gateway ?? _gatewayWith(() async => _noRoad)),
    gpsReporterProvider.overrideWith((ref) => GpsReporter(_MockDriverGateway(), () async => (lat: 0.0, lng: 0.0))),
  ],
  child: testApp(const DriverShell()),
);

_MockDriverGateway _gatewayWith(Future<RoadRoute> Function() road) {
  final gw = _MockDriverGateway();
  when(gw.fetchRoadRoute).thenAnswer((_) => road());
  return gw;
}

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
    final gw = _gatewayWith(() async => _road);
    await tester.pumpWidget(_app(done, gateway: gw));
    await tester.pumpAndSettle();
    await _openMap(tester);

    expect(find.text(l10nJa.routeMapAllDone(5)), findsOneWidget);
    expect(find.byKey(const Key('nextTaskCard')), findsNothing);
    // Không còn điểm nào → không hỏi đường (Routes API có phí)
    verifyNever(gw.fetchRoadRoute);
  });

  testWidgets('D08 bước 2: có đường thật → 「道に沿った道順・残り3か所 約30分（12.4km）」, thẻ 「道で あと 5分」; chọn p3 → 30分', (tester) async {
    await tester.pumpWidget(_app(routeFixture, gateway: _gatewayWith(() async => _road)));
    await tester.pumpAndSettle();
    await _openMap(tester);

    expect(find.text(l10nJa.routeMapRoadLegend(3, 30, '12.4')), findsOneWidget);
    expect(find.text(l10nJa.routeMapLegend), findsNothing);
    final card = find.byKey(const Key('nextTaskCard'));
    expect(find.descendant(of: card, matching: find.text(l10nJa.roadTimeLeftLabel)), findsOneWidget);
    expect(find.descendant(of: card, matching: find.text(l10nJa.minutesShort(5))), findsOneWidget);
    expect(find.descendant(of: card, matching: find.text(l10nJa.timeLeftLabel)), findsNothing);

    await tester.drag(find.text(l10nJa.routeMapListHint), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(DriverRouteMapPage), matching: find.byKey(const Key('stop_p3'))));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(const Key('nextTaskCard')), matching: find.text(l10nJa.minutesShort(30))), findsOneWidget);
  });

  testWidgets('D08 bước 2: API-090 trả rỗng (không vẽ được) → giữ chú thích nét đứt, thẻ 「あと」 theo kế hoạch', (tester) async {
    await tester.pumpWidget(_app(routeFixture));
    await tester.pumpAndSettle();
    await _openMap(tester);

    expect(find.text(l10nJa.routeMapLegend), findsOneWidget);
    expect(find.descendant(of: find.byKey(const Key('nextTaskCard')), matching: find.text(l10nJa.timeLeftLabel)), findsOneWidget);
  });

  testWidgets('D08 bước 2: đang tải đường → 「道を読み込んでいます…」, thẻ vẫn 「あと」 theo giờ kế hoạch', (tester) async {
    final pending = Completer<RoadRoute>();
    await tester.pumpWidget(_app(routeFixture, gateway: _gatewayWith(() => pending.future)));
    await tester.pumpAndSettle();
    await _openMap(tester);

    expect(find.text(l10nJa.routeMapRoadLoading), findsOneWidget);
    final card = find.byKey(const Key('nextTaskCard'));
    expect(find.descendant(of: card, matching: find.text(l10nJa.timeLeftLabel)), findsOneWidget);
    expect(find.descendant(of: card, matching: find.text(l10nJa.roadTimeLeftLabel)), findsNothing);
  });

  testWidgets('D08 bước 2: tải đường lỗi → 「道を読み込めませんでした」 + 「もう一度」 (giữ nét đứt); bấm → đọc lại, có đường', (tester) async {
    var calls = 0;
    final gw = _gatewayWith(() async {
      calls++;
      if (calls == 1) throw StateError('E-DIR-502');
      return _road;
    });
    await tester.pumpWidget(_app(routeFixture, gateway: gw));
    await tester.pumpAndSettle();
    await _openMap(tester);

    expect(find.text(l10nJa.routeMapRoadFailed), findsOneWidget);
    expect(find.byKey(const Key('routeMapLegend')), findsNothing);
    expect(find.descendant(of: find.byKey(const Key('nextTaskCard')), matching: find.text(l10nJa.timeLeftLabel)), findsOneWidget);

    await tester.tap(find.byKey(const Key('routeMapRoadRetry')));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text(l10nJa.routeMapRoadFailed), findsNothing);
    expect(find.text(l10nJa.routeMapRoadLegend(3, 30, '12.4')), findsOneWidget);
  });

  testWidgets('D08 bước 2: bản đồ mở 5 phút → đọc lại đường; ホーム (bản đồ nhỏ) không hỏi đường', (tester) async {
    var calls = 0;
    final gw = _gatewayWith(() async {
      calls++;
      return _road;
    });
    await tester.pumpWidget(_app(routeFixture, gateway: gw));
    await tester.pumpAndSettle();
    expect(calls, 0); // bản đồ nhỏ ở ホーム vẫn nét đứt, không tốn phí
    await _openMap(tester);
    expect(calls, 1);

    await tester.pump(roadRouteRefresh - const Duration(seconds: 1));
    expect(calls, 1);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text(l10nJa.routeMapRoadLegend(3, 30, '12.4')), findsOneWidget);
  });
}
