import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/location.dart';
import 'driver_gateway.dart';

enum GpsStatus { idle, sending, error }

class GpsState {
  const GpsState({required this.status, this.lat, this.lng});
  final GpsStatus status;
  final double? lat; // vị trí gửi thành công gần nhất — GIỮ NGUYÊN khi lỗi (UC-10 例外フロー)
  final double? lng;
}

typedef PositionSource = Future<({double lat, double lng})> Function();

// UC-10: lấy GPS định kỳ rồi INSERT truck_locations (API-008). Khách thấy xe di chuyển qua Realtime
// (Chương 13/16). NFR "phản ánh trong 10 giây" (02_要件定義書) → chu kỳ 5 giây để còn dư cho mạng.
class GpsReporter extends StateNotifier<GpsState> {
  GpsReporter(this._gateway, this._positionSource, {this.interval = const Duration(seconds: 5)})
      : super(const GpsState(status: GpsStatus.idle));

  final DriverGateway _gateway;
  final PositionSource _positionSource;
  final Duration interval;
  Timer? _timer;
  String? _truckId;
  bool _inFlight = false;

  void start(String truckId) {
    if (_timer != null && _truckId == truckId) return; // build() gọi lại nhiều lần — không tạo timer trùng
    stop();
    _truckId = truckId;
    unawaited(reportOnce());
    _timer = Timer.periodic(interval, (_) => unawaited(reportOnce()));
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  // Mạng chậm hơn chu kỳ thì bỏ qua lượt mới thay vì chồng nhiều request (vị trí cũ cũng vô ích).
  Future<void> reportOnce() async {
    final truckId = _truckId;
    if (truckId == null || _inFlight) return;
    _inFlight = true;
    try {
      final position = await _positionSource();
      await _gateway.sendLocation(truckId: truckId, lat: position.lat, lng: position.lng);
      if (mounted) state = GpsState(status: GpsStatus.sending, lat: position.lat, lng: position.lng);
    } catch (_) {
      if (mounted) state = GpsState(status: GpsStatus.error, lat: state.lat, lng: state.lng);
    } finally {
      _inFlight = false;
    }
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

final gpsReporterProvider = StateNotifierProvider.autoDispose<GpsReporter, GpsState>((ref) {
  var asked = false; // hỏi quyền đúng 1 lần mỗi lần vào chế độ tài xế
  return GpsReporter(ref.watch(driverGatewayProvider), () async {
    final p = await getCurrentPositionWithPermission(requestIfDenied: !asked);
    asked = true;
    return (lat: p.latitude, lng: p.longitude);
  });
});
