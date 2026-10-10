import 'package:ecomeal_mobile/features/profile/my_impact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/test_app.dart';

MyImpact _impact(int bags) => MyImpact(
      bags: bags,
      foodKg: bags * 0.5,
      co2Kg: double.parse((bags * 0.5 * 2.26).toStringAsFixed(1)),
      foodKgPerBag: 0.5,
      co2KgPerFoodKg: 2.26,
    );

Future<void> _pump(WidgetTester tester, Future<MyImpact> Function() loader, {Locale locale = const Locale('ja')}) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [myImpactLoaderProvider.overrideWithValue(loader)],
    child: testApp(const Scaffold(body: MyImpactCard()), locale: locale),
  ));
  await tester.pumpAndSettle();
}

void main() {
  test('MyImpact.fromJson: số từ server (numeric có thể là int hoặc double)', () {
    final i = MyImpact.fromJson({'bags': 12, 'food_kg': 6, 'co2_kg': 13.6, 'food_kg_per_bag': 0.5, 'co2_kg_per_food_kg': 2.26});
    expect(i.bags, 12);
    expect(i.foodKg, 6.0);
    expect(i.co2Kg, 13.6);
  });

  testWidgets('có đơn đã nhận → số túi, 約kg, CO₂ và ghi chú hệ số (Figma 465:1290)', (tester) async {
    await _pump(tester, () async => _impact(12));
    expect(find.text('12個'), findsOneWidget);
    expect(find.text('約6.0kg'), findsOneWidget);
    expect(find.text('約13.6kg'), findsOneWidget);
    expect(find.text('推定値です（1袋 約0.5kg、食品ロス1kgあたりCO₂ 約2.26kg で計算）'), findsOneWidget);
  });

  testWidgets('chưa nhận túi nào → câu hướng dẫn (465:1397)', (tester) async {
    await _pump(tester, () async => _impact(0));
    expect(find.text('フードバッグを受け取ると、ここに救った食品の量とCO₂の削減量が表示されます。'), findsOneWidget);
    expect(find.text('0個'), findsNothing);
  });

  testWidgets('lỗi tải → không hiện thẻ (không làm hỏng マイページ)', (tester) async {
    await _pump(tester, () async => throw Exception('offline'));
    expect(find.byKey(const Key('myImpactCard')), findsNothing);
  });

  testWidgets('locale en', (tester) async {
    await _pump(tester, () async => _impact(2), locale: const Locale('en'));
    expect(find.text('Food you have saved'), findsOneWidget);
    expect(find.text('~1.0 kg'), findsOneWidget);
  });
}
