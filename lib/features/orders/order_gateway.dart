import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';

class CreateOrderResult {
  const CreateOrderResult({required this.orderId, required this.status, required this.pricePaid});
  final String orderId;
  final String status; // 'pending' | 'allocated' — xem 13_詳細設計書 §5.2 (Chương 05)
  final int pricePaid;
}

class CancelOrderResult {
  const CancelOrderResult({required this.orderId, required this.refundAmount});
  final String orderId;
  final int refundAmount; // 0 nếu hủy ngoài mốc 30 phút (BR-003)
}

class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.status,
    required this.pricePaid,
    required this.createdAt,
    required this.plannedPickupTime,
    required this.stopName,
  });
  final String id;
  final String status;
  final int pricePaid;
  final DateTime createdAt;
  final DateTime plannedPickupTime;
  final String stopName;
}

abstract class OrderGateway {
  // API-010（0043）: thanh toán bằng thẻ đã lưu (vẫn là thanh toán giả — ADR-006). idempotencyKey = 1 khoá cho 1 lần
  // mở SCR-M05: gửi lại cùng khoá thì server trả lại đơn cũ, không trừ tiền lần 2.
  Future<CreateOrderResult> createOrder({
    required String surplusBatchId,
    required String pickupRouteStopId,
    required String paymentMethodId,
    required String idempotencyKey,
  });
  // Màn 結果確認待ち: đơn đã được tạo bằng khoá này chưa? null = chưa có đơn (chưa trừ tiền).
  Future<CreateOrderResult?> findOrderByIdempotencyKey(String idempotencyKey);
  Future<List<OrderSummary>> fetchMyOrders();
  Future<CancelOrderResult> cancelOrder(String orderId);
}

// Quá thời gian này thì coi như "không rõ kết quả" (06 SCR-M05 結果確認待ち) thay vì để khách chờ mãi.
const paymentTimeout = Duration(seconds: 20);

class SupabaseOrderGateway implements OrderGateway {
  SupabaseOrderGateway(this._client);
  final SupabaseClient _client;

  // create_order/cancel_order ĐÃ là code mẫu đầy đủ từ Chương 05 (backend) — ở đây chỉ gọi lại
  // qua RPC, không viết logic nghiệp vụ mới. Tham số p_* phải khớp CHÍNH XÁC chữ ký đã định nghĩa.
  @override
  Future<CreateOrderResult> createOrder({
    required String surplusBatchId,
    required String pickupRouteStopId,
    required String paymentMethodId,
    required String idempotencyKey,
  }) async {
    final result = await _client.rpc('create_order', params: {
      'p_surplus_batch_id': surplusBatchId,
      'p_pickup_route_stop_id': pickupRouteStopId,
      'p_payment_method_id': paymentMethodId,
      'p_idempotency_key': idempotencyKey,
    }).timeout(paymentTimeout) as Map<String, dynamic>;
    return CreateOrderResult(
      orderId: result['order_id'] as String,
      status: result['status'] as String,
      pricePaid: result['price_paid'] as int,
    );
  }

  // RLS orders_select_own — chỉ tìm trong đơn của chính mình.
  @override
  Future<CreateOrderResult?> findOrderByIdempotencyKey(String idempotencyKey) async {
    final row = await _client
        .from('orders')
        .select('id, status, price_paid')
        .eq('payment_idempotency_key', idempotencyKey)
        .maybeSingle()
        .timeout(paymentTimeout);
    if (row == null) return null;
    return CreateOrderResult(
      orderId: row['id'] as String,
      status: row['status'] as String,
      pricePaid: row['price_paid'] as int,
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
        .select('id, status, price_paid, created_at, route_stops!inner(planned_time, stop_locations(name))')
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
      );
    }).toList();
  }

  @override
  Future<CancelOrderResult> cancelOrder(String orderId) async {
    final result = await _client.rpc('cancel_order', params: {'p_order_id': orderId}) as Map<String, dynamic>;
    return CancelOrderResult(orderId: result['order_id'] as String, refundAmount: result['refund_amount'] as int);
  }
}

final orderGatewayProvider = Provider<OrderGateway>((ref) => SupabaseOrderGateway(SupabaseClientHolder.instance));
