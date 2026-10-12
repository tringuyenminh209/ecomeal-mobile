import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_flavor.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/ecomeal_logo.dart';
import 'locale_controller.dart';
import 'login_signup_page.dart';
import 'reset_password_view.dart';

// Màn đăng nhập của các app nghiệp vụ — tài khoản do 運営 phát hành nên không có 新規登録 / LINE / màn giới thiệu;
// ngôn ngữ đổi ngay tại đây (góc phải). Cùng bố cục, khác huy hiệu / câu dẫn / ghi chú theo app:
//   SCR-D00（app tài xế, ADR-007 — Figma 351:735）, SCR-S00（app nhà hàng, ADR-015 — 552:2）,
//   SCR-A00 ログイン（app vận hành — 562:861; sau đó là bước 2段階認証）.
// Quên mật khẩu: cùng luồng mã xác nhận với SCR-M02 (UC-28), giữ trong cùng trang như SCR-M02.
class BusinessLoginPage extends ConsumerStatefulWidget {
  const BusinessLoginPage({super.key});

  @override
  ConsumerState<BusinessLoginPage> createState() => _BusinessLoginPageState();
}

class _BusinessLoginPageState extends ConsumerState<BusinessLoginPage> {
  bool _resettingPassword = false;

  void _toggleLanguage() {
    final current = ref.read(localeControllerProvider).languageCode;
    ref.read(localeControllerProvider.notifier).setLocale(Locale(current == 'ja' ? 'en' : 'ja'));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final flavor = ref.watch(appFlavorProvider);
    final isAdmin = flavor == AppFlavor.admin;
    final (badge, lead, note) = switch (flavor) {
      AppFlavor.store => (l10n.storeBadge, l10n.storeLoginLead, l10n.storeLoginNote),
      AppFlavor.admin => (l10n.adminBadge, l10n.adminLoginLead, null),
      _ => (l10n.driverBadge, l10n.driverLoginLead, l10n.driverAccountIssuedNote),
    };
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          // iPad (SCR-S00 iPad 559:699): form hẹp ở giữa màn, không kéo giãn theo chiều ngang
          builder: (context, constraints) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 60),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            EcoMealLogo(onDark: flavor.usesNightTheme),
                            const SizedBox(width: 10),
                            // Huy hiệu nhỏ (Figma 11px): 運営 = nền vàng nhạt chữ vàng, còn lại = nền vàng chữ tối
                            Container(
                              key: const Key('appBadge'),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isAdmin ? eco.amber.withValues(alpha: 0.2) : eco.amber,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                badge,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isAdmin ? eco.amber : eco.onAmber,
                                ),
                              ),
                            ),
                            // Đổi ngôn ngữ ngay ở màn đăng nhập: chỉ app tài xế (Figma SCR-D00「日本語 / English」).
                            // App nhà hàng / vận hành đổi ở màn cài đặt sau khi đăng nhập (SCR-S00 / A00 không có nút này).
                            // Màn hẹp / chữ hệ thống lớn: chữ nút tự thu nhỏ thay vì tràn hàng
                            Expanded(
                              child: flavor != AppFlavor.driver
                                  ? const SizedBox.shrink()
                                  : Align(
                                      alignment: Alignment.centerRight,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: TextButton(
                                          key: const Key('switchLanguageButton'),
                                          onPressed: _toggleLanguage,
                                          style: TextButton.styleFrom(foregroundColor: eco.textSecondary),
                                          child: Text(
                                            l10n.languageToggleBoth,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: _resettingPassword
                              ? ResetPasswordView(onBackToLogin: () => setState(() => _resettingPassword = false))
                              : LoginForm(
                                  lead: lead,
                                  footerNote: note,
                                  forgotBelowSubmit: flavor != AppFlavor.driver,
                                  onForgotPassword: () => setState(() => _resettingPassword = true),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
