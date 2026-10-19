import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/core/app_version.dart';
import 'package:ecomeal_mobile/features/admin/admin_dashboard_page.dart';
import 'package:ecomeal_mobile/features/admin/admin_gateway.dart';
import 'package:ecomeal_mobile/features/admin/admin_inquiry_page.dart';
import 'package:ecomeal_mobile/features/admin/admin_license_page.dart';
import 'package:ecomeal_mobile/features/admin/admin_operations_page.dart';
import 'package:ecomeal_mobile/features/admin/admin_restaurant_page.dart';
import 'package:ecomeal_mobile/features/admin/admin_drafts.dart';
import 'package:ecomeal_mobile/features/admin/admin_tasks_gateway.dart';
import 'package:ecomeal_mobile/features/admin/admin_tasks_page.dart';
import 'package:ecomeal_mobile/features/notifications/notification_inbox.dart';
import 'package:ecomeal_mobile/widgets/admin_shell.dart';
import '../../helpers/fake_admin_gateway.dart';
import '../../helpers/fake_admin_tasks_gateway.dart';
import '../../helpers/fake_inbox_gateway.dart';
import '../../helpers/test_app.dart';

// iPad 11インチ 横（Figma section 20〜24「Admin · iPad」1194×834）
void _ipad(WidgetTester tester) {
  tester.view.physicalSize = const Size(1194, 834);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

AdminRestaurant _restaurant() => AdminRestaurant(
  id: 'r-1',
  name: 'Nami Bakery',
  nameKana: 'ナミ ベーカリー',
  address: '大阪市中央区南船場2-4-1',
  contact: '06-1234-5678',
  closingTime: '20:00:00',
  plDocPath: 'r-1/pl.pdf',
  createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  isApproved: false,
  rejectedAt: null,
  rejectionReason: null,
  applicantName: '並木 七海',
);

AdminInquiry _inquiry() => AdminInquiry(
  id: 'q-1',
  type: 'restaurant',
  name: '山田 太郎',
  companyName: '和食処 みなと',
  email: 'yamada@example.jp',
  phone: null,
  message: '余った料理の活用を検討しています。',
  status: 'new',
  adminNote: null,
  createdAt: DateTime.now().subtract(const Duration(hours: 1)),
);

final _license = AdminLicense(
  driverId: 'd-1',
  name: '佐藤 健太',
  status: 'submitted',
  expiresOn: '2029-03-31',
  submittedAt: DateTime.now().subtract(const Duration(days: 1)),
  imagePath: null,
);

Widget _app(Widget home, FakeAdminTasksGateway tasks) => ProviderScope(
  overrides: [
    adminGatewayProvider.overrideWithValue(FakeAdminGateway(state: const AdminMfaOk())),
    adminTasksGatewayProvider.overrideWithValue(tasks),
    notificationInboxGatewayProvider.overrideWithValue(FakeInboxGateway()),
    appVersionProvider.overrideWith((ref) async => '1.0.0'),
  ],
  child: testApp(home),
);

ProviderContainer _container(WidgetTester tester) => ProviderScope.containerOf(tester.element(find.byType(AdminShell)));

void main() {
  testWidgets('iPad: 縦のナビゲーション（下のタブなし）、ホームは右に運行モニタ', (tester) async {
    _ipad(tester);
    await tester.pumpWidget(_app(const AdminShell(userId: 'u-1', email: 'admin@ecomeal.jp'), FakeAdminTasksGateway()));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sideRail')), findsOneWidget);
    expect(find.byKey(const Key('pillTabBar')), findsNothing);
    expect(find.byType(AdminDashboardPage), findsOneWidget);
    // ダッシュボードの右の列（運行タブと同じデータ）
    expect(find.byType(AdminOperationsPage), findsOneWidget);
    await tester.tap(find.byKey(const Key('adminNavOperations')));
    await tester.pumpAndSettle();
    expect(_container(tester).read(adminTabProvider), AdminTab.operations);
  });

  testWidgets('iPad 対応: 一覧で選ぶと右の列に詳細（画面は切り替わらない）、承認したら選択が外れる', (tester) async {
    _ipad(tester);
    final tasks = FakeAdminTasksGateway(restaurants: [_restaurant()]);
    await tester.pumpWidget(_app(const AdminShell(userId: 'u-1', email: 'admin@ecomeal.jp'), tasks));
    await tester.pumpAndSettle();
    _container(tester).read(adminTaskProvider.notifier).state = AdminTask.restaurants;
    _container(tester).read(adminTabProvider.notifier).state = AdminTab.tasks;
    await tester.pumpAndSettle();
    expect(find.text(l10nJa.adminPickRestaurant), findsOneWidget);
    await tester.tap(find.byKey(const Key('adminRest-r-1')));
    await tester.pumpAndSettle();
    // 一覧（左）と詳細（右）が同時に見える
    expect(find.byType(AdminTasksPage), findsOneWidget);
    expect(find.byType(AdminRestaurantPage), findsOneWidget);
    expect(find.text(l10nJa.adminPickRestaurant), findsNothing);
    await tester.tap(find.byKey(const Key('adminRestApprove')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('adminRestApproveConfirm')));
    await tester.pumpAndSettle();
    expect(tasks.actions, ['approve:r-1']);
    expect(find.byType(AdminRestaurantPage), findsNothing);
    expect(find.byType(AdminTasksPage), findsOneWidget); // pop で一覧ごと閉じない
  });

  // Audit A02 (ghi chú Figma 972:22609): viết dở ở việc A → mở việc B → quay lại A thì chữ vẫn còn; lưu xong thì nháp mất
  testWidgets('iPad 問い合わせ: 書きかけのメモは別の件を開いて戻っても残る、保存したら消える', (tester) async {
    _ipad(tester);
    final a = _inquiry();
    final b = AdminInquiry(
      id: 'q-2', type: 'customer', name: '鈴木 花子', companyName: null, email: 'suzuki@example.jp', phone: null,
      message: 'アプリについて', status: 'new', adminNote: null, createdAt: DateTime.now(),
    );
    final tasks = FakeAdminTasksGateway(inquiries: [a, b]);
    await tester.pumpWidget(_app(const AdminShell(userId: 'u-1', email: 'admin@ecomeal.jp'), tasks));
    await tester.pumpAndSettle();
    _container(tester).read(adminTaskProvider.notifier).state = AdminTask.inquiries;
    _container(tester).read(adminTabProvider.notifier).state = AdminTab.tasks;
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('adminInq-q-1')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('adminInqNote')), '10/14 に電話する');
    await tester.tap(find.byKey(const Key('adminInqStatus-in_progress')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('adminInq-q-2')));
    await tester.pumpAndSettle();
    expect(find.text('10/14 に電話する'), findsNothing); // B は B の内容
    await tester.tap(find.byKey(const Key('adminInq-q-1')));
    await tester.pumpAndSettle();
    expect(find.text('10/14 に電話する'), findsOneWidget);
    expect(tester.widget<ChoiceChip>(find.byKey(const Key('adminInqStatus-in_progress'))).selected, isTrue);

    await tester.tap(find.byKey(const Key('adminInqSave')));
    await tester.pumpAndSettle();
    expect(_container(tester).read(adminDraftsProvider), isEmpty);
  });

  testWidgets('iPad 却下: 理由はダイアログ。送信に失敗したら画面内で知らせ、同じ理由でそのまま再送', (tester) async {
    _ipad(tester);
    final tasks = FakeAdminTasksGateway(restaurants: [_restaurant()])..writeError = Exception('offline');
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: AdminRestaurantPage(restaurant: _restaurant(), onClose: () {}),
        ),
        tasks,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('adminRestReject')));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget); // iPad はボトムシートではなく中央のダイアログ
    await tester.tap(find.byKey(const Key('adminRejectPreset-0')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('adminRejectSend')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('adminRestError')), findsOneWidget);
    expect(find.text(l10nJa.adminRestRejectErrorBody), findsOneWidget);
    expect(find.text(l10nJa.adminRestRetryReject), findsOneWidget);
    // 再送: 理由の入力をやり直さない
    tasks.writeError = null;
    await tester.tap(find.byKey(const Key('adminRestReject')));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(tasks.actions, ['reject:r-1:${l10nJa.adminRestReasonPl}']);
  });

  testWidgets('問い合わせ: 保存に失敗したら画面内で知らせ、状態とメモは残る', (tester) async {
    final tasks = FakeAdminTasksGateway()..writeError = Exception('offline');
    await tester.pumpWidget(_app(AdminInquiryPage(inquiry: _inquiry()), tasks));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('adminInqNote')), '10/14 に電話');
    await tester.tap(find.byKey(const Key('adminInqSave')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('adminInqError')), findsOneWidget);
    expect(find.text(l10nJa.adminInqRetrySave), findsOneWidget);
    expect(find.text('10/14 に電話'), findsOneWidget);
  });

  testWidgets('免許: 確認済みにできなかったら画面内で知らせ、有効期限は残る', (tester) async {
    // 一覧の最後（注記の下）に出る — 全体が入る高さで
    tester.view.physicalSize = const Size(1170, 4800);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final tasks = FakeAdminTasksGateway()..writeError = Exception('offline');
    await tester.pumpWidget(_app(AdminLicensePage(license: _license), tasks));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('adminLicVerify')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('adminLicVerifyConfirm')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('adminLicError')), findsOneWidget);
    expect(find.text(l10nJa.adminLicRetryVerify), findsOneWidget);
    expect(tasks.actions, isEmpty);
  });
}
