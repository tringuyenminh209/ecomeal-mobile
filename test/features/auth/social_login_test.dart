import 'package:ecomeal_mobile/core/line_login_bridge.dart';
import 'package:ecomeal_mobile/features/auth/auth_controller.dart';
import 'package:ecomeal_mobile/features/auth/auth_gateway.dart';
import 'package:ecomeal_mobile/features/auth/locale_controller.dart';
import 'package:ecomeal_mobile/features/auth/login_signup_page.dart';
import 'package:ecomeal_mobile/features/auth/social_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthState;
import '../../helpers/test_app.dart';

class MockAuthGateway extends Mock implements AuthGateway {}

class FakeLineBridge implements LineLoginBridge {
  Object? error;
  @override
  Future<String> obtainIdToken() async {
    final e = error;
    if (e != null) throw e;
    return 'line-id-token';
  }
}

class FakeAppleBridge implements AppleSignInBridge {
  AppleCredential? credential = (idToken: 'apple-id-token', rawNonce: 'nonce', fullName: '山田 花子');
  @override
  Future<AppleCredential?> obtainCredential() async => credential;
}

void main() {
  late MockAuthGateway gateway;
  late SharedPreferences prefs;
  late FakeLineBridge line;
  late FakeAppleBridge apple;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    gateway = MockAuthGateway();
    line = FakeLineBridge();
    apple = FakeAppleBridge();
    when(() => gateway.currentSession).thenReturn(null);
    when(() => gateway.onAuthStateChange).thenAnswer((_) => const Stream<AuthState>.empty());
    when(() => gateway.signInWithLineIdToken(idToken: any(named: 'idToken'), languageCode: any(named: 'languageCode')))
        .thenAnswer((_) async {});
    when(() => gateway.signInWithAppleIdToken(
          idToken: any(named: 'idToken'),
          rawNonce: any(named: 'rawNonce'),
          fullName: any(named: 'fullName'),
        )).thenAnswer((_) async {});
  });

  Future<void> pump(WidgetTester tester, {bool lineOn = true, bool appleOn = true}) async {
    tester.view.physicalSize = const Size(390, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authGatewayProvider.overrideWithValue(gateway),
        sharedPreferencesProvider.overrideWithValue(prefs),
        lineLoginAvailableProvider.overrideWithValue(lineOn),
        appleLoginAvailableProvider.overrideWithValue(appleOn),
        lineLoginBridgeProvider.overrideWithValue(line),
        appleSignInBridgeProvider.overrideWithValue(apple),
      ],
      child: testApp(const LoginSignupPage()),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('SCR-M02 (Figma 483:1395): 「LINEでログイン」→ ID token LINE + ngôn ngữ hiện tại gửi cho line-login', (tester) async {
    await pump(tester);
    expect(find.text('または'), findsOneWidget);
    await tester.tap(find.byKey(const Key('lineLoginButton')));
    await tester.pumpAndSettle();
    verify(() => gateway.signInWithLineIdToken(idToken: 'line-id-token', languageCode: 'ja')).called(1);
    expect(find.byKey(const Key('socialLoginError')), findsNothing);
  });

  testWidgets('「Appleでサインイン」→ idToken + nonce gốc + tên (lần đầu)', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('appleLoginButton')));
    await tester.pumpAndSettle();
    verify(() => gateway.signInWithAppleIdToken(idToken: 'apple-id-token', rawNonce: 'nonce', fullName: '山田 花子')).called(1);
  });

  testWidgets('đóng màn Apple / huỷ ở LINE → không báo lỗi, không đăng nhập', (tester) async {
    apple.credential = null;
    line.error = PlatformException(code: 'CANCEL');
    await pump(tester);
    await tester.tap(find.byKey(const Key('appleLoginButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lineLoginButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('socialLoginError')), findsNothing);
    verifyNever(() => gateway.signInWithLineIdToken(idToken: any(named: 'idToken'), languageCode: any(named: 'languageCode')));
  });

  testWidgets('tài khoản quán/tài xế (E-AUTH-403) → câu riêng (Figma 483:1462 vị trí banner)', (tester) async {
    when(() => gateway.signInWithLineIdToken(idToken: any(named: 'idToken'), languageCode: any(named: 'languageCode')))
        .thenThrow(const SocialLoginException('E-AUTH-403'));
    await pump(tester);
    await tester.tap(find.byKey(const Key('lineLoginButton')));
    await tester.pumpAndSettle();
    expect(find.text('このアカウントはLINEでログインできません。メールアドレスとパスワードでログインしてください'), findsOneWidget);
  });

  testWidgets('chưa cấu hình LINE/Apple (Android không có Apple) → không có nút, không có 「または」', (tester) async {
    await pump(tester, lineOn: false, appleOn: false);
    expect(find.byKey(const Key('lineLoginButton')), findsNothing);
    expect(find.text('または'), findsNothing);
    await pump(tester, lineOn: true, appleOn: false);
    expect(find.byKey(const Key('lineLoginButton')), findsOneWidget);
    expect(find.byKey(const Key('appleLoginButton')), findsNothing);
  });

  test('socialLoginErrorMessage / isLineCancel / isLineOnlyEmail', () {
    expect(socialLoginErrorMessage(Exception('x'), l10nJa, isLine: true), 'LINEでログインできませんでした。時間をおいて、もう一度お試しください');
    expect(socialLoginErrorMessage(Exception('x'), l10nJa, isLine: false), 'Appleでサインインできませんでした。時間をおいて、もう一度お試しください');
    expect(isLineCancel(PlatformException(code: 'CANCEL')), isTrue);
    expect(isLineCancel(PlatformException(code: 'AUTHENTICATION_AGENT_ERROR')), isFalse);
    expect(isLineOnlyEmail('line_u1@line.ecomeal.invalid'), isTrue);
    expect(isLineOnlyEmail('a@example.com'), isFalse);
  });
}
