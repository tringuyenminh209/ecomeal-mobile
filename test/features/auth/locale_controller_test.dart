import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecomeal_mobile/features/auth/locale_controller.dart';

void main() {
  test('chưa từng chọn, máy tiếng Nhật → ja (SCR-M01 chọn sẵn)', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final controller = LocaleController(prefs, const Locale('ja', 'JP'));

    expect(controller.state.languageCode, 'ja');
  });

  test('chưa từng chọn, máy dùng ngôn ngữ app chưa có → English', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    expect(LocaleController(prefs, const Locale('en', 'US')).state.languageCode, 'en');
    expect(LocaleController(prefs, const Locale('th')).state.languageCode, 'en');
  });

  test(
    'đã lưu ngôn ngữ từ lần trước → đọc lại đúng giá trị, không theo máy',
    () async {
      SharedPreferences.setMockInitialValues({'preferred_language': 'en'});
      final prefs = await SharedPreferences.getInstance();
      final controller = LocaleController(prefs, const Locale('ja'));

      expect(controller.state.languageCode, 'en');
    },
  );

  test('setLocale() cập nhật state VÀ ghi xuống SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final controller = LocaleController(prefs, const Locale('ja'));

    await controller.setLocale(const Locale('en'));

    expect(controller.state.languageCode, 'en');
    expect(prefs.getString('preferred_language'), 'en');
  });
}
