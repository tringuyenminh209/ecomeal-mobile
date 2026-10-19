import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import 'account_notice_screen.dart';

// Đã đăng nhập nhưng đọc thông tin cần để vào app (hồ sơ/quyền, điều khoản, trạng thái tài xế) bị lỗi — thường do mạng.
// Figma SCR-M02 読み込みエラー (953:1756): nút chính 「もう一度試す」 đọc lại đúng phần lỗi, ログアウト là lối phụ.
// Không bao giờ cho vào app khi chưa đọc được quyền (audit C03 2026-10-19; trước đây chỉ có ログアウト).
class LoadErrorScreen extends StatelessWidget {
  const LoadErrorScreen({super.key, required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AccountNoticeScreen(
      title: l10n.loadErrorTitle,
      body: l10n.loadErrorBody,
      primaryAction: FilledButton(key: const Key('loadErrorRetry'), onPressed: onRetry, child: Text(l10n.tryAgain)),
    );
  }
}
