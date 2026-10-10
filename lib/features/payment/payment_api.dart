import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/rpc_error.dart';

// Lỗi có mã do server trả (envelope { success:false, error:{ code } } của Edge Function stripe-*). Mã giống hệt mã mà RPC
// create_order / add_payment_method raise (E-PAY-402, E-ORDER-007…) → màn hình hiểu lỗi theo 1 cách cho cả 2 chế độ.
class PaymentApiException implements Exception {
  const PaymentApiException(this.code);
  final String code;

  @override
  String toString() => 'PaymentApiException($code)';
}

// Thời gian chờ tối đa 1 lần gọi thanh toán — quá thì app không biết đã trừ tiền chưa → màn 結果確認待ち.
const paymentTimeout = Duration(seconds: 20);

// Hàm gọi Edge Function thanh toán — gateway nhận qua constructor để test thay bằng hàm giả (không mock SupabaseClient).
typedef PaymentInvoker = Future<Map<String, dynamic>> Function(String name, Map<String, dynamic> body);

PaymentInvoker paymentInvokerFor(SupabaseClient client) => (name, body) => invokePaymentFunction(client, name, body);

// Gọi 1 Edge Function thanh toán (stripe-add-card / stripe-pay-order) bằng JWT người dùng, trả `data` của envelope.
// Lỗi có mã → PaymentApiException; 5xx không mã hoặc mất mạng → ném nguyên lỗi (người gọi coi là "không rõ kết quả").
Future<Map<String, dynamic>> invokePaymentFunction(SupabaseClient client, String name, Map<String, dynamic> body) async {
  try {
    final res = await client.functions.invoke(name, body: body).timeout(paymentTimeout);
    final data = res.data;
    if (data is Map && data['success'] == true && data['data'] is Map) {
      return Map<String, dynamic>.from(data['data'] as Map);
    }
    throw StateError('$name: unexpected response');
  } on FunctionException catch (e) {
    final details = e.details;
    final code = details is Map && details['error'] is Map ? (details['error'] as Map)['code'] : null;
    if (code is String) throw PaymentApiException(code);
    rethrow;
  }
}

// Mã lỗi của 1 lỗi thanh toán bất kỳ: PaymentApiException (Stripe) hoặc PostgrestException (RPC thanh toán giả).
// null = không có mã (mất mạng, hết giờ…).
String? paymentErrorCode(Object error) {
  if (error is PaymentApiException) return error.code;
  return rpcErrorCode(error);
}
