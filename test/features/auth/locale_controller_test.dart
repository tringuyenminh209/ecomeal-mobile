import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecomeal_mobile/features/auth/locale_controller.dart';

void main() {
  test('chưa từng chọn ngôn ngữ → mặc định ja', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final controller = LocaleController(prefs);

    expect(controller.state.languageCode, 'ja');
  });

  test(
    'đã lưu ngôn ngữ từ lần trước → đọc lại đúng giá trị khi khởi tạo',
    () async {
      SharedPreferences.setMockInitialValues({'preferred_language': 'en'});
      final prefs = await SharedPreferences.getInstance();
      final controller = LocaleController(prefs);

      expect(controller.state.languageCode, 'en');
    },
  );

  test('setLocale() cập nhật state VÀ ghi xuống SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final controller = LocaleController(prefs);

    await controller.setLocale(const Locale('en'));

    expect(controller.state.languageCode, 'en');
    expect(prefs.getString('preferred_language'), 'en');
  });
}
