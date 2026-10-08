import '../../l10n/l10n.dart';

// 06_画面設計 §SCR-M08 Validation + Error Message (nguyên văn). Đếm theo runes (ký tự Unicode), không
// theo String.length (UTF-16 code unit) — ký tự ngoài BMP sẽ bị String.length đếm thành 2.
// Câu lỗi lấy từ ARB → hàm nhận AppLocalizations (vẫn thuần, test truyền l10nJa/l10nEn vào).
const _maxLength = 50;

String? validateDisplayName(String raw, AppLocalizations l10n) {
  final value = raw.trim();
  if (value.isEmpty) return l10n.errorDisplayNameRequired; // dùng lại key của SCR-M02 (Chương 15)
  if (value.runes.length > _maxLength) return l10n.errorDisplayNameTooLong(_maxLength);
  return null;
}

String? validateNameKana(String raw, AppLocalizations l10n) {
  if (raw.trim().runes.length > _maxLength) return l10n.errorNameKanaTooLong(_maxLength);
  return null;
}

// Avatar tròn ở SCR-M07. Figma hiện "MH" (chữ cái La-tinh) — nhưng users.name là kanji/kana, không có
// cột romaji nào để suy ra → dùng ký tự đầu tiên của tên (xem box-warn đầu chương).
String avatarInitialOf(String name) {
  final trimmed = name.trim();
  return trimmed.isEmpty ? '?' : String.fromCharCode(trimmed.runes.first);
}
