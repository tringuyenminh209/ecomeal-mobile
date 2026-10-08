import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/features/payment/card_input.dart';
import 'package:ecomeal_mobile/features/payment/payment_gateway.dart';
import 'package:ecomeal_mobile/features/payment/payment_methods_page.dart';
import '../../helpers/fake_payment_gateway.dart';
import '../../helpers/test_app.dart';

void main() {
  late FakePaymentGateway gateway;

  setUp(() {
    gateway = FakePaymentGateway([
      FakePaymentGateway.card('pm-visa', CardBrand.visa, '3456', isDefault: true),
      FakePaymentGateway.card('pm-jcb', CardBrand.jcb, '1188'),
    ]);
  });

  Future<void> pump(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(overrides: [paymentGatewayProvider.overrideWithValue(gateway)], child: testApp(page)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('未登録 (Figma 378:3): trạng thái trống + nút thêm thẻ', (tester) async {
    gateway.methods = [];
    await pump(tester, const PaymentMethodsPage());

    expect(find.text('支払い方法が未登録です'), findsOneWidget);
    expect(find.text('＋ クレジットカードを追加'), findsOneWidget);
  });

  testWidgets('登録済み (378:54): thẻ mặc định đứng đầu có nhãn デフォルト, hiện hạn', (tester) async {
    await pump(tester, const PaymentMethodsPage());

    expect(find.text('Visa •••• 3456'), findsOneWidget);
    expect(find.text('JCB •••• 1188'), findsOneWidget);
    expect(find.text('デフォルト'), findsOneWidget);
    expect(find.text('有効期限 08/29'), findsNWidgets(2));
  });

  testWidgets('カード操作 → デフォルトに設定', (tester) async {
    await pump(tester, const PaymentMethodsPage());

    await tester.tap(find.byKey(const Key('paymentMethod-pm-jcb')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('setDefaultCardAction')));
    await tester.pumpAndSettle();

    expect(gateway.methods.firstWhere((m) => m.isDefault).id, 'pm-jcb');
    expect(find.text('デフォルトのカードを変更しました'), findsOneWidget);
  });

  testWidgets('カード削除確認 (405:5501) → 削除する → thẻ biến mất', (tester) async {
    await pump(tester, const PaymentMethodsPage());

    await tester.tap(find.byKey(const Key('paymentMethod-pm-jcb')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('deleteCardAction')));
    await tester.pumpAndSettle();
    expect(find.text('JCB •••• 1188 を削除します。削除すると、このカードは次回以降の注文に使えなくなります。'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirmDeleteCardButton')));
    await tester.pumpAndSettle();

    expect(find.text('JCB •••• 1188'), findsNothing);
    expect(gateway.methods.map((m) => m.id), ['pm-visa']);
  });

  testWidgets('chế độ chọn (từ SCR-M05): chạm thẻ → trả về id thẻ', (tester) async {
    String? picked;
    await pump(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            picked = await Navigator.of(context).push<String>(
              MaterialPageRoute(builder: (_) => const PaymentMethodsPage(isSelecting: true, selectedId: 'pm-visa')),
            );
          },
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('paymentMethod-pm-jcb')));
    await tester.pumpAndSettle();

    expect(picked, 'pm-jcb');
  });

  testWidgets('カードを追加 / 入力エラー (389:1011): sai số thẻ → báo lỗi, không gửi gì', (tester) async {
    await pump(tester, const PaymentMethodsPage());
    await tester.tap(find.byKey(const Key('addAnotherCardButton')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('cardNumberField')), '4242424242424241');
    await tester.enterText(find.byKey(const Key('cardHolderField')), 'MIKA');
    await tester.enterText(find.byKey(const Key('cardExpiryField')), '1230');
    await tester.enterText(find.byKey(const Key('cardCvcField')), '123');
    await tester.tap(find.byKey(const Key('addCardSubmitButton')));
    await tester.pumpAndSettle();

    expect(find.text('カード番号を確認してください。'), findsOneWidget);
    expect(gateway.added, isEmpty);
  });

  testWidgets('カードを追加: chỉ gửi hãng + 4 số cuối + hạn (không gửi số thẻ đầy đủ / CVC)', (tester) async {
    await pump(tester, const PaymentMethodsPage());
    await tester.tap(find.byKey(const Key('addAnotherCardButton')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('cardNumberField')), '3530111333300000');
    expect(find.text('3530  1113  3330  0000'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('cardHolderField')), 'MIKA HARUKA');
    await tester.enterText(find.byKey(const Key('cardExpiryField')), '0429');
    await tester.enterText(find.byKey(const Key('cardCvcField')), '123');
    await tester.tap(find.byKey(const Key('addCardSubmitButton')));
    await tester.pumpAndSettle();

    expect(gateway.added.single, (brand: CardBrand.jcb, last4: '0000', expiry: (month: 4, year: 2029)));
    expect(find.text('JCB •••• 0000'), findsOneWidget); // về lại danh sách, đã tải lại
  });
}
