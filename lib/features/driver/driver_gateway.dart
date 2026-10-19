import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/batch_photo.dart';
import '../../core/jst_date.dart';
import '../../core/supabase_client.dart';
import '../home/home_gateway.dart' show AllergenName;

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
  const TonightRoute({
    required this.truck,
    required this.routeId,
    required this.stops,
    this.batches = const [],
    this.capacityAtStop = const {},
  });
  final DriverTruck truck;
  final String? routeId; // null: đêm nay xe chưa có tuyến nào (chưa nhà hàng nào đăng ký ước tính)
  final List<DriverStop> stops; // đã sắp theo sequence
  final List<RouteBatch> batches; // mọi lô của tuyến đêm nay (SCR-D07: ở quán nào lấy gì, bao nhiêu)
  // route_stop_id → tổng số suất các lô ĐÃ CHỐT chia cho điểm bán đó (batch_route_stops.available_qty, gồm cả suất đã
  // giữ cho đơn đặt trước). Điểm chưa nhận lô nào thì không có khoá.
  final Map<String, int> capacityAtStop;
}

// 1 lô hàng của tuyến (surplus_batches). Tài xế không thấy restaurants (RLS) → nhận diện quán qua restaurantId ==
// điểm thu gom (DriverStop.restaurantId).
class RouteBatch {
  const RouteBatch({
    required this.id,
    required this.restaurantId,
    required this.estimatedQty,
    required this.confirmedQty,
    required this.sellByAt,
    this.photoUrl,
    this.allergens = const [],
  });
  final String id;
  final String restaurantId;
  final int estimatedQty; // số quán dự kiến (S02)
  final int? confirmedQty; // null: chưa nhận (stage='estimated'); có số: tài xế đã chốt ở SCR-D02
  final DateTime sellByAt; // restaurant_sell_by_at — giờ quán ngừng bán, UTC
  final String? photoUrl;
  final List<AllergenName> allergens;

  bool get isPickedUp => confirmedQty != null;
}

// SCR-D02 受け取り完了: 1 điểm bán nhận bao nhiêu suất của lô vừa chốt, trong đó bao nhiêu đã có người đặt.
class BatchDrop {
  const BatchDrop({required this.routeStopId, required this.qty, required this.reservedCount});
  final String routeStopId;
  final int qty;
  final int reservedCount;
}

class ConfirmResult {
  const ConfirmResult({required this.allocatedOrderCount, required this.refundedOrderCount, this.rejectedForTemperature = false});
  final int allocatedOrderCount;
  final int refundedOrderCount;
  // 0042: 芯温が10℃を超えたためサーバーが確定数量0で確定した（予約はすべて返金済み）。判定はサーバーが正
  final bool rejectedForTemperature;
}

// API-090 route-directions (D08 bước 2): đường bộ thật cho các điểm CÒN LẠI theo đúng thứ tự server giao, từ Google
// Routes API qua Edge Function (key chỉ ở server). Có tính tình trạng đường lúc hỏi.
class RoadRoute {
  const RoadRoute({required this.polyline, required this.distanceMeters, required this.durationSeconds, required this.secondsToStop});
  final String? polyline; // Google encoded polyline; null: không còn đoạn nào để vẽ
  final int distanceMeters;
  final int durationSeconds;
  // route_stop_id → số giây từ điểm xuất phát (xe, hoặc điểm còn lại đầu tiên) tới điểm đó, cộng dồn các đoạn
  final Map<String, int> secondsToStop;

  // `data` của envelope API-090. Đoạn i kết thúc ở legs[i].routeStopId → cộng dồn thành thời gian tới từng điểm.
  factory RoadRoute.fromApi(Map<dynamic, dynamic> data) {
    var total = 0;
    final secondsToStop = <String, int>{};
    for (final leg in data['legs'] as List) {
      final l = leg as Map;
      total += (l['durationSeconds'] as num).toInt();
      secondsToStop[l['routeStopId'] as String] = total;
    }
    return RoadRoute(
      polyline: data['polyline'] as String?,
      distanceMeters: (data['distanceMeters'] as num).toInt(),
      durationSeconds: (data['durationSeconds'] as num).toInt(),
      secondsToStop: secondsToStop,
    );
  }

  int get remainingStops => secondsToStop.length;
}

abstract class DriverGateway {
  // SCR-D00 (ADR-007): 運営 đã tạm dừng tài khoản này chưa (driver_profiles.is_active, RLS chỉ cho đọc dòng của mình).
  // Không có dòng hồ sơ → coi như đang hoạt động (chưa từng bị dừng).
  Future<bool> fetchIsActive();
  Future<TonightRoute?> fetchTonightRoute(); // null: tài khoản này chưa được gán xe nào
  Future<void> sendLocation({required String truckId, required double lat, required double lng}); // API-008
  // Sau khi chốt 1 lô (API-026): server đã chia số suất cho các điểm bán (distribute_qty_to_stops) và giữ suất cho đơn.
  Future<List<BatchDrop>> fetchBatchDrops(String batchId);
  // API-026: chốt số lượng + ghi nhiệt độ trong 1 transaction (migration 0033, レビュー第30回)
  Future<ConfirmResult> confirmWithTemperature({
    required String batchId,
    required int confirmedQty,
    required List<String> routeStopIds,
    required double celsius,
  });
  Future<RoadRoute> fetchRoadRoute(); // API-090
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
    final batchRows = await _client
        .from('surplus_batches')
        .select('id, restaurant_id, estimated_qty, confirmed_qty, restaurant_sell_by_at, photo_path, '
            'surplus_batch_allergens(allergen_types(name_ja, name_en))')
        .eq('route_id', routeId) as List;
    final batches = batchRows.map((raw) {
      final row = raw as Map<String, dynamic>;
      return RouteBatch(
        id: row['id'] as String,
        restaurantId: row['restaurant_id'] as String,
        estimatedQty: row['estimated_qty'] as int,
        confirmedQty: row['confirmed_qty'] as int?,
        sellByAt: DateTime.parse(row['restaurant_sell_by_at'] as String),
        photoUrl: batchPhotoUrl(_client, row['photo_path'] as String?),
        allergens: (row['surplus_batch_allergens'] as List).map((a) {
          final type = (a as Map<String, dynamic>)['allergen_types'] as Map<String, dynamic>;
          return AllergenName(ja: type['name_ja'] as String, en: type['name_en'] as String);
        }).toList(),
      );
    }).toList();

    // batch_route_stops chỉ có dòng sau khi lô được chốt (distribute_qty_to_stops) — tổng theo điểm bán.
    final dropRows = stopIds.isEmpty
        ? const <dynamic>[]
        : await _client.from('batch_route_stops').select('route_stop_id, available_qty').inFilter('route_stop_id', stopIds) as List;
    final capacityAtStop = <String, int>{};
    for (final raw in dropRows) {
      final row = raw as Map<String, dynamic>;
      final id = row['route_stop_id'] as String;
      capacityAtStop[id] = (capacityAtStop[id] ?? 0) + (row['available_qty'] as int);
    }
    return TonightRoute(truck: truck, routeId: routeId, stops: stops, batches: batches, capacityAtStop: capacityAtStop);
  }

  // API-008: INSERT trực tiếp — RLS truck_locations_insert_own_truck (Chương 13) chặn xe của người khác,
  // CHECK lat/lng (Chương 09) chặn toạ độ vô lý. Không cần RPC.
  @override
  Future<void> sendLocation({required String truckId, required double lat, required double lng}) async {
    await _client.from('truck_locations').insert({'truck_id': truckId, 'lat': lat, 'lng': lng});
  }

  @override
  Future<List<BatchDrop>> fetchBatchDrops(String batchId) async {
    final drops = await _client.from('batch_route_stops').select('route_stop_id, available_qty').eq('surplus_batch_id', batchId) as List;
    // RLS orders_select_driver: tài xế thấy đơn của lô trên xe mình — đủ để đếm đơn đã được giữ suất ở từng điểm.
    final orders = await _client
        .from('orders')
        .select('pickup_route_stop_id')
        .eq('surplus_batch_id', batchId)
        .eq('status', 'allocated') as List;
    return drops.map((raw) {
      final row = raw as Map<String, dynamic>;
      final stopId = row['route_stop_id'] as String;
      return BatchDrop(
        routeStopId: stopId,
        qty: row['available_qty'] as int,
        reservedCount: orders.where((o) => (o as Map<String, dynamic>)['pickup_route_stop_id'] == stopId).length,
      );
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

  // functions.invoke tự gắn JWT tài xế — server tự đọc tuyến/toạ độ từ DB, app không gửi gì. Lỗi → ném (màn hiện băng lỗi).
  @override
  Future<RoadRoute> fetchRoadRoute() async {
    final res = await _client.functions.invoke('route-directions').timeout(const Duration(seconds: 15));
    final body = res.data;
    if (body is! Map || body['success'] != true || body['data'] is! Map) throw StateError('route-directions: unexpected response');
    return RoadRoute.fromApi(body['data'] as Map);
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

// Đọc lại đường mỗi 5 phút khi bản đồ còn mở (tình trạng đường đổi) — Routes API có phí nên không đọc dày hơn.
const roadRouteRefresh = Duration(minutes: 5);

// Khoá theo điểm kế tiếp: rời 1 điểm → điểm kế tiếp đổi → đọc đường mới. Chỉ SCR-D08 dùng (ホーム vẫn nét đứt, không tốn phí).
final roadRouteProvider = FutureProvider.autoDispose.family<RoadRoute, String>((ref, nextStopId) {
  final timer = Timer(roadRouteRefresh, ref.invalidateSelf);
  ref.onDispose(timer.cancel);
  return ref.watch(driverGatewayProvider).fetchRoadRoute();
});
