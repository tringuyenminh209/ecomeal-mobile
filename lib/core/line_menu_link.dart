import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// LINE Rich Menu ô A–D (Figma 09 LINE · Rich Menu 905:187, design/line-rich-menu/v1): trang trung gian /line/open/ của site
// (Figma P10) mở `ecomeal-customer://open?to=<đích>`. Chỉ app khách đăng ký scheme này (Android manifestPlaceholders theo
// flavor, iOS tool/ios_use_variant.sh) — `ecomeal://open` cả 4 app cùng đăng ký nên có thể mở nhầm app.
// Đích chỉ là "mở màn nào"; dữ liệu (đơn, QR) luôn tải theo phiên hiện tại sau RoleGate — link không mang id hay token.
enum LineMenuTarget { browse, reservations, pickup, stops }

// iOS gửi cả URI (ecomeal-customer://open?to=…), Android chỉ gửi path+query (/?to=…) — chỉ đọc tham số `to`.
LineMenuTarget? parseLineMenuTarget(Uri uri) {
  final to = uri.queryParameters['to'];
  for (final target in LineMenuTarget.values) {
    if (target.name == to) return target;
  }
  return null;
}

// Giữ đích vừa bấm cho tới khi CustomerShell (đã đăng nhập, đúng role) lấy đi.
// Đăng ký làm WidgetsBindingObserver TRƯỚC runApp: Flutter (deep linking bật mặc định) gửi link cho observer đăng ký
// trước — nếu tới WidgetsApp trước, nó pushNamed('/?to=…') vào Navigator và lỗi vì không có route đó.
class LineMenuLinks extends ChangeNotifier with WidgetsBindingObserver {
  LineMenuLinks({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  // Mở link rồi chưa đăng nhập, để đó lâu → lần đăng nhập sau không tự nhảy tới màn cũ
  static const maxAge = Duration(minutes: 10);
  // Link lúc khởi động lạnh có thể tới 2 đường (route ban đầu + pushRouteInformation)
  static const _duplicateWindow = Duration(seconds: 2);

  final DateTime Function() _clock;
  LineMenuTarget? _pending;
  DateTime? _pendingAt;
  LineMenuTarget? _last;
  DateTime? _lastAt;

  // true nếu là link Rich Menu (đã giữ lại)
  bool receive(Uri uri) {
    final target = parseLineMenuTarget(uri);
    if (target == null) return false;
    final now = _clock();
    final lastAt = _lastAt;
    if (target == _last && lastAt != null && now.difference(lastAt) < _duplicateWindow) return true;
    _last = target;
    _lastAt = now;
    _pending = target;
    _pendingAt = now;
    notifyListeners();
    return true;
  }

  // Lấy đích đang chờ (1 lần)
  LineMenuTarget? take() {
    final target = _pending;
    final at = _pendingAt;
    _pending = null;
    _pendingAt = null;
    if (target == null || at == null || _clock().difference(at) > maxAge) return null;
    return target;
  }

  void clear() {
    _pending = null;
    _pendingAt = null;
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) async {
    final uri = routeInformation.uri;
    if (receive(uri)) return true;
    // Link chỉ mở app (`ecomeal://open` của mail xác thực SCR-W10): app đã lên trước là đủ — không để Navigator
    // push thêm 1 RoleGate chồng lên màn đang mở.
    return uri.path.isEmpty || uri.path == '/';
  }
}

// main.dart override bằng instance đã đăng ký observer; app khác (tài xế/quán/vận hành) không dùng.
final lineMenuLinksProvider = Provider<LineMenuLinks>((ref) => LineMenuLinks());
