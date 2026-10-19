import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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

// Pin tròn có số thứ tự trên tuyến (Figma D08 966:1785): vẽ bằng Canvas thành PNG cho Marker — marker mặc định của Google
// Maps không ghi được số. Cache theo (số, màu) vì bản đồ dựng lại mỗi khi GPS đổi.
final _numberedPinCache = <String, BitmapDescriptor>{};

Future<BitmapDescriptor> numberedPin(int number, {required Color fill, required Color label}) async {
  final key = '$number-${fill.toARGB32()}-${label.toARGB32()}';
  final cached = _numberedPinCache[key];
  if (cached != null) return cached;
  const size = 34.0;
  const ratio = 3.0; // vẽ nét ở mật độ cao rồi thu về 34pt
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(ratio);
  const center = Offset(size / 2, size / 2);
  canvas.drawCircle(center, size / 2 - 1, Paint()..color = fill);
  canvas.drawCircle(
    center,
    size / 2 - 1,
    Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2,
  );
  final text = TextPainter(
    text: TextSpan(text: '$number', style: TextStyle(color: label, fontSize: 15, fontWeight: FontWeight.w700)),
    textDirection: TextDirection.ltr,
  )..layout();
  text.paint(canvas, center - Offset(text.width / 2, text.height / 2));
  final image = await recorder.endRecording().toImage((size * ratio).round(), (size * ratio).round());
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  return _numberedPinCache[key] = BitmapDescriptor.bytes(png!.buffer.asUint8List(), width: size, height: size);
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

// Bản đồ đặt trong danh sách cuộn (SCR-D01 tài xế, 運行モニタ của 運営): không có cái này thì cử chỉ kéo / chụm 2 ngón
// bị ListView giành mất → không phóng to, thu nhỏ, kéo bản đồ được (2026-10-15). Bản đồ nhận cử chỉ trước.
final Set<Factory<OneSequenceGestureRecognizer>> mapGestureRecognizers = {
  Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
};

// Khung bao các điểm (tuyến + xe) để camera vừa cả tuyến. null = chưa có điểm nào. 1 điểm → khung rỗng quanh điểm đó.
LatLngBounds? boundsOf(Iterable<LatLng> points) {
  if (points.isEmpty) return null;
  var south = points.first.latitude, north = south, west = points.first.longitude, east = west;
  for (final p in points) {
    if (p.latitude < south) south = p.latitude;
    if (p.latitude > north) north = p.latitude;
    if (p.longitude < west) west = p.longitude;
    if (p.longitude > east) east = p.longitude;
  }
  return LatLngBounds(southwest: LatLng(south, west), northeast: LatLng(north, east));
}

// Camera vừa cả tuyến khi bản đồ vừa mở. 1 điểm thì chỉ dời tâm (newLatLngBounds với khung rỗng phóng quá sát).
Future<void> fitCameraTo(GoogleMapController controller, Iterable<LatLng> points) async {
  final bounds = boundsOf(points);
  if (bounds == null) return;
  await controller.animateCamera(
    bounds.southwest == bounds.northeast
        ? CameraUpdate.newLatLng(bounds.southwest)
        : CameraUpdate.newLatLngBounds(bounds, 48),
  );
}
