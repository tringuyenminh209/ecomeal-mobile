import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecomeal_mobile/core/line_menu_link.dart';
import 'package:ecomeal_mobile/core/screen_brightness.dart';
import 'package:ecomeal_mobile/features/auth/locale_controller.dart';
import 'package:ecomeal_mobile/features/home/customer_home_page.dart';
import 'package:ecomeal_mobile/features/home/home_gateway.dart';
import 'package:ecomeal_mobile/features/orders/active_order_page.dart';
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
  _lineMenuTests();

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

// LINE Rich Menu ô A–D (Figma 905:187): CustomerShell mở đích LineMenuLinks đang giữ
class _NoBrightness implements ScreenBrightnessControl {
  @override
  Future<void> raise() async {}
  @override
  Future<void> restore() async {}
}

OrderSummary _order(String id, String status) => OrderSummary(
  id: id,
  status: status,
  pricePaid: 650,
  createdAt: DateTime.utc(2026, 10, 18, 9),
  plannedPickupTime: DateTime.utc(2026, 10, 18, 11, 10),
  stopName: '大阪学生寮前',
  taxRate: 8,
  taxAmount: 48,
);

Future<void> _pumpShell(WidgetTester tester, {required LineMenuLinks links, required List<OrderSummary> orders}) async {
  final home = MockHomeGateway();
  when(() => home.watchChanges(onChange: any(named: 'onChange'))).thenReturn(() {});
  when(() => home.fetchActiveListings()).thenAnswer((_) async => []);
  when(() => home.fetchTodayTrucks()).thenAnswer((_) async => []);
  final orderGateway = MockOrderGateway();
  when(() => orderGateway.fetchMyOrders()).thenAnswer((_) async => orders);
  SharedPreferences.setMockInitialValues({'preferred_language': 'ja'});
  final prefs = await SharedPreferences.getInstance();
  final profile = MockProfileGateway();
  when(() => profile.fetchMyProfile()).thenAnswer((_) async => const UserProfile(name: '利用 花子', nameKana: null, email: 'c@ecomeal.test'));
  when(() => profile.isLineLinked()).thenAnswer((_) async => false);
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        homeGatewayProvider.overrideWithValue(home),
        orderGatewayProvider.overrideWithValue(orderGateway),
        profileGatewayProvider.overrideWithValue(profile),
        paymentGatewayProvider.overrideWithValue(FakePaymentGateway()),
        sharedPreferencesProvider.overrideWithValue(prefs),
        currentPositionProvider.overrideWith((ref) => Future.error(Exception('GPS denied'))),
        lineMenuLinksProvider.overrideWithValue(links),
        // SCR-M18 hỏi lại đơn mỗi 15 giây — test không phát gì: màn dùng đúng đơn được mở
        activeOrderProvider.overrideWith((ref, _) => const Stream.empty()),
        screenBrightnessProvider.overrideWithValue(_NoBrightness()),
      ],
      child: testApp(const CustomerShell()),
    ),
  );
  await tester.pumpAndSettle();
}

void _lineMenuTests() {
  group('LINE Rich Menu → CustomerShell', () {
    testWidgets('C 受取QR: đúng 1 đơn đã giữ chỗ → mở thẳng SCR-M18 受け取りの案内', (tester) async {
      final links = LineMenuLinks()..receive(Uri.parse('/?to=pickup'));
      await _pumpShell(tester, links: links, orders: [_order('a1b2c3d4-0000-0000-0000-000000000001', 'allocated'), _order('a1b2c3d4-0000-0000-0000-000000000002', 'picked_up')]);
      expect(find.byType(ActiveOrderPage), findsOneWidget);
      expect(links.take(), isNull); // đã dùng
    });

    testWidgets('C 受取QR: chưa có đơn giữ chỗ → tab 予約 (trạng thái trống), không có QR', (tester) async {
      final links = LineMenuLinks()..receive(Uri.parse('/?to=pickup'));
      await _pumpShell(tester, links: links, orders: [_order('a1b2c3d4-0000-0000-0000-000000000001', 'pending')]);
      expect(find.byType(ActiveOrderPage), findsNothing);
      expect(find.text('予約履歴'), findsOneWidget);
    });

    testWidgets('C 受取QR: 2 đơn giữ chỗ → tab 予約 để tự chọn', (tester) async {
      final links = LineMenuLinks()..receive(Uri.parse('/?to=pickup'));
      await _pumpShell(tester, links: links, orders: [_order('a1b2c3d4-0000-0000-0000-000000000001', 'allocated'), _order('a1b2c3d4-0000-0000-0000-000000000002', 'allocated')]);
      expect(find.byType(ActiveOrderPage), findsNothing);
      expect(find.text('予約履歴'), findsOneWidget);
    });

    testWidgets('B 予約一覧 bấm khi app đang mở (đang ở ホーム) → chuyển sang tab 予約', (tester) async {
      final links = LineMenuLinks();
      await _pumpShell(tester, links: links, orders: const []);
      expect(find.text('予約履歴'), findsNothing);
      links.receive(Uri.parse('/?to=reservations'));
      await tester.pumpAndSettle();
      expect(find.text('予約履歴'), findsOneWidget);
    });

    testWidgets('A / D → ở lại ホーム (tab 予約 không hiện)', (tester) async {
      final links = LineMenuLinks()..receive(Uri.parse('/?to=stops'));
      await _pumpShell(tester, links: links, orders: const []);
      expect(find.text('予約履歴'), findsNothing);
      links.receive(Uri.parse('/?to=reservations'));
      await tester.pumpAndSettle();
      links.receive(Uri.parse('/?to=browse'));
      await tester.pumpAndSettle();
      expect(find.text('予約履歴'), findsNothing);
    });
  });
}
