import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/batch_photo.dart';
import '../../core/jst_date.dart';
import '../../core/supabase_client.dart';

class BatchListing {
  const BatchListing({
    required this.batchId,
    required this.routeStopId,
    required this.unitPrice,
    required this.expiresAt,
    required this.stopName,
    required this.plannedPickupTime,
    required this.stopLat,
    required this.stopLng,
    required this.remainingQty,
    this.truckId,
    this.photoUrl,
    this.stopLocationId,
  });

  final String batchId;
  final String routeStopId;
  // stop_locations.id — nút ☆ お気に入り của SCR-M04 (0053). null ở dữ liệu test cũ = không hiện nút.
  final String? stopLocationId;
  final int unitPrice;
  final DateTime expiresAt;
  final String stopName;
  // route_stops.planned_time — SCR-M04 (thẻ 受け取り) và SCR-M05 (Chương 17) hiện khung giờ từ đây.
  final DateTime plannedPickupTime;
  final double stopLat;
  final double stopLng;
  final int remainingQty;
  // surplus_batches.truck_id — chế độ "chọn xe" của SCR-M03 lọc lô theo xe (null: lô chưa gán xe).
  final String? truckId;
  // Ảnh món do quán đăng (0038, tuỳ chọn) — URL công khai của bucket batch_photos; null = dùng ảnh minh hoạ chung.
  final String? photoUrl;
}

class TruckPosition {
  const TruckPosition({
    required this.lat,
    required this.lng,
    required this.recordedAt,
  });
  final double lat;
  final double lng;
  final DateTime recordedAt;
}

// 1 điểm dừng công cộng trên lộ trình tối nay (điểm type='restaurant' bỏ qua: khách không nhận hàng ở đó).
class RouteStopInfo {
  const RouteStopInfo({
    required this.routeStopId,
    required this.stopName,
    required this.plannedTime,
    required this.departed,
  });
  final String routeStopId;
  final String stopName;
  final DateTime plannedTime;
  // actual_departure_at đã ghi = xe đã rời, không bán ở đây nữa.
  final bool departed;
}

// 1 xe đang chạy hôm nay (SCR-M03, レビュー第68回): vị trí mới nhất + lộ trình theo sequence.
class TruckRoute {
  const TruckRoute({required this.truckId, required this.position, required this.stops});
  final String truckId;
  final TruckPosition? position;
  final List<RouteStopInfo> stops;

  // Cùng quy tắc "次の停車地" của SCR-D01 (Chương 19): điểm đầu tiên theo sequence mà xe chưa rời.
  RouteStopInfo? get nextStop {
    for (final stop in stops) {
      if (!stop.departed) return stop;
    }
    return null;
  }
}

class CurrentPriceResult {
  const CurrentPriceResult({
    required this.currentPrice,
    required this.tier,
    required this.minutesRemaining,
  });
  final int currentPrice;
  final String tier;
  final int minutesRemaining;
}

class IngredientInfo {
  const IngredientInfo({required this.name, required this.origin});
  final String name;
  final String origin;
}

// allergen_types có sẵn cả name_ja lẫn name_en (Chương 01, seed 28 mục) — lấy cả 2, màn hình chọn theo ngôn ngữ.
class AllergenName {
  const AllergenName({required this.ja, required this.en});
  final String ja;
  final String en;

  String forLanguage(String languageCode) => languageCode == 'en' ? en : ja;
}

class BatchDetail {
  const BatchDetail({
    required this.batchId,
    required this.unitPrice,
    required this.expiresAt,
    required this.allergens,
    required this.ingredients,
    this.photoUrl,
  });
  final String batchId;
  final int unitPrice;
  final DateTime expiresAt;
  final List<AllergenName> allergens;
  final List<IngredientInfo> ingredients;
  final String? photoUrl;
}

abstract class HomeGateway {
  Future<List<BatchListing>> fetchActiveListings();
  // Xe chạy hôm nay (JST), xếp theo truck_id — thứ tự này là số "n号車" hiển thị.
  Future<List<TruckRoute>> fetchTodayTrucks();
  Future<CurrentPriceResult> calcCurrentPrice({
    required int unitPrice,
    required DateTime expiresAt,
  });
  Future<BatchDetail> fetchBatchDetail(String batchId);
  Future<int> fetchTodayReservationCount();
  // Trả về callback huỷ đăng ký — cùng kiểu trả về đã dùng ở RouteMonitorPage (Chương 13).
  VoidCallback watchChanges({required VoidCallback onChange});
}

class SupabaseHomeGateway implements HomeGateway {
  SupabaseHomeGateway(this._client);
  final SupabaseClient _client;

  String? _photoUrl(String? path) => batchPhotoUrl(_client, path);

  // Bắt đầu từ batch_route_stops (không phải surplus_batches) — xem box-why đầu chương: mỗi dòng
  // ở đây là 1 "cặp lô hàng + điểm dừng" bán được thật sự, khớp đúng đơn vị create_order cần.
  @override
  Future<List<BatchListing>> fetchActiveListings() async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final rows =
        await _client
                .from('batch_route_stops')
                .select(
                  // remaining_qty (0073): phân bổ − đơn đang giữ của điểm này (available_qty không giảm khi đặt, BR-001)
                  'remaining_qty, route_stop_id, '
                  'surplus_batches!inner(id, unit_price, expires_at, truck_id, photo_path), '
                  'route_stops!inner(planned_time, actual_departure_at, stop_locations!inner(id, name, lat, lng, type))',
                )
                .eq('route_stops.stop_locations.type', 'public')
                .isFilter('route_stops.actual_departure_at', null)
                .gt('remaining_qty', 0) // đã đặt hết thì không hiện (chủ dự án quyết 2026-10-15)
                .gt('surplus_batches.expires_at', nowIso)
            as List;

    return rows.map((raw) {
      final row = raw as Map<String, dynamic>;
      final batch = row['surplus_batches'] as Map<String, dynamic>;
      final routeStop = row['route_stops'] as Map<String, dynamic>;
      final stop = routeStop['stop_locations'] as Map<String, dynamic>;
      return BatchListing(
        batchId: batch['id'] as String,
        routeStopId: row['route_stop_id'] as String,
        unitPrice: batch['unit_price'] as int,
        expiresAt: DateTime.parse(batch['expires_at'] as String),
        stopName: stop['name'] as String,
        plannedPickupTime: DateTime.parse(
          routeStop['planned_time'] as String,
        ).toLocal(),
        stopLat: (stop['lat'] as num).toDouble(),
        stopLng: (stop['lng'] as num).toDouble(),
        remainingQty: row['remaining_qty'] as int,
        truckId: batch['truck_id'] as String?,
        photoUrl: _photoUrl(batch['photo_path'] as String?),
        stopLocationId: stop['id'] as String?,
      );
    }).toList();
  }

  // Bỏ ràng buộc "1 truck/đêm" của bản trước (lấy 1 dòng mới nhất toàn bảng): mỗi xe lấy vị trí mới nhất RIÊNG
  // bằng limit 1 — không kéo cả lịch sử GPS về client (bài học 第51回, PostgREST cắt ở 1000 dòng).
  @override
  Future<List<TruckRoute>> fetchTodayTrucks() async {
    final routes =
        await _client
                .from('routes')
                .select(
                  'truck_id, route_stops(id, sequence, planned_time, actual_departure_at, stop_locations!inner(name, type))',
                )
                .eq('service_date', todayInTokyo())
                .eq('route_stops.stop_locations.type', 'public')
                .order('truck_id')
                .order('sequence', referencedTable: 'route_stops')
            as List;
    return Future.wait(
      routes.map((raw) async {
        final route = raw as Map<String, dynamic>;
        final truckId = route['truck_id'] as String;
        final position =
            await _client
                    .from('truck_locations')
                    .select('lat, lng, recorded_at')
                    .eq('truck_id', truckId)
                    .order('recorded_at', ascending: false)
                    .limit(1)
                as List;
        return TruckRoute(
          truckId: truckId,
          position: position.isEmpty ? null : _position(position.first as Map<String, dynamic>),
          stops: (route['route_stops'] as List).map((s) {
            final stop = s as Map<String, dynamic>;
            return RouteStopInfo(
              routeStopId: stop['id'] as String,
              stopName: (stop['stop_locations'] as Map<String, dynamic>)['name'] as String,
              plannedTime: DateTime.parse(stop['planned_time'] as String).toLocal(),
              departed: stop['actual_departure_at'] != null,
            );
          }).toList(),
        );
      }),
    );
  }

  TruckPosition _position(Map<String, dynamic> row) => TruckPosition(
    lat: (row['lat'] as num).toDouble(),
    lng: (row['lng'] as num).toDouble(),
    recordedAt: DateTime.parse(row['recorded_at'] as String),
  );

  @override
  Future<CurrentPriceResult> calcCurrentPrice({
    required int unitPrice,
    required DateTime expiresAt,
  }) async {
    final result =
        await _client.rpc(
              'calc_current_price',
              params: {
                'unit_price': unitPrice,
                'expires_at': expiresAt.toIso8601String(),
              },
            )
            as Map<String, dynamic>;
    return CurrentPriceResult(
      currentPrice: result['current_price'] as int,
      tier: result['tier'] as String,
      minutesRemaining: result['minutes_remaining'] as int,
    );
  }

  @override
  Future<BatchDetail> fetchBatchDetail(String batchId) async {
    final batchRow = await _client
        .from('surplus_batches')
        .select('id, unit_price, expires_at, photo_path')
        .eq('id', batchId)
        .single();
    final allergenRows =
        await _client
                .from('surplus_batch_allergens')
                .select('allergen_types!inner(name_ja, name_en)')
                .eq('surplus_batch_id', batchId)
            as List;
    final ingredientRows =
        await _client
                .from('surplus_batch_ingredients')
                .select('ingredient_name, origin')
                .eq('surplus_batch_id', batchId)
            as List;

    return BatchDetail(
      batchId: batchRow['id'] as String,
      unitPrice: batchRow['unit_price'] as int,
      expiresAt: DateTime.parse(batchRow['expires_at'] as String),
      photoUrl: _photoUrl(batchRow['photo_path'] as String?),
      allergens: allergenRows.map((r) {
        final type =
            (r as Map<String, dynamic>)['allergen_types']
                as Map<String, dynamic>;
        return AllergenName(
          ja: type['name_ja'] as String,
          en: type['name_en'] as String,
        );
      }).toList(),
      ingredients: ingredientRows
          .map(
            (r) => IngredientInfo(
              name: (r as Map<String, dynamic>)['ingredient_name'] as String,
              origin: (r['origin'] as String?) ?? '',
            ),
          )
          .toList(),
    );
  }

  // Khớp CHÍNH XÁC điều kiện BR-002 mà create_order (13_詳細設計書 §5.2) đã dùng — không tự suy
  // diễn lại, copy nguyên văn: channel='reserved', loại cancelled/refunded, theo ngày JST.
  @override
  Future<int> fetchTodayReservationCount() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 0;
    final rows =
        await _client
                .from('orders')
                .select('id')
                .eq('user_id', userId)
                .eq('channel', 'reserved')
                .not('status', 'in', '(cancelled,refunded)')
                .gte('created_at', '${todayInTokyo()}T00:00:00+09:00')
                .lt('created_at', '${tomorrowInTokyo()}T00:00:00+09:00')
            as List;
    return rows.length;
  }

  @override
  VoidCallback watchChanges({required VoidCallback onChange}) {
    final channel = _client.channel('customer-home-updates')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'truck_locations',
        callback: (_) => onChange(),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'surplus_batches',
        callback: (_) => onChange(),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'batch_route_stops',
        callback: (_) => onChange(),
      )
      // actual_departure_at thay đổi khi tài xế rời 1 điểm → "次の停車地" và lộ trình phải cập nhật.
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'route_stops',
        callback: (_) => onChange(),
      );
    channel.subscribe();
    return () => _client.removeChannel(channel);
  }
}

final homeGatewayProvider = Provider<HomeGateway>(
  (ref) => SupabaseHomeGateway(SupabaseClientHolder.instance),
);
