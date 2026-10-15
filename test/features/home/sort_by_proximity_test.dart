import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/features/home/home_gateway.dart';
import 'package:ecomeal_mobile/features/home/sort_by_proximity.dart';

BatchListing _listing(
  String id, {
  required double lat,
  required double lng,
  DateTime? expiresAt,
}) {
  return BatchListing(
    batchId: id,
    routeStopId: 'stop-$id',
    unitPrice: 450,
    expiresAt: expiresAt ?? DateTime(2026, 10, 2, 21, 0),
    stopName: 'Stop $id',
    plannedPickupTime: DateTime(2026, 10, 2, 20, 0),
    stopLat: lat,
    stopLng: lng,
    remainingQty: 3,
  );
}

void main() {
  // Toạ độ xấp xỉ 3 điểm ở Osaka, khoảng cách tăng dần so với vị trí "của tôi".
  final myLat = 34.6937, myLng = 135.5023;
  final near = _listing('near', lat: 34.6940, lng: 135.5025);
  final mid = _listing('mid', lat: 34.7100, lng: 135.5200);
  final far = _listing('far', lat: 34.8000, lng: 135.6000);

  test('có vị trí người dùng → sắp theo khoảng cách gần nhất trước', () {
    final result = sortListingsByProximity(
      [far, near, mid],
      myLat: myLat,
      myLng: myLng,
    );
    expect(result.map((l) => l.batchId).toList(), ['near', 'mid', 'far']);
  });

  test(
    'KHÔNG có vị trí người dùng (null) → sắp theo expiresAt gần nhất trước, không loại bỏ ai',
    () {
      final soon = _listing(
        'soon',
        lat: 0,
        lng: 0,
        expiresAt: DateTime(2026, 10, 2, 20, 0),
      );
      final later = _listing(
        'later',
        lat: 0,
        lng: 0,
        expiresAt: DateTime(2026, 10, 2, 22, 0),
      );
      final result = sortListingsByProximity(
        [later, soon],
        myLat: null,
        myLng: null,
      );
      expect(result.map((l) => l.batchId).toList(), ['soon', 'later']);
    },
  );

  test('không làm thay đổi danh sách gốc (trả về list mới)', () {
    final original = [far, near, mid];
    final originalOrder = original.map((l) => l.batchId).toList();
    sortListingsByProximity(original, myLat: myLat, myLng: myLng);
    expect(original.map((l) => l.batchId).toList(), originalOrder);
  });

  test('walkMinutes: 80 m = 1 phút (làm tròn lên, ít nhất 1); không có GPS → null', () {
    expect(walkMinutes(near, myLat: null, myLng: myLng), isNull);
    expect(walkMinutes(near, myLat: myLat, myLng: null), isNull);
    // near ≈ 38 m → 1 phút (không phải 0)
    expect(walkMinutes(near, myLat: myLat, myLng: myLng), 1);
    // 0.0071° vĩ độ ≈ 789 m về phía bắc → 10 phút (789 / 80 = 9.9, làm tròn lên)
    final north = _listing('north', lat: myLat + 0.0071, lng: myLng);
    expect(walkMinutes(north, myLat: myLat, myLng: myLng), 10);
  });
}
