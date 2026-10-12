import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';

// Thành phần dùng chung của SCR-M02: tab đăng nhập/đăng ký (login_signup_page.dart) và đặt lại mật khẩu
// (reset_password_view.dart, UC-28).

String? validateAuthEmail(String? value, AppLocalizations l10n) =>
    value == null ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())
    ? l10n.errorEmailRequired
    : null;

// Tiêu đề 26 Bold + 1 dòng mô tả 13 (Figma "Heading").
class AuthHeading extends StatelessWidget {
  const AuthHeading({super.key, required this.title, required this.lead});
  final String title;
  final String lead;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 7),
        Text(
          lead,
          // Màu theo bảng màu đang dùng (app nghiệp vụ dùng nền tối — Night), không phải hằng màu của nền sáng
          style: TextStyle(fontSize: 13, height: 1.45, color: context.eco.textSecondary),
        ),
      ],
    );
  }
}

// Dòng chuyển tab ở đáy màn ("まだアカウントをお持ちでない方は 新規登録"). Dùng Text.rich thay vì Text + nút
// riêng để chữ "新規登録"/"ログイン" không trùng với nhãn tab khi tìm bằng find.text trong test.
class AuthSwitchPrompt extends StatelessWidget {
  const AuthSwitchPrompt({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
    this.allAccent = false,
  });
  final String prompt;
  final String action;
  final VoidCallback onTap;
  // true: cả dòng màu nhấn, đậm (Figma SCR-S00 / SCR-A00: link ngay dưới nút ログインする)
  final bool allAccent;

  @override
  Widget build(BuildContext context) {
    // Vùng chạm ≥ 44px (review page 02: 「パスワードを忘れた方は」「再送する」 quá nhỏ để bấm)
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Text.rich(
          TextSpan(
            text: '$prompt ',
            children: [
              TextSpan(
                text: action,
                style: TextStyle(fontWeight: FontWeight.w700, color: context.eco.primary),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: allAccent ? FontWeight.w700 : null,
            color: allAccent ? context.eco.primary : context.eco.textPrimary,
          ),
        ),
      ),
    );
  }
}

// Nội dung nút chính: chữ, hoặc spinner trắng trong nút khi đang gửi (Figma "SCR-M02 ログイン / Loading").
Widget authSubmitChild(bool isSubmitting, String label) => isSubmitting
    ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surface),
      )
    : Text(label);

// Nút chữ 「表示」/「非表示」 ở cuối ô mật khẩu — dùng cho cả form đăng nhập và đăng ký (cùng kiểu với nút
// 表示 của Web Admin SCR-W01). Chữ thay vì icon con mắt: rõ nghĩa với người dùng Nhật và khớp Figma.
class PasswordVisibilityToggle extends StatelessWidget {
  const PasswordVisibilityToggle({super.key, required this.visible, required this.onToggle});
  final bool visible;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onToggle,
      style: TextButton.styleFrom(foregroundColor: context.eco.textSecondary),
      child: Text(
        visible ? context.l10n.hidePassword : context.l10n.showPassword,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      ),
    );
  }
}
