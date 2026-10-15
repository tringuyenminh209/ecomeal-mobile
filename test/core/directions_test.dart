import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/core/directions.dart';

void main() {
  test('drivingDirectionsUri: URL chỉ đường lái xe của Google Maps tới toạ độ', () {
    final uri = drivingDirectionsUri(34.6937, 135.5023);
    expect(uri.host, 'www.google.com');
    expect(uri.path, '/maps/dir/');
    expect(uri.queryParameters, {'api': '1', 'destination': '34.6937,135.5023', 'travelmode': 'driving'});
  });
}
