import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart' show Key, ValueChanged, Widget;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

// Thanh toán thật bằng Stripe (0047, API-053〜055). Có khoá publishable (pk_test_… / pk_live_…) trong env.json thì app
// dùng Stripe; không có thì giữ thanh toán giả (0043) như trước — dev không cần tài khoản Stripe.
// Khoá publishable được phép nằm trong app (Stripe thiết kế để công khai). Khoá bí mật chỉ ở Edge Function.
const stripePublishableKey = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');

// Test thay giá trị (widget test chạy cả 2 chế độ).
final stripeEnabledProvider = Provider<bool>((ref) => stripePublishableKey.isNotEmpty && !kIsWeb);

Future<void> initStripe() async {
  if (stripePublishableKey.isEmpty || kIsWeb) return;
  Stripe.publishableKey = stripePublishableKey;
  await Stripe.instance.applySettings();
}

// Gửi thẻ đang nhập trong CardField thẳng cho Stripe → nhận pm_… (số thẻ/CVC không qua server của EcoMeal).
// Test thay bằng hàm giả.
final stripeCardTokenizerProvider = Provider<Future<String> Function()>((ref) {
  return () async {
    final pm = await Stripe.instance.createPaymentMethod(
      params: const PaymentMethodParams.card(paymentMethodData: PaymentMethodData()),
    );
    return pm.id;
  };
});

// 3D Secure: Stripe SDK hiện màn xác thực của ngân hàng. Test thay bằng hàm giả.
final stripeNextActionProvider = Provider<Future<void> Function(String clientSecret)>((ref) {
  return (clientSecret) async {
    await Stripe.instance.handleNextAction(clientSecret);
  };
});

// Thanh toán giả (0043) hoặc Stripe test mode (pk_test_…) → vẫn hiện ghi chú 「テスト中のため実際の請求は発生しません」.
// Thẻ thử 4242… / thẻ kết thúc 0002 bị từ chối dùng được cho cả 2 (Stripe cũng có thẻ test 4000 0000 0000 0002).
final paymentTestModeProvider = Provider<bool>((ref) {
  return !ref.watch(stripeEnabledProvider) || stripePublishableKey.startsWith('pk_test_');
});

// Ô nhập thẻ của Stripe (CardField — native view, số thẻ không đi qua Dart). onComplete(true) khi đã nhập đủ số/hạn/CVC
// hợp lệ. Test thay bằng widget giả (native view không chạy trong widget test).
final stripeCardInputProvider = Provider<Widget Function(ValueChanged<bool> onComplete)>((ref) {
  return (onComplete) => CardField(
        key: const Key('stripeCardField'),
        enablePostalCode: false,
        countryCode: 'JP',
        onCardChanged: (details) => onComplete(details?.complete ?? false),
      );
});
