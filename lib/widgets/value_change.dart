import 'package:flutter/material.dart';
import '../core/motion.dart';

// Số thay đổi theo thời gian thực (giá giảm theo bậc BR-008, phút còn lại): giá trị cũ mờ đi, giá trị mới trượt lên
// từ dưới — mắt thấy "vừa đổi" thay vì số nhảy âm thầm. Người dùng bật "giảm chuyển động" → đổi ngay, không trượt.
class ValueChange extends StatelessWidget {
  const ValueChange({super.key, required this.value, required this.child, this.alignment = Alignment.centerLeft});

  // Đổi value → chạy hiệu ứng (child mới được gắn key theo value)
  final Object value;
  final Widget child;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Motion.of(context, Motion.small),
      reverseDuration: Motion.of(context, Motion.tap),
      switchInCurve: Motion.enter,
      switchOutCurve: Motion.exit,
      layoutBuilder: (current, previous) => Stack(alignment: alignment, children: [...previous, ?current]),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(animation),
          child: child,
        ),
      ),
      child: KeyedSubtree(key: ValueKey(value), child: child),
    );
  }
}
