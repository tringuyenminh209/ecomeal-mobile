import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:ecomeal_mobile/features/home/home_gateway.dart';
import 'package:ecomeal_mobile/features/orders/order_gateway.dart';
import 'package:ecomeal_mobile/features/orders/reservation_confirm_page.dart';
import 'package:ecomeal_mobile/features/payment/card_input.dart';
import 'package:ecomeal_mobile/features/payment/payment_gateway.dart';
import 'package:ecomeal_mobile/widgets/customer_shell.dart';
import 'package:ecomeal_mobile/features/coupons/coupons.dart';
import '../../helpers/fake_coupons.dart';
import '../../helpers/fake_payment_gateway.dart';
import '../../helpers/test_app.dart';

class MockHomeGateway extends Mock implements HomeGateway {}

class MockOrderGateway extends Mock implements OrderGateway {}

void main() {
  late MockHomeGateway homeGateway;
  late MockOrderGateway orderGateway;
  late FakePaymentGateway paymentGateway;
  late FakeCouponsGateway couponsGateway;

  final visa = FakePaymentGateway.card('pm-visa', CardBrand.visa, '3456', isDefault: true);
  final jcb = FakePaymentGateway.card('pm-jcb', CardBrand.jcb, '1188');

  void stubCreateOrder(Future<CreateOrderResult> Function() answer) {
    when(() => orderGateway.createOrder(
          surplusBatchId: any(named: 'surplusBatchId'),
          pickupRouteStopId: any(named: 'pickupRouteStopId'),
          paymentMethodId: any(named: 'paymentMethodId'),
          idempotencyKey: any(named: 'idempotencyKey'),
        )).thenAnswer((_) => answer());
  }

  setUp(() {
    homeGateway = MockHomeGateway();
    orderGateway = MockOrderGateway();
    paymentGateway = FakePaymentGateway([visa, jcb]);
    couponsGateway = FakeCouponsGateway();
    when(() => homeGateway.calcCurrentPrice(unitPrice: any(named: 'unitPrice'), expiresAt: any(named: 'expiresAt')))
        .thenAnswer((_) async => const CurrentPriceResult(currentPrice: 650, tier: '50%', minutesRemaining: 42));
  });

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeGatewayProvider.overrideWithValue(homeGateway),
          orderGatewayProvider.overrideWithValue(orderGateway),
          paymentGatewayProvider.overrideWithValue(paymentGateway),
          couponsGatewayProvider.overrideWithValue(couponsGateway),
        ],
        child: testApp(
          ReservationConfirmPage(
            batchId: 'b-1',
            routeStopId: 'rs-1',
            stopName: '大阪学生寮前',
            plannedPickupTime: DateTime.utc(2026, 10, 2, 11, 10), // = 20:10 JST
            unitPrice: 1300,
            expiresAt: DateTime.now().add(const Duration(hours: 1)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  FilledButton payButton(WidgetTester tester) => tester.widget<FilledButton>(find.byKey(const Key('confirmReservationButton')));

  testWidgets('支払い方法選択済み (Figma 378:82): thẻ mặc định + 「¥650を支払って予約する」', (tester) async {
    await pumpPage(tester);

    expect(find.text('大阪学生寮前・20:10–20:30'), findsOneWidget);
    expect(find.text('Visa •••• 3456'), findsOneWidget);
    expect(find.text('デフォルトカード'), findsOneWidget);
    expect(find.text('予約を確定すると、¥650が決済されます。'), findsOneWidget);
    expect(find.text('¥650を支払って予約する'), findsOneWidget);
    // Figma 432:1022: 合計は税込、うち消費税（8%）¥48
    expect(find.text('合計（税込・数量 1）'), findsOneWidget);
    expect(find.text('うち消費税（8%）'), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('taxAmount'))).data, '¥48');
    expect(find.text('受取予定の30分前まで無料キャンセル'), findsOneWidget); // BR-003 vẫn hiện
    expect(payButton(tester).onPressed, isNotNull);
  });

  testWidgets('支払い方法なし (16:16527): nút bị khoá; thêm thẻ xong → chọn luôn thẻ đó', (tester) async {
    paymentGateway.methods = [];
    await pumpPage(tester);

    expect(find.text('支払い方法（必須）'), findsOneWidget);
    expect(find.text('支払い方法を追加すると、予約を確定できます。'), findsOneWidget);
    expect(find.text('支払い方法を追加してください'), findsOneWidget);
    expect(payButton(tester).onPressed, isNull);

    await tester.tap(find.byKey(const Key('addPaymentMethodRow')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('cardNumberField')), '4242424242424242');
    await tester.enterText(find.byKey(const Key('cardHolderField')), 'MIKA HARUKA');
    await tester.enterText(find.byKey(const Key('cardExpiryField')), '1230');
    await tester.enterText(find.byKey(const Key('cardCvcField')), '123');
    await tester.tap(find.byKey(const Key('addCardSubmitButton')));
    await tester.pumpAndSettle();

    expect(find.text('Visa •••• 4242'), findsOneWidget);
    expect(payButton(tester).onPressed, isNotNull);
  });

  testWidgets('trả thành công → 完了 (389:935) → 「予約内容を確認」 sang tab 予約', (tester) async {
    final paid = Completer<CreateOrderResult>();
    stubCreateOrder(() => paid.future);
    await pumpPage(tester);
    final container = ProviderScope.containerOf(tester.element(find.byType(ReservationConfirmPage)));
    final tab = container.listen(customerTabProvider, (_, __) {});

    await tester.tap(find.byKey(const Key('confirmReservationButton')));
    await tester.pump();
    // 処理中 (389:913)
    expect(find.text('お支払いを処理しています'), findsOneWidget);
    expect(find.text('¥650（税込）  ·  Visa •••• 3456'), findsOneWidget);

    paid.complete(const CreateOrderResult(orderId: 'o-1', status: 'allocated', pricePaid: 650));
    await tester.pumpAndSettle();
    expect(find.text('お支払いが完了しました'), findsOneWidget);
    expect(find.text('予約完了'), findsOneWidget);

    await tester.tap(find.byKey(const Key('viewReservationButton')));
    await tester.pumpAndSettle();
    expect(tab.read(), CustomerTab.orders);
  });

  testWidgets('cùng 1 lần mở màn → mọi lần bấm trả gửi CÙNG idempotency key', (tester) async {
    stubCreateOrder(() async => throw PostgrestException(message: 'E-PAY-402: card declined'));
    await pumpPage(tester);

    await tester.tap(find.byKey(const Key('confirmReservationButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('backToReviewButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmReservationButton')));
    await tester.pumpAndSettle();

    final keys = verify(() => orderGateway.createOrder(
          surplusBatchId: 'b-1',
          pickupRouteStopId: 'rs-1',
          paymentMethodId: 'pm-visa',
          idempotencyKey: captureAny(named: 'idempotencyKey'),
        )).captured;
    expect(keys, hasLength(2));
    expect(keys[0], keys[1]);
  });

  testWidgets('E-PAY-402 → カード拒否 (389:959) → 「別のカードで支払う」 chọn JCB → trả bằng JCB', (tester) async {
    stubCreateOrder(() async => throw PostgrestException(message: 'E-PAY-402: card declined'));
    await pumpPage(tester);

    await tester.tap(find.byKey(const Key('confirmReservationButton')));
    await tester.pumpAndSettle();
    expect(find.text('お支払いできませんでした'), findsOneWidget);
    expect(find.text('この支払いは完了していません。\n予約はまだ確定していません。'), findsOneWidget);

    await tester.tap(find.byKey(const Key('payWithAnotherCardButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('paymentMethod-pm-jcb')));
    await tester.pumpAndSettle();

    expect(find.text('JCB •••• 1188'), findsOneWidget);
    stubCreateOrder(() async => const CreateOrderResult(orderId: 'o-2', status: 'pending', pricePaid: 650));
    await tester.tap(find.byKey(const Key('confirmReservationButton')));
    await tester.pumpAndSettle();
    verify(() => orderGateway.createOrder(
          surplusBatchId: 'b-1',
          pickupRouteStopId: 'rs-1',
          paymentMethodId: 'pm-jcb',
          idempotencyKey: any(named: 'idempotencyKey'),
        )).called(1);
    expect(find.text('お支払いが完了しました'), findsOneWidget);
  });

  testWidgets('mất mạng → 結果確認待ち (389:985) → 再確認 tìm thấy đơn → 完了', (tester) async {
    stubCreateOrder(() async => throw TimeoutException('no response'));
    when(() => orderGateway.findOrderByIdempotencyKey(any()))
        .thenAnswer((_) async => const CreateOrderResult(orderId: 'o-1', status: 'allocated', pricePaid: 650));
    await pumpPage(tester);

    await tester.tap(find.byKey(const Key('confirmReservationButton')));
    await tester.pumpAndSettle();
    expect(find.text('決済結果を確認できません'), findsOneWidget);

    await tester.tap(find.byKey(const Key('recheckPaymentButton')));
    await tester.pumpAndSettle();
    expect(find.text('お支払いが完了しました'), findsOneWidget);
  });

  testWidgets('結果確認待ち → 再確認 không thấy đơn → quay lại màn xác nhận + báo chưa thanh toán', (tester) async {
    stubCreateOrder(() async => throw TimeoutException('no response'));
    when(() => orderGateway.findOrderByIdempotencyKey(any())).thenAnswer((_) async => null);
    await pumpPage(tester);

    await tester.tap(find.byKey(const Key('confirmReservationButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('recheckPaymentButton')));
    await tester.pumpAndSettle();

    expect(find.text('予約内容の確認'), findsOneWidget);
    expect(find.text('お支払いは完了していませんでした。もう一度お試しください'), findsOneWidget);
  });

  testWidgets('lỗi đặt hàng (vd hết hàng) → khung lỗi cũ, nút đổi thành "もう一度試す"', (tester) async {
    stubCreateOrder(() async => throw PostgrestException(message: 'E-ORDER-007: sold out at this pickup stop'));
    await pumpPage(tester);

    await tester.tap(find.byKey(const Key('confirmReservationButton')));
    await tester.pumpAndSettle();

    expect(find.text(l10nJa.errorReservationFailed), findsOneWidget);
    expect(find.text('もう一度試す'), findsOneWidget);
  });

  testWidgets('calc_current_price lỗi → nút trả bị khoá, có nút 再試行', (tester) async {
    when(() => homeGateway.calcCurrentPrice(unitPrice: any(named: 'unitPrice'), expiresAt: any(named: 'expiresAt')))
        .thenThrow(Exception('network error'));
    await pumpPage(tester);

    expect(payButton(tester).onPressed, isNull);
    expect(find.byKey(const Key('retryPriceButton')), findsOneWidget);
  });

  testWidgets('0056 (Figma 470:1318): có coupon → bật sẵn, 小計/クーポン/合計 ¥550 → trả kèm couponId; tắt → ¥650, không coupon', (tester) async {
    couponsGateway.coupons.add(FakeCouponsGateway.coupon('c-1'));
    when(() => orderGateway.createOrder(
          surplusBatchId: any(named: 'surplusBatchId'),
          pickupRouteStopId: any(named: 'pickupRouteStopId'),
          paymentMethodId: any(named: 'paymentMethodId'),
          idempotencyKey: any(named: 'idempotencyKey'),
          couponId: any(named: 'couponId'),
        )).thenAnswer((_) async => const CreateOrderResult(orderId: 'o-1', status: 'pending', pricePaid: 550));
    await pumpPage(tester);

    expect(find.text('友だち紹介クーポン（ようこそ）'), findsOneWidget);
    expect(find.text('−¥100'), findsOneWidget);
    expect(find.text('¥550'), findsOneWidget);
    expect(find.text('予約を確定すると、¥550が決済されます。'), findsOneWidget);

    await tester.tap(find.byKey(const Key('useCouponSwitch')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('couponDiscountLine')), findsNothing);
    expect(find.text('予約を確定すると、¥650が決済されます。'), findsOneWidget);

    await tester.tap(find.byKey(const Key('useCouponSwitch')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmReservationButton')));
    await tester.pumpAndSettle();
    verify(() => orderGateway.createOrder(
          surplusBatchId: 'b-1',
          pickupRouteStopId: 'rs-1',
          paymentMethodId: 'pm-visa',
          idempotencyKey: any(named: 'idempotencyKey'),
          couponId: 'c-1',
        )).called(1);
  });

  testWidgets('0056: coupon vừa dùng ở máy khác (E-COUPON-409) → câu lỗi riêng', (tester) async {
    couponsGateway.coupons.add(FakeCouponsGateway.coupon('c-1'));
    when(() => orderGateway.createOrder(
          surplusBatchId: any(named: 'surplusBatchId'),
          pickupRouteStopId: any(named: 'pickupRouteStopId'),
          paymentMethodId: any(named: 'paymentMethodId'),
          idempotencyKey: any(named: 'idempotencyKey'),
          couponId: any(named: 'couponId'),
        )).thenThrow(const PostgrestException(message: 'E-COUPON-409: coupon already used'));
    await pumpPage(tester);
    await tester.tap(find.byKey(const Key('confirmReservationButton')));
    await tester.pumpAndSettle();
    expect(find.text('このクーポンは使えなくなりました。内容を確認して、もう一度お試しください'), findsOneWidget);
  });
}
