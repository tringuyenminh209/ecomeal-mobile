import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/core/tax.dart';

// Cùng bộ số với pgTAP 163 (cột sinh orders.tax_amount, 0046) — app và DB phải ra cùng một tiền thuế.
void main() {
  test('includedTax: floor(giá × 8 / 108), giống orders.tax_amount', () {
    expect(includedTax(620), 45);
    expect(includedTax(650), 48);
    expect(includedTax(1), 0);
    expect(includedTax(108), 8);
  });

  test('thuế suất 10%', () {
    expect(includedTax(108, rate: 10), 9);
    expect(includedTax(1100, rate: 10), 100);
  });
}
