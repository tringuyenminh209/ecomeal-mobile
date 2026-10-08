import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'ecomeal_logo.dart';
import 'logout_button.dart';

// Màn "tài khoản này không dùng ở đây" (Figma SCR-M02 対象外アカウント 244:1414 / 351:1178, SCR-D00 351:885 / 351:924):
// logo, thẻ có dấu「!」, tiêu đề, giải thích, (tuỳ chọn) nút chính, rồi ログアウト. Không tự đăng xuất — người dùng cần đọc
// vì sao rồi mới chọn. Màu lấy từ theme nên dùng được cả app khách (sáng) lẫn app tài xế (tối).
class AccountNoticeScreen extends StatelessWidget {
  const AccountNoticeScreen({
    super.key,
    required this.title,
    required this.body,
    this.primaryAction,
    this.footer,
  });

  final String title;
  final String body;
  final Widget? primaryAction;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final eco = context.eco;
    final onDark = Theme.of(context).brightness == Brightness.dark;
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
                    Align(alignment: Alignment.centerLeft, child: EcoMealLogo(onDark: onDark)),
                    const SizedBox(height: 24),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: eco.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Container(
                                width: 56,
                                height: 56,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: eco.primarySoft, shape: BoxShape.circle),
                                child: Text(
                                  '!',
                                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: eco.primary),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.35),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              body,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, height: 1.65, color: eco.textSecondary),
                            ),
                            const SizedBox(height: 20),
                            if (primaryAction != null) ...[primaryAction!, const SizedBox(height: 12)],
                            const LogoutButton(),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (footer != null) ...[const SizedBox(height: 24), footer!],
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
