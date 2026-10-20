import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;
import 'package:ecomeal_mobile/core/stripe_payments.dart';
import 'package:ecomeal_mobile/features/orders/order_gateway.dart';
import 'package:ecomeal_mobile/features/orders/payment_outcome.dart';
import 'package:ecomeal_mobile/features/payment/add_card_page.dart';
import 'package:ecomeal_mobile/features/payment/payment_api.dart';
import 'package:ecomeal_mobile/features/payment/payment_gateway.dart';
import '../../helpers/fake_payment_gateway.dart';
import '../../helpers/test_app.dart';

// 0047 Stripe: luồng trả tiền (stripe-pay-order, có 3D Secure), cách hiểu mã lỗi, và SCR-M09 thêm thẻ bằng CardField.
void main() {
  // Không gọi mạng: luồng Stripe chỉ đi qua invokePayment giả
  final client = SupabaseClient('http://localhost:1', 'anon-key');

  group('SupabaseOrderGateway (Stripe)', () {
    Future<CreateOrderResult> pay(
      List<Map<String, dynamic>> responses, {
      List<Map<String, dynamic>>? sent,
      Future<void> Function(String)? nextAction,
    }) {
      final queue = [...responses];
      final gateway = SupabaseOrderGateway(
        client,
        useStripe: true,
        handleNextAction: nextAction ?? (_) async {},
        invokePayment: (name, body) async {
          expect(name, 'stripe-pay-order');
          sent?.add(body);
          return queue.removeAt(0);
        },
      );
      return gateway.createOrder(surplusBatchId: 'b', pickupRouteStopId: 's', paymentMethodId: 'card-1', idempotencyKey: 'k');
    }

    final paid = {
      'outcome': 'paid',
      'order': {'order_id': 'o-1', 'status': 'allocated', 'price_paid': 600, 'replayed': false},
    };

    test('trả thành công ngay → đơn với price_paid của server', () async {
      final result = await pay([paid]);
      expect(result.orderId, 'o-1');
      expect(result.pricePaid, 600);
    });

    test('3D Secure → Stripe SDK xử lý client_secret → gọi lại kèm payment_intent_id', () async {
      final sent = <Map<String, dynamic>>[];
      final secrets = <String>[];
      final result = await pay(
        [
          {'outcome': 'requires_action', 'client_secret': 'pi_1_secret', 'payment_intent_id': 'pi_1'},
          paid,
        ],
        sent: sent,
        nextAction: (secret) async => secrets.add(secret),
      );
      expect(secrets, ['pi_1_secret']);
      expect(sent[0].containsKey('payment_intent_id'), isFalse);
      expect(sent[1]['payment_intent_id'], 'pi_1');
      expect(sent[1]['idempotency_key'], 'k'); // cùng khoá → server không giữ tiền lần 2
      expect(result.orderId, 'o-1');
    });

    test('khách huỷ / xác thực 3D Secure thất bại → E-PAY-402 (カード拒否)', () async {
      final future = pay(
        [
          {'outcome': 'requires_action', 'client_secret': 's', 'payment_intent_id': 'pi_1'},
        ],
        nextAction: (_) async => throw const StripeException(error: LocalizedErrorMessage(code: FailureCode.Canceled)),
      );
      await expectLater(future, throwsA(isA<PaymentApiException>().having((e) => e.code, 'code', 'E-PAY-402')));
    });
  });

  test('classifyPaymentError: mã của Edge Function được hiểu giống mã của RPC', () {
    expect(classifyPaymentError(const PaymentApiException('E-PAY-402')), PaymentFailure.declined);
    expect(classifyPaymentError(const PaymentApiException('E-PAY-410')), PaymentFailure.cardExpired);
    expect(classifyPaymentError(const PaymentApiException('E-PAY-404')), PaymentFailure.methodMissing);
    expect(classifyPaymentError(const PaymentApiException('E-PAY-504')), PaymentFailure.unknown);
    expect(classifyPaymentError(const PaymentApiException('E-RATE-429')), PaymentFailure.rateLimited);
    // Audit C02 (2026-10-19): lỗi nghiệp vụ tách theo việc khách làm được tiếp, không gom về 'other' (「売り切れ」)
    expect(classifyPaymentError(const PaymentApiException('E-ORDER-007')), PaymentFailure.soldOutAtStop);
    expect(classifyPaymentError(const PaymentApiException('E-ORDER-001')), PaymentFailure.dailyLimit);
    expect(classifyPaymentError(const PaymentApiException('E-ORDER-003')), PaymentFailure.batchUnavailable);
    expect(classifyPaymentError(const PaymentApiException('E-ORDER-004')), PaymentFailure.batchUnavailable);
    expect(classifyPaymentError(const PaymentApiException('E-ORDER-404')), PaymentFailure.batchUnavailable);
    expect(classifyPaymentError(const PaymentApiException('E-ORDER-999')), PaymentFailure.other);
    expect(classifyPaymentError(TimeoutException('slow')), PaymentFailure.unknown);
  });

  test('2026-10-14: hết phiên (E-AUTH-401) và giá không trả được bằng thẻ (E-ORDER-011) không bị coi là hết hàng', () {
    expect(classifyPaymentError(const PaymentApiException('E-AUTH-401')), PaymentFailure.sessionExpired);
    expect(classifyPaymentError(const PaymentApiException('E-ORDER-011')), PaymentFailure.priceUnavailable);
    // 2026-10-15: lỗi phía Stripe không phải lỗi thẻ (vd tham số API bị bỏ) — không phải hết hàng
    expect(classifyPaymentError(const PaymentApiException('E-PAY-502')), PaymentFailure.serviceError);
  });

  group('SCR-M09 カードを追加 (Stripe)', () {
    late FakePaymentGateway gateway;
    late bool tokenized;

    Future<void> pumpPage(WidgetTester tester) async {
      tokenized = false;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            paymentGatewayProvider.overrideWithValue(gateway),
            stripeEnabledProvider.overrideWithValue(true),
            paymentTestModeProvider.overrideWithValue(false), // live: không hiện ghi chú テスト中
            // CardField là native view — thay bằng nút giả "nhập xong"
            stripeCardInputProvider.overrideWithValue(
              (onComplete) => TextButton(key: const Key('fakeCardComplete'), onPressed: () => onComplete(true), child: const Text('card')),
            ),
            stripeCardTokenizerProvider.overrideWithValue(() async {
              tokenized = true;
              return 'pm_test_1';
            }),
          ],
          // Mở bằng push (giống SCR-M09) để kiểm được việc đóng trang khi thêm xong
          child: testApp(
            Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<String>(builder: (_) => const AddCardPage())),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    setUp(() => gateway = FakePaymentGateway());

    testWidgets('không có 4 ô nhập của app; chưa nhập đủ → báo, không gửi Stripe', (tester) async {
      await pumpPage(tester);
      expect(find.byKey(const Key('cardNumberField')), findsNothing);
      expect(find.byKey(const Key('cardCvcField')), findsNothing);
      expect(find.text('テスト中のため、実際に請求されることはありません。テスト用カード 4242 4242 4242 4242 をお使いください（0002で終わるカードは決済が拒否されます）。'), findsNothing);

      await tester.tap(find.byKey(const Key('addCardSubmitButton')));
      await tester.pump();
      expect(find.text('カード番号・有効期限・セキュリティコードを入力してください。'), findsOneWidget);
      expect(tokenized, isFalse);
    });

    testWidgets('nhập đủ → Stripe tạo pm_ → server lưu thẻ → đóng trang', (tester) async {
      await pumpPage(tester);
      await tester.tap(find.byKey(const Key('fakeCardComplete')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('addCardSubmitButton')));
      await tester.pumpAndSettle();

      expect(gateway.stripeAdded, ['pm_test_1']);
      expect(gateway.added, isEmpty); // không đi đường thanh toán giả
      expect(find.byType(AddCardPage), findsNothing);
    });

    testWidgets('server từ chối thẻ (E-PAY-402) → SnackBar, vẫn ở trang', (tester) async {
      gateway.addError = const PaymentApiException('E-PAY-402');
      await pumpPage(tester);
      await tester.tap(find.byKey(const Key('fakeCardComplete')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('addCardSubmitButton')));
      await tester.pumpAndSettle();

      expect(find.text('このカードは登録できませんでした。別のカードをお試しください'), findsOneWidget);
      expect(find.byType(AddCardPage), findsOneWidget);
    });

    testWidgets('quá số lần thêm thẻ (E-RATE-429, 0052) → câu "しばらく時間をおいて…"', (tester) async {
      gateway.addError = const PaymentApiException('E-RATE-429');
      await pumpPage(tester);
      await tester.tap(find.byKey(const Key('fakeCardComplete')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('addCardSubmitButton')));
      await tester.pumpAndSettle();

      expect(find.text('しばらく時間をおいてから再度お試しください'), findsOneWidget);
      expect(find.byType(AddCardPage), findsOneWidget);
    });
  });
}
