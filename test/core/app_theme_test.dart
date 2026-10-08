import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/core/theme/app_theme.dart';

void main() {
  test('buildAppTheme(): bộ màu sáng (Figma) mặc định; dark: true → bộ màu đêm của tài xế, brightness dark', () {
    final day = buildAppTheme();
    expect(day.brightness, Brightness.light);
    expect(day.extension<EcoPalette>(), EcoPalette.day);
    expect(day.colorScheme.primary, AppColors.primary);

    final night = buildAppTheme(dark: true);
    expect(night.brightness, Brightness.dark);
    expect(night.extension<EcoPalette>(), EcoPalette.night);
    expect(night.scaffoldBackgroundColor, EcoPalette.night.background);
    // Chữ trên nền vàng luôn tối ở cả 2 bộ màu (vàng + chữ sáng không đọc được)
    expect(night.colorScheme.onSecondary, AppColors.textPrimary);
  });

  testWidgets('context.eco đọc bộ màu của theme đang dùng', (tester) async {
    late EcoPalette seen;
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(dark: true),
      home: Builder(builder: (context) {
        seen = context.eco;
        return const SizedBox();
      }),
    ));
    expect(seen, EcoPalette.night);
  });
}
