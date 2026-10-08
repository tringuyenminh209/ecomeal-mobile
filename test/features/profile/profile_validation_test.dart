import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/features/profile/profile_validation.dart';
import '../../helpers/test_app.dart';

void main() {
  test('validateDisplayName(): rỗng / chỉ khoảng trắng → lỗi "表示名を入力してください"', () {
    expect(validateDisplayName('', l10nJa), '表示名を入力してください');
    expect(validateDisplayName('　 ', l10nJa), '表示名を入力してください'); // gồm cả khoảng trắng toàn góc
  });

  test('validateDisplayName(): đúng 50 ký tự OK, 51 ký tự → lỗi (đếm sau khi trim)', () {
    expect(validateDisplayName('あ' * 50, l10nJa), isNull);
    expect(validateDisplayName('  ${'あ' * 50}  ', l10nJa), isNull);
    expect(validateDisplayName('あ' * 51, l10nJa), '表示名は50文字以内で入力してください');
    expect(validateDisplayName('あ' * 51, l10nEn), 'Display name must be 50 characters or fewer');
  });

  test('validateNameKana(): rỗng OK (任意), 51 ký tự → lỗi', () {
    expect(validateNameKana('', l10nJa), isNull);
    expect(validateNameKana('ア' * 51, l10nJa), 'フリガナは50文字以内で入力してください');
  });

  test('avatarInitialOf(): ký tự đầu của tên, tên rỗng → "?"', () {
    expect(avatarInitialOf('春香 美香'), '春');
    expect(avatarInitialOf('  '), '?');
  });
}
