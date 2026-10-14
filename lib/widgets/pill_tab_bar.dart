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
class PillTabBar extends StatelessWidget {
  const PillTabBar({super.key, required this.index, required this.onSelect, required this.tabs, this.topBorder = true});
  final int index;
  final ValueChanged<int> onSelect;
  final List<NavTab> tabs;
  // Figma "Admin/Tab bar" không có viền trên
  final bool topBorder;

  @override
  Widget build(BuildContext context) {
    final eco = context.eco;
    return DecoratedBox(
      key: const Key('pillTabBar'),
      decoration: BoxDecoration(
        color: eco.surface,
        border: topBorder ? Border(top: BorderSide(color: eco.border)) : null,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _barHeight,
          child: SlidingPill(
            selected: index,
            color: eco.primarySoft,
            pillSize: _pillSize,
            expand: true,
            children: [
              for (final (i, (key, icon, selectedIcon, label)) in tabs.indexed)
                _TabItem(
                  key: key,
                  selected: i == index,
                  icon: i == index ? selectedIcon : icon,
                  label: label,
                  onTap: () {
                    if (i != index) Haptics.selection();
                    onSelect(i);
                  },
                ),
            ],
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
