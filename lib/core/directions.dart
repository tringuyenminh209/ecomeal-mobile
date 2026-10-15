import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

// 「ナビで行く」(SCR-D01・D07・D02 受け取り完了): mở app bản đồ dẫn đường lái xe tới điểm dừng. Dùng URL Google Maps
// chung (https) — có app Google Maps thì mở app, không có thì mở bản web; không cần khai báo scheme riêng trên iOS.
Uri drivingDirectionsUri(double lat, double lng) => Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '$lat,$lng',
      'travelmode': 'driving',
    });

// Test thay bằng hàm giả (không mở app thật).
final openDirectionsProvider = Provider<Future<bool> Function(double lat, double lng)>((ref) {
  return (lat, lng) => launchUrl(drivingDirectionsUri(lat, lng), mode: LaunchMode.externalApplication);
});
