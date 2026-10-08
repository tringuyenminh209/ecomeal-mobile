import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

// Khung xương lúc tải (06 §3 Loading: "giữ khung bố cục"). Mỗi màn tự xếp các SkeletonBox theo đúng bố cục thật,
// bọc ngoài bằng 1 SkeletonPulse (1 AnimationController cho cả màn, không phải mỗi khối 1 cái).
// Nhịp sáng-tối chậm báo "đang tải" mà không gây chú ý; người dùng bật "giảm chuyển động" → khối tĩnh.
class SkeletonPulse extends StatefulWidget {
  const SkeletonPulse({super.key, required this.child});
  final Widget child;

  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<SkeletonPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
  late final Animation<double> _opacity = Tween<double>(begin: 1, end: 0.55).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Trình đọc màn hình: cả khối là 1 vùng "đang tải", không đọc từng khối rỗng.
    return Semantics(
      label: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
      liveRegion: true,
      child: ExcludeSemantics(child: FadeTransition(opacity: _opacity, child: widget.child)),
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, required this.height, this.width, this.radius = 8});
  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(color: context.eco.chip, borderRadius: BorderRadius.circular(radius)),
    );
  }
}

// Khung xương dạng cột cho các màn chỉ gồm khối xếp dọc (màn tài xế): mỗi phần tử của [heights] là 1 khối, cách nhau 12.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, required this.heights, this.padding = const EdgeInsets.all(16), this.scrollable = true});
  final List<double> heights;
  final EdgeInsetsGeometry padding;
  // false: nằm trong 1 thẻ/khối đã có kích thước (không cuộn riêng)
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final blocks = [
      for (var i = 0; i < heights.length; i++) ...[
        if (i > 0) const SizedBox(height: 12),
        SkeletonBox(height: heights[i], radius: 12),
      ],
    ];
    return SkeletonPulse(
      child: scrollable
          ? ListView(padding: padding, physics: const NeverScrollableScrollPhysics(), children: blocks)
          : Padding(padding: padding, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: blocks)),
    );
  }
}
