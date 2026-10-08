import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/widgets/value_change.dart';

Widget _app(int price, {bool reduceMotion = false}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(body: ValueChange(value: price, child: Text('¥$price'))),
      ),
    );

void main() {
  testWidgets('giá đổi → giá cũ mờ dần và giá mới trượt vào (cả 2 cùng có mặt giữa chừng)', (tester) async {
    await tester.pumpWidget(_app(450));
    await tester.pumpWidget(_app(220));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('¥450'), findsOneWidget);
    expect(find.text('¥220'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('¥450'), findsNothing);
    expect(find.text('¥220'), findsOneWidget);
  });

  testWidgets('bật "giảm chuyển động" → đổi ngay, không có khung hình chuyển tiếp', (tester) async {
    await tester.pumpWidget(_app(450, reduceMotion: true));
    await tester.pumpWidget(_app(220, reduceMotion: true));
    await tester.pump();
    expect(find.text('¥450'), findsNothing);
    expect(find.text('¥220'), findsOneWidget);
  });
}
