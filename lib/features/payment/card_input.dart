import '../../l10n/l10n.dart';

// SCR-M09 カードを追加 — kiểm tra số thẻ / hạn / CVC NGAY TRÊN MÁY. Số thẻ đầy đủ và CVC không bao giờ được gửi
// đi (ADR-006 追記, 0043): app chỉ gửi hãng + 4 số cuối + hạn. Giá trị đúng tên cột payment_methods.brand.
// badge = chữ trên ô logo (Figma「VISA」「JCB」), displayName = chữ trong「Visa •••• 3456」.
enum CardBrand {
  visa('VISA', 'Visa'),
  mastercard('MC', 'Mastercard'),
  jcb('JCB', 'JCB'),
  amex('AMEX', 'American Express'),
  diners('DINERS', 'Diners Club');

  const CardBrand(this.badge, this.displayName);
  final String badge;
  final String displayName;

  static CardBrand? fromDb(String value) {
    for (final b in values) {
      if (b.name == value) return b;
    }
    return null;
  }
}

String digitsOnly(String raw) => raw.replaceAll(RegExp(r'\D'), '');

// Theo dải IIN công khai của từng hãng — đủ để chọn logo và độ dài CVC; hãng khác coi như không hỗ trợ.
CardBrand? detectCardBrand(String raw) {
  final d = digitsOnly(raw);
  if (d.isEmpty) return null;
  if (d.startsWith('4')) return CardBrand.visa;
  if (d.length >= 2) {
    final two = int.parse(d.substring(0, 2));
    if (two == 34 || two == 37) return CardBrand.amex;
    if (two >= 51 && two <= 55) return CardBrand.mastercard;
    if (two == 36 || two == 38 || two == 39) return CardBrand.diners;
  }
  if (d.length >= 3) {
    final three = int.parse(d.substring(0, 3));
    if (three >= 300 && three <= 305) return CardBrand.diners;
  }
  if (d.length >= 4) {
    final four = int.parse(d.substring(0, 4));
    if (four >= 2221 && four <= 2720) return CardBrand.mastercard;
    if (four >= 3528 && four <= 3589) return CardBrand.jcb;
  }
  return null;
}

bool luhnValid(String digits) {
  var sum = 0;
  var doubleIt = false;
  for (var i = digits.length - 1; i >= 0; i--) {
    var n = digits.codeUnitAt(i) - 48;
    if (doubleIt) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
    doubleIt = !doubleIt;
  }
  return digits.isNotEmpty && sum % 10 == 0;
}

int _numberLength(CardBrand brand) => switch (brand) {
      CardBrand.amex => 15,
      CardBrand.diners => 14,
      _ => 16,
    };

int cvcLength(CardBrand? brand) => brand == CardBrand.amex ? 4 : 3;

// Hiển thị theo nhóm như thẻ thật: AMEX 4-6-5, Diners 4-6-4, còn lại 4-4-4-4.
String formatCardNumber(String raw) {
  final brand = detectCardBrand(raw);
  final d = digitsOnly(raw);
  final limited = d.length > 16 ? d.substring(0, 16) : d;
  final groups = (brand == CardBrand.amex || brand == CardBrand.diners) ? const [4, 6, 5] : const [4, 4, 4, 4];
  final parts = <String>[];
  var start = 0;
  for (final size in groups) {
    if (start >= limited.length) break;
    final end = (start + size).clamp(0, limited.length);
    parts.add(limited.substring(start, end));
    start = end;
  }
  return parts.join('  ');
}

// "0829" / "08/29" → MM / YY
String formatExpiry(String raw) {
  final d = digitsOnly(raw);
  final limited = d.length > 4 ? d.substring(0, 4) : d;
  if (limited.length <= 2) return limited;
  return '${limited.substring(0, 2)} / ${limited.substring(2)}';
}

typedef CardExpiry = ({int month, int year});

CardExpiry? parseExpiry(String raw) {
  final d = digitsOnly(raw);
  if (d.length != 4) return null;
  final month = int.parse(d.substring(0, 2));
  if (month < 1 || month > 12) return null;
  return (month: month, year: 2000 + int.parse(d.substring(2)));
}

// Hết hạn sau tháng ghi trên thẻ — so theo tháng của giờ Nhật, giống payment_card_expired (0043).
bool isCardExpired(CardExpiry expiry, DateTime nowJst) =>
    expiry.year < nowJst.year || (expiry.year == nowJst.year && expiry.month < nowJst.month);

String? validateCardNumber(String raw, AppLocalizations l10n) {
  final d = digitsOnly(raw);
  final brand = detectCardBrand(d);
  if (brand == null || d.length != _numberLength(brand) || !luhnValid(d)) return l10n.cardNumberInvalid;
  return null;
}

String? validateCardHolder(String raw, AppLocalizations l10n) =>
    raw.trim().isEmpty ? l10n.cardHolderRequired : null;

String? validateExpiry(String raw, DateTime nowJst, AppLocalizations l10n) {
  final expiry = parseExpiry(raw);
  if (expiry == null || isCardExpired(expiry, nowJst)) return l10n.cardExpiryInvalid;
  return null;
}

String? validateCvc(String raw, CardBrand? brand, AppLocalizations l10n) =>
    digitsOnly(raw).length == cvcLength(brand) ? null : l10n.cardCvcInvalid;
