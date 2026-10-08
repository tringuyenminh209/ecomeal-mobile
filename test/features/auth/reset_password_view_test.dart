import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthChangeEvent, AuthException, AuthState, Session, User;
import 'package:ecomeal_mobile/features/auth/auth_controller.dart';
import 'package:ecomeal_mobile/features/auth/auth_gateway.dart';
import 'package:ecomeal_mobile/features/auth/locale_controller.dart';
import 'package:ecomeal_mobile/features/auth/login_signup_page.dart';
import 'package:ecomeal_mobile/features/auth/role_gate.dart';
import '../../helpers/test_app.dart';

class MockAuthGateway extends Mock implements AuthGateway {}

class MockSession extends Mock implements Session {}

class MockUser extends Mock implements User {}

// UC-28 (SCR-M02 パスワード再設定). Dựng qua RoleGate thật: điểm dễ hỏng nhất là mã đúng tạo session
// rồi RoleGate rời SCR-M02 trước khi người dùng kịp đổi mật khẩu.
void main() {
  late MockAuthGateway gateway;
  late StreamController<AuthState> authEvents;
  late MockSession session;

  setUp(() {
    gateway = MockAuthGateway();
    authEvents = StreamController<AuthState>.broadcast();
    session = MockSession();
    final user = MockUser();
    when(() => session.user).thenReturn(user);
    when(() => user.id).thenReturn('u-1');
    when(() => gateway.currentSession).thenReturn(null);
    when(() => gateway.onAuthStateChange).thenAnswer((_) => authEvents.stream);
    // restaurant_owner → RoleGate hiện WebAdminOnlyScreen, không cần giả lập gateway của màn khách.
    when(() => gateway.fetchProfile('u-1')).thenAnswer((_) async => (role: 'restaurant_owner', languageCode: 'ja'));
    when(() => gateway.requestPasswordReset(any())).thenAnswer((_) async {});
    // Giống Supabase thật: mã đúng → phát signedIn TRƯỚC khi verifyOTP trả về.
    when(
      () => gateway.verifyRecoveryCode(email: any(named: 'email'), code: any(named: 'code')),
    ).thenAnswer((_) async {
      authEvents.add(AuthState(AuthChangeEvent.signedIn, session));
      await pumpEventQueue();
    });
    when(() => gateway.updatePassword(any())).thenAnswer((_) async {});
    when(() => gateway.signOut()).thenAnswer((_) async {
      authEvents.add(AuthState(AuthChangeEvent.signedOut, null));
    });
  });

  tearDown(() => authEvents.close());

  Future<void> pumpGate(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'preferred_language': 'ja'});
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

  // Từ ログイン → こちら → gửi mã tới email → đang ở bước ②.
  Future<void> openCodeStep(WidgetTester tester) async {
    await pumpGate(tester);
    await tester.tap(find.byKey(const Key('forgotPasswordLink')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('resetEmailField')), ' taro@example.jp ');
    await tester.tap(find.byKey(const Key('resetSendCodeButton')));
    await tester.pumpAndSettle();
  }

  Future<void> submitCode(WidgetTester tester, {String code = '482913', String password = 'newpass123'}) async {
    await tester.enterText(find.byKey(const Key('resetCodeField')), code);
    await tester.enterText(find.byKey(const Key('resetPasswordField')), password);
    await tester.tap(find.byKey(const Key('resetSubmitButton')));
    await tester.pumpAndSettle();
  }

  testWidgets('gửi mã: email đã trim, chuyển sang bước nhập mã + mật khẩu mới (API-028)', (tester) async {
    await openCodeStep(tester);

    verify(() => gateway.requestPasswordReset('taro@example.jp')).called(1);
    expect(find.text(l10nJa.resetPasswordCodeLead('taro@example.jp')), findsOneWidget);
    expect(find.byKey(const Key('resetCodeField')), findsOneWidget);
  });

  testWidgets('mã sai định dạng / mật khẩu < 8 → chặn ở client, KHÔNG gọi verify', (tester) async {
    await openCodeStep(tester);
    await submitCode(tester, code: '12ab', password: '1234567');

    expect(find.text(l10nJa.errorVerificationCodeFormat), findsOneWidget);
    expect(find.text(l10nJa.errorPasswordMin8), findsOneWidget);
    verifyNever(() => gateway.verifyRecoveryCode(email: any(named: 'email'), code: any(named: 'code')));
  });

  testWidgets('mã sai/hết hạn → banner E-AUTH-412, không đổi mật khẩu, vẫn ở SCR-M02', (tester) async {
    when(
      () => gateway.verifyRecoveryCode(email: any(named: 'email'), code: any(named: 'code')),
    ).thenThrow(const AuthException('Token has expired or is invalid', statusCode: '403', code: 'otp_expired'));
    await openCodeStep(tester);
    await submitCode(tester);

    expect(find.text(l10nJa.errorVerificationCodeInvalid), findsOneWidget);
    verifyNever(() => gateway.updatePassword(any()));
    expect(find.byType(LoginSignupPage), findsOneWidget);
  });

  testWidgets('mã đúng → session có ngay nhưng VẪN ở SCR-M02 tới khi đổi mật khẩu xong (RoleGate)', (tester) async {
    final update = Completer<void>();
    when(() => gateway.updatePassword(any())).thenAnswer((_) => update.future);
    await openCodeStep(tester);
    await tester.enterText(find.byKey(const Key('resetCodeField')), '482913');
    await tester.enterText(find.byKey(const Key('resetPasswordField')), 'newpass123');
    await tester.tap(find.byKey(const Key('resetSubmitButton')));
    // updatePassword đang treo → spinner quay mãi, pumpAndSettle không dừng được.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    verify(() => gateway.verifyRecoveryCode(email: 'taro@example.jp', code: '482913')).called(1);
    expect(find.byType(LoginSignupPage), findsOneWidget);
    expect(find.byKey(const Key('resetPasswordField')), findsOneWidget);

    update.complete();
    await tester.pumpAndSettle();
    verify(() => gateway.updatePassword('newpass123')).called(1);
    expect(find.byType(LoginSignupPage), findsNothing);
    expect(find.text(l10nJa.webOnlyAccountTitle), findsOneWidget);
    expect(find.text(l10nJa.passwordResetDone), findsOneWidget);
  });

  testWidgets('trùng mật khẩu cũ (E-AUTH-413) → lỗi dưới ô, thử lại chỉ đổi mật khẩu, không verify lại', (
    tester,
  ) async {
    var attempt = 0;
    when(() => gateway.updatePassword(any())).thenAnswer((_) async {
      if (attempt++ == 0) {
        throw const AuthException('New password should be different', statusCode: '422', code: 'same_password');
      }
    });
    await openCodeStep(tester);
    await submitCode(tester, password: 'oldpass123');

    expect(find.text(l10nJa.errorSamePassword), findsOneWidget);
    expect(find.byType(LoginSignupPage), findsOneWidget);

    await tester.enterText(find.byKey(const Key('resetPasswordField')), 'brandnew123');
    await tester.tap(find.byKey(const Key('resetSubmitButton')));
    await tester.pumpAndSettle();

    verify(() => gateway.verifyRecoveryCode(email: any(named: 'email'), code: any(named: 'code'))).called(1);
    verify(() => gateway.updatePassword('brandnew123')).called(1);
    expect(find.byType(LoginSignupPage), findsNothing);
  });

  testWidgets('mã đã đúng rồi bấm quay lại → đăng xuất, về tab ログイン', (tester) async {
    when(() => gateway.updatePassword(any())).thenThrow(Exception('offline'));
    await openCodeStep(tester);
    await submitCode(tester);
    expect(find.text(l10nJa.errorNetwork), findsOneWidget);

    await tester.tap(find.byKey(const Key('resetBackButton')));
    await tester.pumpAndSettle();

    verify(() => gateway.signOut()).called(1);
    expect(find.byKey(const Key('loginSubmitButton')), findsOneWidget);
  });

  testWidgets('gửi mã bị giới hạn tần suất → E-AUTH-429, vẫn ở bước nhập email', (tester) async {
    when(() => gateway.requestPasswordReset(any())).thenThrow(
      const AuthException('Email rate limit exceeded', statusCode: '429', code: 'over_email_send_rate_limit'),
    );
    await openCodeStep(tester);

    expect(find.text(l10nJa.errorRateLimited), findsOneWidget);
    expect(find.byKey(const Key('resetEmailField')), findsOneWidget);
  });
}
