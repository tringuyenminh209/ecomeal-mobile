import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/state_panel.dart';
import '../orders/order_helpers.dart';
import '../orders/order_history_page.dart';
import 'profile_gateway.dart';

// SCR-M12 アカウントの削除 (UC-37, 06 §SCR-M12, Figma section 425:1005 — 425:1075 thường / 425:1141 受け取り前の予約あり /
// 425:1171 確認). Mở từ link 「アカウントを削除」 dưới nút ログアウト ở SCR-M07. Không có Bottom Navigation.
class DeleteAccountPage extends ConsumerStatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  ConsumerState<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends ConsumerState<DeleteAccountPage> {
  bool _deleting = false;
  bool _serverSaysOpen = false; // E-ACCOUNT-409 (đơn mới phát sinh sau khi màn hình đã tải)

  Future<void> _delete() async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.deleteAccountDialogTitle,
      message: l10n.deleteAccountDialogBody,
      cancelLabel: l10n.cancelButton,
      confirmLabel: l10n.deleteAccountConfirm,
      confirmKey: const Key('confirmDeleteAccountButton'),
      destructive: true,
      centered: true,
    );
    if (confirmed != true || !mounted) return;
    setState(() => _deleting = true);
    // Lấy trước khi await: sau khi đăng xuất, RoleGate thay cây widget phía dưới trang này.
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(profileGatewayProvider).deleteMyAccount();
      navigator.popUntil((route) => route.isFirst); // về RoleGate (lúc này là SCR-M02)
      messenger.showSnackBar(SnackBar(content: Text(l10n.accountDeleted)));
    } on OpenReservationsException {
      if (mounted) setState(() => _serverSaysOpen = true);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorDeleteAccount)));
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Dùng lại danh sách đơn của tab 予約 + canCancel (pending/allocated) — cùng điều kiện với RPC (E-ACCOUNT-409).
    final ordersAsync = ref.watch(myOrdersProvider);
    final hasOpen = _serverSaysOpen || (ordersAsync.valueOrNull?.any((o) => canCancel(o.status)) ?? false);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.deleteAccountTitle), centerTitle: true),
      body: ordersAsync.hasError && !ordersAsync.hasValue
          ? Center(
              child: StatePanel.error(
                title: l10n.errorLoadTitle,
                message: l10n.errorLoadBody,
                actionLabel: l10n.retry,
                onAction: () => ref.invalidate(myOrdersProvider),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                if (hasOpen) ...[
                  ErrorBanner(key: const Key('openReservationsBanner'), message: l10n.deleteAccountOpenOrders),
                  const SizedBox(height: 20),
                ],
                Text(l10n.deleteAccountLead, style: const TextStyle(fontSize: 14, height: 1.6)),
                const SizedBox(height: 20),
                _InfoCard(
                  title: l10n.deleteAccountRemovedTitle,
                  lines: [l10n.deleteAccountRemoved1, l10n.deleteAccountRemoved2, l10n.deleteAccountRemoved3],
                ),
                const SizedBox(height: 20),
                _InfoCard(title: l10n.deleteAccountKeptTitle, lines: [l10n.deleteAccountKeptBody]),
                const SizedBox(height: 20),
                Text(
                  l10n.deleteAccountNote,
                  style: const TextStyle(fontSize: 12, height: 1.6, color: AppColors.textSecondary),
                ),
              ],
            ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: FilledButton(
            key: const Key('deleteAccountButton'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            // Chưa tải xong danh sách đơn thì chưa biết được phép xoá hay không → khoá nút.
            onPressed: _deleting || hasOpen || !ordersAsync.hasValue ? null : _delete,
            child: _deleting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surface),
                  )
                : Text(l10n.deleteAccountButton),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.lines});
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          for (final line in lines) ...[
            const SizedBox(height: 8),
            Text(line, style: const TextStyle(fontSize: 13, height: 1.6)),
          ],
        ],
      ),
    );
  }
}
