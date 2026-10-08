import 'package:supabase_flutter/supabase_flutter.dart';

// Lỗi create_order (API-010, 0043) → màn hình kết quả của SCR-M05.
enum PaymentFailure {
  declined, // E-PAY-402 → カード拒否
  cardExpired, // E-PAY-410 → カード拒否 (câu "hết hạn")
  methodMissing, // E-PAY-404 → thẻ vừa bị xoá ở máy khác: chọn lại thẻ
  unknown, // mất mạng / quá giờ → 結果確認待ち: server có thể ĐÃ tạo đơn
  other, // hết hàng, giới hạn ngày… → khung lỗi đặt hàng như trước
}

PaymentFailure classifyPaymentError(Object error) {
  // Server đã trả lời (có mã lỗi) → biết chắc kết quả. Còn lại (Timeout, Socket, ClientException…) thì
  // request có thể đã tới server và commit — không được coi là thất bại, phải cho khách kiểm tra lại.
  if (error is! PostgrestException) return PaymentFailure.unknown;
  final text = error.message;
  if (text.contains('E-PAY-402')) return PaymentFailure.declined;
  if (text.contains('E-PAY-410')) return PaymentFailure.cardExpired;
  if (text.contains('E-PAY-404')) return PaymentFailure.methodMissing;
  return PaymentFailure.other;
}
