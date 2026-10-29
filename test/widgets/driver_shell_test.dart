import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart' show LocationPermission;
import 'package:mocktail/mocktail.dart';
import 'package:ecomeal_mobile/features/driver/driver_gateway.dart';
import 'package:ecomeal_mobile/features/driver/driver_report.dart' show DriverReportSheet;
import 'package:ecomeal_mobile/features/driver/gps_reporter.dart';
import 'package:ecomeal_mobile/widgets/driver_shell.dart';
import 'package:ecomeal_mobile/widgets/skeleton.dart';
import '../features/driver/driver_test_data.dart';
import '../helpers/test_app.dart';

class _MockDriverGateway extends Mock implements DriverGateway {}

Widget _shell(Future<TonightRoute?> Function() route) => ProviderScope(
      overrides: [
        tonightRouteProvider.overrideWith((ref) => route()),
        // GPS không chạy trong test (không có xe → reporter không bao giờ start)
        gpsReporterProvider.overrideWith((ref) => GpsReporter(_MockDriverGateway(), () async => (lat: 0.0, lng: 0.0))),
      ],
      child: testApp(const DriverShell()),
    );

void main() {
  testWidgets('tab 受取 lúc đang tải tuyến → khung xương, KHÔNG hiện 「今夜の受取はありません」', (tester) async {
    final pending = Completer<TonightRoute?>();
    await tester.pumpWidget(_shell(() => pending.future));
    await tester.tap(find.text(l10nJa.driverTabPickup));
    await tester.pump();
    expect(find.byType(SkeletonList), findsOneWidget);
    expect(find.text(l10nJa.noPickupsTonight), findsNothing);
  });

  testWidgets('tab 販売 khi tải tuyến lỗi → báo lỗi + 再試行 (không giả vờ là "không có điểm bán")', (tester) async {
    await tester.pumpWidget(_shell(() => Future.error(Exception('offline'))));
    await tester.tap(find.text(l10nJa.driverTabSales));
    await tester.pump();
    await tester.pump();
    expect(find.text(l10nJa.errorLoadTitle), findsOneWidget);
    expect(find.text(l10nJa.retry), findsOneWidget);
    expect(find.text(l10nJa.noSalesTonight), findsNothing);
  });

  testWidgets('SCR-D01: 今夜の運行があるときだけ「運営に連絡」→ SCR-D06 のシート', (tester) async {
    await tester.pumpWidget(_shell(() async => routeFixture));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('driverReportButton')));
    await tester.pumpAndSettle();
    expect(find.byType(DriverReportSheet), findsOneWidget);
  });

  // Audit D02: chưa được gán xe → vẫn vào được 設定 (bằng lái, ca, đăng xuất) và tải lại khi vận hành vừa gán xe
  testWidgets('D02: chưa gán xe → có 設定 + 再読み込み; bấm 再読み込み sau khi được gán → hiện tuyến', (tester) async {
    var fetches = 0;
    await tester.pumpWidget(_shell(() async => fetches++ == 0 ? null : routeFixture));
    await tester.pumpAndSettle();
    expect(find.text(l10nJa.noTruckAssigned), findsOneWidget);
    expect(find.byKey(const Key('driverSettingsButton')), findsOneWidget);

    await tester.tap(find.text(l10nJa.storeReload));
    await tester.pumpAndSettle();
    expect(find.text(l10nJa.noTruckAssigned), findsNothing);
    expect(find.byKey(const Key('driverReportButton')), findsOneWidget);
  });

  testWidgets('D02: tải tuyến lỗi → vẫn có 設定 (không mắc kẹt ở màn lỗi)', (tester) async {
    await tester.pumpWidget(_shell(() => Future.error(Exception('offline'))));
    await tester.pumpAndSettle();
    expect(find.text(l10nJa.errorLoadTitle), findsOneWidget);
    expect(find.byKey(const Key('driverSettingsButton')), findsOneWidget);
  });

  // Audit D05: băng GPS theo nguyên nhân — thiếu quyền có 「設定を開く」, lỗi mạng thì không có nút (tự gửi lại)
  // Reporter thật (DriverShell start khi có xe), nguồn vị trí / gateway giả ném đúng loại lỗi
  Widget shellWithGps(PositionSource source, {bool sendFails = false}) {
    final gateway = _MockDriverGateway();
    when(() => gateway.sendLocation(truckId: any(named: 'truckId'), lat: any(named: 'lat'), lng: any(named: 'lng')))
        .thenAnswer((_) async => sendFails ? throw Exception('network') : null);
    return ProviderScope(
      overrides: [
        tonightRouteProvider.overrideWith((ref) async => routeFixture),
        gpsReporterProvider.overrideWith((ref) => GpsReporter(gateway, source, interval: const Duration(hours: 1))),
      ],
      child: testApp(const DriverShell()),
    );
  }

  testWidgets('D05: thiếu quyền vị trí → băng 「位置情報がオフになっています」 + 設定を開く', (tester) async {
    await tester.pumpWidget(shellWithGps(() async => throw LocationPermission.deniedForever));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('gpsProblem-permission')), findsOneWidget);
    expect(find.text(l10nJa.gpsPermissionTitle), findsOneWidget);
    expect(find.descendant(of: find.byKey(const Key('gpsProblem-permission')), matching: find.text(l10nJa.openSettings)), findsOneWidget);
  });

  testWidgets('D05: gửi lỗi mạng → 「位置を送れていません」, không có nút', (tester) async {
    await tester.pumpWidget(shellWithGps(() async => (lat: 34.7, lng: 135.5), sendFails: true));
    await tester.pumpAndSettle();
    expect(find.text(l10nJa.gpsNotSentTitle), findsOneWidget);
    expect(find.descendant(of: find.byKey(const Key('gpsProblem-notSent')), matching: find.text(l10nJa.openSettings)), findsNothing);
  });

  testWidgets('SCR-D01: 今夜の運行がない（routeId なし）→ ボタンを出さない', (tester) async {
    await tester.pumpWidget(_shell(() async => TonightRoute(truck: routeFixture.truck, routeId: null, stops: const [])));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('driverReportButton')), findsNothing);
  });

  testWidgets('F03: successfully removing a truck stops an in-flight GPS read', (tester) async {
    var removed = false;
    final position = Completer<({double lat, double lng})>();
    final gateway = _MockDriverGateway();
    when(() => gateway.sendLocation(truckId: any(named: 'truckId'), lat: any(named: 'lat'), lng: any(named: 'lng'))).thenAnswer((_) async {});
    await tester.pumpWidget(ProviderScope(
      overrides: [
        tonightRouteProvider.overrideWith((ref) async => removed ? null : routeFixture),
        gpsReporterProvider.overrideWith((ref) => GpsReporter(gateway, () => position.future)),
      ],
      child: testApp(const DriverShell()),
    ));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(tester.element(find.byType(DriverShell)));
    removed = true;
    container.invalidate(tonightRouteProvider);
    await tester.pumpAndSettle();
    position.complete((lat: 1.0, lng: 2.0));
    await tester.pumpAndSettle();
    verifyNever(() => gateway.sendLocation(truckId: any(named: 'truckId'), lat: any(named: 'lat'), lng: any(named: 'lng')));
  });
}
