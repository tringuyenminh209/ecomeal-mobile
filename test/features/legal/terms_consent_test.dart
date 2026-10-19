import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthState, Session, User;
import 'package:ecomeal_mobile/features/auth/auth_controller.dart';
import 'package:ecomeal_mobile/features/auth/auth_gateway.dart';
import 'package:ecomeal_mobile/features/auth/locale_controller.dart';
import 'package:ecomeal_mobile/features/auth/role_gate.dart';
import 'package:ecomeal_mobile/features/home/customer_home_page.dart';
import 'package:ecomeal_mobile/features/home/home_gateway.dart';
import 'package:ecomeal_mobile/features/legal/legal_pages.dart';
import 'package:ecomeal_mobile/features/legal/terms_gateway.dart';
import 'package:ecomeal_mobile/features/orders/order_gateway.dart';
import 'package:ecomeal_mobile/widgets/customer_shell.dart';
import '../../helpers/test_app.dart';

class MockAuthGateway extends Mock implements AuthGateway {}

class MockHomeGateway extends Mock implements HomeGateway {}

class MockOrderGateway extends Mock implements OrderGateway {}

class MockTermsGateway extends Mock implements TermsGateway {}

class MockSession extends Mock implements Session {}

class MockUser extends Mock implements User {}

// UC-36 改定時: khách đã đăng nhập nhưng users.terms_version ≠ currentTermsVersion → RoleGate hiện SCR-M10 同意が必要.
void main() {
  late MockAuthGateway auth;
  late MockTermsGateway terms;
  late SharedPreferences prefs;

  setUp(() async {
    auth = MockAuthGateway();
    terms = MockTermsGateway();
    final session = MockSession();
    final user = MockUser();
    when(() => session.user).thenReturn(user);
    when(() => user.id).thenReturn('u-1');
    when(() => auth.currentSession).thenReturn(session);
    when(() => auth.onAuthStateChange).thenAnswer((_) => const Stream<AuthState>.empty());
    when(() => auth.fetchProfile('u-1')).thenAnswer((_) async => (role: 'customer', languageCode: 'ja'));
    SharedPreferences.setMockInitialValues({'preferred_language': 'ja'});
    prefs = await SharedPreferences.getInstance();
  });

  Future<void> pumpGate(WidgetTester tester) async {
    final home = MockHomeGateway();
    when(() => home.watchChanges(onTrucks: any(named: 'onTrucks'), onListings: any(named: 'onListings'))).thenReturn(() {});
    when(() => home.fetchActiveListings()).thenAnswer((_) async => []);
    when(() => home.fetchTodayTrucks()).thenAnswer((_) async => []);
    final orders = MockOrderGateway();
    when(() => orders.fetchMyOrders()).thenAnswer((_) async => []);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authGatewayProvider.overrideWithValue(auth),
          termsGatewayProvider.overrideWithValue(terms),
          homeGatewayProvider.overrideWithValue(home),
          orderGatewayProvider.overrideWithValue(orders),
          sharedPreferencesProvider.overrideWithValue(prefs),
          currentPositionProvider.overrideWith((ref) => Future.error(Exception('GPS denied'))),
        ],
        child: testApp(const RoleGate()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('chưa đồng ý (NULL) → màn 「利用規約が更新されました」, không vào CustomerShell', (tester) async {
    when(() => terms.fetchAcceptedVersion('u-1')).thenAnswer((_) async => null);
    await pumpGate(tester);

    expect(find.byType(TermsConsentPage), findsOneWidget);
    expect(find.text('利用規約が更新されました'), findsOneWidget);
    expect(find.byType(CustomerShell), findsNothing);
  });

  testWidgets('đã đồng ý bản cũ → 同意して続ける → accept_terms(bản hiện hành) → CustomerShell', (tester) async {
    var accepted = '2026-01-01';
    when(() => terms.fetchAcceptedVersion('u-1')).thenAnswer((_) async => accepted);
    when(() => terms.acceptTerms(currentTermsVersion)).thenAnswer((_) async => accepted = currentTermsVersion);
    await pumpGate(tester);
    expect(find.byType(TermsConsentPage), findsOneWidget);

    await tester.tap(find.byKey(const Key('acceptTermsButton')));
    await tester.pumpAndSettle();

    verify(() => terms.acceptTerms(currentTermsVersion)).called(1);
    expect(find.byType(TermsConsentPage), findsNothing);
    expect(find.byType(CustomerShell), findsOneWidget);
  });

  testWidgets('accept_terms lỗi → SnackBar, vẫn ở màn đồng ý', (tester) async {
    when(() => terms.fetchAcceptedVersion('u-1')).thenAnswer((_) async => null);
    when(() => terms.acceptTerms(any())).thenThrow(Exception('network'));
    await pumpGate(tester);

    await tester.tap(find.byKey(const Key('acceptTermsButton')));
    await tester.pumpAndSettle();

    expect(find.text('同意を記録できませんでした。もう一度お試しください'), findsOneWidget);
    expect(find.byType(TermsConsentPage), findsOneWidget);
  });

  testWidgets('同意しない（ログアウト） → signOut', (tester) async {
    when(() => terms.fetchAcceptedVersion('u-1')).thenAnswer((_) async => null);
    when(() => auth.signOut()).thenAnswer((_) async {});
    await pumpGate(tester);

    await tester.tap(find.byKey(const Key('declineTermsButton')));
    await tester.pumpAndSettle();

    verify(() => auth.signOut()).called(1);
    verifyNever(() => terms.acceptTerms(any()));
  });

  testWidgets('đã đồng ý bản hiện hành → thẳng CustomerShell', (tester) async {
    when(() => terms.fetchAcceptedVersion('u-1')).thenAnswer((_) async => currentTermsVersion);
    await pumpGate(tester);

    expect(find.byType(CustomerShell), findsOneWidget);
    expect(find.byType(TermsConsentPage), findsNothing);
  });

  testWidgets('SCR-M11: đủ 5 mục, khung お問い合わせ mở trang liên hệ', (tester) async {
    var opened = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          openExternalUrlProvider.overrideWithValue((url) async {
            expect(url, contactPageUrl);
            return (opened++) >= 0;
          }),
        ],
        child: testApp(const LegalDocumentPage(document: LegalDocument.privacy)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('プライバシーポリシー'), findsOneWidget);
    expect(find.text('5. 開示・訂正・削除のご請求', skipOffstage: false), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('legalContactCard')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('legalContactCard')));
    expect(opened, 1);
  });
}
