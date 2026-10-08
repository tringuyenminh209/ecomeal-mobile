import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/features/payment/card_input.dart';
import '../../helpers/test_app.dart';

void main() {
  final nowJst = DateTime(2026, 10, 9);

  test('detectCardBrand theo dải IIN', () {
    expect(detectCardBrand('4242'), CardBrand.visa);
    expect(detectCardBrand('5555'), CardBrand.mastercard);
    expect(detectCardBrand('2221 0000'), CardBrand.mastercard);
    expect(detectCardBrand('3530 1113'), CardBrand.jcb);
    expect(detectCardBrand('3782'), CardBrand.amex);
    expect(detectCardBrand('3056'), CardBrand.diners);
    expect(detectCardBrand('6011'), isNull); // Discover — không hỗ trợ
    expect(detectCardBrand(''), isNull);
  });

  test('validateCardNumber: Luhn + đúng độ dài của hãng', () {
    expect(validateCardNumber('4242 4242 4242 4242', l10nJa), isNull);
    expect(validateCardNumber('4000 0000 0000 0002', l10nJa), isNull); // thẻ test bị từ chối — hợp lệ về định dạng
    expect(validateCardNumber('3530 1113 3330 0000', l10nJa), isNull);
    expect(validateCardNumber('3782 822463 10005', l10nJa), isNull);
    expect(validateCardNumber('4242 4242 4242 4241', l10nJa), 'カード番号を確認してください。');
    expect(validateCardNumber('4242 4242 4242', l10nJa), 'カード番号を確認してください。');
    expect(validateCardNumber('6011 1111 1111 1117', l10nJa), 'カード番号を確認してください。');
  });

  test('formatCardNumber nhóm số như trên thẻ', () {
    expect(formatCardNumber('4242424242424242'), '4242  4242  4242  4242');
    expect(formatCardNumber('378282246310005'), '3782  822463  10005');
    expect(formatCardNumber('42424'), '4242  4');
    expect(formatCardNumber('42424242424242429999'), '4242  4242  4242  4242');
  });

  test('formatExpiry / parseExpiry / validateExpiry (theo tháng giờ Nhật)', () {
    expect(formatExpiry('0829'), '08 / 29');
    expect(formatExpiry('08'), '08');
    expect(parseExpiry('08 / 29'), (month: 8, year: 2029));
    expect(parseExpiry('13 / 29'), isNull);
    expect(validateExpiry('10 / 26', nowJst, l10nJa), isNull); // tháng hiện tại vẫn dùng được
    expect(validateExpiry('09 / 26', nowJst, l10nJa), '有効期限を確認してください。');
    expect(validateExpiry('1', nowJst, l10nJa), '有効期限を確認してください。');
  });

  test('validateCvc: 3 số, AMEX 4 số', () {
    expect(validateCvc('123', CardBrand.visa, l10nJa), isNull);
    expect(validateCvc('1234', CardBrand.visa, l10nJa), 'セキュリティコードを確認してください。');
    expect(validateCvc('1234', CardBrand.amex, l10nJa), isNull);
  });
}
