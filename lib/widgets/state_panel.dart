import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

// "共通状態パターン" của Figma (trang 01 Components): Empty / Error = icon trong vòng tròn nhạt + tiêu đề +
// mô tả + 1 nút hành động. Loading thì mỗi màn tự giữ khung bố cục (không dùng widget này).
class StatePanel extends StatelessWidget {
  const StatePanel({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.isError = false,
    this.filledAction,
  });

  const StatePanel.error({
    super.key,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.filledAction,
  }) : icon = Icons.warning_amber_rounded,
       isError = true;

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isError;
  // null = theo isError. Figma SCR-M03/M04 vẽ 再試行 dạng nút viền → truyền false.
  final bool? filledAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isError ? context.eco.errorSoft : context.eco.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: isError ? context.eco.error : context.eco.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: textTheme.titleMedium),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(message!, textAlign: TextAlign.center, style: textTheme.bodySmall),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            // Mặc định: Error = nút đặc (再試行), Empty = nút viền (次の行動) — 2 biến thể của trang Components.
            (filledAction ?? isError)
                ? FilledButton(onPressed: onAction, child: Text(actionLabel!))
                : OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
