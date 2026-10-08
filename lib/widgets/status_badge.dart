import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

// StatusBadge/Active·Warning·Error của Figma + 2 biến thể nhạt xuất hiện trong các frame màn hình
// (nhãn "EcoMeal提携店", "位置更新中"…). Luôn có chữ — màu không bao giờ là tín hiệu trạng thái duy nhất.
enum BadgeTone { active, warning, error, soft, neutral }

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, this.tone = BadgeTone.active});
  final String label;
  final BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground) = switch (tone) {
      BadgeTone.active => (context.eco.primary, context.eco.surface),
      BadgeTone.warning => (context.eco.amber, context.eco.onAmber),
      BadgeTone.error => (context.eco.error, context.eco.surface),
      BadgeTone.soft => (context.eco.primarySoft, context.eco.primary),
      BadgeTone.neutral => (context.eco.chip, context.eco.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: foreground),
      ),
    );
  }
}
