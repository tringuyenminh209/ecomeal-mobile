import 'package:ecomeal_mobile/features/coupons/coupons.dart';
import 'package:ecomeal_mobile/features/coupons/coupons_page.dart';
import 'package:ecomeal_mobile/features/legal/legal_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import '../../helpers/fake_coupons.dart';
import '../../helpers/test_app.dart';

void main() {
  group('hàm thuần', () {
    test('couponDiscount: khách trả tối thiểu ¥50 (cùng công thức coupon_discount 0056)', () {
      expect(couponDiscount(100, 650), 100);
      expect(couponDiscount(1000, 300), 250);
      expect(couponDiscount(100, 40), 0);
    });

    test('bestCoupon: giảm nhiều nhất, bằng nhau thì sắp hết hạn trước', () {
      final soon = FakeCouponsGateway.coupon('soon', days: 3);
      final later = FakeCouponsGateway.coupon('later', days: 30);
      final big = FakeCouponsGateway.coupon('big', amount: 300, days: 50);
      expect(bestCoupon([later, soon])!.id, 'soon');
      expect(bestCoupon([later, soon, big])!.id, 'big');
      expect(bestCoupon([]), isNull);
    });

    test('referralErrorMessage: map mã lỗi', () {
      expect(referralErrorMessage(const PostgrestException(message: 'E-REF-404: x'), l10nJa), 'この紹介コードは見つかりません');
      expect(referralErrorMessage(const PostgrestException(message: 'E-REF-409: x'), l10nJa), 'ご自身の紹介コードは使えません');
      expect(referralErrorMessage(const PostgrestException(message: 'E-REF-410: x'), l10nJa), '紹介コードを入力できる期間が過ぎています');
      expect(referralErrorMessage(Exception('net'), l10nJa), '紹介コードを適用できませんでした。もう一度お試しください');
    });

    test('lineShareUri: line.me/R/share?text=… (mã hoá đúng)', () {
      expect(lineShareUri('コード ABC').toString(), startsWith('https://line.me/R/share?text='));
      expect(lineShareUri('a b').queryParameters['text'], 'a b');
    });
  });

  group('SCR-M19', () {
    late FakeCouponsGateway gateway;
    final opened = <String>[];

    Future<void> pump(WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          couponsGatewayProvider.overrideWithValue(gateway),
          openExternalUrlProvider.overrideWithValue((url) async {
            opened.add(url);
            return true;
          }),
        ],
        child: testApp(const CouponsPage()),
      ));
      await tester.pumpAndSettle();
    }

    setUp(() {
      gateway = FakeCouponsGateway();
      opened.clear();
    });

    testWidgets('mã của mình + nhập mã bạn bè → nhận coupon, ô nhập biến mất, hiện 「適用しました」 (470:1518 → 470:1579)', (tester) async {
      await pump(tester);
      expect(find.text('EM7K2Q'), findsOneWidget);
      expect(find.text('使えるクーポンはありません'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('referralCodeInput')), 'em3px9');
      await tester.tap(find.byKey(const Key('applyReferralButton')));
      await tester.pumpAndSettle();

      expect(gateway.applied, ['EM3PX9']);
      expect(find.text('¥100クーポンを受け取りました'), findsOneWidget);
      expect(find.byKey(const Key('referralCodeInput')), findsNothing);
      expect(find.text('紹介コード EM3PX9 を適用しました'), findsOneWidget);
      expect(find.text('友だち紹介クーポン（登録特典）'), findsOneWidget);
    });

    testWidgets('mã sai độ dài → báo ngay, không gọi server; server báo E-REF-404 → câu lỗi', (tester) async {
      await pump(tester);
      await tester.enterText(find.byKey(const Key('referralCodeInput')), 'ABC');
      await tester.tap(find.byKey(const Key('applyReferralButton')));
      await tester.pumpAndSettle();
      expect(find.text('6文字の紹介コードを入力してください'), findsOneWidget);
      expect(gateway.applied, isEmpty);

      gateway.applyError = const PostgrestException(message: 'E-REF-404: referral code not found');
      await tester.enterText(find.byKey(const Key('referralCodeInput')), 'ZZZZZZ');
      await tester.tap(find.byKey(const Key('applyReferralButton')));
      await tester.pumpAndSettle();
      expect(find.text('この紹介コードは見つかりません'), findsOneWidget);
    });

    testWidgets('「LINEで送る」 → mở line.me/R/share với mã trong nội dung', (tester) async {
      gateway.referral = const MyReferral(code: 'EM7K2Q', canApply: false, invited: 2, rewarded: 1);
      await pump(tester);
      expect(find.byKey(const Key('referralCodeInput')), findsNothing);
      await tester.tap(find.byKey(const Key('shareReferralLine')));
      await tester.pumpAndSettle();
      expect(opened.single, startsWith('https://line.me/R/share?text='));
      expect(Uri.parse(opened.single).queryParameters['text'], contains('EM7K2Q'));
    });
  });
}
