import 'package:flutter/material.dart';
import 'package:ecomeal_mobile/core/theme/app_theme.dart';
import 'package:ecomeal_mobile/l10n/l10n.dart';

// MaterialApp cho widget test: nạp bản dịch giống main.dart. Mặc định 'ja' vì môi trường test của Flutter
// mặc định en_US — không ghi locale thì mọi test đang so chuỗi tiếng Nhật sẽ thấy bản tiếng Anh.
MaterialApp testApp(Widget home, {Locale locale = const Locale('ja')}) =>
    MaterialApp(
      locale: locale,
      theme: buildAppTheme(), // cùng theme với main.dart — widget test dựng đúng bố cục thật
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

// Hàm thuần (map mã lỗi, validate) nhận AppLocalizations làm tham số — test lấy thẳng bản dịch, không cần widget.
final l10nJa = lookupAppLocalizations(const Locale('ja'));
final l10nEn = lookupAppLocalizations(const Locale('en'));
