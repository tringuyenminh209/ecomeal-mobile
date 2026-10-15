import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart' show StripeException;
import '../../core/stripe_payments.dart';
import '../../core/supabase_client.dart';
import '../payment/payment_api.dart';

class CreateOrderResult {
  const CreateOrderResult({required this.orderId, required this.status, required this.pricePaid, this.paymentConfirmed = true});
  final String orderId;
  final String status; // 'pending' | 'allocated' — xem 13_詳細設計書 §5.2 (Chương 05)
  final int pricePaid;
  // 0070: đơn Stripe đã có nhưng server chưa ghi nhận chốt tiền (orders.payment_captured_at NULL) → chưa phải "đã trả"
  final bool paymentConfirmed;
}

class CancelOrderResult {
  const CancelOrderResult({required this.orderId, required this.refundAmount});
  final String orderId;
  final int refundAmount; // 0 nếu hủy ngoài mốc 30 phút (BR-003)
}

// 0050: báo cáo vấn đề của 1 đơn (order_issues, RLS chỉ thấy của mình). Mỗi đơn tối đa 1.
class OrderIssue {
  const OrderIssue({required this.isResolved, this.refundAmount, this.resolution});
  final bool isResolved;
  final int? refundAmount; // 0 = xử lý nhưng không hoàn tiền
  final String? resolution; // câu trả lời của 運営, hiện cho khách
}

class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.status,
    required this.pricePaid,
    required this.createdAt,
    required this.plannedPickupTime,
    required this.stopName,
    required this.taxRate,
    required this.taxAmount,
    this.issue,
    this.rating,
    this.discountAmount = 0,
    this.stopDepartedAt,
    this.surplusBatchId,
    this.pickupRouteStopId,
    this.stopLocationId,
  });
  final String id;
  final String status;
  final int pricePaid;
  final DateTime createdAt;
  final DateTime plannedPickupTime;
  final String stopName;
  final int taxRate; // orders.tax_rate (0046): 8 = thuế suất giảm cho đồ ăn mang về
  final int taxAmount; // orders.tax_amount: phần thuế nằm trong pricePaid (cột sinh ở server)
  final OrderIssue? issue; // 0050: null = chưa báo cáo
  final int? rating; // 0054: số sao đã đánh giá (1〜5), null = chưa đánh giá
  final int discountAmount; // 0056: tiền coupon đã trừ (pricePaid là số khách thật sự trả)
  final DateTime? stopDepartedAt; // route_stops.actual_departure_at: xe đã rời điểm nhận (SCR-M18 受け取りの案内)
  // Chạm thẻ đơn ở SCR-M06 → chi tiết túi đã đặt (SCR-M04, chế độ 予約済み, 2026-10-15). null = không mở được
  final String? surplusBatchId;
  final String? pickupRouteStopId;
  final String? stopLocationId;
}

abstract class OrderGateway {
  // API-010（0043）: thanh toán bằng thẻ đã lưu (vẫn là thanh toán giả — ADR-006). idempotencyKey = 1 khoá cho 1 lần
  // mở SCR-M05: gửi lại cùng khoá thì server trả lại đơn cũ, không trừ tiền lần 2.
  Future<CreateOrderResult> createOrder({
    required String surplusBatchId,
    required String pickupRouteStopId,
    required String paymentMethodId,
    required String idempotencyKey,
    String? couponId, // 0056: coupon (1 lần đặt 1 phiếu). Giảm bao nhiêu do server tính
  });
  // Màn 結果確認待ち: đơn đã được tạo bằng khoá này chưa? null = chưa có đơn (chưa trừ tiền).
  Future<CreateOrderResult?> findOrderByIdempotencyKey(String idempotencyKey);
  Future<List<OrderSummary>> fetchMyOrders();
  Future<CancelOrderResult> cancelOrder(String orderId);
  // API-061 (0050): category = wrong_contents | quality | not_received | other
  Future<void> reportIssue({required String orderId, required String category, required String message});
  // API-069 (0054): chấm 1〜5 sao + 1 câu (tuỳ chọn, ≤200 ký tự) cho đơn đã nhận, 1 lần, trong 7 ngày
  Future<void> rateOrder({required String orderId, required int rating, String? comment});
}

class SupabaseOrderGateway implements OrderGateway {
  SupabaseOrderGateway(this._client, {this.useStripe = false, this.handleNextAction, PaymentInvoker? invokePayment})
      : _invokePayment = invokePayment ?? paymentInvokerFor(_client);
  final SupabaseClient _client;
  final PaymentInvoker _invokePayment;
  // 0047: true → trả tiền thật qua Edge Function stripe-pay-order; false → RPC create_order (thanh toán giả, 0043).
  final bool useStripe;
  final Future<void> Function(String clientSecret)? handleNextAction; // 3D Secure (Stripe SDK)

  // create_order/cancel_order ĐÃ là code mẫu đầy đủ từ Chương 05 (backend) — ở đây chỉ gọi lại
  // qua RPC, không viết logic nghiệp vụ mới. Tham số p_* phải khớp CHÍNH XÁC chữ ký đã định nghĩa.
  @override
  Future<CreateOrderResult> createOrder({
    required String surplusBatchId,
    required String pickupRouteStopId,
    required String paymentMethodId,
    required String idempotencyKey,
    String? couponId,
  }) async {
    if (useStripe) {
      return _payWithStripe(
        surplusBatchId: surplusBatchId,
        pickupRouteStopId: pickupRouteStopId,
        paymentMethodId: paymentMethodId,
        idempotencyKey: idempotencyKey,
        couponId: couponId,
      );
    }
    final result = await _client.rpc('create_order', params: {
      'p_surplus_batch_id': surplusBatchId,
      'p_pickup_route_stop_id': pickupRouteStopId,
      'p_payment_method_id': paymentMethodId,
      'p_idempotency_key': idempotencyKey,
      'p_coupon_id': couponId,
    }).timeout(paymentTimeout) as Map<String, dynamic>;
    return CreateOrderResult(
      orderId: result['order_id'] as String,
      status: result['status'] as String,
      pricePaid: result['price_paid'] as int,
    );
  }

  // API-054: giữ tiền → (3D Secure) → tạo đơn → chốt tiền. Lần đầu có thể nhận requires_action: Stripe SDK hiện màn xác thực
  // của ngân hàng, rồi gọi lại đúng 1 lần kèm payment_intent_id. Khách huỷ / xác thực thất bại → coi như thẻ bị từ chối.
  Future<CreateOrderResult> _payWithStripe({
    required String surplusBatchId,
    required String pickupRouteStopId,
    required String paymentMethodId,
    required String idempotencyKey,
    String? couponId,
  }) async {
    final body = {
      'surplus_batch_id': surplusBatchId,
      'pickup_route_stop_id': pickupRouteStopId,
      'payment_method_id': paymentMethodId,
      'idempotency_key': idempotencyKey,
      if (couponId != null) 'coupon_id': couponId,
    };
    var data = await _invokePayment('stripe-pay-order', body);
    if (data['outcome'] == 'requires_action') {
      try {
        await handleNextAction!(data['client_secret'] as String);
      } on StripeException {
        throw const PaymentApiException('E-PAY-402');
      }
      data = await _invokePayment('stripe-pay-order', {...body, 'payment_intent_id': data['payment_intent_id']});
    }
    if (data['outcome'] != 'paid') throw const PaymentApiException('E-PAY-402');
    final order = Map<String, dynamic>.from(data['order'] as Map);
    return CreateOrderResult(
      orderId: order['order_id'] as String,
      status: order['status'] as String,
      pricePaid: order['price_paid'] as int,
    );
  }

  // RLS orders_select_own — chỉ tìm trong đơn của chính mình.
  @override
  Future<CreateOrderResult?> findOrderByIdempotencyKey(String idempotencyKey) async {
    final row = await _client
        .from('orders')
        .select('id, status, price_paid, payment_intent_id, payment_captured_at')
        .eq('payment_idempotency_key', idempotencyKey)
        .maybeSingle()
        .timeout(paymentTimeout);
    if (row == null) return null;
    return CreateOrderResult(
      orderId: row['id'] as String,
      status: row['status'] as String,
      pricePaid: row['price_paid'] as int,
      paymentConfirmed: row['payment_intent_id'] == null || row['payment_captured_at'] != null,
    );
  }

  @override
  Future<List<OrderSummary>> fetchMyOrders() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    // orders.pickup_route_stop_id NOT NULL → route_stops luôn có (!inner an toàn, RLS route_stops_select_all).
    // stop_locations để LEFT: RLS chỉ cho khách đọc điểm type='public' (0004) — nếu 1 đơn rơi vào điểm
    // khác, !inner sẽ làm MẤT CẢ ĐƠN khỏi lịch sử (không báo lỗi); left join chỉ mất tên điểm.
    final rows = await _client
        .from('orders')
        .select('id, status, price_paid, discount_amount, tax_rate, tax_amount, created_at, surplus_batch_id, pickup_route_stop_id, route_stops!inner(planned_time, actual_departure_at, stop_location_id, stop_locations(name)), order_issues(status, refund_amount, resolution), order_ratings(rating)')
        .eq('user_id', userId)
        .order('created_at', ascending: false) as List;

    return rows.map((raw) {
      final row = raw as Map<String, dynamic>;
      final stop = row['route_stops'] as Map<String, dynamic>;
      final location = stop['stop_locations'] as Map<String, dynamic>?;
      return OrderSummary(
        id: row['id'] as String,
        status: row['status'] as String,
        pricePaid: row['price_paid'] as int,
        createdAt: DateTime.parse(row['created_at'] as String),
        plannedPickupTime: DateTime.parse(stop['planned_time'] as String),
        stopName: location?['name'] as String? ?? '',
        taxRate: row['tax_rate'] as int,
        taxAmount: row['tax_amount'] as int,
        issue: _issueOf(row['order_issues']),
        rating: _ratingOf(row['order_ratings']),
        discountAmount: (row['discount_amount'] as int?) ?? 0,
        stopDepartedAt: stop['actual_departure_at'] == null ? null : DateTime.parse(stop['actual_departure_at'] as String),
        surplusBatchId: row['surplus_batch_id'] as String?,
        pickupRouteStopId: row['pickup_route_stop_id'] as String?,
        stopLocationId: stop['stop_location_id'] as String?,
      );
    }).toList();
  }

  // order_issues.order_id là UNIQUE → PostgREST trả 1 object (hoặc null); vẫn chấp nhận dạng mảng cho chắc.
  static OrderIssue? _issueOf(Object? raw) {
    final row = raw is List ? (raw.isEmpty ? null : raw.first) : raw;
    if (row is! Map) return null;
    return OrderIssue(
      isResolved: row['status'] == 'resolved',
      refundAmount: row['refund_amount'] as int?,
      resolution: row['resolution'] as String?,
    );
  }

  // order_ratings.order_id là khoá chính → 1 object hoặc null (cùng cách đọc với order_issues).
  static int? _ratingOf(Object? raw) {
    final row = raw is List ? (raw.isEmpty ? null : raw.first) : raw;
    return row is Map ? (row['rating'] as num?)?.toInt() : null;
  }

  @override
  Future<void> rateOrder({required String orderId, required int rating, String? comment}) =>
      _client.rpc('rate_order', params: {'p_order_id': orderId, 'p_rating': rating, 'p_comment': comment});

  @override
  Future<void> reportIssue({required String orderId, required String category, required String message}) =>
      _client.rpc('report_order_issue', params: {'p_order_id': orderId, 'p_category': category, 'p_message': message});

  @override
  Future<CancelOrderResult> cancelOrder(String orderId) async {
    final result = await _client.rpc('cancel_order', params: {'p_order_id': orderId}) as Map<String, dynamic>;
    return CancelOrderResult(orderId: result['order_id'] as String, refundAmount: result['refund_amount'] as int);
  }
}

final orderGatewayProvider = Provider<OrderGateway>((ref) => SupabaseOrderGateway(
      SupabaseClientHolder.instance,
      useStripe: ref.watch(stripeEnabledProvider),
      handleNextAction: ref.watch(stripeNextActionProvider),
    ));
