import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/auth_controller.dart';
import '../features/notifications/push_registration.dart';
import '../l10n/l10n.dart';
import 'confirm_dialog.dart';

// UC-26: dùng chung cho SCR-M07 (khách, Chương 18) và SCR-D05 (tài xế, Chương 19) — cùng dialog
// ログアウト確認 của Figma (54:3054), cùng hành vi. Không tự điều hướng: RoleGate thấy session = null
// và tự hiện SCR-M02.
class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key, this.filled = false, this.danger = true});

  // Figma: SCR-M07 = nút viền đỏ (470:1400), SCR-D05 = nút đỏ đặc dính đáy (49:105) — chỉ khác hình thức.
  final bool filled;
  // false: viền màu chính (SCR-S00 審査中・却下 552:72 / 552:107 — đăng xuất là lối ra bình thường, không phải thao tác nguy hiểm)
  final bool danger;

  Future<void> _confirmAndSignOut(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.logoutDialogTitle,
      message: l10n.logoutDialogBody,
      cancelLabel: l10n.cancelButton,
      confirmLabel: l10n.signOutButton,
      confirmKey: const Key('confirmLogoutButton'),
      destructive: true,
      centered: true,
    );
    if (confirmed != true) return;
    try {
      await unregisterPush(ref); // 0048: máy này thôi nhận thông báo của tài khoản này
      await ref.read(authControllerProvider.notifier).signOut();
    } catch (_) {
      // Cùng xử lý với PlaceholderScreen (Chương 15): đăng xuất lỗi thì báo, không im lặng.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorSignOutFailed)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = Text(context.l10n.signOutButton);
    if (filled) {
      return FilledButton(
        key: const Key('logoutButton'),
        style: FilledButton.styleFrom(backgroundColor: context.eco.error),
        onPressed: () => _confirmAndSignOut(context, ref),
        child: label,
      );
    }
    final color = danger ? context.eco.error : context.eco.primary;
    return OutlinedButton(
      key: const Key('logoutButton'),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
      ),
      onPressed: () => _confirmAndSignOut(context, ref),
      child: label,
    );
  }
}
