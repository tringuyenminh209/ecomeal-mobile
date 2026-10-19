import 'package:flutter/semantics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ecomeal_mobile/features/home/batch_detail_page.dart';
import 'package:ecomeal_mobile/features/home/home_gateway.dart';
import 'package:ecomeal_mobile/features/orders/order_gateway.dart';
import 'package:ecomeal_mobile/features/orders/order_helpers.dart';
import 'package:ecomeal_mobile/features/orders/order_history_page.dart';
import 'package:ecomeal_mobile/features/orders/receipt_page.dart';
import 'package:ecomeal_mobile/features/profile/profile_gateway.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import '../../helpers/test_app.dart';

class MockOrderGateway extends Mock implements OrderGateway {}

class MockProfileGateway extends Mock implements ProfileGateway {}

class MockHomeGateway extends Mock implements HomeGateway {}

// id phải có dạng UUID thật: orderDisplayNumber()/pickupManualCode() đọc 4 ký tự hex cuối của orders.id.
// Id kiểu 'o-1' làm card ném RangeError/FormatException ngay lúc build (đã bắt được khi chạy thật).

void main() {
  late MockOrderGateway gateway;
  late MockProfileGateway profile;

  setUp(() {
    gateway = MockOrderGateway();
    profile = MockProfileGateway();
    when(() => profile.fetchMyProfile())
        .thenAnswer((_) async => const UserProfile(name: '春香 美香', nameKana: null, email: 'mika@example.jp'));
  });

  Future<void> pumpPage(WidgetTester tester, {Locale locale = const Locale('ja')}) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [orderGatewayProvider.overrideWithValue(gateway), profileGatewayProvider.overrideWithValue(profile)],
        child: testApp(const OrderHistoryPage(), locale: locale),
      ),
    );
  }

  testWidgets('Empty: chưa có đơn nào → hiện đúng câu hướng dẫn', (tester) async {
    when(() => gateway.fetchMyOrders()).thenAnswer((_) async => []);
    await pumpPage(tester);
    await tester.pumpAndSettle();

    expect(find.text('まだ予約がありません'), findsOneWidget);
  });

  testWidgets('có 2 đơn pending/picked_up → chip "予約中" chỉ lọc còn 1 đơn pending', (tester) async {
    when(() => gateway.fetchMyOrders()).thenAnswer((_) async => [
          OrderSummary(
            id: '00000000-0000-0000-0000-00000000a001',
            status: 'pending',
            pricePaid: 780,
            createdAt: DateTime(2026, 10, 2, 10, 0),
            plannedPickupTime: DateTime.now().add(const Duration(hours: 5)),
            stopName: '大阪学生寮前',
            taxRate: 8,
            taxAmount: 0,
          ),
          OrderSummary(
            id: '00000000-0000-0000-0000-00000000a002',
            status: 'picked_up',
            pricePaid: 620,
            createdAt: DateTime(2026, 9, 28, 10, 0),
            plannedPickupTime: DateTime(2026, 9, 28, 19, 40),
            stopName: '西成区民センター前',
            taxRate: 8,
            taxAmount: 0,
          ),
        ]);
    await pumpPage(tester);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('orderCard_00000000-0000-0000-0000-00000000a001')), findsOneWidget);
    expect(find.byKey(const Key('orderCard_00000000-0000-0000-0000-00000000a002')), findsOneWidget);

    await tester.tap(find.text('予約中'));
    await tester.pumpAndSettle();
    // nền xanh (viên thuốc) đã trượt sang chip 予約中
    expect(tester.getCenter(find.byKey(const Key('slidingPill'))).dx, closeTo(tester.getCenter(find.text('予約中')).dx, 1));

    expect(find.byKey(const Key('orderCard_00000000-0000-0000-0000-00000000a001')), findsOneWidget);
    expect(find.byKey(const Key('orderCard_00000000-0000-0000-0000-00000000a002')), findsNothing);
  });

  // Audit C06: trình đọc màn hình đọc được chip nào đang chọn
  testWidgets('chip lọc: trạng thái chọn có trong semantics, đổi theo lựa chọn', (tester) async {
    when(() => gateway.fetchMyOrders()).thenAnswer((_) async => []);
    final handle = tester.ensureSemantics();
    await pumpPage(tester);
    SemanticsNode chip(String label) => tester.getSemantics(find.ancestor(of: find.text(label), matching: find.byType(Semantics)).first);
    expect(chip('すべて').hasFlag(SemanticsFlag.isSelected), isTrue);
    expect(chip('予約中').hasFlag(SemanticsFlag.isSelected), isFalse);
    await tester.tap(find.text('予約中'));
    await tester.pumpAndSettle();
    expect(chip('すべて').hasFlag(SemanticsFlag.isSelected), isFalse);
    expect(chip('予約中').hasFlag(SemanticsFlag.isSelected), isTrue);
    handle.dispose();
  });

  testWidgets('đơn pending còn hơn 30 phút → có nút キャンセル; xác nhận dialog → gọi cancelOrder', (tester) async {
    when(() => gateway.fetchMyOrders()).thenAnswer((_) async => [
          OrderSummary(
            id: '00000000-0000-0000-0000-00000000a003',
            status: 'pending',
            pricePaid: 780,
            createdAt: DateTime.now(),
            plannedPickupTime: DateTime.now().add(const Duration(hours: 5)),
            stopName: '大阪学生寮前',
            taxRate: 8,
            taxAmount: 0,
          ),
        ]);
    when(() => gateway.cancelOrder('00000000-0000-0000-0000-00000000a003')).thenAnswer((_) async => const CancelOrderResult(orderId: '00000000-0000-0000-0000-00000000a003', refundAmount: 780));
    await pumpPage(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('cancelOrderButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmCancelButton')));
    await tester.pumpAndSettle();

    verify(() => gateway.cancelOrder('00000000-0000-0000-0000-00000000a003')).called(1);
  });

  testWidgets('BR-003: còn 10 phút (qua mốc 30 phút) → nút キャンセル VẪN hiện, dialog báo không hoàn tiền', (tester) async {
    when(() => gateway.fetchMyOrders()).thenAnswer((_) async => [
          OrderSummary(
            id: '00000000-0000-0000-0000-00000000a004',
            status: 'allocated',
            pricePaid: 780,
            createdAt: DateTime.now(),
            plannedPickupTime: DateTime.now().add(const Duration(minutes: 10)),
            stopName: '大阪学生寮前',
            taxRate: 8,
            taxAmount: 0,
          ),
        ]);
    when(() => gateway.cancelOrder('00000000-0000-0000-0000-00000000a004')).thenAnswer((_) async => const CancelOrderResult(orderId: '00000000-0000-0000-0000-00000000a004', refundAmount: 0));
    await pumpPage(tester);
    await tester.pumpAndSettle();

    // Card allocated có QR 160px → nút キャンセル nằm dưới khung 800×600 mặc định của widget test;
    // tap() vào widget ngoài màn hình sẽ trượt (chỉ in cảnh báo) → phải cuộn tới trước.
    await tester.ensureVisible(find.byKey(const Key('cancelOrderButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cancelOrderButton')));
    await tester.pumpAndSettle();
    expect(find.text(l10nJa.cancelDialogNoRefund), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirmCancelButton')));
    await tester.pumpAndSettle();

    verify(() => gateway.cancelOrder('00000000-0000-0000-0000-00000000a004')).called(1);
    expect(find.text('キャンセルしました（返金なし）'), findsOneWidget);
  });

  // REQ-015: nhãn trạng thái, chip lọc, nút và NGÀY đều theo locale (DateFormat của intl, không ghép "M月d日")
  testWidgets('allocated còn hơn 30 phút → khối QR + mã thủ công VÀ nút キャンセル cùng hiện (06 §SCR-M06)', (tester) async {
    when(() => gateway.fetchMyOrders()).thenAnswer((_) async => [
          OrderSummary(
            id: '00000000-0000-0000-0000-00000000a7c2',
            status: 'allocated',
            pricePaid: 780,
            createdAt: DateTime.now(),
            plannedPickupTime: DateTime.now().add(const Duration(hours: 5)),
            stopName: '大阪学生寮前',
            taxRate: 8,
            taxAmount: 0,
          ),
        ]);
    await pumpPage(tester);
    await tester.pumpAndSettle();

    expect(find.text(l10nJa.allocatedExplanation('大阪学生寮前')), findsOneWidget);
    // QR と手動入力コードは「受け取りの案内」（SCR-M18）に移した — 先にキャンセルの確認をしてから開く
    final open = find.byKey(const Key('openActiveOrder_00000000-0000-0000-0000-00000000a7c2'));
    expect(open, findsOneWidget);
    // Figma 78:192 không vẽ nút huỷ cho thẻ allocated, nhưng 06 (レビュー第25回) cho huỷ mọi đơn pending/allocated.
    await tester.ensureVisible(find.byKey(const Key('cancelOrderButton')));
    expect(find.byKey(const Key('cancelOrderButton')), findsOneWidget);
    expect(find.text(l10nJa.freeCancelTitle), findsOneWidget);
    await tester.ensureVisible(open);
    await tester.tap(open);
    await tester.pumpAndSettle();
    expect(find.text('手動入力：A7C2'), findsOneWidget);
    expect(find.text(l10nJa.activeOrderTitle), findsOneWidget);
  });

  testWidgets('locale en → nhãn tiếng Anh, ngày dạng "Sep 28 19:40" (giờ Tokyo)', (tester) async {
    when(() => gateway.fetchMyOrders()).thenAnswer((_) async => [
          OrderSummary(
            id: '00000000-0000-0000-0000-00000000a005',
            status: 'picked_up',
            pricePaid: 620,
            createdAt: DateTime.utc(2026, 9, 28, 1, 0),
            plannedPickupTime: DateTime.utc(2026, 9, 28, 10, 40), // = 19:40 JST
            stopName: '西成区民センター前',
            taxRate: 8,
            taxAmount: 0,
          ),
        ]);
    await pumpPage(tester, locale: const Locale('en'));
    await tester.pumpAndSettle();

    expect(find.text('Reservation history'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Picked up'), findsOneWidget);
    expect(find.text('Sep 28 19:40'), findsOneWidget);
    expect(find.text('受け取り済み'), findsNothing);
  });
  testWidgets('giá ghi 「税込」; chỉ đơn đã nhận có nút 領収書 → SCR-M13 với tiền thuế của đơn (0046)', (tester) async {
    when(() => gateway.fetchMyOrders()).thenAnswer((_) async => [
          OrderSummary(
            id: '00000000-0000-0000-0000-00000000b001',
            status: 'picked_up',
            pricePaid: 620,
            createdAt: DateTime.utc(2026, 9, 28, 1, 0),
            plannedPickupTime: DateTime.utc(2026, 9, 28, 10, 40), // 2026-09-28 19:40 JST
            stopName: '西成区民センター前',
            taxRate: 8,
            taxAmount: 45,
          ),
          OrderSummary(
            id: '00000000-0000-0000-0000-00000000b002',
            status: 'refunded',
            pricePaid: 840,
            createdAt: DateTime.utc(2026, 9, 17, 1, 0),
            plannedPickupTime: DateTime.utc(2026, 9, 17, 11, 20),
            stopName: '大阪学生寮前',
            taxRate: 8,
            taxAmount: 62,
          ),
        ]);
    await pumpPage(tester);
    await tester.pumpAndSettle();

    expect(find.text('¥620（税込）'), findsOneWidget);
    expect(find.text('¥840（税込）'), findsOneWidget);
    expect(find.byKey(const Key('receiptButton')), findsOneWidget); // đơn hoàn tiền không có biên lai

    await tester.tap(find.byKey(const Key('receiptButton')));
    await tester.pumpAndSettle();

    expect(find.byType(ReceiptPage), findsOneWidget);
    expect(find.text('春香 美香 様'), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('receiptAmount'))).data, '¥620（税込）');
    expect(tester.widget<Text>(find.byKey(const Key('receiptTax'))).data, '¥45');
    expect(find.text('8%対象（税込）'), findsOneWidget);
    expect(find.text('2026年9月28日'), findsOneWidget); // ご利用日 = ngày nhận theo giờ Tokyo
  });

  OrderSummary pickedUp({int? rating, Duration ago = const Duration(hours: 2)}) => OrderSummary(
        id: '00000000-0000-0000-0000-00000000b001',
        status: 'picked_up',
        pricePaid: 620,
        createdAt: DateTime.now().subtract(ago),
        plannedPickupTime: DateTime.now().subtract(ago),
        stopName: '大阪学生寮前',
        taxRate: 8,
        taxAmount: 46,
        rating: rating,
      );

  testWidgets('0054: đơn đã nhận chưa đánh giá → chạm ★4 → bảng → gửi kèm câu → tải lại, thẻ hiện 「あなたの評価」', (tester) async {
    var rated = false;
    when(() => gateway.fetchMyOrders()).thenAnswer((_) async => [pickedUp(rating: rated ? 4 : null)]);
    when(() => gateway.rateOrder(orderId: any(named: 'orderId'), rating: any(named: 'rating'), comment: any(named: 'comment')))
        .thenAnswer((_) async => rated = true);
    await pumpPage(tester);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ratingPrompt')), findsOneWidget);
    await tester.tap(find.byKey(const Key('ratingStar4')));
    await tester.pumpAndSettle();
    expect(find.text('満足'), findsOneWidget); // bảng mở với 4 sao đã chọn

    await tester.enterText(find.byKey(const Key('ratingComment')), '  温かかったです ');
    await tester.tap(find.byKey(const Key('submitRatingButton')));
    await tester.pumpAndSettle();

    verify(() => gateway.rateOrder(orderId: '00000000-0000-0000-0000-00000000b001', rating: 4, comment: '温かかったです')).called(1);
    expect(find.text('評価を送信しました。ありがとうございました'), findsOneWidget);
    expect(find.byKey(const Key('ratedNote')), findsOneWidget);
    expect(find.byKey(const Key('ratingPrompt')), findsNothing);
  });

  testWidgets('0054: quá 7 ngày → không mời; server báo E-RATING-410 → câu lỗi trong bảng', (tester) async {
    when(() => gateway.fetchMyOrders()).thenAnswer((_) async => [pickedUp(ago: const Duration(days: 8))]);
    await pumpPage(tester);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ratingPrompt')), findsNothing);

    when(() => gateway.fetchMyOrders()).thenAnswer((_) async => [pickedUp()]);
    when(() => gateway.rateOrder(orderId: any(named: 'orderId'), rating: any(named: 'rating'), comment: any(named: 'comment')))
        .thenThrow(const PostgrestException(message: 'E-RATING-410: rating period has ended'));
    await tester.pumpWidget(const SizedBox()); // bỏ ProviderScope cũ để đọc lại danh sách
    await pumpPage(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ratingStar2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('submitRatingButton')));
    await tester.pumpAndSettle();
    expect(find.text('受け取りから7日を過ぎたため評価できません'), findsOneWidget);
  });

  testWidgets('2026-10-15: chạm thẻ đơn → chi tiết túi đã đặt (số đơn, số đã trả, không có nút 予約する)', (tester) async {
    final home = MockHomeGateway();
    when(() => home.fetchBatchDetail('batch-1')).thenAnswer((_) async => BatchDetail(
          batchId: 'batch-1',
          unitPrice: 5000,
          expiresAt: DateTime.now().add(const Duration(hours: 6)),
          allergens: const [],
          ingredients: const [],
        ));
    when(() => gateway.fetchMyOrders()).thenAnswer((_) async => [
          OrderSummary(
            id: '00000000-0000-0000-0000-000000002146',
            status: 'pending',
            pricePaid: 3500,
            createdAt: DateTime(2026, 10, 15, 10, 0),
            plannedPickupTime: DateTime.now().add(const Duration(hours: 7)),
            stopName: '大阪駅 南口広場',
            taxRate: 8,
            taxAmount: 259,
            surplusBatchId: 'batch-1',
            pickupRouteStopId: 'rs-1',
          ),
        ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        orderGatewayProvider.overrideWithValue(gateway),
        profileGatewayProvider.overrideWithValue(profile),
        homeGatewayProvider.overrideWithValue(home),
      ],
      child: testApp(const OrderHistoryPage()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10nJa.mysteryBag)); // chỗ trống của thẻ (không phải nút)
    await tester.pumpAndSettle();

    final page = tester.widget<BatchDetailPage>(find.byType(BatchDetailPage));
    expect(page.batchId, 'batch-1');
    expect(page.routeStopId, 'rs-1');
    expect(page.reserved, (orderNumber: orderDisplayNumber('00000000-0000-0000-0000-000000002146'), pricePaid: 3500));
    expect(find.byKey(const Key('reserveButton')), findsNothing);
    expect(find.byKey(const Key('reservedNote')), findsOneWidget);
  });
}
