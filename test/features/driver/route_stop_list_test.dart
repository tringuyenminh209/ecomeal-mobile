import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/features/driver/driver_home_page.dart';
import '../../helpers/test_app.dart';
import 'driver_test_data.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1080, 2600);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(testApp(Scaffold(body: ListView(children: [child]))));
    await tester.pumpAndSettle(); // chờ nạp bản dịch (LocalizationsDelegate.load là bất đồng bộ)
  }

  testWidgets('SCR-D01 v2: 今夜の進み具合 — đã rời / tổng, tách 集荷・販売', (tester) async {
    await pump(tester, RouteProgressCard(stops: routeFixture.stops));
    expect(find.text('5か所中 2か所 完了'), findsOneWidget);
    expect(find.text('集荷 1/2'), findsOneWidget);
    expect(find.text('販売 1/3'), findsOneWidget);
  });

  testWidgets('SCR-D01 v2: 次にやること — điểm kế tiếp là quán B: đi đâu, lúc nào, lấy bao nhiêu', (tester) async {
    var navigated = 0, arrived = 0;
    final next = routeFixture.stops[2];
    await pump(
      tester,
      NextTaskCard(
        route: routeFixture,
        stop: next,
        now: DateTime.utc(2026, 10, 2, 9, 52),
        onNavigate: () => navigated++,
        onArrive: () => arrived++,
      ),
    );
    expect(find.text('3か所目・集荷'), findsOneWidget); // vị trí trên cả tuyến
    expect(find.text('Stop rB で料理を受け取る'), findsOneWidget);
    expect(find.text('19:00'), findsOneWidget); // planned 10:00Z = 19:00 JST
    expect(find.text('8分'), findsOneWidget);
    expect(find.text('約16食'), findsOneWidget); // 2 lô chưa nhận: 10 + 6 (lô của quán A không tính)
    // Giờ ngừng bán sớm nhất của các lô chưa nhận (bB1 18:30), không phải thứ tự trong dữ liệu
    expect(find.text('受け取る料理 2つ ・ お店の販売終了 18:30'), findsOneWidget);

    await tester.tap(find.byKey(const Key('navigateButton')));
    await tester.tap(find.byKey(const Key('arriveButton')));
    expect((navigated, arrived), (1, 1));
  });

  testWidgets('SCR-D01 v2: 次にやること ở điểm bán — số suất đã chia + số đơn đặt trước', (tester) async {
    await pump(
      tester,
      NextTaskCard(route: routeFixture, stop: routeFixture.stops[3], onNavigate: () {}, onArrive: () {}),
    );
    expect(find.text('Stop p2 でお客様に渡す'), findsOneWidget);
    expect(find.text('8食'), findsOneWidget);
    expect(find.text('予約 24件は受け取りQRを読んで渡します'), findsOneWidget);
    expect(find.text('着いた・渡す'), findsOneWidget);
  });

  testWidgets('SCR-D01 v2: danh sách chia 集荷 / 販売, mỗi dòng ghi việc + số lượng, tap gọi đúng điểm', (tester) async {
    String? tapped;
    await pump(tester, RouteStopList(route: routeFixture, onTapStop: (s) => tapped = s.routeStopId));

    expect(find.text('① お店で受け取る（集荷）'), findsOneWidget);
    expect(find.text('② お客様に渡す（販売）'), findsOneWidget);
    expect(find.text('2か所'), findsOneWidget);
    expect(find.text('3か所'), findsOneWidget);
    expect(find.text('受け取り済み・12食'), findsOneWidget);
    expect(find.text('完了 • 18件引き渡し'), findsOneWidget);
    expect(find.text('次の停車 • 約16食を受け取る'), findsOneWidget);
    expect(find.text('予約 24件 ・ 全部で 8食'), findsOneWidget);
    expect(find.text('予約 17件'), findsOneWidget); // p3 chưa nhận lô nào → chỉ số đơn

    await tester.tap(find.byKey(const Key('stop_p2')));
    expect(tapped, 'p2');
  });

  testWidgets('tab 販売: onlyType chỉ hiện phần お客様に渡す', (tester) async {
    await pump(tester, RouteStopList(route: routeFixture, onlyType: 'public', onTapStop: (_) {}));
    expect(find.text('① お店で受け取る（集荷）'), findsNothing);
    expect(find.text('② お客様に渡す（販売）'), findsOneWidget);
    expect(find.byKey(const Key('stop_rB')), findsNothing);
  });
}
