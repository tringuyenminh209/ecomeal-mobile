import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';

class ReservationAtStop {
  const ReservationAtStop({required this.orderId, required this.status, required this.createdAt});
  final String orderId;
  final String status; // 'allocated' (chờ giao) | 'picked_up' (đã giao)
  final DateTime createdAt; // hiện kèm khi mã thủ công trùng (06 §SCR-M06, レビュー第25回)
}

class WalkupStock {
  const WalkupStock({required this.batchId, required this.restaurantId, required this.capacity, required this.used, required this.remaining});
  final String batchId;
  final String restaurantId;
  final int capacity;
  final int used;
  final int remaining;
}

class StopHandoff {
  const StopHandoff({required this.plannedDepartureAt, required this.departedAt, required this.reservations, required this.walkupStocks});
  final DateTime plannedDepartureAt;
  final DateTime? departedAt;
  final List<ReservationAtStop> reservations;
  final List<WalkupStock> walkupStocks;
}

class DonationBatch {
  const DonationBatch({required this.id, required this.restaurantId, required this.confirmedQty});
  final String id;
  final String restaurantId;
  final int confirmedQty;
}

abstract class HandoffGateway {
  Future<StopHandoff> fetchStopHandoff(String routeStopId);
  Future<void> confirmPickup(String orderId); // API-014
  Future<int> walkUpPurchase({required String batchId, required String routeStopId}); // API-013 → giá đã bán
  Future<int> closeRouteStop(String routeStopId); // API-020 → số đơn bị expired
  Future<List<DonationBatch>> fetchConfirmedBatches(String routeId);
  Future<int> recordDonation({required String batchId, required int quantity, required String note}); // API-016 → còn lại
}

class SupabaseHandoffGateway implements HandoffGateway {
  SupabaseHandoffGateway(this._client);
  final SupabaseClient _client;

  @override
  Future<StopHandoff> fetchStopHandoff(String routeStopId) async {
    final stop = await _client.from('route_stops').select('planned_departure_at, actual_departure_at').eq('id', routeStopId).single();
    // Chỉ đơn đặt trước (reserved) — đơn walk-up đã picked_up ngay lúc bán, không thuộc danh sách "chờ giao".
    final orderRows = await _client
        .from('orders')
        .select('id, status, created_at')
        .eq('pickup_route_stop_id', routeStopId)
        .eq('channel', 'reserved')
        .inFilter('status', ['allocated', 'picked_up'])
        .order('created_at') as List;
    // Hàm SQL 0034 — đúng công thức walk_up_purchase dùng để chặn bán quá (không tự tính lại ở Dart).
    final stockRows = await _client.rpc('walkup_stock_at_stop', params: {'p_route_stop_id': routeStopId}) as List;
    final departed = stop['actual_departure_at'] as String?;
    return StopHandoff(
      plannedDepartureAt: DateTime.parse(stop['planned_departure_at'] as String), // UTC — so sánh thời điểm, không định dạng
      departedAt: departed == null ? null : DateTime.parse(departed),
      reservations: orderRows.map((raw) {
        final row = raw as Map<String, dynamic>;
        return ReservationAtStop(
          orderId: row['id'] as String,
          status: row['status'] as String,
          createdAt: DateTime.parse(row['created_at'] as String), // UTC — hiển thị qua toTokyo()
        );
      }).toList(),
      walkupStocks: stockRows.map((raw) {
        final row = raw as Map<String, dynamic>;
        return WalkupStock(
          batchId: row['surplus_batch_id'] as String,
          restaurantId: row['restaurant_id'] as String,
          capacity: row['capacity'] as int,
          used: row['used'] as int,
          remaining: row['remaining'] as int,
        );
      }).toList(),
    );
  }

  @override
  Future<void> confirmPickup(String orderId) async {
    await _client.rpc('confirm_pickup', params: {'p_order_id': orderId});
  }

  // Không gửi user_id nào: đơn walk-up luôn user_id = NULL (API-013, レビュー第43回).
  @override
  Future<int> walkUpPurchase({required String batchId, required String routeStopId}) async {
    final result = await _client.rpc('walk_up_purchase', params: {
      'p_surplus_batch_id': batchId,
      'p_pickup_route_stop_id': routeStopId,
    }) as Map<String, dynamic>;
    return result['price_paid'] as int;
  }

  @override
  Future<int> closeRouteStop(String routeStopId) async {
    final result = await _client.rpc('close_route_stop', params: {'p_route_stop_id': routeStopId}) as Map<String, dynamic>;
    return result['expired_order_count'] as int;
  }

  @override
  Future<List<DonationBatch>> fetchConfirmedBatches(String routeId) async {
    final rows = await _client
        .from('surplus_batches')
        .select('id, restaurant_id, confirmed_qty')
        .eq('route_id', routeId)
        .eq('stage', 'confirmed') as List;
    return rows.map((raw) {
      final row = raw as Map<String, dynamic>;
      return DonationBatch(id: row['id'] as String, restaurantId: row['restaurant_id'] as String, confirmedQty: row['confirmed_qty'] as int);
    }).toList();
  }

  // Số còn lại = confirmed − đã bán − đã tặng: chỉ record_donation (Chương 08) tính, app chỉ hiện kết quả.
  @override
  Future<int> recordDonation({required String batchId, required int quantity, required String note}) async {
    final result = await _client.rpc('record_donation', params: {
      'p_surplus_batch_id': batchId,
      'p_quantity': quantity,
      'p_note': note,
    }) as Map<String, dynamic>;
    return result['remaining_qty'] as int;
  }
}

final handoffGatewayProvider = Provider<HandoffGateway>((ref) => SupabaseHandoffGateway(SupabaseClientHolder.instance));

final stopHandoffProvider = FutureProvider.autoDispose.family<StopHandoff, String>((ref, routeStopId) {
  return ref.watch(handoffGatewayProvider).fetchStopHandoff(routeStopId);
});
