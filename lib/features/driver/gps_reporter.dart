import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/location.dart';
import 'driver_gateway.dart';

enum GpsStatus { idle, sending, error }

// Audit D05: lỗi lấy vị trí (quyền / dịch vụ tắt / không lấy được) khác lỗi gửi lên server (mạng) — mỗi loại 1 câu + 1 cách sửa
enum GpsProblem { permission, serviceOff, notSent }

class GpsState {
  const GpsState({required this.status, this.problem, this.lat, this.lng});
  final GpsStatus status;
  final GpsProblem? problem; // chỉ khi status == error
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
  int _generation = 0;
  int? _inFlightGeneration;

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
    _truckId = null;
    _generation++;
  }

  // Mạng chậm hơn chu kỳ thì bỏ qua lượt mới thay vì chồng nhiều request (vị trí cũ cũng vô ích).
  Future<void> reportOnce() async {
    final truckId = _truckId;
    final generation = _generation;
    if (truckId == null || _inFlightGeneration == generation) return;
    _inFlightGeneration = generation;
    try {
      final ({double lat, double lng}) position;
      try {
        position = await _positionSource();
      } catch (e) {
        if (!mounted || generation != _generation) return;
        _fail(switch (locationProblemOf(e)) {
          LocationProblem.permission => GpsProblem.permission,
          LocationProblem.serviceOff => GpsProblem.serviceOff,
          LocationProblem.unavailable => GpsProblem.notSent,
        });
        return;
      }
      try {
        if (!mounted || generation != _generation) return;
        await _gateway.sendLocation(truckId: truckId, lat: position.lat, lng: position.lng);
      } catch (_) {
        if (!mounted || generation != _generation) return;
        _fail(GpsProblem.notSent); // lấy được vị trí nhưng mạng lỗi — tự gửi lại ở lượt sau
        return;
      }
      if (mounted && generation == _generation) state = GpsState(status: GpsStatus.sending, lat: position.lat, lng: position.lng);
    } finally {
      if (_inFlightGeneration == generation) _inFlightGeneration = null;
    }
  }

  void _fail(GpsProblem problem) {
    if (mounted) state = GpsState(status: GpsStatus.error, problem: problem, lat: state.lat, lng: state.lng);
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
