import 'package:flutter/material.dart';
import '../core/haptics.dart';
import '../core/theme/app_theme.dart';
import '../core/wide_layout.dart';
import 'ecomeal_logo.dart';
import 'fade_on_change.dart';
import 'pill_tab_bar.dart';
import 'press_scale.dart';
import 'sliding_pill.dart';

export 'pill_tab_bar.dart' show NavTab;

// Khung tab chung của app 店舗 và app 運営: iPad ngang (Figma "Store/Side rail" 559:677, "Admin/Side rail" 791:2483)
// → thanh dọc bên trái; điện thoại / iPad dọc → tab dưới (PillTabBar, cùng viên thuốc trượt với app khách).
// Đổi mục → nội dung hiện dần (FadeOnChange).
class AdaptiveNavShell extends StatelessWidget {
  const AdaptiveNavShell({
    super.key,
    required this.index,
    required this.onSelect,
    required this.tabs,
    required this.body,
    this.bottomBarBorder = false,
  });
  final int index;
  final ValueChanged<int> onSelect;
  final List<NavTab> tabs;
  final Widget body;
  // Figma "Store/Tab bar" có viền trên; "Admin/Tab bar" thì không
  final bool bottomBarBorder;

  @override
  Widget build(BuildContext context) {
    final wide = isWideLayout(context);
    // Nội dung (các trang) LUÔN ở cùng một chỗ trong cây widget — chỉ thêm/bớt thanh dọc và tab dưới quanh nó. Trước đây
    // iPad ngang đặt nội dung trong Row còn dọc đặt thẳng vào Scaffold: xoay iPad làm Flutter dựng lại mọi trang, mất cả dữ
    // liệu đang nhập và ảnh vừa chụp ở 余剰を登録 (báo lỗi của chủ dự án, 2026-10-14). Key giữ Expanded khớp khi rail biến mất.
    return Scaffold(
      body: Row(
        children: [
          if (wide) ...[
            _SideRail(index: index, onSelect: onSelect, tabs: tabs),
            VerticalDivider(width: 1, color: context.eco.border),
          ],
          Expanded(
            key: const ValueKey('adaptiveNavShellBody'),
            child: FadeOnChange(value: index, child: body),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : PillTabBar(index: index, onSelect: onSelect, tabs: tabs, topBorder: bottomBarBorder),
    );
  }
}

// Kích thước theo Figma "Side rail": rộng 96, mục 72×63 bo 16, cách nhau 8; logo (bát 40×40) ở trên.
// Nền của mục đang chọn (Primary Soft) là 1 khối trượt dọc sang mục mới (Figma 「動きの提案」 25).
const _railWidth = 96.0;
const _itemSize = Size(72, 63);

class _SideRail extends StatelessWidget {
  const _SideRail({required this.index, required this.onSelect, required this.tabs});
  final int index;
  final ValueChanged<int> onSelect;
  final List<NavTab> tabs;

  @override
  Widget build(BuildContext context) {
    final eco = context.eco;
    return ColoredBox(
      key: const Key('sideRail'),
      color: eco.surface,
      child: SafeArea(
        right: false,
        child: SizedBox(
          width: _railWidth,
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.fromLTRB(0, 16, 0, 32), child: EcoMealLogo.symbol()),
              SlidingPill(
                selected: index,
                color: eco.primarySoft,
                direction: Axis.vertical,
                spacing: 8,
                radius: 16,
                children: [
                  for (final (i, (key, icon, selectedIcon, label)) in tabs.indexed)
                    _RailItem(
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
            ],
          ),
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({super.key, required this.selected, required this.icon, required this.label, required this.onTap});
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: PressScale(
          child: SizedBox.fromSize(
            size: _itemSize,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 26, color: color),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
