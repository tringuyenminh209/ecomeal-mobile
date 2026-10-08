import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthState;
import 'package:ecomeal_mobile/core/line_login_bridge.dart';
import 'package:ecomeal_mobile/core/line_official_account.dart';
import 'package:ecomeal_mobile/features/auth/auth_controller.dart';
import 'package:ecomeal_mobile/features/auth/auth_gateway.dart';
import 'package:ecomeal_mobile/features/auth/locale_controller.dart';
import 'package:ecomeal_mobile/features/payment/card_input.dart';
import 'package:ecomeal_mobile/features/payment/payment_gateway.dart';
import 'package:ecomeal_mobile/features/profile/my_page.dart';
import 'package:ecomeal_mobile/features/profile/profile_gateway.dart';
import '../../helpers/fake_payment_gateway.dart';
import '../../helpers/test_app.dart';

class MockProfileGateway extends Mock implements ProfileGateway {}

class MockLineLoginBridge extends Mock implements LineLoginBridge {}

class MockAuthGateway extends Mock implements AuthGateway {}

void main() {
  late MockProfileGateway profileGateway;
  late MockLineLoginBridge lineBridge;
  late MockAuthGateway authGateway;
  late SharedPreferences prefs;
  late FakePaymentGateway paymentGateway;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'preferred_language': 'ja'});
    prefs = await SharedPreferences.getInstance();
    profileGateway = MockProfileGateway();
    lineBridge = MockLineLoginBridge();
    authGateway = MockAuthGateway();
    paymentGateway = FakePaymentGateway();
    when(() => profileGateway.fetchMyProfile()).thenAnswer(
      (_) async => const UserProfile(name: '春香 美香', nameKana: null, email: 'mika@example.jp'),
    );
    when(() => authGateway.currentSession).thenReturn(null);
    when(() => authGateway.onAuthStateChange).thenAnswer((_) => const Stream<AuthState>.empty());
  });

  Future<void> pumpPage(WidgetTester tester, {Future<bool> Function()? openLine}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileGatewayProvider.overrideWithValue(profileGateway),
          paymentGatewayProvider.overrideWithValue(paymentGateway),
          lineLoginBridgeProvider.overrideWithValue(lineBridge),
          authGatewayProvider.overrideWithValue(authGateway),
          sharedPreferencesProvider.overrideWithValue(prefs),
          openLineOfficialAccountProvider.overrideWithValue(openLine),
        ],
        child: testApp(const MyPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('chưa liên kết LINE → bấm "LINEと連携する" → gửi ID token lên server → hiện "LINE連携済み"', (tester) async {
    var linked = false;
    when(() => profileGateway.isLineLinked()).thenAnswer((_) async => linked);
    when(() => lineBridge.obtainIdToken()).thenAnswer((_) async => 'id-token-xyz');
    when(() => profileGateway.linkLineAccount('id-token-xyz')).thenAnswer((_) async => linked = true);
    await pumpPage(tester);

    expect(find.text('春香 美香'), findsOneWidget);
    expect(find.text('mika@example.jp'), findsOneWidget);
    await tester.tap(find.text('LINEと連携する'));
    await tester.pumpAndSettle();

    verify(() => profileGateway.linkLineAccount('id-token-xyz')).called(1);
    expect(find.byKey(const Key('lineLinkedCard')), findsOneWidget);
    expect(find.byKey(const Key('lineLinkButton')), findsNothing);
  });

  testWidgets('đã liên kết → nút LINEでトークを開く mở Official Account; mở thất bại → toast lỗi', (tester) async {
    when(() => profileGateway.isLineLinked()).thenAnswer((_) async => true);
    var result = true;
    var calls = 0;
    await pumpPage(tester, openLine: () async {
      calls++;
      return result;
    });

    expect(find.text(l10nJa.lineLinkHint), findsOneWidget);
    await tester.tap(find.byKey(const Key('lineOpenChatButton')));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(find.text(l10nJa.errorOpenLine), findsNothing);

    result = false;
    await tester.tap(find.byKey(const Key('lineOpenChatButton')));
    await tester.pump();
    expect(find.text(l10nJa.errorOpenLine), findsOneWidget);
  });

  testWidgets('chưa cấu hình LINE_OFFICIAL_ACCOUNT_ID → không hiện nút mở LINE (không mở link hỏng)', (tester) async {
    when(() => profileGateway.isLineLinked()).thenAnswer((_) async => true);
    await pumpPage(tester);

    expect(find.byKey(const Key('lineLinkedCard')), findsOneWidget);
    expect(find.byKey(const Key('lineOpenChatButton')), findsNothing);
  });

  testWidgets('liên kết LINE lỗi → banner lỗi đúng câu chữ + nút đổi thành "もう一度試す"', (tester) async {
    when(() => profileGateway.isLineLinked()).thenAnswer((_) async => false);
    when(() => lineBridge.obtainIdToken()).thenAnswer((_) async => 'id-token-xyz');
    when(() => profileGateway.linkLineAccount(any())).thenThrow(Exception('E-AUTH-402'));
    await pumpPage(tester);

    await tester.tap(find.text('LINEと連携する'));
    await tester.pumpAndSettle();

    expect(find.text('LINE連携に失敗しました。もう一度お試しください'), findsOneWidget);
    expect(find.text('もう一度試す'), findsOneWidget);
  });

  // レビュー第30回: query trạng thái lỗi KHÔNG được hiểu là "chưa liên kết" — người đã liên kết sẽ bị mời liên kết lại.
  testWidgets('đọc trạng thái LINE lỗi → hiện lỗi + 再試行, KHÔNG hiện nút "LINEと連携する"; thử lại OK → hiện đúng trạng thái', (tester) async {
    var failing = true;
    when(() => profileGateway.isLineLinked()).thenAnswer((_) async {
      if (failing) throw Exception('network error');
      return true;
    });
    await pumpPage(tester);

    expect(find.byKey(const Key('lineStatusError')), findsOneWidget);
    expect(find.byKey(const Key('lineLinkButton')), findsNothing);

    failing = false;
    await tester.tap(find.byKey(const Key('retryLineStatusButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('lineLinkedCard')), findsOneWidget);
    expect(find.byKey(const Key('lineStatusError')), findsNothing);
  });

  testWidgets('đổi sang English → lưu preferred_language lên server (API-023) rồi mới đổi locale', (tester) async {
    when(() => profileGateway.isLineLinked()).thenAnswer((_) async => false);
    when(() => profileGateway.updatePreferredLanguage('en')).thenAnswer((_) async {});
    await pumpPage(tester);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    verify(() => profileGateway.updatePreferredLanguage('en')).called(1);
    expect(prefs.getString('preferred_language'), 'en');
  });

  testWidgets('đăng xuất: hiện dialog xác nhận → bấm ログアウト → gọi signOut()', (tester) async {
    when(() => profileGateway.isLineLinked()).thenAnswer((_) async => true);
    when(() => authGateway.signOut()).thenAnswer((_) async {});
    await pumpPage(tester);

    await tester.ensureVisible(find.byKey(const Key('logoutButton')));
    await tester.tap(find.byKey(const Key('logoutButton')));
    await tester.pumpAndSettle();
    expect(find.text('ログアウトしますか？'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirmLogoutButton')));
    await tester.pumpAndSettle();

    verify(() => authGateway.signOut()).called(1);
  });

  testWidgets('「支払い方法」 hiện thẻ mặc định (Figma 16:16656) → chạm mở SCR-M09', (tester) async {
    when(() => profileGateway.isLineLinked()).thenAnswer((_) async => false);
    paymentGateway.methods = [
      FakePaymentGateway.card('pm-jcb', CardBrand.jcb, '1188'),
      FakePaymentGateway.card('pm-visa', CardBrand.visa, '3456', isDefault: true),
    ];
    await pumpPage(tester);

    expect(find.text('Visa •••• 3456 ・ デフォルト'), findsOneWidget);
    await tester.tap(find.byKey(const Key('paymentMethodRow')));
    await tester.pumpAndSettle();
    expect(find.text('登録済みカード'), findsOneWidget);
  });

  testWidgets('chưa có thẻ → 「未登録」', (tester) async {
    when(() => profileGateway.isLineLinked()).thenAnswer((_) async => false);
    await pumpPage(tester);

    expect(find.text('未登録'), findsOneWidget);
  });
}
