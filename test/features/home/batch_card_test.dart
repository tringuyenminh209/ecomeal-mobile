import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/features/home/batch_card.dart';

Future<double> _rowHeight(WidgetTester tester, double scale) async {
  late double h;
  await tester.pumpWidget(MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: Builder(builder: (context) {
        h = BatchCard.rowHeight(context);
        return const SizedBox();
      }),
    ),
  ));
  return h;
}

void main() {
  testWidgets('hàng thẻ cao 168 (Figma) và cao theo cỡ chữ hệ thống, tối đa 1.8 lần', (tester) async {
    expect(await _rowHeight(tester, 1.0), 168);
    expect(await _rowHeight(tester, 1.5), closeTo(252, 0.01));
    expect(await _rowHeight(tester, 3.0), closeTo(168 * 1.8, 0.01));
  });
}
