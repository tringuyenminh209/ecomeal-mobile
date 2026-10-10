import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:ecomeal_mobile/features/orders/order_gateway.dart';
import 'package:ecomeal_mobile/features/orders/order_helpers.dart';
import 'package:ecomeal_mobile/features/orders/order_history_page.dart';
import 'package:ecomeal_mobile/features/orders/report_issue_page.dart';
import '../../helpers/test_app.dart';

class MockOrderGateway extends Mock implements OrderGateway {}

OrderSummary _order({String status = 'picked_up', Duration ago = const Duration(hours: 2), OrderIssue? issue}) => OrderSummary(
      id: '00000000-0000-0000-0000-00000000c001',
      status: status,
      pricePaid: 620,
      createdAt: DateTime.now().subtract(ago),
      plannedPickupTime: DateTime.now().subtract(ago),
      stopName: '梅田',
      taxRate: 8,
      taxAmount: 45,
      issue: issue,
    );

// UC-40 / API-061: SCR-M15 問題を報告 と SCR-M06 の表示 (Figma 443:1094)
void main() {
  late MockOrderGateway gateway;
  setUp(() => gateway = MockOrderGateway());

  group('canReportIssue', () {
    final now = DateTime(2026, 10, 9, 12);
    test('受取済み・失効は48時間以内なら報告できる', () {
      expect(canReportIssue(status: 'picked_up', hasIssue: false, plannedPickupTime: now.subtract(const Duration(hours: 47)), now: now), isTrue);
      expect(canReportIssue(status: 'expired', hasIssue: false, plannedPickupTime: now.subtract(const Duration(hours: 1)), now: now), isTrue);
    });
    test('48時間を過ぎた・報告済み・受け取り前は不可', () {
      expect(canReportIssue(status: 'picked_up', hasIssue: false, plannedPickupTime: now.subtract(const Duration(hours: 49)), now: now), isFalse);
      expect(canReportIssue(status: 'picked_up', hasIssue: true, plannedPickupTime: now, now: now), isFalse);
      expect(canReportIssue(status: 'allocated', hasIssue: false, plannedPickupTime: now, now: now), isFalse);
    });
  });

  group('SCR-M06 カード', () {
    Future<void> pumpHistory(WidgetTester tester, List<OrderSummary> orders) async {
      when(() => gateway.fetchMyOrders()).thenAnswer((_) async => orders);
      await tester.pumpWidget(ProviderScope(
        overrides: [orderGatewayProvider.overrideWithValue(gateway)],
        child: testApp(const OrderHistoryPage()),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('最近受け取った注文 → 「問題を報告」', (tester) async {
      await pumpHistory(tester, [_order()]);
      expect(find.byKey(const Key('reportIssueButton')), findsOneWidget);
    });

    testWidgets('3日前に受け取った注文 → 出さない', (tester) async {
      await pumpHistory(tester, [_order(ago: const Duration(days: 3))]);
      expect(find.byKey(const Key('reportIssueButton')), findsNothing);
    });

    testWidgets('報告済み（確認中）→ 黄色の注記、ボタンは出さない', (tester) async {
      await pumpHistory(tester, [_order(issue: const OrderIssue(isResolved: false))]);
      expect(find.text('問題を報告しました（確認中）'), findsOneWidget);
      expect(find.byKey(const Key('reportIssueButton')), findsNothing);
    });

    testWidgets('対応済み → 返金額と運営の回答', (tester) async {
      await pumpHistory(tester, [_order(issue: const OrderIssue(isResolved: true, refundAmount: 450, resolution: 'ご不便をおかけしました。'))]);
      expect(find.text('対応しました：¥450を返金'), findsOneWidget);
      expect(find.text('ご不便をおかけしました。'), findsOneWidget);
    });
  });

  group('SCR-M15 報告フォーム', () {
    Future<void> pumpPage(WidgetTester tester, {void Function(bool?)? onResult}) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [orderGatewayProvider.overrideWithValue(gateway)],
        child: testApp(Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              final r = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => ReportIssuePage(order: _order())));
              onResult?.call(r);
            },
            child: const Text('open'),
          ),
        )),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('種類を選ばない → エラー、送らない', (tester) async {
      await pumpPage(tester);
      await tester.enterText(find.byKey(const Key('issueMessageField')), 'カビ');
      await tester.tap(find.byKey(const Key('submitIssueButton')));
      await tester.pump();
      expect(find.text('問題の種類を選んでください'), findsOneWidget);
      verifyNever(() => gateway.reportIssue(orderId: any(named: 'orderId'), category: any(named: 'category'), message: any(named: 'message')));
    });

    testWidgets('種類と内容 → report_order_issue → 閉じる', (tester) async {
      bool? result;
      when(() => gateway.reportIssue(orderId: any(named: 'orderId'), category: any(named: 'category'), message: any(named: 'message')))
          .thenAnswer((_) async {});
      await pumpPage(tester, onResult: (r) => result = r);
      await tester.tap(find.byKey(const Key('issueCategory_quality')));
      await tester.enterText(find.byKey(const Key('issueMessageField')), '  パンにカビ  ');
      await tester.tap(find.byKey(const Key('submitIssueButton')));
      await tester.pumpAndSettle();
      verify(() => gateway.reportIssue(orderId: '00000000-0000-0000-0000-00000000c001', category: 'quality', message: 'パンにカビ')).called(1);
      expect(result, isTrue);
    });

    testWidgets('48時間を過ぎていた（E-ISSUE-410）→ 案内を出してページに残る', (tester) async {
      when(() => gateway.reportIssue(orderId: any(named: 'orderId'), category: any(named: 'category'), message: any(named: 'message')))
          .thenThrow(const PostgrestException(message: 'E-ISSUE-410: report period has ended'));
      await pumpPage(tester);
      await tester.tap(find.byKey(const Key('issueCategory_other')));
      await tester.enterText(find.byKey(const Key('issueMessageField')), 'x');
      await tester.tap(find.byKey(const Key('submitIssueButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('issueError')), findsOneWidget);
      expect(find.textContaining('48時間を過ぎた'), findsOneWidget);
      expect(find.byType(ReportIssuePage), findsOneWidget);
    });
  });
}
