import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/features/driver/driver_home_page.dart';
import '../../helpers/test_app.dart';
import 'driver_test_data.dart';

void main() {
  testWidgets('SCR-D01: card tổng hợp + danh sách hiện đúng 完了 / 次の停車 / số đơn, tap gọi đúng điểm', (tester) async {
    String? tapped;
    await tester.pumpWidget(testApp(
      Scaffold(
        body: ListView(
          children: [
            RouteSummaryCards(stops: routeFixture.stops, now: DateTime.utc(2026, 10, 2, 9, 52)),
            RouteStopList(stops: routeFixture.stops, onTapStop: (s) => tapped = s.routeStopId),
          ],
        ),
      ),
    ));
    await tester.pumpAndSettle(); // chờ nạp bản dịch (LocalizationsDelegate.load là bất đồng bộ)

    expect(find.text('8分'), findsOneWidget); // rB dự kiến 19:00, bây giờ 18:52
    // Figma 16:16731 「予約注文 / 次の停車地点の予約」: số đơn của ĐIỂM KẾ TIẾP (rB là điểm thu gom → 0),
    // không phải tổng cả tuyến.
    expect(find.text('0件'), findsOneWidget);
    expect(find.text('19:00'), findsOneWidget); // giờ Nhật của rB
    expect(find.text('完了 • 18件引き渡し'), findsOneWidget);
    expect(find.text('次の停車 • 集荷'), findsOneWidget);
    expect(find.text('予約 24件'), findsOneWidget);

    await tester.tap(find.byKey(const Key('stop_p2')));
    expect(tapped, 'p2');
  });
}
