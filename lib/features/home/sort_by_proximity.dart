import 'package:geolocator/geolocator.dart';
import 'home_gateway.dart';

// myLat/myLng null (chưa có GPS, hoặc bị từ chối quyền) → sắp theo expiresAt gần nhất (giữ nguyên
// hữu ích thay vì bỏ trống) — xem box-why đầu chương về việc KHÔNG lọc cứng theo bán kính.
List<BatchListing> sortListingsByProximity(
  List<BatchListing> listings, {
  double? myLat,
  double? myLng,
}) {
  final sorted = [...listings];
  if (myLat == null || myLng == null) {
    sorted.sort((a, b) => a.expiresAt.compareTo(b.expiresAt));
    return sorted;
  }
  sorted.sort((a, b) {
    final distA = Geolocator.distanceBetween(
      myLat,
      myLng,
      a.stopLat,
      a.stopLng,
    );
    final distB = Geolocator.distanceBetween(
      myLat,
      myLng,
      b.stopLat,
      b.stopLng,
    );
    return distA.compareTo(distB);
  });
  return sorted;
}

// Phút đi bộ tới điểm nhận (danh sách dọc của SCR-M03, 2026-10-15). Quy ước hiển thị bất động sản Nhật: 80m = 1 phút,
// làm tròn lên. Chưa có GPS → null (chỉ hiện tên điểm, không đoán số phút).
const metersPerWalkMinute = 80;

int? walkMinutes(BatchListing listing, {double? myLat, double? myLng}) {
  if (myLat == null || myLng == null) return null;
  final meters = Geolocator.distanceBetween(myLat, myLng, listing.stopLat, listing.stopLng);
  return (meters / metersPerWalkMinute).ceil().clamp(1, 999);
}
