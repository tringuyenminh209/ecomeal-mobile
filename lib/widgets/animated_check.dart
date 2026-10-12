import 'dart:ui' show PathMetric;
import 'package:flutter/material.dart';
import '../core/motion.dart';

// Dấu ✓ "được vẽ ra" cho 2 khoảnh khắc ăn mừng của app (Figma "SCR-M05 決済 / 完了（入場前）" và
// "SCR-M18 受け取り完了（入場前）"): vòng tròn nảy lên (nếu có [background]) rồi nét ✓ chạy từ trái sang phải.
// Chạy 1 lần khi xuất hiện. "Giảm chuyển động" → hiện ngay trạng thái cuối. Chỉ trang trí: chữ đi kèm mới là nội dung.
class AnimatedCheck extends StatelessWidget {
  const AnimatedCheck({super.key, required this.size, required this.color, this.background, this.strokeWidth});

  // background != null: đường kính vòng tròn; null: cạnh của vùng vẽ ✓
  final double size;
  final Color color;
  final Color? background;
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Motion.of(context, Motion.celebrate),
        builder: (context, t, _) {
          // 0〜40%: vòng tròn phóng từ 0.6 (vượt nhẹ rồi về 1); 30〜100%: vẽ nét ✓
          final circle = Motion.pop.transform((t / 0.4).clamp(0, 1));
          final stroke = Motion.enter.transform(((t - 0.3) / 0.7).clamp(0, 1));
          final check = CustomPaint(
            size: Size.square(background == null ? size : size * 0.5),
            painter: _CheckPainter(
              progress: stroke,
              color: color,
              strokeWidth: strokeWidth ?? size * (background == null ? 0.11 : 0.06),
            ),
          );
          if (background == null) return check;
          return Opacity(
            opacity: (t / 0.2).clamp(0, 1),
            child: Transform.scale(
              scale: 0.6 + 0.4 * circle,
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: background, shape: BoxShape.circle),
                child: check,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.progress, required this.color, required this.strokeWidth});
  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final w = size.width;
    final path = Path()
      ..moveTo(w * 0.2, w * 0.53)
      ..lineTo(w * 0.42, w * 0.74)
      ..lineTo(w * 0.8, w * 0.3);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final metrics = path.computeMetrics().toList();
    final total = metrics.fold<double>(0, (sum, m) => sum + m.length);
    var remaining = total * progress;
    for (final PathMetric m in metrics) {
      if (remaining <= 0) break;
      canvas.drawPath(m.extractPath(0, remaining.clamp(0, m.length)), paint);
      remaining -= m.length;
    }
  }

  @override
  bool shouldRepaint(_CheckPainter old) =>
      old.progress != progress || old.color != color || old.strokeWidth != strokeWidth;
}
