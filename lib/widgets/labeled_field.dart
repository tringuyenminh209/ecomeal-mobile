import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

// "Form field" của Figma: nhãn 12 Medium nằm TRÊN ô nhập (cách 6px), không dùng nhãn nổi của Material.
// badge: viên nhỏ cạnh nhãn của SCR-M08 — 「必須」 (isRequired, nền đỏ nhạt) / 「任意」 (nền xám nhạt).
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.badge,
    this.isRequired = false,
  });
  final String label;
  final Widget child;
  final String? badge;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            // Flexible: nhãn dài (tiếng Anh) xuống dòng thay vì tràn khỏi Row.
            Flexible(child: Text(label, style: Theme.of(context).textTheme.labelMedium)),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isRequired ? context.eco.errorSoft : context.eco.chip,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isRequired ? context.eco.error : context.eco.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
