import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecomeal_mobile/core/maps.dart';
import 'package:ecomeal_mobile/features/driver/driver_gateway.dart';

// D08 bước 2: giải đường của Routes API + đọc envelope API-090.
void main() {
  test('decodePolyline: ví dụ chuẩn trong tài liệu Google', () {
    final points = decodePolyline('_p~iF~ps|U_ulLnnqC_mqNvxq`@');
    expect(points, const [LatLng(38.5, -120.2), LatLng(40.7, -120.95), LatLng(43.252, -126.453)]);
  });

  test('decodePolyline: chuỗi rỗng / bị cắt giữa chừng → chỉ các điểm đọc trọn', () {
    expect(decodePolyline(''), isEmpty);
    expect(decodePolyline('_p~iF~ps|U_ulL'), const [LatLng(38.5, -120.2)]);
  });

  test('RoadRoute.fromApi: thời gian tới từng điểm = cộng dồn các đoạn, theo đúng thứ tự', () {
    final road = RoadRoute.fromApi({
      'polyline': 'abc',
      'distanceMeters': 12400,
      'durationSeconds': 1800,
      'legs': [
        {'routeStopId': 'rB', 'durationSeconds': 300, 'distanceMeters': 2000},
        {'routeStopId': 'p2', 'durationSeconds': 600, 'distanceMeters': 4000},
        {'routeStopId': 'p3', 'durationSeconds': 900, 'distanceMeters': 6400},
      ],
    });
    expect(road.secondsToStop, {'rB': 300, 'p2': 900, 'p3': 1800});
    expect(road.remainingStops, 3);
    expect(road.polyline, 'abc');
    expect(road.distanceMeters, 12400);
  });

  test('RoadRoute.fromApi: không còn đoạn → polyline null, không có điểm', () {
    final road = RoadRoute.fromApi({'polyline': null, 'distanceMeters': 0, 'durationSeconds': 0, 'legs': <Object>[]});
    expect(road.polyline, isNull);
    expect(road.remainingStops, 0);
  });
}
