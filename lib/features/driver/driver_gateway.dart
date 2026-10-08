import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/jst_date.dart';
import '../../core/supabase_client.dart';

class DriverTruck {
  const DriverTruck({required this.id, required this.plateNumber});
  final String id;
  final String plateNumber;
}

class DriverStop {
  const DriverStop({
    required this.routeStopId,
    required this.name,
    required this.address,
    required this.type,
    required this.restaurantId,
    required this.sequence,
    required this.plannedTime,
    required this.departedAt,
    required this.lat,
    required this.lng,
    required this.reservedCount,
    required this.pickedUpCount,
  });
  final String routeStopId;
  final String name;
  final String? address;
  final String type; // 'restaurant' (điểm thu gom) | 'public' (điểm bán) — stop_locations.type
  final String? restaurantId;
  final int sequence;
  final DateTime plannedTime;
  final DateTime? departedAt; // route_stops.actual_departure_at — != null nghĩa là đã rời điểm này
  final double lat;
  final double lng;
  final int reservedCount; // đơn pending/allocated đang chờ ở điểm này
  final int pickedUpCount; // đơn đã giao xong (picked_up)
}

class TonightRoute {
  const TonightRoute({required this.truck, required this.routeId, required this.stops});
  final DriverTruck truck;
  final String? routeId; // null: đêm nay xe chưa có tuyến nào (chưa nhà hàng nào đăng ký ước tính)
  final List<DriverStop> stops; // đã sắp theo sequence
}

class PickupBatch {
  const PickupBatch({required this.id, required this.estimatedQty});
  final String id;
  final int estimatedQty;
}

class ConfirmResult {
  const ConfirmResult({required this.allocatedOrderCount, required this.refundedOrderCount, this.rejectedForTemperature = false});
  final int allocatedOrderCount;
  final int refundedOrderCount;
  // 0042: 芯温が10℃を超えたためサーバーが確定数量0で確定した（予約はすべて返金済み）。判定はサーバーが正
  final bool rejectedForTemperature;
}

abstract class DriverGateway {
  // SCR-D00 (ADR-007): 運営 đã tạm dừng tài khoản này chưa (driver_profiles.is_active, RLS chỉ cho đọc dòng của mình).
  // Không có dòng hồ sơ → coi như đang hoạt động (chưa từng bị dừng).
  Future<bool> fetchIsActive();
  Future<TonightRoute?> fetchTonightRoute(); // null: tài khoản này chưa được gán xe nào
  Future<void> sendLocation({required String truckId, required double lat, required double lng}); // API-008
  Future<List<PickupBatch>> fetchPendingBatches({required String routeId, required String restaurantId});
  // API-026: chốt số lượng + ghi nhiệt độ trong 1 transaction (migration 0033, レビュー第30回)
  Future<ConfirmResult> confirmWithTemperature({
    required String batchId,
    required int confirmedQty,
    required List<String> routeStopIds,
    required double celsius,
  });
}

class SupabaseDriverGateway implements DriverGateway {
  SupabaseDriverGateway(this._client);
  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  @override
  Future<bool> fetchIsActive() async {
    final row = await _client.from('driver_profiles').select('is_active').eq('driver_id', _uid).maybeSingle();
    return row == null || row['is_active'] as bool;
  }

  @override
  Future<TonightRoute?> fetchTonightRoute() async {
    final truckRow = await _client.from('trucks').select('id, plate_number').eq('driver_id', _uid).limit(1).maybeSingle();
    if (truckRow == null) return null;
    final truck = DriverTruck(id: truckRow['id'] as String, plateNumber: truckRow['plate_number'] as String);

    // "Đêm nay" theo giờ Nhật — routes.service_date là DATE (Chương 03 tạo theo Asia/Tokyo).
    final routeRow =
        await _client.from('routes').select('id').eq('truck_id', truck.id).eq('service_date', todayInTokyo()).maybeSingle();
    if (routeRow == null) return TonightRoute(truck: truck, routeId: null, stops: const []);
    final routeId = routeRow['id'] as String;

    final stopRows = await _client
        .from('route_stops')
        .select('id, sequence, planned_time, actual_departure_at, '
            'stop_locations!inner(name, address, type, restaurant_id, lat, lng)')
        .eq('route_id', routeId)
        .order('sequence') as List;
    final stopIds = stopRows.map((r) => (r as Map<String, dynamic>)['id'] as String).toList();

    // RLS orders_select_driver (Chương 06): tài xế chỉ thấy đơn của lô hàng trên xe mình — đủ để đếm.
    final orderRows = stopIds.isEmpty
        ? const <dynamic>[]
        : await _client.from('orders').select('pickup_route_stop_id, status').inFilter('pickup_route_stop_id', stopIds) as List;
    int countAt(String stopId, Set<String> statuses) => orderRows
        .map((r) => r as Map<String, dynamic>)
        .where((o) => o['pickup_route_stop_id'] == stopId && statuses.contains(o['status']))
        .length;

    final stops = stopRows.map((raw) {
      final row = raw as Map<String, dynamic>;
      final loc = row['stop_locations'] as Map<String, dynamic>;
      final id = row['id'] as String;
      final departed = row['actual_departure_at'] as String?;
      return DriverStop(
        routeStopId: id,
        name: loc['name'] as String,
        address: loc['address'] as String?,
        type: loc['type'] as String,
        restaurantId: loc['restaurant_id'] as String?,
        sequence: row['sequence'] as int,
        plannedTime: DateTime.parse(row['planned_time'] as String), // UTC — hiển thị qua toTokyo()
        departedAt: departed == null ? null : DateTime.parse(departed),
        lat: (loc['lat'] as num).toDouble(),
        lng: (loc['lng'] as num).toDouble(),
        reservedCount: countAt(id, {'pending', 'allocated'}),
        pickedUpCount: countAt(id, {'picked_up'}),
      );
    }).toList();
    return TonightRoute(truck: truck, routeId: routeId, stops: stops);
  }

  // API-008: INSERT trực tiếp — RLS truck_locations_insert_own_truck (Chương 13) chặn xe của người khác,
  // CHECK lat/lng (Chương 09) chặn toạ độ vô lý. Không cần RPC.
  @override
  Future<void> sendLocation({required String truckId, required double lat, required double lng}) async {
    await _client.from('truck_locations').insert({'truck_id': truckId, 'lat': lat, 'lng': lng});
  }

  @override
  Future<List<PickupBatch>> fetchPendingBatches({required String routeId, required String restaurantId}) async {
    final rows = await _client
        .from('surplus_batches')
        .select('id, estimated_qty')
        .eq('route_id', routeId)
        .eq('restaurant_id', restaurantId)
        .eq('stage', 'estimated') as List;
    return rows.map((raw) {
      final row = raw as Map<String, dynamic>;
      return PickupBatch(id: row['id'] as String, estimatedQty: row['estimated_qty'] as int);
    }).toList();
  }

  // 1 RPC duy nhất: server tự lấy truck_id từ lô và recorded_by = auth.uid() — client không gửi 2 giá trị
  // đó nữa, nên không thể ghi nhiệt độ nhân danh xe/người khác.
  @override
  Future<ConfirmResult> confirmWithTemperature({
    required String batchId,
    required int confirmedQty,
    required List<String> routeStopIds,
    required double celsius,
  }) async {
    final result = await _client.rpc('confirm_surplus_batch_with_temperature', params: {
      'p_surplus_batch_id': batchId,
      'p_confirmed_qty': confirmedQty,
      'p_route_stop_ids': routeStopIds,
      'p_temperature_celsius': celsius,
    }) as Map<String, dynamic>;
    return ConfirmResult(
      allocatedOrderCount: result['allocated_order_count'] as int,
      refundedOrderCount: result['refunded_order_count'] as int,
      rejectedForTemperature: result['rejected_for_temperature'] as bool? ?? false,
    );
  }
}

final driverGatewayProvider = Provider<DriverGateway>((ref) => SupabaseDriverGateway(SupabaseClientHolder.instance));

// Khoá theo user id: đăng xuất rồi tài khoản khác đăng nhập (cùng máy) thì đọc lại, không dùng kết quả cũ.
final driverActiveProvider = FutureProvider.autoDispose.family<bool, String>((ref, userId) {
  return ref.watch(driverGatewayProvider).fetchIsActive();
});

final tonightRouteProvider = FutureProvider.autoDispose<TonightRoute?>((ref) {
  return ref.watch(driverGatewayProvider).fetchTonightRoute();
});
