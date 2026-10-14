import 'package:flutter/widgets.dart';
import '../core/motion.dart';

// Mục lún nhẹ khi đang chạm (0.96, Motion.tap 120ms) — tab, rail, chip lọc (Figma 「動きの提案」, guide §5.2).
// Dùng Listener nên không tranh sự kiện chạm với nút bên trong. Giảm chuyển động → không lún.
const pressedScale = 0.96;

class PressScale extends StatefulWidget {
  const PressScale({super.key, required this.child});
  final Widget child;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _set(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      // translucent: chạm vào khoảng trống trong mục (giữa icon và chữ) cũng lún
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _pressed && !Motion.reduced(context) ? pressedScale : 1,
        duration: Motion.of(context, Motion.tap),
        curve: Motion.enter,
        child: widget.child,
      ),
    );
  }
}
