import 'package:flutter/widgets.dart';
import '../core/motion.dart';

// Đổi tab / mục rail: nội dung mới hiện dần (Motion.small, Motion.enter) — Figma 「動きの提案」 cho nội dung mờ dần khi đổi
// tab. Không tạo lại trang (IndexedStack bên trong giữ nguyên trạng thái, vị trí cuộn). Giảm chuyển động → đổi ngay.
class FadeOnChange extends StatefulWidget {
  const FadeOnChange({super.key, required this.value, required this.child});
  final Object value;
  final Widget child;

  @override
  State<FadeOnChange> createState() => _FadeOnChangeState();
}

class _FadeOnChangeState extends State<FadeOnChange> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, value: 1);
  late final _opacity = CurvedAnimation(parent: _controller, curve: Motion.enter);

  @override
  void didUpdateWidget(FadeOnChange old) {
    super.didUpdateWidget(old);
    if (old.value == widget.value) return;
    _controller.duration = Motion.of(context, Motion.small);
    _controller.forward(from: _controller.duration == Duration.zero ? 1 : 0);
  }

  @override
  void dispose() {
    _opacity.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(opacity: _opacity, child: widget.child);
}
