import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecomeal_mobile/core/app_language.dart';
import 'package:ecomeal_mobile/features/auth/locale_controller.dart';

void main() {
  test('chưa từng chọn, máy tiếng Nhật → ja (SCR-M01 chọn sẵn)', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final controller = LocaleController(prefs, const Locale('ja', 'JP'), allowedCodes: businessLanguageCodes);

    expect(controller.state.languageCode, 'ja');
  });

  test('chưa từng chọn, máy dùng ngôn ngữ app chưa có → English', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    expect(LocaleController(prefs, const Locale('en', 'US'), allowedCodes: businessLanguageCodes).state.languageCode, 'en');
    expect(LocaleController(prefs, const Locale('th'), allowedCodes: businessLanguageCodes).state.languageCode, 'en');
  });

  test(
    'đã lưu ngôn ngữ từ lần trước → đọc lại đúng giá trị, không theo máy',
    () async {
      SharedPreferences.setMockInitialValues({'preferred_language': 'en'});
      final prefs = await SharedPreferences.getInstance();
      final controller = LocaleController(prefs, const Locale('ja'), allowedCodes: businessLanguageCodes);

      expect(controller.state.languageCode, 'en');
    },
  );

  test('setLocale() cập nhật state VÀ ghi xuống SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final controller = LocaleController(prefs, const Locale('ja'), allowedCodes: businessLanguageCodes);

    await controller.setLocale(const Locale('en'));

    expect(controller.state.languageCode, 'en');
    expect(prefs.getString('preferred_language'), 'en');
  });

  group('2026-11-09: app khách có thêm 7 ngôn ngữ (zh tw ko id ne fil pt)', () {
    test('máy tiếng Hàn / Indonesia → app khách chọn sẵn đúng ngôn ngữ; app quán/tài xế/vận hành vẫn English', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      expect(LocaleController(prefs, const Locale('ko', 'KR'), allowedCodes: customerLanguageCodes).state.appCode, 'ko');
      expect(LocaleController(prefs, const Locale('id'), allowedCodes: customerLanguageCodes).state.appCode, 'id');
      expect(LocaleController(prefs, const Locale('ko', 'KR'), allowedCodes: businessLanguageCodes).state.appCode, 'en');
    });

    test('máy tiếng Trung: Đài Loan / Hồng Kông / script Hant → tw (phồn thể); đại lục → zh', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      LocaleController make(Locale d) => LocaleController(prefs, d, allowedCodes: customerLanguageCodes);
      expect(make(const Locale('zh', 'TW')).state.appCode, 'tw');
      expect(make(const Locale('zh', 'HK')).state.appCode, 'tw');
      expect(make(const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')).state.appCode, 'tw');
      expect(make(const Locale('zh', 'CN')).state.appCode, 'zh');
      expect(make(const Locale('zh')).state.appCode, 'zh');
    });

    test("'tw' là Locale zh + Hant (không phải mã ISO 'tw' = Twi) và quay lại đúng 'tw'", () {
      final l = localeForCode('tw');
      expect(l.languageCode, 'zh');
      expect(l.scriptCode, 'Hant');
      expect(l.appCode, 'tw');
      expect(localeForCode('zh').appCode, 'zh');
      expect(localeForCode('fil').appCode, 'fil');
    });

    test('setLocale(tw) lưu mã "tw" xuống máy, mở lại app đọc ra đúng tiếng Trung phồn thể', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final c = LocaleController(prefs, const Locale('ja'), allowedCodes: customerLanguageCodes);
      await c.setLocale(localeForCode('tw'));
      expect(prefs.getString('preferred_language'), 'tw');
      final reopened = LocaleController(prefs, const Locale('ja'), allowedCodes: customerLanguageCodes);
      expect(reopened.state.appCode, 'tw');
    });

    test('đã lưu "zh" nhưng app này không hỗ trợ (app quán/tài xế/vận hành) → coi như chưa chọn, theo máy', () async {
      SharedPreferences.setMockInitialValues({'preferred_language': 'zh'});
      final prefs = await SharedPreferences.getInstance();
      expect(LocaleController(prefs, const Locale('ja'), allowedCodes: businessLanguageCodes).state.appCode, 'ja');
    });
  });
}
