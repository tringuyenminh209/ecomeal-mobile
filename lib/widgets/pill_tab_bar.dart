import 'package:flutter/material.dart';
import '../core/haptics.dart';
import '../core/theme/app_theme.dart';
import 'press_scale.dart';
import 'sliding_pill.dart';

// 1 mục điều hướng: key (cho test), icon thường / icon khi chọn, nhãn
typedef NavTab = (Key key, IconData icon, IconData selectedIcon, String label);

// Kích thước viên thuốc theo Figma (Pill 84×50, bo tròn hết)
const _pillSize = Size(84, 50);
const _barHeight = 64.0;

// Tab dưới có viên thuốc trượt (Figma Mobile/Bottom Navigation 88:245, Store/Tab bar, Admin/Tab bar — 「動きの提案」):
// app khách, và app 店舗・運営 trên điện thoại. Đổi tab → rung nhẹ; mục lún khi chạm. App tài xế giữ thanh riêng.
// Giữ rồi vuốt / vuốt ngang trên thanh (2026-10-14, kiểu thanh tab iOS — không làm kính trong suốt): viên thuốc phồng nhẹ
// và đi theo ngón tay, tab dưới ngón tay sáng lên + rung 1 nhịp khi đổi; thả tay mới chọn tab đó (không đổi trang liên tục
// khi đang kéo), viên thuốc trượt về giữa tab.
class PillTabBar extends StatefulWidget {
  const PillTabBar({super.key, required this.index, required this.onSelect, required this.tabs, this.topBorder = true});
  final int index;
  final ValueChanged<int> onSelect;
  final List<NavTab> tabs;
  // Figma "Admin/Tab bar" không có viền trên
  final bool topBorder;

  @override
  State<PillTabBar> createState() => _PillTabBarState();
}

class _PillTabBarState extends State<PillTabBar> {
  double? _dragX; // toạ độ ngón tay trong thanh; null = không kéo
  int? _hover; // tab dưới ngón tay khi đang kéo

  // Các tab chia đều bề ngang (SlidingPill expand)
  int _indexAt(double x, double width) => (x / (width / widget.tabs.length)).floor().clamp(0, widget.tabs.length - 1);

  void _start(double x, double width) {
    Haptics.selection();
    setState(() {
      _dragX = x;
      _hover = _indexAt(x, width);
    });
  }

  void _move(double x, double width) {
    if (_dragX == null) return;
    final i = _indexAt(x, width);
    if (i != _hover) Haptics.selection();
    setState(() {
      _dragX = x;
      _hover = i;
    });
  }

  void _end() {
    final i = _hover;
    setState(() {
      _dragX = null;
      _hover = null;
    });
    if (i != null) widget.onSelect(i);
  }

  void _cancel() => setState(() {
    _dragX = null;
    _hover = null;
  });

  @override
  Widget build(BuildContext context) {
    final eco = context.eco;
    final shown = _hover ?? widget.index; // đang kéo: tab dưới ngón tay hiện như đã chọn
    return DecoratedBox(
      key: const Key('pillTabBar'),
      decoration: BoxDecoration(
        color: eco.surface,
        border: widget.topBorder ? Border(top: BorderSide(color: eco.border)) : null,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _barHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragStart: (d) => _start(d.localPosition.dx, width),
                onHorizontalDragUpdate: (d) => _move(d.localPosition.dx, width),
                onHorizontalDragEnd: (_) => _end(),
                onHorizontalDragCancel: _cancel,
                onLongPressStart: (d) => _start(d.localPosition.dx, width),
                onLongPressMoveUpdate: (d) => _move(d.localPosition.dx, width),
                onLongPressEnd: (_) => _end(),
                onLongPressCancel: _cancel,
                child: SlidingPill(
                  selected: shown,
                  color: eco.primarySoft,
                  pillSize: _pillSize,
                  expand: true,
                  followOffset: _dragX,
                  lifted: _dragX != null,
                  children: [
                    for (final (i, (key, icon, selectedIcon, label)) in widget.tabs.indexed)
                      _TabItem(
                        key: key,
                        selected: i == shown,
                        icon: i == shown ? selectedIcon : icon,
                        label: label,
                        onTap: () {
                          if (i != widget.index) Haptics.selection();
                          widget.onSelect(i);
                        },
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({super.key, required this.selected, required this.icon, required this.label, required this.onTap});
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? context.eco.primary : context.eco.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      child: InkResponse(
        onTap: onTap,
        containedInkWell: true,
        highlightShape: BoxShape.rectangle,
        child: PressScale(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
