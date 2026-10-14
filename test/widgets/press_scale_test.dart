import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/widgets/press_scale.dart';

Widget _app({bool reduceMotion = false, VoidCallback? onTap}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Scaffold(
      body: Center(
        child: InkWell(
          onTap: onTap,
          child: const PressScale(child: SizedBox(key: Key('box'), width: 80, height: 40)),
        ),
      ),
    ),
  ),
);

double _scale(WidgetTester tester) => tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

void main() {
  testWidgets('đang chạm → lún 0.96, thả ra → trở lại; nút bên trong vẫn nhận tap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_app(onTap: () => taps++));
    final gesture = await tester.startGesture(tester.getCenter(find.byKey(const Key('box'))));
    await tester.pump();
    expect(_scale(tester), pressedScale);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(_scale(tester), 1);
    expect(taps, 1);
  });

  testWidgets('bật "giảm chuyển động" → không lún', (tester) async {
    await tester.pumpWidget(_app(reduceMotion: true));
    final gesture = await tester.startGesture(tester.getCenter(find.byKey(const Key('box'))));
    await tester.pump();
    expect(_scale(tester), 1);
    await gesture.up();
  });
}
