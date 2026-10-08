import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

// Modal xác nhận của Figma (キャンセル確認 SCR-M06, ログアウト確認 SCR-M07/D05, 出発確認 SCR-D03):
// nền trắng bo 16, tiêu đề đậm, mô tả màu phụ, (tuỳ chọn) 1 khối thông tin, 2 nút pill ngang nhau —
// trái = viền (huỷ), phải = đặc (xác nhận; nền Error khi hành động là phá huỷ/đăng xuất).
// Trả về true khi bấm xác nhận; false/null khi huỷ hoặc chạm ra ngoài.
Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String cancelLabel,
  required String confirmLabel,
  Key? confirmKey,
  Key? cancelKey,
  Key? messageKey,
  bool destructive = false,
  bool centered = false,
  Widget? extra,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      final align = centered ? TextAlign.center : TextAlign.start;
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: align,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                key: messageKey,
                textAlign: align,
                style: TextStyle(fontSize: 13, height: 1.6, color: context.eco.textSecondary),
              ),
              if (extra != null) ...[const SizedBox(height: 16), extra],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: cancelKey,
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(cancelLabel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      key: confirmKey,
                      style: destructive ? FilledButton.styleFrom(backgroundColor: context.eco.error) : null,
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(confirmLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
