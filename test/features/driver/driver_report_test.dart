import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:ecomeal_mobile/features/driver/driver_report.dart';
import '../../helpers/test_app.dart';

// SCR-D06「運営に連絡」(0067 / API-083)
class _FakeReportGateway implements DriverReportGateway {
  final calls = <String>[];
  Object? error;

  @override
  Future<void> report({required String category, int? delayMinutes, String? message}) async {
    if (error != null) throw error!;
    calls.add('$category:${delayMinutes ?? '-'}:${message ?? '-'}');
  }
}

Widget _app(_FakeReportGateway gateway) => ProviderScope(
      overrides: [driverReportGatewayProvider.overrideWithValue(gateway)],
      child: testApp(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(onPressed: () => openDriverReportSheet(context), child: const Text('open')),
            ),
          ),
        ),
      ),
    );

Future<void> _open(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Future<void> _send(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('driverReportSend')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('種類を選ばずに送る → 案内、送信しない', (tester) async {
    final gateway = _FakeReportGateway();
    await tester.pumpWidget(_app(gateway));
    await _open(tester);
    await _send(tester);
    expect(find.text(l10nJa.driverReportSelect), findsOneWidget);
    expect(gateway.calls, isEmpty);
  });

  testWidgets('「その他」は一言が必要（サーバーと同じ決まり）', (tester) async {
    final gateway = _FakeReportGateway();
    await tester.pumpWidget(_app(gateway));
    await _open(tester);
    await tester.tap(find.byKey(const Key('driverReport_other')));
    await tester.pumpAndSettle();
    await _send(tester);
    expect(find.text(l10nJa.driverReportNeedMessage), findsOneWidget);
    expect(gateway.calls, isEmpty);
  });

  testWidgets('遅れ: 分数を選んで送る → 閉じて「送信しました」', (tester) async {
    final gateway = _FakeReportGateway();
    await tester.pumpWidget(_app(gateway));
    await _open(tester);
    expect(find.byKey(const Key('driverReportDelay_10')), findsNothing); // 分数は「遅れ」を選んだときだけ
    await tester.tap(find.byKey(const Key('driverReport_delay')));
    await tester.pumpAndSettle();
    expect(find.text(l10nJa.driverReportMinutesMax), findsOneWidget);
    await tester.tap(find.byKey(const Key('driverReportDelay_30')));
    await tester.enterText(find.byKey(const Key('driverReportMessage')), ' 渋滞で中之島公園の出発が遅れています ');
    await _send(tester);
    expect(gateway.calls, ['delay:30:渋滞で中之島公園の出発が遅れています']);
    expect(find.byType(DriverReportSheet), findsNothing);
    expect(find.text(l10nJa.driverReportSent), findsOneWidget);
  });

  testWidgets('車両のトラブル: 一言なしでも送れる、分数は付けない', (tester) async {
    final gateway = _FakeReportGateway();
    await tester.pumpWidget(_app(gateway));
    await _open(tester);
    await tester.tap(find.byKey(const Key('driverReport_vehicle')));
    await tester.pumpAndSettle();
    await _send(tester);
    expect(gateway.calls, ['vehicle:-:-']);
  });

  testWidgets('サーバーのエラー: 連続送信（E-REPORT-429）・運行なし（E-REPORT-404）はその旨、シートは残る', (tester) async {
    final gateway = _FakeReportGateway()..error = const PostgrestException(message: 'E-REPORT-429: already reported');
    await tester.pumpWidget(_app(gateway));
    await _open(tester);
    await tester.tap(find.byKey(const Key('driverReport_food')));
    await tester.pumpAndSettle();
    await _send(tester);
    expect(find.text(l10nJa.driverReportDuplicate), findsOneWidget);
    gateway.error = const PostgrestException(message: 'E-REPORT-404: no route tonight');
    await _send(tester);
    expect(find.text(l10nJa.driverReportNoRoute), findsOneWidget);
    expect(find.byType(DriverReportSheet), findsOneWidget);
  });
}
