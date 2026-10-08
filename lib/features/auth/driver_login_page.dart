import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/ecomeal_logo.dart';
import 'locale_controller.dart';
import 'login_signup_page.dart';
import 'reset_password_view.dart';

// SCR-D00 ログイン（app tài xế, ADR-007 — Figma 351:735）. Tài khoản tài xế do 運営 phát hành (SCR-W11 → mail mời →
// SCR-W12 đặt mật khẩu) nên không có 新規登録 / LINE / màn giới thiệu; ngôn ngữ đổi ngay tại đây (góc phải).
// Quên mật khẩu: cùng luồng mã xác nhận với SCR-M02 (UC-28), giữ trong cùng trang như SCR-M02.
class DriverLoginPage extends ConsumerStatefulWidget {
  const DriverLoginPage({super.key});

  @override
  ConsumerState<DriverLoginPage> createState() => _DriverLoginPageState();
}

class _DriverLoginPageState extends ConsumerState<DriverLoginPage> {
  bool _resettingPassword = false;

  void _toggleLanguage() {
    final current = ref.read(localeControllerProvider).languageCode;
    ref.read(localeControllerProvider.notifier).setLocale(Locale(current == 'ja' ? 'en' : 'ja'));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 60),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const EcoMealLogo(onDark: true),
                        const SizedBox(width: 10),
                        Container(
                          key: const Key('driverBadge'),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: eco.amber, borderRadius: BorderRadius.circular(999)),
                          child: Text(
                            l10n.driverBadge,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: eco.onAmber),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          key: const Key('switchLanguageButton'),
                          onPressed: _toggleLanguage,
                          child: Text(l10n.switchLanguageLabel),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: _resettingPassword
                          ? ResetPasswordView(onBackToLogin: () => setState(() => _resettingPassword = false))
                          : LoginForm(
                              lead: l10n.driverLoginLead,
                              footerNote: l10n.driverAccountIssuedNote,
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
    );
  }
}
