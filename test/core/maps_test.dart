import 'package:ecomeal_mobile/core/maps.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  test('boundsOf: khung bao mọi điểm của tuyến; không có điểm → null', () {
    expect(boundsOf(const []), isNull);
    final b = boundsOf(const [LatLng(34.70, 135.53), LatLng(34.66, 135.50), LatLng(34.69, 135.51)])!;
    expect(b.southwest, const LatLng(34.66, 135.50));
    expect(b.northeast, const LatLng(34.70, 135.53));
  });

  test('2026-10-15: bản đồ trong danh sách cuộn nhận cử chỉ trước (phóng to / kéo được)', () {
    expect(mapGestureRecognizers, hasLength(1));
    expect(mapGestureRecognizers.first.constructor(), isA<EagerGestureRecognizer>());
  });
}
