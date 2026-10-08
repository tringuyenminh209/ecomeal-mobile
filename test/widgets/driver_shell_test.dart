import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ecomeal_mobile/features/driver/driver_gateway.dart';
import 'package:ecomeal_mobile/features/driver/gps_reporter.dart';
import 'package:ecomeal_mobile/widgets/driver_shell.dart';
import 'package:ecomeal_mobile/widgets/skeleton.dart';
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
}
