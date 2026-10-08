import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/widgets/skeleton.dart';

Widget _app({required bool reduceMotion}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: const Scaffold(body: SkeletonList(heights: [56, 88])),
      ),
    );

void main() {
  testWidgets('khung xương nhấp nháy chậm (animation đang chạy)', (tester) async {
    await tester.pumpWidget(_app(reduceMotion: false));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.hasRunningAnimations, isTrue);
    expect(find.byType(SkeletonBox), findsNWidgets(2));
  });

  testWidgets('bật "giảm chuyển động" → khối tĩnh (không có animation chạy mãi)', (tester) async {
    await tester.pumpWidget(_app(reduceMotion: true));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.hasRunningAnimations, isFalse);
  });
}
