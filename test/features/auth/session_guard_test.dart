import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent, AuthState, Session, User;
import 'package:ecomeal_mobile/features/auth/auth_controller.dart';
import 'package:ecomeal_mobile/features/auth/auth_gateway.dart';
import 'package:ecomeal_mobile/features/auth/locale_controller.dart';
import 'package:ecomeal_mobile/features/auth/session_guard.dart';
import 'package:ecomeal_mobile/l10n/l10n.dart';
import '../../helpers/test_app.dart';

class MockAuthGateway extends Mock implements AuthGateway {}

class MockSession extends Mock implements Session {}

class MockUser extends Mock implements User {}

// docs/proposals/2026-10-14_mobile-session-payment-bug.md — A: đăng xuất ở trang đã push vẫn đứng ở trang đó;
// B: server đã xoá phiên nhưng app vẫn như đang đăng nhập.
void main() {
  late MockAuthGateway gateway;
  late StreamController<AuthState> events;

  setUp(() {
    gateway = MockAuthGateway();
    events = StreamController<AuthState>.broadcast();
    final session = MockSession();
    final user = MockUser();
    when(() => session.user).thenReturn(user);
    when(() => user.id).thenReturn('u-1');
    when(() => gateway.currentSession).thenReturn(session);
    when(() => gateway.onAuthStateChange).thenAnswer((_) => events.stream);
    when(() => gateway.fetchProfile('u-1')).thenAnswer((_) async => (role: 'driver', languageCode: 'ja'));
    when(() => gateway.isSessionAlive()).thenAnswer((_) async => true);
    // signOut thật của SDK: xoá phiên trên máy rồi phát signedOut
    when(() => gateway.signOut()).thenAnswer((_) async => events.add(const AuthState(AuthChangeEvent.signedOut, null)));
  });
  tearDown(() => events.close());

  Future<void> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'preferred_language': 'ja'});
    final prefs = await SharedPreferences.getInstance();
    final navigatorKey = GlobalKey<NavigatorState>();
    final messengerKey = GlobalKey<ScaffoldMessengerState>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authGatewayProvider.overrideWithValue(gateway), sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: messengerKey,
          locale: const Locale('ja'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) =>
              SessionGuard(navigatorKey: navigatorKey, messengerKey: messengerKey, child: child!),
          home: Consumer(
            builder: (context, ref, _) {
              final signedIn = ref.watch(authControllerProvider).session != null;
              return Scaffold(
                body: Center(
                  child: signedIn
                      ? ElevatedButton(
                          key: const Key('openProfile'),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => Scaffold(body: Text('profile', key: const Key('profilePage'))),
                            ),
                          ),
                          child: const Text('open'),
                        )
                      : const Text('login', key: Key('loginPage')),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('openProfile')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profilePage')), findsOneWidget);
  }

  testWidgets('A: đăng xuất khi đang ở trang đã push → đóng trang đó, về màn đăng nhập, không báo hết phiên', (
    tester,
  ) async {
    await pumpApp(tester);
    events.add(const AuthState(AuthChangeEvent.signedOut, null));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profilePage')), findsNothing);
    expect(find.byKey(const Key('loginPage')), findsOneWidget);
    expect(find.text(l10nJa.errorSessionExpired), findsNothing);
  });

  testWidgets('B: quay lại app, server từ chối phiên → đăng xuất, về đăng nhập, báo 「ログインし直してください」', (tester) async {
    await pumpApp(tester);
    when(() => gateway.isSessionAlive()).thenAnswer((_) async => false);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    verify(() => gateway.signOut()).called(1);
    expect(find.byKey(const Key('profilePage')), findsNothing);
    expect(find.byKey(const Key('loginPage')), findsOneWidget);
    expect(find.text(l10nJa.errorSessionExpired), findsOneWidget);
  });

  testWidgets('B: quay lại app khi mất mạng (không biết) → giữ đăng nhập, không đóng trang', (tester) async {
    await pumpApp(tester);
    when(() => gateway.isSessionAlive()).thenAnswer((_) async => null);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    verifyNever(() => gateway.signOut());
    expect(find.byKey(const Key('profilePage')), findsOneWidget);
  });
}
