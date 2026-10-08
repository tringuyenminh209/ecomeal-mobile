import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ecomeal_mobile/features/driver/driver_gateway.dart';
import 'package:ecomeal_mobile/features/driver/gps_reporter.dart';

class MockDriverGateway extends Mock implements DriverGateway {}

void main() {
  late MockDriverGateway gateway;

  setUp(() {
    gateway = MockDriverGateway();
    when(() => gateway.sendLocation(truckId: any(named: 'truckId'), lat: any(named: 'lat'), lng: any(named: 'lng')))
        .thenAnswer((_) async {});
  });

  test('start(): gửi ngay 1 lần với đúng truck_id → trạng thái sending', () async {
    final reporter = GpsReporter(gateway, () async => (lat: 34.70, lng: 135.50), interval: const Duration(hours: 1));
    reporter.start('truck-1');
    await pumpEventQueue();

    verify(() => gateway.sendLocation(truckId: 'truck-1', lat: 34.70, lng: 135.50)).called(1);
    expect(reporter.state.status, GpsStatus.sending);
    reporter.dispose();
  });

  test('UC-10 例外フロー: lấy GPS lỗi → trạng thái error nhưng GIỮ vị trí gửi thành công gần nhất', () async {
    var fail = false;
    final reporter = GpsReporter(gateway, () async {
      if (fail) throw Exception('location service disabled');
      return (lat: 34.70, lng: 135.50);
    }, interval: const Duration(hours: 1));
    reporter.start('truck-1');
    await pumpEventQueue();

    fail = true;
    await reporter.reportOnce();

    expect(reporter.state.status, GpsStatus.error);
    expect(reporter.state.lat, 34.70);
    verify(() => gateway.sendLocation(truckId: any(named: 'truckId'), lat: any(named: 'lat'), lng: any(named: 'lng'))).called(1);
    reporter.dispose();
  });
}
