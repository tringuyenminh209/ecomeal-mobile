import 'package:geolocator/geolocator.dart';

// Dùng chung cho SCR-M03 (vị trí khách, Chương 16) và GPS tài xế (SCR-D01, Chương 19).
// 06_画面設計.md §SCR-M03 Error: "位置情報を取得できませんでした" — xảy ra khi quyền bị từ chối HOẶC dịch vụ
// định vị tắt. Quyền bị từ chối thì ném chính LocationPermission để UI phân biệt deniedForever (nút mở Cài đặt).
// requestIfDenied=false: chỉ kiểm tra, không bật hộp thoại xin quyền (GPS tài xế gọi mỗi 5 giây).
Future<Position> getCurrentPositionWithPermission({bool requestIfDenied = true}) async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) throw Exception('location service disabled');

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied && requestIfDenied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    throw permission;
  }
  return Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(timeLimit: Duration(seconds: 15)),
  );
}
