import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Xe tải trên bản đồ SCR-M03 trượt từ vị trí cũ tới vị trí mới (Figma "SCR-M03 / トラック移動") thay vì nhảy cóc
// mỗi lần làm mới 30 giây. Hàm thuần — widget chỉ gọi theo tiến độ animation.

// Số lần cập nhật marker trong 1 lần trượt. Mỗi lần đổi marker là 1 lần gửi sang bản đồ native (không phải
// vẽ trong Flutter) → không cập nhật mỗi frame; 15 bước / 1,2 giây vẫn thấy liền mạch ở mức zoom 14.
const truckGlideSteps = 15;

// Quá xa (đổi xe / GPS nhảy / mở lại app sau lâu) → nhảy thẳng, không cho xe "bay" ngang thành phố
const truckGlideMaxMeters = 1500.0;

LatLng lerpLatLng(LatLng a, LatLng b, double t) =>
    LatLng(a.latitude + (b.latitude - a.latitude) * t, a.longitude + (b.longitude - a.longitude) * t);

// Khoảng cách xấp xỉ (equirectangular) — đủ chính xác cho vài km trong thành phố
double approxMeters(LatLng a, LatLng b) {
  const earthRadius = 6371000.0;
  final lat = (a.latitude + b.latitude) / 2 * math.pi / 180;
  final dx = (b.longitude - a.longitude) * math.pi / 180 * math.cos(lat);
  final dy = (b.latitude - a.latitude) * math.pi / 180;
  return math.sqrt(dx * dx + dy * dy) * earthRadius;
}

bool shouldGlide(LatLng from, LatLng to) {
  final d = approxMeters(from, to);
  return d > 0 && d <= truckGlideMaxMeters;
}
