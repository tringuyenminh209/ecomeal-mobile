import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/core/app_version.dart';
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
import 'package:ecomeal_mobile/features/legal/legal_pages.dart';
import 'package:ecomeal_mobile/features/favorites/favorite_stops.dart';
import 'package:ecomeal_mobile/features/favorites/favorite_stops_page.dart';
import '../../helpers/fake_favorite_stops.dart';
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
  late FakeFavoriteStopsGateway favoriteGateway;
  final openedUrls = <String>[];

  setUp(() async {
    SharedPreferences.setMockInitialValues({'preferred_language': 'ja'});
    prefs = await SharedPreferences.getInstance();
    profileGateway = MockProfileGateway();
    lineBridge = MockLineLoginBridge();
    authGateway = MockAuthGateway();
    paymentGateway = FakePaymentGateway();
    favoriteGateway = FakeFavoriteStopsGateway([]);
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
          favoriteStopsGatewayProvider.overrideWithValue(favoriteGateway),
          lineLoginBridgeProvider.overrideWithValue(lineBridge),
          authGatewayProvider.overrideWithValue(authGateway),
          sharedPreferencesProvider.overrideWithValue(prefs),
          openLineOfficialAccountProvider.overrideWithValue(openLine),
          appVersionProvider.overrideWith((ref) async => '1.0.0'),
          openExternalUrlProvider.overrideWithValue((url) async {
            openedUrls.add(url);
            return true;
          }),
        ],
        child: testApp(const MyPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('kéo mạnh xuống ở đầu trang → trang không trượt quá mép rồi bật lại (ClampingScrollPhysics)', (tester) async {
    when(() => profileGateway.isLineLinked()).thenAnswer((_) async => false);
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await pumpPage(tester);
    final list = find.byKey(const Key('myPageList'));
    final before = tester.getTopLeft(find.text('春香 美香'));
    final gesture = await tester.startGesture(tester.getCenter(list));
    await gesture.moveBy(const Offset(0, 300));
    await tester.pump();
    expect(tester.getTopLeft(find.text('春香 美香')), before); // không bị kéo xuống theo ngón tay
    await gesture.up();
    await tester.pumpAndSettle();
    debugDefaultTargetPlatformOverride = null;
  });

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

    // ListView dựng lười: nút ở cuối (dưới 「アプリについて」) chưa tồn tại cho tới khi cuộn tới
    await tester.scrollUntilVisible(find.byKey(const Key('logoutButton')), 200);
    await tester.ensureVisible(find.byKey(const Key('logoutButton'))); // cuộn tới khi thấy CẢ nút, không chỉ mép trên
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('logoutButton')));
    await tester.pumpAndSettle();
    expect(find.text('ログアウトしますか？'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirmLogoutButton')));
    await tester.pumpAndSettle();

    verify(() => authGateway.signOut()).called(1);
  });

  testWidgets('0053 「お気に入りの受取地点」: hiện số điểm → chạm mở SCR-M16', (tester) async {
    when(() => profileGateway.isLineLinked()).thenAnswer((_) async => false);
    favoriteGateway.favorites.add(const FavoriteStop(stopLocationId: 'stop-1', name: '大阪学生寮前'));
    await pumpPage(tester);

    expect(find.text('1件 ・ 新しいフードバッグをお知らせ'), findsOneWidget);
    await tester.tap(find.byKey(const Key('favoriteStopsRow')));
    await tester.pumpAndSettle();
    expect(find.byType(FavoriteStopsPage), findsOneWidget);
    expect(find.text('大阪学生寮前'), findsOneWidget);
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

  testWidgets('「アプリについて」: バージョン 1.0.0, 利用規約 → SCR-M10, プライバシーポリシー → SCR-M11 (Figma 419:5532)', (tester) async {
    when(() => profileGateway.isLineLinked()).thenAnswer((_) async => false);
    await pumpPage(tester);

    await tester.scrollUntilVisible(find.byKey(const Key('termsRow')), 200);
    await tester.ensureVisible(find.byKey(const Key('termsRow')));
    await tester.pumpAndSettle();
    expect(find.text('アプリについて'), findsOneWidget);
    expect(find.text('1.0.0'), findsOneWidget);

    await tester.tap(find.byKey(const Key('termsRow')));
    await tester.pumpAndSettle();
    expect(find.byType(LegalDocumentPage), findsOneWidget);
    expect(find.text('第10条（変更・停止・免責）', skipOffstage: false), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('privacyRow')));
    await tester.pumpAndSettle();
    expect(find.text('1. 取得する情報'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // 特定商取引法に基づく表記 → site công khai (bản tiếng Nhật vì ngôn ngữ đang là ja)
    openedUrls.clear();
    await tester.tap(find.byKey(const Key('tokushohoRow')));
    expect(openedUrls, ['https://ecomeal-site.vercel.app/tokushoho/']);
  });

  testWidgets('có avatar_path → xin URL ký và hiện ảnh (UC-35)', (tester) async {
    when(() => profileGateway.isLineLinked()).thenAnswer((_) async => false);
    when(() => profileGateway.fetchMyProfile()).thenAnswer(
      (_) async => const UserProfile(name: '春香 美香', nameKana: null, email: 'mika@example.jp', avatarPath: 'u-1/a.jpg'),
    );
    when(() => profileGateway.signedAvatarUrl('u-1/a.jpg')).thenAnswer((_) async => 'https://example.test/a.jpg');
    await pumpPage(tester);

    verify(() => profileGateway.signedAvatarUrl('u-1/a.jpg')).called(1);
    expect(find.byKey(const Key('profileAvatarImage')), findsOneWidget);
  });
}
