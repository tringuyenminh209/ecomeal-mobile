import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ecomeal_mobile/features/orders/order_gateway.dart';
import 'package:ecomeal_mobile/features/orders/order_history_page.dart';
import '../../helpers/test_app.dart';

class MockOrderGateway extends Mock implements OrderGateway {}

// id phải có dạng UUID thật: orderDisplayNumber()/pickupManualCode() đọc 4 ký tự hex cuối của orders.id.
// Id kiểu 'o-1' làm card ném RangeError/FormatException ngay lúc build (đã bắt được khi chạy thật).

void main() {
  late MockOrderGateway gateway;

  setUp(() {
    gateway = MockOrderGateway();
  });

  Future<void> pumpPage(WidgetTester tester, {Locale locale = const Locale('ja')}) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [orderGatewayProvider.overrideWithValue(gateway)],
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
          ),
          OrderSummary(
            id: '00000000-0000-0000-0000-00000000a002',
            status: 'picked_up',
            pricePaid: 620,
            createdAt: DateTime(2026, 9, 28, 10, 0),
            plannedPickupTime: DateTime(2026, 9, 28, 19, 40),
            stopName: '西成区民センター前',
          ),
        ]);
    await pumpPage(tester);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('orderCard_00000000-0000-0000-0000-00000000a001')), findsOneWidget);
    expect(find.byKey(const Key('orderCard_00000000-0000-0000-0000-00000000a002')), findsOneWidget);

    await tester.tap(find.text('予約中'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('orderCard_00000000-0000-0000-0000-00000000a001')), findsOneWidget);
    expect(find.byKey(const Key('orderCard_00000000-0000-0000-0000-00000000a002')), findsNothing);
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
    expect(find.text('受取予定の30分前を過ぎているため、キャンセルしても返金されません。'), findsOneWidget);

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
          ),
        ]);
    await pumpPage(tester);
    await tester.pumpAndSettle();

    expect(find.text('大阪学生寮前で1袋を確保しました。受け取り時はQRコードを提示し、読み取れない場合は下記コードを伝えてください。'), findsOneWidget);
    expect(find.text('手動入力：A7C2'), findsOneWidget);
    // Figma 78:192 không vẽ nút huỷ cho thẻ allocated, nhưng 06 (レビュー第25回) cho huỷ mọi đơn pending/allocated.
    await tester.ensureVisible(find.byKey(const Key('cancelOrderButton')));
    expect(find.byKey(const Key('cancelOrderButton')), findsOneWidget);
    expect(find.text('受取予定の30分前まで無料キャンセル'), findsOneWidget);
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
}
