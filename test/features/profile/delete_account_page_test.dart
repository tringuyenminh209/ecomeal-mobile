import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ecomeal_mobile/features/orders/order_gateway.dart';
import 'package:ecomeal_mobile/features/profile/delete_account_page.dart';
import 'package:ecomeal_mobile/features/profile/profile_gateway.dart';
import '../../helpers/test_app.dart';

class MockProfileGateway extends Mock implements ProfileGateway {}

class MockOrderGateway extends Mock implements OrderGateway {}

OrderSummary _order(String status) => OrderSummary(
      id: 'o-$status',
      status: status,
      pricePaid: 500,
      createdAt: DateTime(2026, 10, 9, 18),
      plannedPickupTime: DateTime(2026, 10, 9, 19),
      stopName: '梅田',
      taxRate: 8,
      taxAmount: 0,
    );

// UC-37 / API-051: SCR-M12 アカウントの削除 (Figma 425:1075 / 425:1141 / 425:1171).
void main() {
  late MockProfileGateway profile;
  late MockOrderGateway orders;

  setUp(() {
    profile = MockProfileGateway();
    orders = MockOrderGateway();
  });

  // Mở bằng push từ 1 màn giả (giống SCR-M07) để kiểm được việc quay về màn gốc sau khi xoá.
  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileGatewayProvider.overrideWithValue(profile),
          orderGatewayProvider.overrideWithValue(orders),
        ],
        child: testApp(
          Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const DeleteAccountPage())),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  FilledButton deleteButton(WidgetTester tester) => tester.widget<FilledButton>(find.byKey(const Key('deleteAccountButton')));

  testWidgets('chỉ có đơn đã xong → nút bật; xác nhận → deleteMyAccount → về màn gốc + SnackBar', (tester) async {
    when(() => orders.fetchMyOrders()).thenAnswer((_) async => [_order('picked_up'), _order('cancelled')]);
    when(() => profile.deleteMyAccount()).thenAnswer((_) async {});
    await pumpPage(tester);

    expect(find.text('削除されるもの'), findsOneWidget);
    expect(find.byKey(const Key('openReservationsBanner')), findsNothing);
    expect(deleteButton(tester).onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('deleteAccountButton')));
    await tester.pumpAndSettle();
    expect(find.text('アカウントを削除しますか？'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirmDeleteAccountButton')));
    await tester.pumpAndSettle();

    verify(() => profile.deleteMyAccount()).called(1);
    expect(find.byType(DeleteAccountPage), findsNothing);
    expect(find.text('アカウントを削除しました'), findsOneWidget);
  });

  testWidgets('huỷ ở hộp thoại → không xoá', (tester) async {
    when(() => orders.fetchMyOrders()).thenAnswer((_) async => []);
    await pumpPage(tester);

    await tester.tap(find.byKey(const Key('deleteAccountButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();

    verifyNever(() => profile.deleteMyAccount());
    expect(find.byType(DeleteAccountPage), findsOneWidget);
  });

  for (final status in ['pending', 'allocated']) {
    testWidgets('còn đơn $status → banner đỏ, nút khoá (425:1141)', (tester) async {
      when(() => orders.fetchMyOrders()).thenAnswer((_) async => [_order(status)]);
      await pumpPage(tester);

      expect(find.byKey(const Key('openReservationsBanner')), findsOneWidget);
      expect(deleteButton(tester).onPressed, isNull);
    });
  }

  testWidgets('server trả E-ACCOUNT-409 (đơn mới phát sinh) → hiện banner, vẫn ở trang', (tester) async {
    when(() => orders.fetchMyOrders()).thenAnswer((_) async => []);
    when(() => profile.deleteMyAccount()).thenThrow(const OpenReservationsException());
    await pumpPage(tester);

    await tester.tap(find.byKey(const Key('deleteAccountButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmDeleteAccountButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('openReservationsBanner')), findsOneWidget);
    expect(deleteButton(tester).onPressed, isNull);
  });

  testWidgets('lỗi mạng khi xoá → SnackBar lỗi, vẫn ở trang', (tester) async {
    when(() => orders.fetchMyOrders()).thenAnswer((_) async => []);
    when(() => profile.deleteMyAccount()).thenThrow(Exception('network'));
    await pumpPage(tester);

    await tester.tap(find.byKey(const Key('deleteAccountButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmDeleteAccountButton')));
    await tester.pumpAndSettle();

    expect(find.text('アカウントを削除できませんでした。もう一度お試しください'), findsOneWidget);
    expect(find.byType(DeleteAccountPage), findsOneWidget);
  });

  testWidgets('không tải được danh sách đơn → màn lỗi + 再試行, nút khoá', (tester) async {
    when(() => orders.fetchMyOrders()).thenThrow(Exception('network'));
    await pumpPage(tester);

    expect(find.text('再試行'), findsOneWidget);
    expect(deleteButton(tester).onPressed, isNull);
  });
}
