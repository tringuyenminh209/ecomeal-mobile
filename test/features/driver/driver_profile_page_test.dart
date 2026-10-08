import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthState;
import 'package:ecomeal_mobile/features/auth/auth_controller.dart';
import 'package:ecomeal_mobile/features/auth/auth_gateway.dart';
import 'package:ecomeal_mobile/features/driver/driver_account_gateway.dart';
import 'package:ecomeal_mobile/features/driver/driver_gateway.dart';
import 'package:ecomeal_mobile/features/driver/driver_profile_page.dart';
import 'package:ecomeal_mobile/features/profile/profile_gateway.dart';
import '../../helpers/test_app.dart';
import 'driver_test_data.dart';

class MockProfileGateway extends Mock implements ProfileGateway {}

class MockDriverGateway extends Mock implements DriverGateway {}

class MockAuthGateway extends Mock implements AuthGateway {}

class MockDriverAccountGateway extends Mock implements DriverAccountGateway {}

void main() {
  testWidgets('SCR-D05: hiện tên + biển số xe; đăng xuất dùng chung LogoutButton → gọi signOut()', (tester) async {
    final profileGateway = MockProfileGateway();
    final driverGateway = MockDriverGateway();
    final authGateway = MockAuthGateway();
    when(() => profileGateway.fetchMyProfile()).thenAnswer(
      (_) async => const UserProfile(name: '配送 太郎', nameKana: null, email: 'driver@ecomeal.test'),
    );
    when(() => driverGateway.fetchTonightRoute()).thenAnswer((_) async => routeFixture);
    when(() => authGateway.currentSession).thenReturn(null);
    when(() => authGateway.onAuthStateChange).thenAnswer((_) => const Stream<AuthState>.empty());
    when(() => authGateway.signOut()).thenAnswer((_) async {});
    final accountGateway = MockDriverAccountGateway();
    when(() => accountGateway.fetchLicense()).thenAnswer((_) async => const DriverLicense(status: LicenseStatus.verified, expiresOn: '2029-03-31'));
    when(() => accountGateway.fetchUpcomingShifts()).thenAnswer((_) async => const []);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        profileGatewayProvider.overrideWithValue(profileGateway),
        driverGatewayProvider.overrideWithValue(driverGateway),
        authGatewayProvider.overrideWithValue(authGateway),
        driverAccountGatewayProvider.overrideWithValue(accountGateway),
      ],
      child: testApp(const DriverProfilePage()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('配送 太郎'), findsOneWidget);
    expect(find.text('大阪 500 あ 12-34'), findsOneWidget);
    // レビュー第74回: 運転免許証と今後のシフトのカード
    expect(find.text('運転免許証'), findsOneWidget);
    expect(find.text('確認済み'), findsOneWidget);

    await tester.tap(find.byKey(const Key('logoutButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmLogoutButton')));
    await tester.pumpAndSettle();
    verify(() => authGateway.signOut()).called(1);
  });
}
