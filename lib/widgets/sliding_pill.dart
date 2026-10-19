import 'package:flutter/material.dart';
import '../core/motion.dart';

// Vùng chọn hình viên thuốc trượt giữa các mục (Figma 「動きの提案（Liquid 風）」: thanh tab app khách, chip lọc SCR-M06,
// rail iPad của app 店舗・運営). Đo vị trí từng mục sau khi vẽ, đặt 1 viên thuốc phía sau mục đang chọn; đổi mục → viên
// thuốc trượt sang (Motion.small, Motion.enter). Bật "giảm chuyển động" → Motion.of trả 0, nhảy ngay.
// Kéo (PillTabBar, 2026-10-14): followOffset = toạ độ ngón tay theo trục chính → viên thuốc đi theo ngón tay (không hoạt
// ảnh), lifted = phồng nhẹ khi đang giữ. Thả tay → followOffset = null → trượt mượt về mục được chọn.
const liftedScale = 1.08;

class SlidingPill extends StatefulWidget {
  const SlidingPill({
    super.key,
    required this.selected,
    required this.color,
    required this.children,
    this.direction = Axis.horizontal,
    this.spacing = 0,
    this.pillSize,
    this.radius,
    this.expand = false,
    this.followOffset,
    this.lifted = false,
    this.pillInset = EdgeInsets.zero,
  });

  final int selected;
  final Color color;
  final List<Widget> children;
  final Axis direction;
  final double spacing;
  // null = viên thuốc bằng đúng kích thước mục; có giá trị = cỡ cố định, đặt giữa mục (thanh tab: 84×50)
  final Size? pillSize;
  // null = bo tròn hết (viên thuốc)
  final double? radius;
  // true = các mục chia đều chiều dài (thanh tab)
  final bool expand;
  // null = đứng ở mục đang chọn; có giá trị = tâm viên thuốc theo ngón tay (toạ độ trong widget này, trục chính)
  final double? followOffset;
  // đang giữ → viên thuốc phồng nhẹ (liftedScale); giảm chuyển động → không phồng
  final bool lifted;
  // Mục có vùng bấm lớn hơn phần nhìn thấy (chip lọc: bấm được cao 44, viên thuốc vẫn theo cỡ chip) → thu viên thuốc vào
  final EdgeInsets pillInset;

  @override
  State<SlidingPill> createState() => _SlidingPillState();
}

class _SlidingPillState extends State<SlidingPill> {
  late List<GlobalKey> _keys = _newKeys(widget.children.length);
  List<Rect>? _rects;

  static List<GlobalKey> _newKeys(int n) => List.generate(n, (_) => GlobalKey());

  @override
  void didUpdateWidget(SlidingPill old) {
    super.didUpdateWidget(old);
    if (old.children.length != widget.children.length) {
      _keys = _newKeys(widget.children.length);
      _rects = null;
    }
  }

  // Vị trí các mục trong hệ toạ độ của widget này — chỉ setState khi thật sự đổi (tránh vòng lặp vẽ lại)
  void _measure() {
    if (!mounted) return;
    final stack = context.findRenderObject() as RenderBox?;
    if (stack == null || !stack.hasSize) return;
    final rects = <Rect>[];
    for (final key in _keys) {
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      rects.add(box.localToGlobal(Offset.zero, ancestor: stack) & box.size);
    }
    final old = _rects;
    final same =
        old != null && old.length == rects.length && Iterable.generate(rects.length).every((i) => old[i] == rects[i]);
    if (!same) setState(() => _rects = rects);
  }

  Rect _pillRect(Rect item) {
    final size = widget.pillSize;
    return size == null ? widget.pillInset.deflateRect(item) : Rect.fromCenter(center: item.center, width: size.width, height: size.height);
  }

  // Viên thuốc đặt tâm ở ngón tay, nhưng không ra khỏi mục đầu / mục cuối
  Rect _followRect(Rect rest, List<Rect> rects, double at) {
    final horizontal = widget.direction == Axis.horizontal;
    final half = (horizontal ? rest.width : rest.height) / 2;
    final first = _pillRect(rects.first), last = _pillRect(rects.last);
    final lo = (horizontal ? first.left : first.top) + half;
    final hi = (horizontal ? last.right : last.bottom) - half;
    final c = at.clamp(lo, hi < lo ? lo : hi);
    return horizontal
        ? Rect.fromCenter(center: Offset(c, rest.center.dy), width: rest.width, height: rest.height)
        : Rect.fromCenter(center: Offset(rest.center.dx, c), width: rest.width, height: rest.height);
  }

  ShapeBorder get _shape => widget.radius == null
      ? const StadiumBorder()
      : RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.radius!));

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    final rects = _rects;
    final pill = DecoratedBox(
      key: const Key('slidingPill'),
      decoration: ShapeDecoration(color: widget.color, shape: _shape),
    );
    final items = <Widget>[];
    for (final (i, child) in widget.children.indexed) {
      if (i > 0 && widget.spacing > 0) {
        items.add(
          SizedBox(
            width: widget.direction == Axis.horizontal ? widget.spacing : 0,
            height: widget.direction == Axis.vertical ? widget.spacing : 0,
          ),
        );
      }
      // Trước khi đo được (khung hình đầu): tô nền ngay sau mục đang chọn để không có 1 khung hình thiếu nền
      final Widget item = rects == null && i == widget.selected
          ? Stack(
              alignment: Alignment.center,
              children: [
                if (widget.pillSize != null)
                  SizedBox.fromSize(size: widget.pillSize, child: pill)
                else
                  Positioned.fill(child: Padding(padding: widget.pillInset, child: pill)),
                child,
              ],
            )
          : child;
      final keyed = KeyedSubtree(key: _keys[i], child: item);
      items.add(widget.expand ? Expanded(child: keyed) : keyed);
    }
    final rest = rects == null || widget.selected >= rects.length ? null : _pillRect(rects[widget.selected]);
    final follow = widget.followOffset;
    final target = rest == null || follow == null ? rest : _followRect(rest, rects!, follow);
    final reduced = Motion.reduced(context);
    return Stack(
      children: [
        if (target != null)
          AnimatedPositioned.fromRect(
            rect: target,
            // đang kéo: bám ngón tay ngay; thả ra: trượt về mục
            duration: follow != null ? Duration.zero : Motion.of(context, Motion.small),
            curve: Motion.enter,
            child: AnimatedScale(
              scale: widget.lifted && !reduced ? liftedScale : 1,
              duration: Motion.of(context, Motion.tap),
              curve: Motion.enter,
              child: pill,
            ),
          ),
        Flex(
          direction: widget.direction,
          mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: items,
        ),
      ],
    );
  }
}
