import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;
import 'package:ecomeal_mobile/core/app_version.dart';
import 'package:ecomeal_mobile/features/admin/admin_dashboard_page.dart';
import 'package:ecomeal_mobile/features/admin/admin_gateway.dart';
import 'package:ecomeal_mobile/features/admin/admin_mfa_gate.dart';
import 'package:ecomeal_mobile/features/admin/admin_settings_page.dart';
import 'package:ecomeal_mobile/features/notifications/notification_inbox.dart';
import 'package:ecomeal_mobile/features/notifications/notification_preferences.dart';
import 'package:ecomeal_mobile/features/notifications/push_registration.dart';
import 'package:ecomeal_mobile/widgets/admin_shell.dart';
import 'package:ecomeal_mobile/features/admin/admin_tasks_gateway.dart';
import '../../helpers/fake_admin_gateway.dart';
import '../../helpers/fake_admin_tasks_gateway.dart';
import '../../helpers/fake_inbox_gateway.dart';
import '../../helpers/test_app.dart';

Widget _app(Widget home, {FakeAdminGateway? admin, FakePreferencesGateway? prefs}) => ProviderScope(
      overrides: [
        adminGatewayProvider.overrideWithValue(admin ?? FakeAdminGateway()),
        adminTasksGatewayProvider.overrideWithValue(FakeAdminTasksGateway()),
        notificationInboxGatewayProvider.overrideWithValue(FakeInboxGateway()),
        notificationPreferencesGatewayProvider.overrideWithValue(prefs ?? FakePreferencesGateway(const [])),
        appVersionProvider.overrideWith((ref) async => '1.0.0'),
        pushStatusProvider.overrideWith((ref) async => PushStatus.on),
      ],
      child: testApp(home),
    );

const _gated = AdminMfaGate(userId: 'u-1', child: Text('ADMIN HOME'));

// Toàn bộ trang dựng một lần (ListView không tạo phần ngoài màn hình)
void _tall(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 4800);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  group('logic', () {
    test('normalizeTotpCode: 6桁のみ、空白・ハイフンは無視', () {
      expect(normalizeTotpCode('123 456'), '123456');
      expect(normalizeTotpCode('123-456'), '123456');
      expect(normalizeTotpCode('12345'), isNull);
      expect(normalizeTotpCode('12345a'), isNull);
    });

    test('formatTotpSecret: 4文字ずつ', () {
      expect(formatTotpSecret('JBSWY3DPEHPK3PXP'), 'JBSW Y3DP EHPK 3PXP');
      expect(formatTotpSecret('ABCDEF'), 'ABCD EF');
    });

    test('mfaErrorMessage: 違うコード／回数制限／その他', () {
      expect(mfaErrorMessage(const AuthException('x', code: 'mfa_verification_failed'), l10nJa), l10nJa.adminMfaWrongCode);
      expect(mfaErrorMessage(const AuthException('x', statusCode: '429'), l10nJa), l10nJa.errorRateLimited);
      // 2026-10-15: challenge và verify khác IP (iPhone/iPad) — không phải mã sai
      expect(mfaErrorMessage(const AuthException('x', code: 'mfa_ip_address_mismatch'), l10nJa), l10nJa.adminMfaNetworkChanged);
      expect(mfaErrorMessage(Exception('network'), l10nJa), l10nJa.adminMfaFailed);
    });
  });

  group('SCR-A00 2段階認証', () {
    testWidgets('aal2 済み（または必須でない）→ そのまま運営画面', (tester) async {
      await tester.pumpWidget(_app(_gated, admin: FakeAdminGateway(state: const AdminMfaOk())));
      await tester.pumpAndSettle();
      expect(find.text('ADMIN HOME'), findsOneWidget);
    });

    testWidgets('コード入力: 6桁でないと送らない、正しいコードで運営画面へ', (tester) async {
      final admin = FakeAdminGateway();
      await tester.pumpWidget(_app(_gated, admin: admin));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('adminMfaCode')), '123');
      await tester.tap(find.byKey(const Key('adminMfaVerify')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.adminMfaInvalidCode), findsOneWidget);
      expect(admin.verified, isEmpty);
      await tester.enterText(find.byKey(const Key('adminMfaCode')), '123456');
      await tester.tap(find.byKey(const Key('adminMfaVerify')));
      await tester.pumpAndSettle();
      expect(admin.verified, ['factor-1:123456']);
      expect(find.text('ADMIN HOME'), findsOneWidget);
    });

    testWidgets('違うコード → 理由を表示して留まる', (tester) async {
      final admin = FakeAdminGateway()..verifyError = const AuthException('invalid', code: 'mfa_verification_failed');
      await tester.pumpWidget(_app(_gated, admin: admin));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('adminMfaCode')), '000000');
      await tester.tap(find.byKey(const Key('adminMfaVerify')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.adminMfaWrongCode), findsOneWidget);
      expect(find.text(l10nJa.adminMfaLostDevice), findsOneWidget); // 認証アプリを失ったときの戻り方も同じ画面に
      expect(find.text('ADMIN HOME'), findsNothing);
    });

    testWidgets('初回設定: キーを4文字ずつ表示、コピーでクリップボードへ、コードで完了', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
      _tall(tester);
      final admin = FakeAdminGateway(state: const AdminMfaEnroll());
      await tester.pumpWidget(_app(_gated, admin: admin));
      await tester.pumpAndSettle();
      expect(find.text('JBSW Y3DP EHPK 3PXP'), findsOneWidget);
      await tester.tap(find.byKey(const Key('adminMfaCopy')));
      await tester.pumpAndSettle();
      expect(copied, 'JBSWY3DPEHPK3PXP');
      expect(find.text(l10nJa.adminMfaCopied), findsOneWidget);
      await tester.enterText(find.byKey(const Key('adminMfaCode')), '123456');
      await tester.tap(find.byKey(const Key('adminMfaSetupDone')));
      await tester.pumpAndSettle();
      expect(admin.verified, ['factor-new:123456']);
      expect(find.text('ADMIN HOME'), findsOneWidget);
    });
  });

  group('SCR-A01', () {
    final admin = FakeAdminGateway(
      state: const AdminMfaOk(),
      badges: AdminBadges(
        openIssues: 2,
        pendingRestaurants: 3,
        pendingLicenses: 1,
        newInquiries: 3,
        latestIssue: (orderId: '00000000-0000-0000-0000-0000000007ef', category: 'not_received', createdAt: DateTime.now().subtract(const Duration(minutes: 15))),
        latestRestaurant: (name: 'Nami Bakery', createdAt: DateTime.now().subtract(const Duration(minutes: 30))),
        newInquiryTypes: const {'restaurant': 2, 'other': 1},
      ),
      tonight: const AdminTonight(trucksTotal: 3, trucksRunning: 2, stopsTotal: 14, stopsDone: 9, reserved: 126, pickedUp: 48),
    );

    testWidgets('今夜の運行と対応が必要（件数と最新）', (tester) async {
      await tester.pumpWidget(_app(Scaffold(body: AdminDashboardPage(userId: 'u-1', onOpenTask: (_) {})), admin: admin));
      await tester.pumpAndSettle();
      expect(find.text('2/3'), findsOneWidget);
      expect(find.text('9/14'), findsOneWidget);
      expect(find.text('126'), findsOneWidget);
      expect(find.text(l10nJa.adminRunning), findsOneWidget);
      expect(find.text(l10nJa.adminTaskIssueLatest('#EM-2031', l10nJa.issueCategoryNotReceived, l10nJa.inboxMinutesAgo(15))), findsOneWidget);
      expect(find.text(l10nJa.adminTaskLatest('Nami Bakery', l10nJa.inboxMinutesAgo(30))), findsOneWidget);
      expect(find.text(l10nJa.adminTaskInquiryTypes(2, 1)), findsOneWidget);
    });

    testWidgets('カードをタップ → 対応タブのその項目', (tester) async {
      await tester.pumpWidget(_app(const AdminShell(userId: 'u-1', email: 'admin@ecomeal.jp'), admin: admin));
      await tester.pumpAndSettle();
      // 0067 で「運行の連絡」のカードが増え、免許のカードは画面の下へ
      await tester.ensureVisible(find.byKey(const Key('adminTask-licenses')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('adminTask-licenses')));
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(tester.element(find.byType(AdminShell)));
      expect(container.read(adminTabProvider), AdminTab.tasks);
      expect(container.read(adminTaskProvider), AdminTask.licenses);
    });
  });

  group('SCR-A07', () {
    testWidgets('通知の種類を Figma の順で、切り替えるとサーバーに保存', (tester) async {
      final prefs = FakePreferencesGateway(const [
        NotificationPreference(type: 'inquiry_received', isMandatory: false, isEnabled: true),
        NotificationPreference(type: 'issue_reported', isMandatory: false, isEnabled: true),
        NotificationPreference(type: 'license_submitted', isMandatory: false, isEnabled: true),
        NotificationPreference(type: 'restaurant_applied', isMandatory: false, isEnabled: true),
      ]);
      _tall(tester);
      await tester.pumpWidget(_app(const Scaffold(body: AdminSettingsPage(userId: 'u-1', email: 'admin@ecomeal.jp')), prefs: prefs));
      await tester.pumpAndSettle();
      final titles = tester.widgetList<SwitchListTile>(find.byType(SwitchListTile)).map((t) => (t.title as Text).data).toList();
      expect(titles, [l10nJa.adminPrefIssues, l10nJa.adminPrefRestaurants, l10nJa.adminPrefLicenses, l10nJa.adminPrefInquiries]);
      await tester.tap(find.byKey(const Key('adminPref-license_submitted')));
      await tester.pumpAndSettle();
      expect(prefs.changes, ['license_submitted=false']);
      expect(tester.widget<SwitchListTile>(find.byKey(const Key('adminPref-license_submitted'))).value, isFalse);
      expect(find.text('EcoMeal 運営チーム'), findsOneWidget);
      expect(find.text(l10nJa.adminVersion('1.0.0')), findsOneWidget);
    });

    testWidgets('保存に失敗 → 知らせて、表示はサーバーの値に戻る', (tester) async {
      final prefs = FakePreferencesGateway(const [NotificationPreference(type: 'issue_reported', isMandatory: false, isEnabled: true)])
        ..setError = Exception('network');
      await tester.pumpWidget(_app(const Scaffold(body: AdminSettingsPage(userId: 'u-1', email: 'a@b.jp')), prefs: prefs));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('adminPref-issue_reported')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.adminPrefSaveFailed), findsOneWidget);
      expect(tester.widget<SwitchListTile>(find.byKey(const Key('adminPref-issue_reported'))).value, isTrue);
    });
  });
}
