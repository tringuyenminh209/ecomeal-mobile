import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localePrefsKey = 'preferred_language';

// Quản lý ngôn ngữ TRƯỚC khi có session — xem box-warn đầu chương. Lưu local (SharedPreferences)
// thay vì gọi API-023 ngay, vì SCR-M01 chạy lúc chưa đăng nhập, chưa có auth.uid() nào để UPDATE.
class LocaleController extends StateNotifier<Locale> {
  LocaleController(this._prefs)
    : super(Locale(_prefs.getString(_localePrefsKey) ?? 'ja'));

  final SharedPreferences _prefs;

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _prefs.setString(_localePrefsKey, locale.languageCode);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'override ở main.dart bằng SharedPreferences.getInstance() đã await xong',
  );
});

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
      return LocaleController(ref.watch(sharedPreferencesProvider));
    });

// Đã qua SCR-M01 (chọn ngôn ngữ) ít nhất 1 lần trên máy này chưa — RoleGate (bước 8) dùng để quyết định
// khi chưa đăng nhập thì hiện SCR-M01 hay đi thẳng SCR-M02 (mở lại app, hoặc vừa đăng xuất ở SCR-M07).
final onboardingDoneProvider = StateProvider<bool>((ref) {
  return ref.watch(sharedPreferencesProvider).containsKey(_localePrefsKey);
});
