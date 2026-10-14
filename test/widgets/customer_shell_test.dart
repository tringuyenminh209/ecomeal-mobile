import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecomeal_mobile/features/auth/locale_controller.dart';
import 'package:ecomeal_mobile/features/home/customer_home_page.dart';
import 'package:ecomeal_mobile/features/home/home_gateway.dart';
import 'package:ecomeal_mobile/features/orders/order_gateway.dart';
import 'package:ecomeal_mobile/features/profile/profile_gateway.dart';
import 'package:ecomeal_mobile/features/payment/payment_gateway.dart';
import 'package:ecomeal_mobile/widgets/customer_shell.dart';
import '../helpers/fake_payment_gateway.dart';
import '../helpers/test_app.dart';

class MockHomeGateway extends Mock implements HomeGateway {}

class MockOrderGateway extends Mock implements OrderGateway {}

class MockProfileGateway extends Mock implements ProfileGateway {}

void main() {
  testWidgets('3 tab ホーム/予約/マイページ; mở tab 予約 → tải lại lịch sử; tab マイページ là SCR-M07 thật (Chương 18)', (tester) async {
    final home = MockHomeGateway();
    when(() => home.watchChanges(onChange: any(named: 'onChange'))).thenReturn(() {});
    when(() => home.fetchActiveListings()).thenAnswer((_) async => []);
    when(() => home.fetchTodayTrucks()).thenAnswer((_) async => []);
    final orders = MockOrderGateway();
    when(() => orders.fetchMyOrders()).thenAnswer((_) async => []);
    // SCR-M07 đọc ngôn ngữ hiện tại từ LocaleController (SharedPreferences) — cùng cách test Chương 15.
    SharedPreferences.setMockInitialValues({'preferred_language': 'ja'});
    final prefs = await SharedPreferences.getInstance();
    final profile = MockProfileGateway();
    when(() => profile.fetchMyProfile())
        .thenAnswer((_) async => const UserProfile(name: '利用 花子', nameKana: null, email: 'customer@ecomeal.test'));
    when(() => profile.isLineLinked()).thenAnswer((_) async => false);

    // Khung màn hình như frame Figma (390×844) — khung mặc định 800×600 đẩy nút ログアウト ra ngoài ListView.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeGatewayProvider.overrideWithValue(home),
          orderGatewayProvider.overrideWithValue(orders),
          profileGatewayProvider.overrideWithValue(profile),
          paymentGatewayProvider.overrideWithValue(FakePaymentGateway()),
          sharedPreferencesProvider.overrideWithValue(prefs),
          currentPositionProvider.overrideWith((ref) => Future.error(Exception('GPS denied'))),
        ],
        child: testApp(const CustomerShell()),
      ),
    );
    await tester.pumpAndSettle();
    // IndexedStack dựng cả 3 tab ngay từ đầu → lịch sử đã tải 1 lần.
    verify(() => orders.fetchMyOrders()).called(1);

    await tester.tap(find.byKey(const Key('navOrders')));
    await tester.pumpAndSettle();
    expect(find.text('予約履歴'), findsOneWidget);
    // viên thuốc của thanh tab đã trượt sang 予約 (chip lọc của 予約履歴 cũng có viên thuốc riêng)
    final tabPill = find.descendant(of: find.byKey(const Key('pillTabBar')), matching: find.byKey(const Key('slidingPill')));
    expect(tester.getCenter(tabPill).dx, closeTo(tester.getCenter(find.byKey(const Key('navOrders'))).dx, 0.5));
    verify(() => orders.fetchMyOrders()).called(1); // mở tab → tải lại

    await tester.tap(find.byKey(const Key('navProfile')));
    await tester.pumpAndSettle();
    expect(find.text('customer@ecomeal.test'), findsOneWidget);
    // ListView dựng lười: nút ở cuối マイページ chỉ tồn tại khi cuộn tới
    await tester.scrollUntilVisible(find.byKey(const Key('logoutButton')), 300, scrollable: find.byType(Scrollable).last);
    expect(find.byKey(const Key('logoutButton')), findsOneWidget);
  });
}
