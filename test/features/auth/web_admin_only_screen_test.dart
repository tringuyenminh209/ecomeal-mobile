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
import 'package:ecomeal_mobile/features/auth/web_admin_only_screen.dart';
import '../../helpers/test_app.dart';

class MockAuthGateway extends Mock implements AuthGateway {}

class MockSession extends Mock implements Session {}

class MockUser extends Mock implements User {}

// Tài khoản 飲食店・運営 đăng nhập app (Figma 244:1414): không vào màn khách/tài xế, chỉ đường sang Web Admin.
void main() {
  late MockAuthGateway gateway;

  setUp(() {
    gateway = MockAuthGateway();
    final session = MockSession();
    final user = MockUser();
    when(() => session.user).thenReturn(user);
    when(() => user.id).thenReturn('u-1');
    when(() => gateway.currentSession).thenReturn(session);
    when(() => gateway.onAuthStateChange).thenAnswer((_) => const Stream<AuthState>.empty());
  });

  Future<void> pumpGate(WidgetTester tester, {required String role, required Future<bool> Function() openWebAdmin}) async {
    when(() => gateway.fetchProfile('u-1')).thenAnswer((_) async => (role: role, languageCode: 'ja'));
    SharedPreferences.setMockInitialValues({'preferred_language': 'ja'});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authGatewayProvider.overrideWithValue(gateway),
          sharedPreferencesProvider.overrideWithValue(prefs),
          openWebAdminProvider.overrideWithValue(openWebAdmin),
        ],
        child: testApp(const RoleGate()),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final role in ['restaurant_owner', 'admin']) {
    testWidgets('$role → màn chỉ đường Web Admin; nút mở Web Admin gọi trình duyệt ngoài', (tester) async {
      var opened = 0;
      await pumpGate(tester, role: role, openWebAdmin: () async {
        opened++;
        return true;
      });

      expect(find.byType(WebAdminOnlyScreen), findsOneWidget);
      expect(find.text(l10nJa.webOnlyAccountTitle), findsOneWidget);
      expect(find.byKey(const Key('logoutButton')), findsOneWidget);
      await tester.tap(find.byKey(const Key('openWebAdminButton')));
      await tester.pumpAndSettle();
      expect(opened, 1);
    });
  }

  testWidgets('không mở được trình duyệt → toast lỗi', (tester) async {
    await pumpGate(tester, role: 'admin', openWebAdmin: () async => false);

    await tester.tap(find.byKey(const Key('openWebAdminButton')));
    await tester.pump();
    expect(find.text(l10nJa.errorOpenWebAdmin), findsOneWidget);
  });
}
