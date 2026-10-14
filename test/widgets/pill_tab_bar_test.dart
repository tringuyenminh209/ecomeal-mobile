import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/widgets/pill_tab_bar.dart';
import 'package:ecomeal_mobile/widgets/sliding_pill.dart';
import '../helpers/test_app.dart';

// Giữ rồi vuốt trái/phải trên thanh tab (2026-10-14): viên thuốc đi theo ngón tay, thả tay mới chọn tab.
void main() {
  late List<int> selected;

  Future<void> pumpBar(WidgetTester tester) async {
    selected = [];
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var index = 0;
    await tester.pumpWidget(
      testApp(
        StatefulBuilder(
          builder: (context, setState) => Scaffold(
            bottomNavigationBar: PillTabBar(
              index: index,
              onSelect: (i) {
                selected.add(i);
                setState(() => index = i);
              },
              tabs: const [
                (Key('tab0'), Icons.home_outlined, Icons.home, 'ホーム'),
                (Key('tab1'), Icons.receipt_long_outlined, Icons.receipt_long, '予約'),
                (Key('tab2'), Icons.person_outline, Icons.person, 'マイページ'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder pill() =>
      find.descendant(of: find.byKey(const Key('pillTabBar')), matching: find.byKey(const Key('slidingPill')));
  double pillX(WidgetTester tester) => tester.getCenter(pill()).dx;
  double tabX(WidgetTester tester, String key) => tester.getCenter(find.byKey(Key(key))).dx;

  testWidgets('vuốt từ ホーム sang マイページ: viên thuốc theo ngón tay, phồng lên, chỉ chọn khi thả tay', (tester) async {
    await pumpBar(tester);
    final start = tester.getCenter(find.byKey(const Key('tab0')));
    final gesture = await tester.startGesture(start);
    await gesture.moveBy(const Offset(40, 0)); // vượt touch slop → bắt đầu kéo
    await tester.pump();
    await gesture.moveTo(Offset(tabX(tester, 'tab1') + 10, start.dy));
    await tester.pump();
    // đang kéo: viên thuốc ở dưới ngón tay, chưa đổi trang
    expect(pillX(tester), closeTo(tabX(tester, 'tab1') + 10, 1));
    expect(selected, isEmpty);
    expect(tester.widget<SlidingPill>(find.byType(SlidingPill)).lifted, isTrue);

    await gesture.moveTo(Offset(tabX(tester, 'tab2'), start.dy));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(selected, [2]);
    // thả tay: viên thuốc trượt về giữa マイページ và hết phồng
    expect(pillX(tester), closeTo(tabX(tester, 'tab2'), 0.5));
    expect(tester.widget<SlidingPill>(find.byType(SlidingPill)).lifted, isFalse);
  });

  testWidgets('kéo quá mép phải: viên thuốc dừng ở tab cuối, không ra khỏi thanh', (tester) async {
    await pumpBar(tester);
    final start = tester.getCenter(find.byKey(const Key('tab1')));
    final gesture = await tester.startGesture(start);
    await gesture.moveBy(const Offset(40, 0));
    await tester.pump();
    await gesture.moveTo(Offset(389, start.dy));
    await tester.pump();
    expect(pillX(tester), lessThanOrEqualTo(tabX(tester, 'tab2') + 390 / 6));
    expect(tester.getRect(pill()).right, lessThanOrEqualTo(390));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(selected, [2]);
  });

  testWidgets('chạm nhanh vẫn chọn tab như cũ', (tester) async {
    await pumpBar(tester);
    await tester.tap(find.byKey(const Key('tab1')));
    await tester.pumpAndSettle();
    expect(selected, [1]);
    expect(pillX(tester), closeTo(tabX(tester, 'tab1'), 0.5));
  });
}
