import 'package:ecomeal_mobile/widgets/tap_outside_to_unfocus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({VoidCallback? onButton}) => MaterialApp(
  builder: (context, child) => TapOutsideToUnfocus(child: child!),
  home: Scaffold(
    body: Column(
      children: [
        const TextField(key: Key('a')),
        const TextField(key: Key('b')),
        ElevatedButton(key: const Key('button'), onPressed: onButton, child: const Text('OK')),
        const Expanded(child: SizedBox.expand(key: Key('blank'))),
      ],
    ),
  ),
);

bool _hasFocus(WidgetTester tester, String key) =>
    tester.widget<EditableText>(find.descendant(of: find.byKey(Key(key)), matching: find.byType(EditableText))).focusNode.hasFocus;

void main() {
  testWidgets('chạm vào chỗ trống → ô nhập mất focus (bàn phím hạ xuống)', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.byKey(const Key('a')));
    await tester.pump();
    expect(_hasFocus(tester, 'a'), isTrue);
    expect(tester.testTextInput.isVisible, isTrue);

    await tester.tap(find.byKey(const Key('blank')));
    await tester.pump();
    expect(_hasFocus(tester, 'a'), isFalse);
    expect(tester.testTextInput.isVisible, isFalse);
  });

  testWidgets('chạm sang ô nhập khác → focus chuyển sang ô đó (không bị bỏ focus)', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.byKey(const Key('a')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('b')));
    await tester.pump();
    expect(_hasFocus(tester, 'b'), isTrue);
  });

  testWidgets('nút vẫn nhận chạm như bình thường', (tester) async {
    var pressed = 0;
    await tester.pumpWidget(_app(onButton: () => pressed++));
    await tester.tap(find.byKey(const Key('button')));
    await tester.pump();
    expect(pressed, 1);
  });
}
