import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_flavor.dart';
import '../../l10n/l10n.dart';
import '../driver/driver_gateway.dart';
import '../legal/legal_pages.dart';
import '../admin/admin_mfa_gate.dart';
import '../store/store_gate.dart';
import '../notifications/push_registration.dart';
import '../legal/terms_gateway.dart';
import 'auth_controller.dart';
import 'business_login_page.dart';
import 'locale_controller.dart';
import 'login_signup_page.dart';
import 'onboarding_page.dart';
import 'web_admin_only_screen.dart';
import '../../widgets/account_notice_screen.dart';
import '../../widgets/admin_shell.dart';
import '../../widgets/customer_shell.dart';
import '../../widgets/driver_shell.dart';
import '../../widgets/placeholder_screen.dart';

// Màn gốc của cả 4 app (ADR-007, ADR-015). Mọi chuyển màn trước/sau đăng nhập đều đi qua đây — không màn nào tự
// Navigator.push. App khách: SCR-M01/M02 → CustomerShell. App tài xế: SCR-D00 → DriverShell. App nhà hàng: SCR-S00 →
// StoreGate（審査中・却下）→ StoreShell. App vận hành: SCR-A00 → AdminMfaGate（2段階認証）→ AdminShell. Tài khoản không thuộc app này thì báo dùng
// app/Web nào (quyền thật vẫn chặn ở server — RLS, RPC, pre-request aal2 của 0058).
class RoleGate extends ConsumerWidget {
  const RoleGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final flavor = ref.watch(appFlavorProvider);
    final isDriverApp = flavor == AppFlavor.driver;
    final isCustomerApp = flavor == AppFlavor.customer;
    final l10n = context.l10n;

    if (authState.isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // UC-28: đang đặt lại mật khẩu thì vẫn ở màn đăng nhập dù mã đúng đã tạo session — cùng kiểu widget ở cùng
    // vị trí nên State của trang (bước nhập mật khẩu mới) được giữ nguyên.
    if (authState.isRecoveringPassword) {
      return isCustomerApp ? const LoginSignupPage() : const BusinessLoginPage();
    }
    if (authState.session == null) {
      // App nghiệp vụ: không có màn giới thiệu (ngôn ngữ đổi ngay ở màn đăng nhập).
      if (!isCustomerApp) return const BusinessLoginPage();
      // App khách: lần đầu (chưa chọn ngôn ngữ) → SCR-M01; đã chọn rồi (mở lại app, vừa đăng xuất) → thẳng SCR-M02.
      return ref.watch(onboardingDoneProvider) ? const LoginSignupPage() : const OnboardingPage();
    }
    if (authState.role == null) return PlaceholderScreen(label: l10n.errorProfileLoadFailed);
    if (flavor == AppFlavor.store) {
      return authState.role == AppRole.restaurantOwner
          ? StoreGate(userId: authState.session!.user.id)
          : AccountNoticeScreen(title: l10n.storeOnlyAppTitle, body: l10n.storeOnlyAppBody);
    }
    if (flavor == AppFlavor.admin) {
      final session = authState.session!;
      return authState.role == AppRole.admin
          ? AdminMfaGate(userId: session.user.id, child: AdminApp(userId: session.user.id, email: session.user.email ?? ''))
          : AccountNoticeScreen(title: l10n.adminOnlyAppTitle, body: l10n.adminOnlyAppBody);
    }
    switch (authState.role) {
      case AppRole.customer:
        return isDriverApp
            ? AccountNoticeScreen(title: l10n.driverOnlyAppTitle, body: l10n.driverOnlyAppBody)
            : _TermsGate(userId: authState.session!.user.id);
      case AppRole.driver:
        if (!isDriverApp) {
          // Figma SCR-M02 対象外アカウント（ドライバー）351:1178
          return AccountNoticeScreen(title: l10n.driverAccountTitle, body: l10n.driverAccountBody);
        }
        return _DriverActiveGate(userId: authState.session!.user.id);
      case AppRole.restaurantOwner:
      case AppRole.admin:
        // App khách: chỉ đường sang Web Admin (Figma 244:1414). App tài xế: SCR-D00 対象外アカウント (351:885).
        return isDriverApp
            ? AccountNoticeScreen(title: l10n.driverOnlyAppTitle, body: l10n.driverOnlyAppBody)
            : const WebAdminOnlyScreen();
      case null:
        return PlaceholderScreen(label: l10n.errorProfileLoadFailed);
    }
  }
}

// Tài xế bị 運営 tạm dừng (driver_profiles.is_active = false) → SCR-D00 稼働停止中 (351:924). Bằng lái chưa duyệt / hết hạn
// vẫn vào được (nộp ở SCR-D05; SCR-D01 báo không vào ca được).
class _DriverActiveGate extends ConsumerWidget {
  const _DriverActiveGate({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ref.watch(driverActiveProvider(userId)).when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => PlaceholderScreen(label: l10n.errorProfileLoadFailed),
      data: (active) => active
          ? const DriverShell()
          : AccountNoticeScreen(title: l10n.driverSuspendedTitle, body: l10n.driverSuspendedBody),
    );
  }
}

// UC-36 / 06 §SCR-M10: khách chưa đồng ý bản điều khoản hiện hành (tài khoản cũ, hoặc điều khoản vừa đổi) → màn
// 「利用規約が更新されました」 thay cho CustomerShell. App tài xế không đi qua đây (tài khoản do 運営 mời — UC-36 備考).
class _TermsGate extends ConsumerWidget {
  const _TermsGate({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(acceptedTermsVersionProvider(userId)).when(
      // invalidate sau khi bấm 同意 là "refresh": mặc định giữ màn đồng ý tới khi có kết quả mới (không nháy spinner).
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => PlaceholderScreen(label: context.l10n.errorProfileLoadFailed),
      data: (version) => version == currentTermsVersion
          ? const PushRegistrar(onMessage: refreshOrdersAfterPush, onOpened: openOrdersFromPush, child: CustomerShell())
          : TermsConsentPage(userId: userId),
    );
  }
}
