import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_flavor.dart';
import '../../core/app_language.dart';
import '../../widgets/language_picker.dart';

const _localePrefsKey = 'preferred_language';

// Quản lý ngôn ngữ TRƯỚC khi có session — xem box-warn đầu chương. Lưu local (SharedPreferences)
// thay vì gọi API-023 ngay, vì SCR-M01 chạy lúc chưa đăng nhập, chưa có auth.uid() nào để UPDATE.
class LocaleController extends StateNotifier<Locale> {
  // Chưa từng chọn → ngôn ngữ của máy nếu app có, không thì English (SCR-M01 chọn sẵn, 2026-10-20)
  LocaleController(this._prefs, Locale device, {required List<String> allowedCodes})
    : super(_saved(_prefs, allowedCodes) ?? defaultLocaleFor(device, [for (final c in allowedCodes) localeForCode(c)]));

  // Mã đã lưu mà app này không còn (hoặc chưa) hỗ trợ → coi như chưa chọn
  static Locale? _saved(SharedPreferences prefs, List<String> allowedCodes) {
    final code = prefs.getString(_localePrefsKey);
    return code == null || !allowedCodes.contains(code) ? null : localeForCode(code);
  }

  final SharedPreferences _prefs;

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _prefs.setString(_localePrefsKey, locale.appCode);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'override ở main.dart bằng SharedPreferences.getInstance() đã await xong',
  );
});

// Ngôn ngữ của máy (test ghi đè để không phụ thuộc máy chạy test)
final deviceLocaleProvider = Provider<Locale>((ref) => WidgetsBinding.instance.platformDispatcher.locale);

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
      return LocaleController(
        ref.watch(sharedPreferencesProvider),
        ref.watch(deviceLocaleProvider),
        allowedCodes: languageCodesFor(ref.watch(appFlavorProvider)),
      );
    });

// Đã qua SCR-M01 (chọn ngôn ngữ) ít nhất 1 lần trên máy này chưa — RoleGate (bước 8) dùng để quyết định
// khi chưa đăng nhập thì hiện SCR-M01 hay đi thẳng SCR-M02 (mở lại app, hoặc vừa đăng xuất ở SCR-M07).
final onboardingDoneProvider = StateProvider<bool>((ref) {
  return ref.watch(sharedPreferencesProvider).containsKey(_localePrefsKey);
});
