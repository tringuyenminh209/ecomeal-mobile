import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/core/motion.dart';
import 'package:ecomeal_mobile/widgets/sliding_pill.dart';

Widget _pills(int selected, {bool reduceMotion = false, Size? pillSize}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Scaffold(
      body: Center(
        child: SlidingPill(
          selected: selected,
          color: Colors.green,
          spacing: 8,
          pillSize: pillSize,
          children: [
            for (final w in [60.0, 90.0, 40.0]) SizedBox(key: Key('item$w'), width: w, height: 30),
          ],
        ),
      ),
    ),
  ),
);

Rect _pill(WidgetTester tester) => tester.getRect(find.byKey(const Key('slidingPill')));
Rect _item(WidgetTester tester, double w) => tester.getRect(find.byKey(Key('item$w')));

void main() {
  testWidgets('viên thuốc nằm đúng sau mục đang chọn (đo theo kích thước từng mục)', (tester) async {
    await tester.pumpWidget(_pills(1));
    await tester.pumpAndSettle();
    expect(_pill(tester), _item(tester, 90));
  });

  testWidgets('đổi mục → viên thuốc trượt (giữa chừng nằm giữa 2 mục), xong thì nằm sau mục mới', (tester) async {
    await tester.pumpWidget(_pills(0));
    await tester.pumpAndSettle();
    final from = _item(tester, 60).center.dx;
    final to = _item(tester, 40).center.dx;
    await tester.pumpWidget(_pills(2));
    await tester.pump(Motion.small ~/ 2);
    final mid = _pill(tester).center.dx;
    expect(mid, greaterThan(from));
    expect(mid, lessThan(to));
    await tester.pumpAndSettle();
    expect(_pill(tester), _item(tester, 40));
  });

  testWidgets('bật "giảm chuyển động" → nhảy ngay, không có khung hình trượt', (tester) async {
    await tester.pumpWidget(_pills(0, reduceMotion: true));
    await tester.pumpAndSettle();
    await tester.pumpWidget(_pills(2, reduceMotion: true));
    await tester.pump();
    expect(_pill(tester), _item(tester, 40));
  });

  testWidgets('pillSize: viên thuốc cỡ cố định đặt giữa mục (thanh tab 84×50)', (tester) async {
    await tester.pumpWidget(_pills(1, pillSize: const Size(84, 50)));
    await tester.pumpAndSettle();
    expect(_pill(tester).size, const Size(84, 50));
    expect(_pill(tester).center, _item(tester, 90).center);
  });
}
