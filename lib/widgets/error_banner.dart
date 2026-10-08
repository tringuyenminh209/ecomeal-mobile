import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

// "Error message" của Figma (SCR-M02 Error, SCR-M05 Error…): nền đỏ nhạt, viền Error, icon cảnh báo +
// chữ 12. Dùng cho lỗi của cả form (sai mật khẩu, 429, mạng) — lỗi của 1 ô thì để errorText của ô đó.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message, this.onRetry, this.retryLabel});
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.eco.errorSoft,
        border: Border.all(color: context.eco.error),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: context.eco.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, height: 1.45, color: context.eco.error),
            ),
          ),
          if (onRetry != null && retryLabel != null)
            TextButton(onPressed: onRetry, child: Text(retryLabel!)),
        ],
      ),
    );
  }
}
