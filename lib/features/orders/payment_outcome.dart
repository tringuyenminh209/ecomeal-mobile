import 'package:supabase_flutter/supabase_flutter.dart';
import '../payment/payment_api.dart';

// Lỗi khi đặt + trả tiền (create_order 0043 hoặc stripe-pay-order 0047) → màn hình kết quả của SCR-M05.
enum PaymentFailure {
  declined, // E-PAY-402 → カード拒否
  cardExpired, // E-PAY-410 → カード拒否 (câu "hết hạn")
  methodMissing, // E-PAY-404 → thẻ vừa bị xoá ở máy khác: chọn lại thẻ
  couponUnavailable, // E-COUPON-404/409/410 (0056) → coupon vừa được dùng ở máy khác / hết hạn: tải lại coupon
  rateLimited, // E-RATE-429 (0052) → thanh toán quá nhiều lần trong 1 giờ: chưa giữ tiền, thử lại sau
  sessionExpired, // E-AUTH-401 → server không nhận phiên: không phải lỗi đặt hàng, phải đăng nhập lại (2026-10-14)
  priceUnavailable, // E-ORDER-011 (0071) → giá hiện tại dưới mức Stripe nhận (¥50): chưa giữ tiền
  unknown, // mất mạng / quá giờ → 結果確認待ち: server có thể ĐÃ tạo đơn
  other, // hết hàng, giới hạn ngày… → khung lỗi đặt hàng như trước
}

PaymentFailure classifyPaymentError(Object error) {
  // Server đã trả lời (có mã lỗi) → biết chắc kết quả. Còn lại (Timeout, Socket, ClientException…) thì
  // request có thể đã tới server và commit — không được coi là thất bại, phải cho khách kiểm tra lại.
  if (error is! PostgrestException && error is! PaymentApiException) return PaymentFailure.unknown;
  return switch (paymentErrorCode(error)) {
    'E-PAY-402' => PaymentFailure.declined,
    'E-PAY-410' => PaymentFailure.cardExpired,
    'E-PAY-404' => PaymentFailure.methodMissing,
    'E-RATE-429' => PaymentFailure.rateLimited,
    'E-AUTH-401' => PaymentFailure.sessionExpired,
    'E-ORDER-011' => PaymentFailure.priceUnavailable,
    'E-COUPON-404' || 'E-COUPON-409' || 'E-COUPON-410' => PaymentFailure.couponUnavailable,
    'E-PAY-504' => PaymentFailure.unknown, // Stripe không trả lời kịp: có thể đã giữ/chốt tiền
    _ => PaymentFailure.other,
  };
}
