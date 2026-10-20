import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/l10n/l10n.dart';
import 'package:ecomeal_mobile/widgets/language_picker.dart';
import '../helpers/test_app.dart';

void main() {
  test('mọi ngôn ngữ app có đều có tên viết bằng chính ngôn ngữ đó và tên bằng ja/en', () {
    for (final l in AppLocalizations.supportedLocales) {
      final code = l.languageCode;
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
        onPressed: () async => result = await showLanguageSheet(context, current: 'ja'),
        child: const Text('open'),
      ),
    )));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('日本語'), findsWidgets);
    expect(find.text('English'), findsOneWidget);
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
}
