import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthState, Session, User;
import 'package:ecomeal_mobile/features/auth/auth_controller.dart';
import 'package:ecomeal_mobile/features/auth/auth_gateway.dart';
import 'package:ecomeal_mobile/features/auth/locale_controller.dart';
import 'package:ecomeal_mobile/features/auth/login_signup_page.dart';
import 'package:ecomeal_mobile/features/auth/onboarding_page.dart';
import 'package:ecomeal_mobile/features/auth/role_gate.dart';
import 'package:ecomeal_mobile/app.dart';
import 'package:ecomeal_mobile/core/app_flavor.dart';
import 'package:ecomeal_mobile/features/auth/driver_login_page.dart';
import '../../helpers/test_app.dart';
import 'package:ecomeal_mobile/features/home/customer_home_page.dart';
import 'package:ecomeal_mobile/features/home/home_gateway.dart';
import 'package:ecomeal_mobile/features/driver/driver_gateway.dart';
import 'package:ecomeal_mobile/features/orders/order_gateway.dart';
import 'package:ecomeal_mobile/widgets/customer_shell.dart';
import 'package:ecomeal_mobile/widgets/driver_shell.dart';

class MockAuthGateway extends Mock implements AuthGateway {}

class MockHomeGateway extends Mock implements HomeGateway {}

class MockOrderGateway extends Mock implements OrderGateway {}

class MockDriverGateway extends Mock implements DriverGateway {}

class MockSession extends Mock implements Session {}

class MockUser extends Mock implements User {}

void main() {
  late MockAuthGateway gateway;

  setUp(() {
    gateway = MockAuthGateway();
    when(() => gateway.currentSession).thenReturn(null);
    when(
      () => gateway.onAuthStateChange,
    ).thenAnswer((_) => const Stream<AuthState>.empty());
  });

  for (final role in ['customer', 'driver']) {
    testWidgets('$role vào đúng màn và đồng bộ ngôn ngữ server', (
      tester,
    ) async {
      final home = MockHomeGateway();
      when(
        () => home.watchChanges(onChange: any(named: 'onChange')),
      ).thenReturn(() {});
      when(() => home.fetchActiveListings()).thenAnswer((_) async => []);
      when(() => home.fetchTodayTrucks()).thenAnswer((_) async => []);
      // CustomerShell (Chương 17) dựng sẵn cả tab 予約 trong IndexedStack → cần gateway đơn hàng giả.
      final orders = MockOrderGateway();
      when(() => orders.fetchMyOrders()).thenAnswer((_) async => []);
      // DriverShell (Chương 19): chưa gán xe → không bật GPS, D01 hiện trạng thái "chưa có xe".
      final driver = MockDriverGateway();
      when(() => driver.fetchTonightRoute()).thenAnswer((_) async => null);
      when(() => driver.fetchIsActive()).thenAnswer((_) async => true);
      final session = MockSession();
      final user = MockUser();
      when(() => session.user).thenReturn(user);
      when(() => user.id).thenReturn('u-1');
      when(() => gateway.currentSession).thenReturn(session);
      when(
        () => gateway.fetchProfile('u-1'),
      ).thenAnswer((_) async => (role: role, languageCode: 'en'));
      SharedPreferences.setMockInitialValues({'preferred_language': 'ja'});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeGatewayProvider.overrideWithValue(home),
            orderGatewayProvider.overrideWithValue(orders),
            driverGatewayProvider.overrideWithValue(driver),
            currentPositionProvider.overrideWith(
              (ref) => Future.error(Exception("GPS denied")),
            ),
            authGatewayProvider.overrideWithValue(gateway),
            sharedPreferencesProvider.overrideWithValue(prefs),
            // ADR-007: khách mở app khách, tài xế mở app tài xế
            appFlavorProvider.overrideWithValue(role == 'customer' ? AppFlavor.customer : AppFlavor.driver),
          ],
          child: const EcoMealApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(role == 'customer' ? 'Home' : 'Route'), findsOneWidget); // nhãn tab đầu (en)
      expect(prefs.getString('preferred_language'), 'en');
      expect(find.byType(LoginSignupPage), findsNothing);
      expect(find.byType(CustomerShell), role == 'customer' ? findsOneWidget : findsNothing);
      expect(find.byType(DriverShell), role == 'driver' ? findsOneWidget : findsNothing);
    });
  }

  Future<void> pumpGate(
    WidgetTester tester,
    Map<String, Object> prefsValues,
  ) async {
    SharedPreferences.setMockInitialValues(prefsValues);
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authGatewayProvider.overrideWithValue(gateway),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: testApp(const RoleGate()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'lần đầu: SCR-M01 → chọn 日本語 → SCR-M02, RoleGate VẪN là route gốc (regression Chương 15)',
    (tester) async {
      await pumpGate(tester, {});
      expect(find.byType(OnboardingPage), findsOneWidget);

      await tester.tap(find.byKey(const Key('selectJapaneseButton')));
      await tester.pumpAndSettle();

      expect(find.byType(LoginSignupPage), findsOneWidget);
      // Nếu Onboarding còn pushReplacement như bản cũ, RoleGate bị thay mất → sau khi đăng nhập không
      // còn ai đưa người dùng vào màn chính.
      expect(find.byType(RoleGate), findsOneWidget);
    },
  );

  testWidgets(
    'đã chọn ngôn ngữ trước đó (vd vừa đăng xuất ở SCR-M07) → vào thẳng SCR-M02',
    (tester) async {
      await pumpGate(tester, {'preferred_language': 'en'});
      expect(find.byType(LoginSignupPage), findsOneWidget);
      expect(find.byType(OnboardingPage), findsNothing);
    },
  );

  // REQ-015: chọn English ở SCR-M01 → mọi chữ của màn kế tiếp đổi ngay sang tiếng Anh. Dùng EcoMealApp thật
  // (main.dart) vì chính nó nối localeControllerProvider vào MaterialApp.locale.
  testWidgets(
    'chọn English ở SCR-M01 → SCR-M02 hiển thị tiếng Anh, lưu "en" cho lần mở sau',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authGatewayProvider.overrideWithValue(gateway),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const EcoMealApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(l10nJa.onboardingHeadline),
        findsOneWidget,
      ); // lần đầu: mặc định ja

      await tester.tap(find.byKey(const Key('selectEnglishButton')));
      await tester.pumpAndSettle();

      expect(find.text('Log in'), findsNWidgets(3)); // tab + tiêu đề + nút
      expect(find.text('Sign up'), findsOneWidget);
      expect(find.text('ログイン'), findsNothing);
      expect(prefs.getString('preferred_language'), 'en');
    },
  );

  // ---- ADR-007: mỗi app chỉ mở luồng của mình ----
  Future<void> pumpApp(WidgetTester tester, AppFlavor flavor, {String? role, bool active = true}) async {
    final driver = MockDriverGateway();
    when(() => driver.fetchIsActive()).thenAnswer((_) async => active);
    when(() => driver.fetchTonightRoute()).thenAnswer((_) async => null);
    if (role != null) {
      final session = MockSession();
      final user = MockUser();
      when(() => session.user).thenReturn(user);
      when(() => user.id).thenReturn('u-1');
      when(() => gateway.currentSession).thenReturn(session);
      when(() => gateway.fetchProfile('u-1')).thenAnswer((_) async => (role: role, languageCode: 'ja'));
    }
    SharedPreferences.setMockInitialValues({'preferred_language': 'ja'});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authGatewayProvider.overrideWithValue(gateway),
          sharedPreferencesProvider.overrideWithValue(prefs),
          driverGatewayProvider.overrideWithValue(driver),
          currentPositionProvider.overrideWith((ref) => Future.error(Exception('GPS denied'))),
          appFlavorProvider.overrideWithValue(flavor),
        ],
        child: const EcoMealApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('app tài xế, chưa đăng nhập → SCR-D00 (không có màn giới thiệu, không có 新規登録)', (tester) async {
    await pumpApp(tester, AppFlavor.driver);
    expect(find.byType(DriverLoginPage), findsOneWidget);
    expect(find.byType(OnboardingPage), findsNothing);
    expect(find.text(l10nJa.driverBadge), findsOneWidget);
    expect(find.text(l10nJa.driverAccountIssuedNote), findsOneWidget);
    expect(find.text(l10nJa.signupTab), findsNothing);
  });

  testWidgets('SCR-D00: nút ngôn ngữ đổi sang tiếng Anh ngay và lưu lại', (tester) async {
    await pumpApp(tester, AppFlavor.driver);
    await tester.tap(find.byKey(const Key('switchLanguageButton')));
    await tester.pumpAndSettle();
    expect(find.text(l10nEn.driverLoginLead), findsOneWidget);
    expect(find.text(l10nEn.switchLanguageLabel), findsOneWidget); // giờ nút hiện 「日本語」
  });

  for (final role in ['customer', 'restaurant_owner', 'admin']) {
    testWidgets('app tài xế + tài khoản $role → 「ドライバー専用アプリです」, không vào màn tài xế', (tester) async {
      await pumpApp(tester, AppFlavor.driver, role: role);
      expect(find.text(l10nJa.driverOnlyAppTitle), findsOneWidget);
      expect(find.byType(DriverShell), findsNothing);
      expect(find.byType(CustomerShell), findsNothing);
    });
  }

  testWidgets('app khách + tài khoản tài xế → 「ドライバー用アカウントです」 (Figma 351:1178)', (tester) async {
    await pumpApp(tester, AppFlavor.customer, role: 'driver');
    expect(find.text(l10nJa.driverAccountTitle), findsOneWidget);
    expect(find.byType(DriverShell), findsNothing);
  });

  testWidgets('app tài xế + tài khoản bị tạm dừng (is_active=false) → 「稼働が停止されています」', (tester) async {
    await pumpApp(tester, AppFlavor.driver, role: 'driver', active: false);
    expect(find.text(l10nJa.driverSuspendedTitle), findsOneWidget);
    expect(find.byType(DriverShell), findsNothing);
  });

  testWidgets('app tài xế + tài xế đang hoạt động → DriverShell, theme tối', (tester) async {
    await pumpApp(tester, AppFlavor.driver, role: 'driver');
    expect(find.byType(DriverShell), findsOneWidget);
    final ctx = tester.element(find.byType(DriverShell));
    expect(Theme.of(ctx).brightness, Brightness.dark);
  });
}
