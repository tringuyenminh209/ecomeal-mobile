import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, AuthState;
import 'package:ecomeal_mobile/features/auth/auth_controller.dart';
import 'package:ecomeal_mobile/features/auth/auth_gateway.dart';
import 'package:ecomeal_mobile/features/auth/locale_controller.dart';
import 'package:ecomeal_mobile/features/auth/login_signup_page.dart';
import '../../helpers/test_app.dart';

class MockAuthGateway extends Mock implements AuthGateway {}

void main() {
  late MockAuthGateway gateway;
  late SharedPreferences prefs;

  setUp(() async {
    // Tab đăng ký đọc localeControllerProvider (preferred_language) → cần override
    // sharedPreferencesProvider giống main.dart, nếu không provider ném UnimplementedError.
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    gateway = MockAuthGateway();
    when(() => gateway.currentSession).thenReturn(null);
    when(
      () => gateway.onAuthStateChange,
    ).thenAnswer((_) => const Stream<AuthState>.empty());
  });

  Future<void> pumpPage(WidgetTester tester) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          authGatewayProvider.overrideWithValue(gateway),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: testApp(const LoginSignupPage()),
      ),
    );
  }

  testWidgets('mật khẩu 7 ký tự bị chặn trước khi gọi signUp', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('新規登録'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('signupNameField')), '山田太郎');
    await tester.enterText(
      find.byKey(const Key('signupEmailField')),
      'new@ecomeal.test',
    );
    await tester.enterText(
      find.byKey(const Key('signupPasswordField')),
      '1234567',
    );
    await tester.tap(find.byKey(const Key('signupSubmitButton')));
    await tester.pumpAndSettle();
    expect(find.text('パスワードは8文字以上で入力してください'), findsOneWidget);
    verifyNever(
      () => gateway.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        data: any(named: 'data'),
      ),
    );
  });

  testWidgets('email sai định dạng và lỗi mạng được xử lý', (tester) async {
    await pumpPage(tester);
    await tester.enterText(find.byKey(const Key('loginEmailField')), 'a@');
    await tester.enterText(
      find.byKey(const Key('loginPasswordField')),
      'password123',
    );
    await tester.tap(find.byKey(const Key('loginSubmitButton')));
    await tester.pumpAndSettle();
    expect(find.text(l10nJa.errorEmailRequired), findsOneWidget);
    verifyNever(
      () => gateway.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
    when(
      () => gateway.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(Exception('offline'));
    await tester.enterText(
      find.byKey(const Key('loginEmailField')),
      'a@example.com',
    );
    await tester.tap(find.byKey(const Key('loginSubmitButton')));
    await tester.pumpAndSettle();
    expect(find.text(l10nJa.errorNetwork), findsOneWidget);
  });

  testWidgets(
    'submit khi để trống email/password → báo lỗi validate, KHÔNG gọi gateway',
    (tester) async {
      await pumpPage(tester);
      await tester.tap(find.byKey(const Key('loginSubmitButton')));
      await tester.pumpAndSettle();

      expect(find.text('メールアドレスを入力してください'), findsOneWidget);
      expect(find.text('パスワードを入力してください'), findsOneWidget);
      verifyNever(
        () => gateway.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    },
  );

  testWidgets('form đăng nhập: nút 表示 hiện mật khẩu, bấm lại (非表示) thì ẩn', (tester) async {
    await pumpPage(tester);
    await tester.pumpAndSettle();

    EditableText passwordText() => tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const Key('loginPasswordField')),
        matching: find.byType(EditableText),
      ),
    );
    expect(passwordText().obscureText, isTrue);

    await tester.tap(find.byKey(const Key('loginPasswordToggle')));
    await tester.pump();
    expect(passwordText().obscureText, isFalse);
    expect(find.text('非表示'), findsOneWidget);

    await tester.tap(find.byKey(const Key('loginPasswordToggle')));
    await tester.pump();
    expect(passwordText().obscureText, isTrue);
  });

  testWidgets('nhập đủ hợp lệ → gọi gateway.signInWithPassword đúng tham số', (
    tester,
  ) async {
    when(
      () => gateway.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});
    await pumpPage(tester);

    await tester.enterText(
      find.byKey(const Key('loginEmailField')),
      'customer@ecomeal.test',
    );
    await tester.enterText(
      find.byKey(const Key('loginPasswordField')),
      'password123',
    );
    await tester.tap(find.byKey(const Key('loginSubmitButton')));
    await tester.pumpAndSettle();

    verify(
      () => gateway.signInWithPassword(
        email: 'customer@ecomeal.test',
        password: 'password123',
      ),
    ).called(1);
  });

  testWidgets(
    'đăng nhập khi email chưa xác nhận → hiện đúng message E-AUTH-410 (Chương 10 box-why)',
    (tester) async {
      when(
        () => gateway.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        const AuthException(
          'Email not confirmed',
          statusCode: '400',
          code: 'email_not_confirmed',
        ),
      );
      await pumpPage(tester);

      await tester.enterText(
        find.byKey(const Key('loginEmailField')),
        'unconfirmed@ecomeal.test',
      );
      await tester.enterText(
        find.byKey(const Key('loginPasswordField')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('loginSubmitButton')));
      await tester.pumpAndSettle();

      expect(find.text('メールアドレスの確認が完了していません。受信ボックスをご確認ください'), findsOneWidget);
    },
  );

  testWidgets(
    'đăng ký thành công → chuyển sang trạng thái "確認メールを送信しました" (UC-25)',
    (tester) async {
      when(
        () => gateway.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async {});
      await pumpPage(tester);

      await tester.tap(find.text('新規登録'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('signupNameField')), '山田太郎');
      await tester.enterText(
        find.byKey(const Key('signupEmailField')),
        'new@ecomeal.test',
      );
      await tester.enterText(
        find.byKey(const Key('signupPasswordField')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('signupSubmitButton')));
      await tester.pumpAndSettle();

      expect(find.text('確認メールを送信しました'), findsOneWidget);
    },
  );

  testWidgets(
    'đăng ký bị giới hạn tần suất (HTTP 429) → hiện E-AUTH-429, KHÔNG chuyển sang "確認メール"',
    (tester) async {
      when(
        () => gateway.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      ).thenThrow(
        const AuthException(
          'Email rate limit exceeded',
          statusCode: '429',
          code: 'over_email_send_rate_limit',
        ),
      );
      await pumpPage(tester);

      await tester.tap(find.text('新規登録'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('signupNameField')), '山田太郎');
      await tester.enterText(
        find.byKey(const Key('signupEmailField')),
        'new@ecomeal.test',
      );
      await tester.enterText(
        find.byKey(const Key('signupPasswordField')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('signupSubmitButton')));
      await tester.pumpAndSettle();

      expect(find.text('しばらく時間をおいてから再度お試しください'), findsOneWidget);
      expect(find.text('確認メールを送信しました'), findsNothing);
    },
  );

  testWidgets(
    'đăng ký trùng email (E-AUTH-409) → lỗi hiện ngay dưới ô email, không phải banner (Figma 新規登録 / Error)',
    (tester) async {
      when(
        () => gateway.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      ).thenThrow(
        const AuthException(
          'User already registered',
          statusCode: '422',
          code: 'user_already_exists',
        ),
      );
      await pumpPage(tester);

      await tester.tap(find.text('新規登録'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('signupNameField')), '山田太郎');
      await tester.enterText(
        find.byKey(const Key('signupEmailField')),
        'customer@ecomeal.test',
      );
      await tester.enterText(
        find.byKey(const Key('signupPasswordField')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('signupSubmitButton')));
      await tester.pumpAndSettle();

      final emailField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('signupEmailField')),
          matching: find.byType(TextField),
        ),
      );
      expect(emailField.decoration?.errorText, l10nJa.errorEmailAlreadyRegistered);
      expect(find.text('確認メールを送信しました'), findsNothing);
    },
  );
}
