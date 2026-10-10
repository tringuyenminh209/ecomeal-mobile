import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/features/admin/admin_gateway.dart';
import 'package:ecomeal_mobile/features/admin/admin_operations_page.dart';
import '../../helpers/fake_admin_gateway.dart';
import '../../helpers/test_app.dart';

AdminRouteStop _stop(String name, {required bool departed, int hourUtc = 11}) =>
    AdminRouteStop(name: name, lat: 34.7, lng: 135.5, plannedTime: DateTime.utc(2026, 10, 10, hourUtc, 18), departed: departed);

AdminRoute _route(String id, List<AdminRouteStop> stops, {String? driver = '佐藤', double? lat = 34.7}) => AdminRoute(
      id: id,
      plateNumber: 'なにわ 400 さ 12-34',
      driverName: driver,
      stops: stops,
      reservedCount: 12,
      lat: lat,
      lng: lat == null ? null : 135.5,
    );

void main() {
  test('status / nextStop: Web の routeStatus と同じ規則', () {
    expect(_route('a', [_stop('A', departed: false), _stop('B', departed: false)]).status, AdminRouteStatus.waiting);
    expect(_route('a', [_stop('A', departed: true), _stop('B', departed: false)]).status, AdminRouteStatus.running);
    expect(_route('a', [_stop('A', departed: true), _stop('B', departed: true)]).status, AdminRouteStatus.done);
    expect(_route('a', const []).status, AdminRouteStatus.waiting);
    expect(_route('a', [_stop('A', departed: true), _stop('B', departed: false)]).nextStop?.name, 'B');
    expect(_route('a', [_stop('A', departed: true)]).nextStop, isNull);
  });

  testWidgets('SCR-A02: 車両ごとに状態・次の地点・到着予定（JST）、Maps キーが無ければ地図の代わりに案内', (tester) async {
    final admin = FakeAdminGateway(state: const AdminMfaOk())
      ..routes = [
        _route('r1', [_stop('梅田駅前', departed: true), _stop('大阪学生寮前', departed: false)]),
        _route('r2', [_stop('天王寺公園', departed: false)], driver: null, lat: null),
      ];
    await tester.pumpWidget(ProviderScope(
      overrides: [adminGatewayProvider.overrideWithValue(admin)],
      child: testApp(const Scaffold(body: AdminOperationsPage())),
    ));
    await tester.pumpAndSettle();
    expect(find.text(l10nJa.adminOpsMapUnavailable), findsOneWidget);
    expect(find.text(l10nJa.adminOpsRunning), findsOneWidget);
    expect(find.text(l10nJa.adminOpsWaiting), findsOneWidget);
    expect(find.text(l10nJa.adminOpsNext('佐藤', '大阪学生寮前')), findsOneWidget);
    expect(find.text(l10nJa.adminOpsNext(l10nJa.adminOpsNoDriver, '天王寺公園')), findsOneWidget);
    expect(find.text('20:18'), findsNWidgets(2));
  });
}
