import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/core/line_official_account.dart';

void main() {
  test('lineOfficialAccountUri: thêm @ nếu thiếu, trống → null', () {
    expect(lineOfficialAccountUri('@939hqcxi').toString(), 'https://line.me/R/ti/p/@939hqcxi');
    expect(lineOfficialAccountUri(' 939hqcxi ').toString(), 'https://line.me/R/ti/p/@939hqcxi');
    expect(lineOfficialAccountUri(''), isNull);
  });
}
