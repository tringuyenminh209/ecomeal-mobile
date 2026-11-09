import 'package:flutter/widgets.dart';
import 'app_flavor.dart';

// Mã ngôn ngữ của EcoMeal — đúng chuỗi lưu ở máy (SharedPreferences) và ở DB (users.preferred_language, push/LINE) và
// trùng với mã đường dẫn của site công khai (/zh/, /tw/, /fil/ ...). Thứ tự = thứ tự trong bảng chọn (giống header site).
// 'tw' là mã của EcoMeal cho tiếng Trung phồn thể (Đài Loan); với Flutter đó là Locale zh + script Hant (không phải mã ISO 'tw' = Twi).
//
// Chữ của app khách có đủ 11 ngôn ngữ. App quán / tài xế / vận hành chỉ dịch 4 (ja en vi uz): 7 ngôn ngữ còn lại mới có
// chữ của app khách (ARB thiếu khoá thì rơi về tiếng Nhật) nên KHÔNG đưa vào bảng chọn của 3 app đó.
const customerLanguageCodes = ['ja', 'en', 'vi', 'uz', 'zh', 'ko', 'id', 'ne', 'tw', 'fil', 'pt'];
const businessLanguageCodes = ['ja', 'en', 'vi', 'uz'];

List<String> languageCodesFor(AppFlavor flavor) => flavor == AppFlavor.customer ? customerLanguageCodes : businessLanguageCodes;

Locale localeForCode(String code) =>
    code == 'tw' ? const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant') : Locale(code);

extension AppLanguageCode on Locale {
  // Ngược lại của [localeForCode]; mọi biến thể tiếng Trung phồn thể (Hant, TW, HK, MO) → 'tw'
  String get appCode {
    if (languageCode == 'zh' && (scriptCode == 'Hant' || const {'TW', 'HK', 'MO'}.contains(countryCode))) return 'tw';
    return languageCode;
  }
}
