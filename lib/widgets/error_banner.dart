import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

// "Error message" của Figma (SCR-M02 Error, SCR-M05 Error…): nền đỏ nhạt, viền Error, icon cảnh báo +
// chữ 12. Dùng cho lỗi của cả form (sai mật khẩu, 429, mạng) — lỗi của 1 ô thì để errorText của ô đó.
// [title]: lỗi gửi / lưu ở app 運営 (SCR-A03〜A06, Figma section 24「送信エラー（入力は残る）」) có thêm dòng tiêu đề đậm.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message, this.title, this.onRetry, this.retryLabel});
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final color = context.eco.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.eco.errorSoft,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: title == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(message, style: TextStyle(fontSize: 12, height: 1.45, color: color)),
              ],
            ),
          ),
          if (onRetry != null && retryLabel != null) TextButton(onPressed: onRetry, child: Text(retryLabel!)),
        ],
      ),
    );
  }
}
