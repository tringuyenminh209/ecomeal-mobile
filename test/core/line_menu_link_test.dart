import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/core/line_menu_link.dart';

void main() {
  group('parseLineMenuTarget', () {
    test('4 đích của Rich Menu (A–D) — cả URI đầy đủ (iOS) lẫn chỉ path+query (Android)', () {
      expect(parseLineMenuTarget(Uri.parse('ecomeal-customer://open?to=browse')), LineMenuTarget.browse);
      expect(parseLineMenuTarget(Uri.parse('/?to=reservations')), LineMenuTarget.reservations);
      expect(parseLineMenuTarget(Uri.parse('/?to=pickup')), LineMenuTarget.pickup);
      expect(parseLineMenuTarget(Uri.parse('ecomeal-customer://open?to=stops')), LineMenuTarget.stops);
    });

    test('đích lạ / thiếu / viết hoa → null (không mở màn tuỳ ý)', () {
      expect(parseLineMenuTarget(Uri.parse('/?to=admin')), isNull);
      expect(parseLineMenuTarget(Uri.parse('/?to=BROWSE')), isNull);
      expect(parseLineMenuTarget(Uri.parse('/')), isNull);
      expect(parseLineMenuTarget(Uri.parse('ecomeal://open')), isNull);
    });
  });

  group('LineMenuLinks', () {
    late DateTime now;
    late LineMenuLinks links;
    setUp(() {
      now = DateTime(2026, 10, 18, 20);
      links = LineMenuLinks(clock: () => now);
    });

    test('nhận đích → báo listener; take() trả 1 lần rồi hết', () {
      var notified = 0;
      links.addListener(() => notified++);
      expect(links.receive(Uri.parse('/?to=pickup')), isTrue);
      expect(notified, 1);
      expect(links.take(), LineMenuTarget.pickup);
      expect(links.take(), isNull);
    });

    test('cùng link tới 2 lần liền (lúc mở app + stream) → chỉ giữ 1 lần', () {
      links.receive(Uri.parse('/?to=pickup'));
      expect(links.take(), LineMenuTarget.pickup);
      now = now.add(const Duration(milliseconds: 500));
      links.receive(Uri.parse('ecomeal-customer://open?to=pickup'));
      expect(links.take(), isNull);
      // bấm lại sau vài giây là lần bấm mới
      now = now.add(const Duration(seconds: 5));
      links.receive(Uri.parse('/?to=pickup'));
      expect(links.take(), LineMenuTarget.pickup);
    });

    test('đích chờ quá 10 phút (vd chưa đăng nhập rồi bỏ đó) → bỏ', () {
      links.receive(Uri.parse('/?to=reservations'));
      now = now.add(const Duration(minutes: 11));
      expect(links.take(), isNull);
    });

    test('clear() (đăng xuất) → không áp đích cho tài khoản sau', () {
      links.receive(Uri.parse('/?to=reservations'));
      links.clear();
      expect(links.take(), isNull);
    });

    test('didPushRouteInformation: link Rich Menu và link mở app chung (ecomeal://open) đều không tới Navigator', () async {
      expect(await links.didPushRouteInformation(RouteInformation(uri: Uri.parse('/?to=stops'))), isTrue);
      expect(links.take(), LineMenuTarget.stops);
      // mail xác thực (SCR-W10) chỉ mở app: path "/" → nuốt luôn, không push thêm 1 RoleGate
      expect(await links.didPushRouteInformation(RouteInformation(uri: Uri.parse('/'))), isTrue);
      expect(links.take(), isNull);
      // route khác (không phải của 2 loại link trên) → để Flutter xử lý như cũ
      expect(await links.didPushRouteInformation(RouteInformation(uri: Uri.parse('/other'))), isFalse);
    });
  });
}
