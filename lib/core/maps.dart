import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Dùng chung cho bản đồ SCR-M03 (khách, Chương 16) và SCR-D01 (tài xế, Chương 19).

const osakaCenter = LatLng(34.6937, 135.5023);

// Chỉ vẽ GoogleMap khi nền tảng có key: iOS thiếu key thì GMSServices chưa được khởi tạo → crash ngay
// (AppDelegate đọc cùng dart-define này); web không có bản google_maps_flutter cấu hình cho app này.
bool get isGoogleMapsConfigured {
  if (kIsWeb) return false;
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => const String.fromEnvironment('GOOGLE_MAPS_ANDROID_API_KEY').isNotEmpty,
    TargetPlatform.iOS => const String.fromEnvironment('GOOGLE_MAPS_IOS_API_KEY').isNotEmpty,
    _ => false,
  };
}

// Marker xe Eco-Truck xuất từ Figma (assets/images/truck-marker.png).
Future<BitmapDescriptor> loadTruckMarkerIcon() {
  return BitmapDescriptor.asset(
    const ImageConfiguration(size: Size(38, 38)),
    'assets/images/truck-marker.png',
    width: 38,
    height: 38,
  );
}

// Bản đồ ban đêm cho chế độ tài xế (theme tối): nền và đường tối, nhãn sáng vừa đủ đọc — bản đồ sáng giữa màn tối gây
// chói trong cabin. Màu theo nền đêm của app (EcoPalette.night: #151F18 / #1D2A21). JSON theo định dạng Map Styling của
// Google Maps; null = bản đồ mặc định (khách, theme sáng).
String? mapStyleFor(Brightness brightness) => brightness == Brightness.dark ? _nightMapStyle : null;

const _nightMapStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#1d2a21"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#a8b3a9"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#151f18"}]},
  {"featureType": "poi", "elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color": "#203325"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#34453a"}]},
  {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#4a5e50"}]},
  {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#c9d2ca"}]},
  {"featureType": "transit", "elementType": "geometry", "stylers": [{"color": "#263328"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#0f1a14"}]}
]
''';
