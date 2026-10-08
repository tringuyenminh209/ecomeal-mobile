import 'package:flutter/material.dart';

// "EcoMeal logo" của Figma (SCR-M01/M02, header SCR-M03): logo Rev 04 hai màu (bát + mặt trời vàng + chữ EcoMeal,
// design/logo-kit/rev04), cao 30 logic px (≈126 rộng). [onDark]: bản đảo màu (bát và chữ trắng) cho nền tối — app tài xế
// (SCR-D00, Figma 351:735). Ảnh PNG theo độ phân giải 1x/2x/3x trong assets/brand/ (xuất bằng
// design/logo-kit/rev04/export-app-icons.cjs) — không thêm package SVG chỉ cho 1 logo.
class EcoMealLogo extends StatelessWidget {
  const EcoMealLogo({super.key, this.height = 30, this.onDark = false});
  final double height;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      onDark ? 'assets/brand/ecomeal-horizontal-on-dark.png' : 'assets/brand/ecomeal-horizontal.png',
      height: height,
      // Tên thương hiệu — giống nhau ở mọi ngôn ngữ, không qua ARB.
      semanticLabel: 'EcoMeal',
      filterQuality: FilterQuality.high,
    );
  }
}
