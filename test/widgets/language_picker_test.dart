import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/core/app_flavor.dart';
import 'package:ecomeal_mobile/core/app_language.dart';
import 'package:ecomeal_mobile/features/home/home_gateway.dart';
import 'package:ecomeal_mobile/features/legal/terms_gateway.dart';
import 'package:ecomeal_mobile/l10n/l10n.dart';
import 'package:ecomeal_mobile/widgets/language_picker.dart';
import '../helpers/test_app.dart';

void main() {
  test('mọi ngôn ngữ app có đều có tên viết bằng chính ngôn ngữ đó và tên bằng ja/en', () {
    for (final l in AppLocalizations.supportedLocales) {
      final code = l.appCode;
      expect(languageEndonym(code), isNot(code), reason: code);
      expect(languageNameIn(l10nJa, code), isNot(code), reason: code);
      expect(languageNameIn(l10nEn, code), isNot(code), reason: code);
    }
  });

  test('defaultLocaleFor: máy dùng ngôn ngữ app có → ngôn ngữ đó, không có → English', () {
    const supported = [Locale('ja'), Locale('en')];
    expect(defaultLocaleFor(const Locale('ja', 'JP'), supported), const Locale('ja'));
    expect(defaultLocaleFor(const Locale('en', 'GB'), supported), const Locale('en'));
    expect(defaultLocaleFor(const Locale('ko'), supported), const Locale('en'));
  });

  test('2026-10-20: app có tiếng Việt và Uzbek (chữ Latin); máy tiếng Việt / Uzbek → chọn sẵn đúng ngôn ngữ đó', () {
    final codes = AppLocalizations.supportedLocales.map((l) => l.appCode).toList();
    expect(codes, containsAll(['ja', 'en', 'vi', 'uz']));
    expect(languageEndonym('vi'), 'Tiếng Việt');
    expect(languageEndonym('uz'), 'Oʻzbekcha');
    expect(languageNameIn(l10nJa, 'uz'), 'ウズベク語');
    const supported = AppLocalizations.supportedLocales;
    expect(defaultLocaleFor(const Locale('vi', 'VN'), supported), const Locale('vi'));
    expect(defaultLocaleFor(const Locale('uz'), supported), const Locale('uz'));
  });

  test('2026-11-09: app có đủ 11 ngôn ngữ cho app khách; mỗi mã có file ARB + tên viết bằng chính ngôn ngữ đó', () {
    final codes = AppLocalizations.supportedLocales.map((l) => l.appCode).toSet();
    expect(codes, containsAll(customerLanguageCodes));
    // 2026-11-09: नेपाली tạm gỡ khỏi bảng chọn (rủi ro chưa có người bản xứ đọc) → app khách 10 ngôn ngữ, ARB ne vẫn có sẵn
    expect(customerLanguageCodes.length, 10);
    expect(customerLanguageCodes, isNot(contains('ne')));
    expect(codes, contains('ne'));
    expect(businessLanguageCodes, ['ja', 'en', 'vi', 'uz']);
    expect(languageEndonym('tw'), '繁體中文');
    expect(languageEndonym('ne'), 'नेपाली');
    expect(languageNameIn(l10nEn, 'tw'), 'Chinese (Traditional)');
    expect(languageNameIn(l10nJa, 'fil'), 'フィリピン語');
  });

  test('flavor: app khách 11 ngôn ngữ, 3 app còn lại 4', () {
    expect(languageCodesFor(AppFlavor.customer), customerLanguageCodes);
    for (final f in [AppFlavor.driver, AppFlavor.store, AppFlavor.admin]) {
      expect(languageCodesFor(f), businessLanguageCodes);
    }
  });

  test('tokushohoPageUrl: mỗi ngôn ngữ vào đúng trang của site (/tw/tokushoho/ ...)', () {
    expect(tokushohoPageUrl('ja'), endsWith('.vercel.app/tokushoho/'));
    expect(tokushohoPageUrl('en'), endsWith('.vercel.app/en/tokushoho/'));
    expect(tokushohoPageUrl('tw'), endsWith('.vercel.app/tw/tokushoho/'));
    expect(tokushohoPageUrl('pt'), endsWith('.vercel.app/pt/tokushoho/'));
  });

  test('tên chất gây dị ứng (DB chỉ có ja/en): tiếng Nhật → ja, còn lại (en/vi/uz) → en', () {
    const a = AllergenName(ja: '卵', en: 'Egg');
    expect(a.forLanguage('ja'), '卵');
    expect(a.forLanguage('en'), 'Egg');
    expect(a.forLanguage('vi'), 'Egg');
    expect(a.forLanguage('uz'), 'Egg');
  });

  test('filterLanguages: khớp tên bằng ngôn ngữ đó, tên bằng ngôn ngữ đang dùng, không phân biệt hoa thường', () {
    String jaName(String c) => languageNameIn(l10nJa, c);
    expect(filterLanguages(['ja', 'en'], '', jaName), ['ja', 'en']);
    expect(filterLanguages(['ja', 'en'], 'ENG', jaName), ['en']);
    expect(filterLanguages(['ja', 'en'], '英語', jaName), ['en']);
    expect(filterLanguages(['ja', 'en'], '日本', jaName), ['ja']);
    expect(filterLanguages(['ja', 'en'], 'xyz', jaName), isEmpty);
  });

  testWidgets('bảng chọn: chọn ngôn ngữ khác → trả mã; chọn lại ngôn ngữ đang dùng → null', (tester) async {
    String? result = 'unset';
    await tester.pumpWidget(testApp(Builder(
      builder: (context) => TextButton(
        onPressed: () async => result = await showLanguageSheet(context, current: 'ja', codes: businessLanguageCodes),
        child: const Text('open'),
      ),
    )));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('日本語'), findsWidgets);
    expect(find.text('English'), findsOneWidget);
    // mỗi ngôn ngữ 1 dòng: không có dòng tên dịch (英語, ベトナム語…) bên dưới
    expect(find.text('英語'), findsNothing);
    expect(find.text('ベトナム語'), findsNothing);
    // ít hơn 9 ngôn ngữ → không có ô tìm
    expect(find.byKey(const Key('languageSearch')), findsNothing);
    await tester.tap(find.byKey(const Key('languageOption_en')));
    await tester.pumpAndSettle();
    expect(result, 'en');

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('languageOption_ja')));
    await tester.pumpAndSettle();
    expect(result, isNull);
  });

  testWidgets('app khách: 10 ngôn ngữ → có ô tìm; gõ 繁 → chỉ còn 繁體中文; chọn → trả mã tw', (tester) async {
    String? result = 'unset';
    await tester.pumpWidget(testApp(Builder(
      builder: (context) => TextButton(
        onPressed: () async => result = await showLanguageSheet(context, current: 'ja', codes: customerLanguageCodes),
        child: const Text('open'),
      ),
    )));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('languageSearch')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('languageSearch')), '繁');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('languageOption_tw')), findsOneWidget);
    expect(find.byKey(const Key('languageOption_zh')), findsNothing);
    await tester.tap(find.byKey(const Key('languageOption_tw')));
    await tester.pumpAndSettle();
    expect(result, 'tw');
  });
}
