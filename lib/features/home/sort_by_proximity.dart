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
