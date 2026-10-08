import 'package:ecomeal_mobile/features/driver/driver_gateway.dart';

// Dữ liệu dùng chung cho các test tài xế: 1 tuyến 5 điểm —
// [1] quán A (thu gom, đã rời) → [2] ký túc xá (bán, đã rời) → [3] quán B (thu gom) → [4] ga Umeda (bán) → [5] ga Tennoji (bán)
DriverStop stopFixture(
  String id, {
  required String type,
  required int sequence,
  bool departed = false,
  int reserved = 0,
  int pickedUp = 0,
  String? restaurantId,
}) {
  return DriverStop(
    routeStopId: id,
    name: 'Stop $id',
    address: '大阪市…',
    type: type,
    restaurantId: restaurantId,
    sequence: sequence,
    // planned_time từ Supabase là UTC: 09:00Z = 18:00 JST — test không phụ thuộc múi giờ máy chạy.
    plannedTime: DateTime.utc(2026, 10, 2, 9, 0).add(Duration(minutes: 20 * sequence)),
    departedAt: departed ? DateTime.utc(2026, 10, 2, 9, 0) : null,
    lat: 34.69,
    lng: 135.50,
    reservedCount: reserved,
    pickedUpCount: pickedUp,
  );
}

final routeFixture = TonightRoute(
  truck: const DriverTruck(id: 'truck-1', plateNumber: '大阪 500 あ 12-34'),
  routeId: 'route-1',
  stops: [
    stopFixture('rA', type: 'restaurant', sequence: 1, departed: true, restaurantId: 'rest-A'),
    stopFixture('p1', type: 'public', sequence: 2, departed: true, pickedUp: 18),
    stopFixture('rB', type: 'restaurant', sequence: 3, restaurantId: 'rest-B'),
    stopFixture('p2', type: 'public', sequence: 4, reserved: 24),
    stopFixture('p3', type: 'public', sequence: 5, reserved: 17),
  ],
);
