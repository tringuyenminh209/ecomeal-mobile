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
  serviceError, // E-PAY-502 → Stripe trả lỗi không phải lỗi thẻ (cấu hình / API): không phải hết hàng, thử lại sau (2026-10-15)
  unknown, // mất mạng / quá giờ → 結果確認待ち: server có thể ĐÃ tạo đơn
  // Audit C02 (2026-10-19): lỗi nghiệp vụ tách theo việc khách làm được tiếp (trước đây gom hết về other = 「売り切れ」)
  dailyLimit, // E-ORDER-001 → đã đủ 2 đơn hôm nay: đổi túi khác cũng không được → xem tab 予約
  soldOutAtStop, // E-ORDER-007 → hết phần ở điểm nhận này → tìm túi khác
  batchUnavailable, // E-ORDER-003 hết giờ bán / 004 điểm không thuộc lô / 404 không tìm thấy → tìm túi khác
  other, // mã khác → lỗi tạm thời, thử lại
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
    'E-ORDER-001' => PaymentFailure.dailyLimit,
    'E-ORDER-007' => PaymentFailure.soldOutAtStop,
    'E-ORDER-003' || 'E-ORDER-004' || 'E-ORDER-404' => PaymentFailure.batchUnavailable,
    'E-COUPON-404' || 'E-COUPON-409' || 'E-COUPON-410' => PaymentFailure.couponUnavailable,
    'E-PAY-502' => PaymentFailure.serviceError,
    'E-PAY-504' => PaymentFailure.unknown, // Stripe không trả lời kịp: có thể đã giữ/chốt tiền
    _ => PaymentFailure.other,
  };
}
