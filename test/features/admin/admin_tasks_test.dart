import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:ecomeal_mobile/features/admin/admin_dashboard_page.dart' show AdminTask;
import 'package:ecomeal_mobile/features/admin/admin_gateway.dart';
import 'package:ecomeal_mobile/features/admin/admin_inquiry_page.dart';
import 'package:ecomeal_mobile/features/admin/admin_issue_page.dart';
import 'package:ecomeal_mobile/features/admin/admin_license_page.dart';
import 'package:ecomeal_mobile/features/admin/admin_restaurant_page.dart';
import 'package:ecomeal_mobile/features/admin/admin_tasks_gateway.dart';
import 'package:ecomeal_mobile/features/admin/admin_tasks_page.dart';
import 'package:ecomeal_mobile/features/store/store_gateway.dart';
import '../../helpers/fake_admin_gateway.dart';
import '../../helpers/fake_admin_tasks_gateway.dart';
import '../../helpers/fake_store_gateway.dart';
import '../../helpers/test_app.dart';

AdminIssue _issue({bool open = true}) => AdminIssue(
      id: 'i-1',
      orderId: '00000000-0000-0000-0000-0000000007eb',
      category: 'quality',
      message: 'パンの一部にカビがありました。',
      isOpen: open,
      refundAmount: open ? null : 300,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      pricePaid: 620,
      refundable: 620,
      plannedTime: DateTime.utc(2026, 10, 10, 10, 52),
      restaurantName: 'ベーカリー ナミ',
      stopName: '梅田駅前',
      customerName: '田中 優',
    );

AdminRestaurant _restaurant({bool pending = true}) => AdminRestaurant(
      id: 'r-1',
      name: 'Nami Bakery',
      nameKana: 'ナミ ベーカリー',
      address: '大阪市中央区南船場2-4-1',
      contact: '06-1234-5678',
      closingTime: '20:00:00',
      plDocPath: 'r-1/pl.pdf',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isApproved: !pending,
      rejectedAt: null,
      rejectionReason: null,
      applicantName: '並木 七海',
    );

final _license = AdminLicense(
  driverId: 'd-1',
  name: '佐藤 健太',
  status: 'submitted',
  expiresOn: null,
  submittedAt: DateTime.now().subtract(const Duration(days: 1)),
  imagePath: 'd-1/license.jpg',
);

AdminInquiry _inquiry(String status) => AdminInquiry(
      id: 'q-$status',
      type: 'restaurant',
      name: '山田 太郎',
      companyName: '和食処 みなと',
      email: 'yamada@example.jp',
      phone: null,
      message: '余った料理の活用を検討しています。',
      status: status,
      adminNote: null,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    );

// Trang dựng đủ một lần (ListView không tạo phần ngoài màn hình)
void _tall(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 4800);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Widget _app(Widget home, FakeAdminTasksGateway tasks, {FakeStoreGateway? store}) => ProviderScope(
      overrides: [
        storeGatewayProvider.overrideWithValue(store ?? FakeStoreGateway()),
        adminTasksGatewayProvider.overrideWithValue(tasks),
        adminGatewayProvider.overrideWithValue(FakeAdminGateway(state: const AdminMfaOk())),
      ],
      child: testApp(home),
    );

// Mở trang chi tiết từ 1 trang có Navigator (để pop được)
Widget _launcher(Widget page) => Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page)),
            child: const Text('OPEN'),
          ),
        ),
      ),
    );

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('OPEN'));
  await tester.pumpAndSettle();
}

void main() {
  group('logic', () {
    test('parseRefund: 0〜返金可能額の整数だけ', () {
      expect(parseRefund('620', 620), 620);
      expect(parseRefund('0', 620), 0);
      expect(parseRefund('621', 620), isNull);
      expect(parseRefund('-1', 620), isNull);
      expect(parseRefund('', 620), isNull);
    });

    test('plDocPathFromUrl: pl_docs のパスを取り出す', () {
      expect(plDocPathFromUrl('https://x.supabase.co/storage/v1/object/pl_docs/r-1/pl.pdf'), 'r-1/pl.pdf');
      expect(plDocPathFromUrl('https://x/other.pdf'), isNull);
      expect(plDocPathFromUrl(null), isNull);
    });
  });

  group('SCR-A04 問題報告の対応', () {
    testWidgets('¥0 にするとボタンが「対応済みにする」、案内も返金なしに', (tester) async {
      await tester.pumpWidget(_app(AdminIssuePage(issue: _issue()), FakeAdminTasksGateway()));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.adminIssueSubmitRefund), findsOneWidget);
      await tester.enterText(find.byKey(const Key('adminIssueAmount')), '0');
      await tester.pump();
      expect(find.text(l10nJa.adminIssueSubmitNoRefund), findsOneWidget);
      expect(find.text(l10nJa.adminIssueNoRefundHint), findsOneWidget);
    });

    testWidgets('返金可能額を超える／回答が空 → 送らない', (tester) async {
      final tasks = FakeAdminTasksGateway();
      await tester.pumpWidget(_app(AdminIssuePage(issue: _issue()), tasks));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('adminIssueAmount')), '700');
      await tester.tap(find.byKey(const Key('adminIssueSubmit')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.adminIssueErrAmount('¥620')), findsOneWidget);
      expect(find.text(l10nJa.adminIssueErrAnswer), findsOneWidget);
      expect(tasks.actions, isEmpty);
    });

    testWidgets('送信に失敗 → エラーを出し、返金額と回答は残す、ボタンは「もう一度送信する」', (tester) async {
      _tall(tester);
      final tasks = FakeAdminTasksGateway()..writeError = Exception('network');
      await tester.pumpWidget(_app(AdminIssuePage(issue: _issue()), tasks));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('adminIssueAnswer')), '申し訳ありません');
      await tester.tap(find.byKey(const Key('adminIssueSubmit')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('adminIssueConfirm')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('adminIssueError')), findsOneWidget);
      // Audit A03: mất mạng = không biết server đã xử lý chưa → không được nói 「返金はまだ行われていません」
      expect(find.text(l10nJa.adminIssueUnknownTitle), findsOneWidget);
      expect(find.text(l10nJa.adminIssueUnknownBody), findsOneWidget);
      expect(find.text(l10nJa.adminIssueErrorBody), findsNothing);
      expect(find.text(l10nJa.adminIssueRetry), findsOneWidget);
      expect(tester.widget<TextField>(find.byKey(const Key('adminIssueAnswer'))).controller!.text, '申し訳ありません');
      expect(tester.widget<TextField>(find.byKey(const Key('adminIssueAmount'))).controller!.text, '620');
    });

    testWidgets('サーバーが受け付けなかった（エラーコードあり）→「返金はまだ行われていません」', (tester) async {
      _tall(tester);
      final tasks = FakeAdminTasksGateway()..writeError = const PostgrestException(message: 'E-ISSUE-422: refund exceeds refundable amount');
      await tester.pumpWidget(_app(AdminIssuePage(issue: _issue()), tasks));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('adminIssueAnswer')), '回答');
      await tester.tap(find.byKey(const Key('adminIssueSubmit')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('adminIssueConfirm')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.adminIssueErrorTitle), findsOneWidget);
      expect(find.text(l10nJa.adminIssueErrorBody), findsOneWidget);
      expect(find.text(l10nJa.adminIssueUnknownTitle), findsNothing);
    });

    // Audit A01 (2026-10-19): xác nhận gắn với NỘI DUNG đã xác nhận, không phải với việc "lần trước bị lỗi"
    testWidgets('送信エラー後に金額を変えたら、新しい金額でもう一度確認する', (tester) async {
      _tall(tester);
      final tasks = FakeAdminTasksGateway()..writeError = Exception('network');
      await tester.pumpWidget(_app(AdminIssuePage(issue: _issue()), tasks));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('adminIssueAmount')), '0');
      await tester.enterText(find.byKey(const Key('adminIssueAnswer')), '対象外です');
      await tester.tap(find.byKey(const Key('adminIssueSubmit')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('adminIssueConfirm')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('adminIssueError')), findsOneWidget);

      tasks.writeError = null;
      await tester.enterText(find.byKey(const Key('adminIssueAmount')), '620');
      await tester.tap(find.byKey(const Key('adminIssueSubmit')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.adminIssueConfirmRefundTitle('¥620')), findsOneWidget);
      expect(tasks.actions, isEmpty);
      await tester.tap(find.byKey(const Key('adminIssueConfirm')));
      await tester.pumpAndSettle();
      expect(tasks.actions, ['resolve:i-1:620:対象外です']);
    });

    testWidgets('送信エラー後、内容を変えずに「もう一度送信する」なら確認を繰り返さない', (tester) async {
      _tall(tester);
      final tasks = FakeAdminTasksGateway()..writeError = Exception('network');
      await tester.pumpWidget(_app(AdminIssuePage(issue: _issue()), tasks));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('adminIssueAnswer')), '返金します');
      await tester.tap(find.byKey(const Key('adminIssueSubmit')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('adminIssueConfirm')));
      await tester.pumpAndSettle();

      tasks.writeError = null;
      await tester.tap(find.byKey(const Key('adminIssueSubmit')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('adminIssueConfirm')), findsNothing);
      expect(tasks.actions, ['resolve:i-1:620:返金します']);
    });

    testWidgets('返金: 金額・注文・店舗を出して確認し、戻るなら送らない', (tester) async {
      _tall(tester);
      final tasks = FakeAdminTasksGateway();
      await tester.pumpWidget(_app(AdminIssuePage(issue: _issue()), tasks));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('adminIssueAnswer')), '全額を返金しました');
      await tester.tap(find.byKey(const Key('adminIssueSubmit')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.adminIssueConfirmRefundTitle('¥620')), findsOneWidget);
      expect(find.textContaining('ベーカリー ナミ'), findsWidgets);
      await tester.tap(find.text(l10nJa.back));
      await tester.pumpAndSettle();
      expect(tasks.actions, isEmpty);
    });

    testWidgets('送信できたら閉じる', (tester) async {
      final tasks = FakeAdminTasksGateway();
      await tester.pumpWidget(_app(_launcher(AdminIssuePage(issue: _issue())), tasks));
      await _open(tester);
      await tester.enterText(find.byKey(const Key('adminIssueAmount')), '0');
      await tester.enterText(find.byKey(const Key('adminIssueAnswer')), '対象外です');
      await tester.tap(find.byKey(const Key('adminIssueSubmit')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.adminIssueConfirmNoRefundTitle), findsOneWidget);
      await tester.tap(find.byKey(const Key('adminIssueConfirm')));
      await tester.pumpAndSettle();
      expect(tasks.actions, ['resolve:i-1:0:対象外です']);
      expect(find.byType(AdminIssuePage), findsNothing);
    });

    testWidgets('他の人が先に対応済み（E-ISSUE-409）→ 知らせて閉じる', (tester) async {
      final tasks = FakeAdminTasksGateway()..writeError = const PostgrestException(message: 'E-ISSUE-409: already resolved');
      await tester.pumpWidget(_app(_launcher(AdminIssuePage(issue: _issue())), tasks));
      await _open(tester);
      await tester.enterText(find.byKey(const Key('adminIssueAnswer')), '回答');
      await tester.tap(find.byKey(const Key('adminIssueSubmit')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('adminIssueConfirm')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.adminIssueErrAlready), findsOneWidget);
      expect(find.byType(AdminIssuePage), findsNothing);
    });
  });

  group('SCR-A03 飲食店の審査', () {
    testWidgets('却下: 理由のテンプレートを選んで通知、理由は必須', (tester) async {
      final tasks = FakeAdminTasksGateway();
      await tester.pumpWidget(_app(_launcher(AdminRestaurantPage(restaurant: _restaurant())), tasks));
      await _open(tester);
      expect(find.text('Nami Bakery（ナミ ベーカリー）'), findsOneWidget);
      expect(find.text('並木 七海'), findsOneWidget);
      await tester.tap(find.byKey(const Key('adminRestReject')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('adminRejectSend')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.adminRestErrReason), findsOneWidget);
      await tester.tap(find.byKey(const Key('adminRejectPreset-0')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('adminRejectSend')));
      await tester.pumpAndSettle();
      expect(tasks.actions, ['reject:r-1:${l10nJa.adminRestReasonPl}']);
      expect(find.byType(AdminRestaurantPage), findsNothing);
    });

    testWidgets('承認: メールが送れなくても審査は確定、その旨を知らせる', (tester) async {
      final tasks = FakeAdminTasksGateway()..notifyOk = false;
      await tester.pumpWidget(_app(_launcher(AdminRestaurantPage(restaurant: _restaurant())), tasks));
      await _open(tester);
      await tester.tap(find.byKey(const Key('adminRestApprove')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.adminRestApproveConfirmTitle('Nami Bakery')), findsOneWidget);
      await tester.tap(find.byKey(const Key('adminRestApproveConfirm')));
      await tester.pumpAndSettle();
      expect(tasks.actions, ['approve:r-1']);
      expect(find.text(l10nJa.adminRestNotifyFailed), findsOneWidget);
    });

    testWidgets('承認: 確認で戻ったら承認しない', (tester) async {
      final tasks = FakeAdminTasksGateway();
      await tester.pumpWidget(_app(AdminRestaurantPage(restaurant: _restaurant()), tasks));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('adminRestApprove')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10nJa.back));
      await tester.pumpAndSettle();
      expect(tasks.actions, isEmpty);
    });

    testWidgets('担当者のメール・今月の売上・評価・最近の出品・精算を出す（承認済み）', (tester) async {
      _tall(tester);
      final opened = <String>[];
      final tasks = FakeAdminTasksGateway(
        members: [
          AdminRestaurantMember(userId: 'u-1', name: '並木 七海', email: 'owner@nami.jp', isOwner: true, createdAt: DateTime(2026, 10, 1)),
        ],
        batches: [
          AdminBatch(id: 'b-1', isConfirmed: true, quantity: 6, unitPrice: 450, sellByAt: DateTime.utc(2026, 10, 12, 11)),
        ],
      );
      final store = FakeStoreGateway(settlements: [
        StoreSettlement(id: 's-0001', periodMonth: '2026-09-01', orders: 30, sales: 12000, payout: 3000,
            confirmedAt: DateTime(2026, 10, 2), paidAt: DateTime(2026, 10, 5)),
      ]);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          storeGatewayProvider.overrideWithValue(store),
          adminTasksGatewayProvider.overrideWithValue(tasks),
          adminGatewayProvider.overrideWithValue(FakeAdminGateway(state: const AdminMfaOk())),
          openExternalUrlProvider.overrideWithValue((url) async {
            opened.add(url);
            return true;
          }),
        ],
        child: testApp(AdminRestaurantPage(restaurant: _restaurant(pending: false))),
      ));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.adminRestOwner), findsOneWidget);
      await tester.tap(find.text('owner@nami.jp'));
      expect(opened, ['mailto:owner@nami.jp']);
      // FakeStoreGateway: 売上 ¥53,320・還元額 ¥10,664・86食・還元率 20%、評価 4.3（28件）
      expect(find.text('¥53,320'), findsOneWidget);
      expect(find.text(l10nJa.adminRestSharePct('20')), findsOneWidget);
      expect(find.text(l10nJa.adminRestRatingsValue('4.3', 28)), findsOneWidget);
      expect(find.text(l10nJa.adminRestBatchLine(6, '¥450')), findsOneWidget);
      expect(find.text('¥3,000'), findsOneWidget);
      expect(find.text(l10nJa.storeSettlementPaid), findsOneWidget);
    });

    testWidgets('審査待ちの店舗は担当者だけ出し、売上などは出さない', (tester) async {
      _tall(tester);
      final tasks = FakeAdminTasksGateway(members: [
        AdminRestaurantMember(userId: 'u-1', name: '並木 七海', email: 'owner@nami.jp', isOwner: true, createdAt: DateTime(2026, 10, 1)),
      ]);
      await tester.pumpWidget(_app(AdminRestaurantPage(restaurant: _restaurant()), tasks));
      await tester.pumpAndSettle();
      expect(find.text('owner@nami.jp'), findsOneWidget);
      expect(find.text(l10nJa.adminRestMonth), findsNothing);
      expect(find.text(l10nJa.adminRestSettlements), findsNothing);
    });

    testWidgets('承認済みの店舗にはボタンを出さない', (tester) async {
      await tester.pumpWidget(_app(AdminRestaurantPage(restaurant: _restaurant(pending: false)), FakeAdminTasksGateway()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('adminRestApprove')), findsNothing);
    });
  });

  group('SCR-A05 免許の確認', () {
    testWidgets('有効期限を入れないと確認済みにできない、画像が読めなくても落ちない', (tester) async {
      _tall(tester);
      final tasks = FakeAdminTasksGateway();
      await tester.pumpWidget(_app(AdminLicensePage(license: _license), tasks));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.adminLicImageFailed), findsOneWidget);
      expect(find.text('なにわ 400 さ 12-34'), findsOneWidget);
      await tester.tap(find.byKey(const Key('adminLicVerify')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.adminLicErrExpiry), findsOneWidget);
      expect(tasks.actions, isEmpty);
    });

    testWidgets('差し戻し: 理由を入れて送る', (tester) async {
      final tasks = FakeAdminTasksGateway();
      await tester.pumpWidget(_app(_launcher(AdminLicensePage(license: _license)), tasks));
      await _open(tester);
      await tester.tap(find.byKey(const Key('adminLicReject')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('adminRejectReason')), '画像がぼやけています');
      await tester.tap(find.byKey(const Key('adminRejectSend')));
      await tester.pumpAndSettle();
      expect(tasks.actions, ['reject:d-1:画像がぼやけています']);
    });
  });

  group('SCR-A06 問い合わせ', () {
    testWidgets('状態とメモを保存', (tester) async {
      final tasks = FakeAdminTasksGateway();
      await tester.pumpWidget(_app(_launcher(AdminInquiryPage(inquiry: _inquiry('new'))), tasks));
      await _open(tester);
      await tester.tap(find.byKey(const Key('adminInqStatus-in_progress')));
      await tester.enterText(find.byKey(const Key('adminInqNote')), '電話で説明済み');
      await tester.tap(find.byKey(const Key('adminInqSave')));
      await tester.pumpAndSettle();
      expect(tasks.actions, ['inquiry:q-new:in_progress:電話で説明済み']);
      expect(find.byType(AdminInquiryPage), findsNothing);
    });
  });

  group('対応タブ', () {
    testWidgets('項目を切り替えると一覧が変わる、承認待ちだけ／新着だけを表示', (tester) async {
      var task = AdminTask.issues;
      final tasks = FakeAdminTasksGateway(
        issues: [_issue(), _issue(open: false)],
        restaurants: [_restaurant(), _restaurant(pending: false)],
        inquiries: [_inquiry('new'), _inquiry('done')],
      );
      await tester.pumpWidget(_app(
        StatefulBuilder(
          builder: (context, setState) => Scaffold(body: AdminTasksPage(task: task, onSelect: (t) => setState(() => task = t))),
        ),
        tasks,
      ));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.adminIssueOpen), findsOneWidget);
      expect(find.text(l10nJa.adminIssueRefunded('¥300')), findsOneWidget);

      await tester.tap(find.byKey(const Key('adminSeg-restaurants')));
      await tester.pumpAndSettle();
      expect(find.text('Nami Bakery'), findsOneWidget); // 承認待ちの1件だけ（承認済みは隠れる）

      await tester.tap(find.byKey(const Key('adminSeg-inquiries')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('adminInq-q-new')), findsOneWidget);
      expect(find.byKey(const Key('adminInq-q-done')), findsNothing);
    });
  });

  group('運行の連絡（SCR-D06 → 0067）', () {
    AdminDriverReport report({bool open = true}) => AdminDriverReport(
          id: open ? 'dr-1' : 'dr-2',
          category: open ? 'delay' : 'vehicle',
          delayMinutes: open ? 20 : null,
          message: open ? '渋滞で中之島公園の出発が遅れています' : null,
          isOpen: open,
          resolution: open ? null : '代わりの車両を手配',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          plateNumber: '大阪 500 あ 12-34',
          driverName: '佐藤 健太',
          nextStopName: open ? '大阪学生寮前' : null,
        );
    Widget page(FakeAdminTasksGateway tasks) =>
        _app(Scaffold(body: AdminTasksPage(task: AdminTask.driverReports, onSelect: (_) {})), tasks);

    testWidgets('一覧（種類・遅れの分数・次の停車）→ タップで対応内容を書いて対応済み', (tester) async {
      final tasks = FakeAdminTasksGateway(driverReports: [report(), report(open: false)]);
      await tester.pumpWidget(page(tasks));
      await tester.pumpAndSettle();
      expect(find.text('${l10nJa.driverReportDelay}・${l10nJa.driverReportMinutes(20)}'), findsOneWidget);
      expect(find.text('渋滞で中之島公園の出発が遅れています'), findsOneWidget);
      expect(find.textContaining('大阪学生寮前'), findsOneWidget);
      expect(find.text('代わりの車両を手配'), findsOneWidget); // 対応済みは対応内容を表示
      expect(find.textContaining(l10nJa.adminDriverReportNoStop), findsOneWidget);
      await tester.tap(find.byKey(const Key('adminDriverReport-dr-1')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.adminDriverReportResolveNote), findsOneWidget);
      await tester.enterText(find.byKey(const Key('adminRejectReason')), '20:10 受取のお客様へ遅れを連絡');
      await tester.tap(find.byKey(const Key('adminRejectSend')));
      await tester.pumpAndSettle();
      expect(tasks.actions, ['driverReport:dr-1:20:10 受取のお客様へ遅れを連絡']);
      expect(find.text(l10nJa.adminDriverReportDone), findsOneWidget);
    });

    testWidgets('ほかの運営が先に対応済み（E-REPORT-409）→ その旨を表示', (tester) async {
      final tasks = FakeAdminTasksGateway(driverReports: [report()])
        ..writeError = const PostgrestException(message: 'E-REPORT-409: already resolved');
      await tester.pumpWidget(page(tasks));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('adminDriverReport-dr-1')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('adminRejectReason')), '対応しました');
      await tester.tap(find.byKey(const Key('adminRejectSend')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.adminDriverReportAlready), findsOneWidget);
    });
  });
}
