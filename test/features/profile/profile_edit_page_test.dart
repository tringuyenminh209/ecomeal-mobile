import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ecomeal_mobile/features/profile/profile_edit_page.dart';
import 'package:ecomeal_mobile/features/profile/profile_gateway.dart';
import '../../helpers/test_app.dart';

class MockProfileGateway extends Mock implements ProfileGateway {}

void main() {
  late MockProfileGateway gateway;
  const initial = UserProfile(name: '春香 美香', nameKana: null, email: 'mika@example.jp');

  setUp(() => gateway = MockProfileGateway());

  // Mở SCR-M08 bằng push từ 1 màn giả (giống thật: SCR-M07 push sang) — để test được cả pop(true)
  // lẫn hộp thoại "変更を破棄しますか？" khi quay lại. Màn giả phải có Scaffold như SCR-M07 thật:
  // SnackBar "プロフィールを更新しました" cần 1 Scaffold còn trên màn hình sau khi pop() mới hiện được.
  Future<void> pumpPage(WidgetTester tester, {void Function(bool?)? onResult}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [profileGatewayProvider.overrideWithValue(gateway)],
        child: testApp(
          Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => const ProfileEditPage(initial: initial)),
                  );
                  onResult?.call(result);
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  FilledButton saveButton(WidgetTester tester) => tester.widget<FilledButton>(find.byKey(const Key('saveProfileButton')));

  testWidgets('chưa đổi gì → "保存する" disabled', (tester) async {
    await pumpPage(tester);
    expect(saveButton(tester).onPressed, isNull);
  });

  testWidgets('xoá trống 表示名 → hiện "表示名を入力してください", vẫn disabled, KHÔNG gọi API', (tester) async {
    await pumpPage(tester);
    await tester.enterText(find.byKey(const Key('nameField')), '  ');
    await tester.pump();

    expect(find.text('表示名を入力してください'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNull);
    verifyNever(() => gateway.updateProfile(name: any(named: 'name'), nameKana: any(named: 'nameKana')));
  });

  testWidgets('sửa hợp lệ → gửi giá trị đã trim (API-023), quay về SCR-M07 với kết quả true', (tester) async {
    bool? result;
    when(() => gateway.updateProfile(name: any(named: 'name'), nameKana: any(named: 'nameKana'))).thenAnswer((_) async {});
    await pumpPage(tester, onResult: (r) => result = r);

    await tester.enterText(find.byKey(const Key('nameField')), ' 春香 美香子 ');
    await tester.enterText(find.byKey(const Key('kanaField')), 'ハルカ ミカコ');
    await tester.pump();
    await tester.tap(find.byKey(const Key('saveProfileButton')));
    await tester.pumpAndSettle();

    verify(() => gateway.updateProfile(name: '春香 美香子', nameKana: 'ハルカ ミカコ')).called(1);
    expect(result, isTrue);
    expect(find.text('プロフィールを更新しました'), findsOneWidget);
  });

  testWidgets('lưu thất bại (mạng) → vẫn ở SCR-M08, giữ nguyên nội dung, báo "保存に失敗しました。もう一度お試しください"', (tester) async {
    when(() => gateway.updateProfile(name: any(named: 'name'), nameKana: any(named: 'nameKana')))
        .thenThrow(Exception('network'));
    await pumpPage(tester);

    await tester.enterText(find.byKey(const Key('nameField')), '春香 美香子');
    await tester.pump();
    await tester.tap(find.byKey(const Key('saveProfileButton')));
    await tester.pumpAndSettle();

    expect(find.text('保存に失敗しました。もう一度お試しください'), findsOneWidget);
    expect(find.text('プロフィール編集'), findsOneWidget);
    expect(tester.widget<TextField>(find.byKey(const Key('nameField'))).controller!.text, '春香 美香子');
    expect(saveButton(tester).onPressed, isNotNull); // bấm lại được để thử lần nữa
  });

  testWidgets('có thay đổi chưa lưu + bấm back → hỏi "変更を破棄しますか？"; 編集を続ける thì ở lại, 破棄する thì thoát', (tester) async {
    bool? result;
    await pumpPage(tester, onResult: (r) => result = r);
    await tester.enterText(find.byKey(const Key('nameField')), '春香 美香子');
    await tester.pump();

    // Không dùng tester.pageBack(): hàm đó tìm nút theo tooltip tiếng Anh "Back", mà app chạy ja nên tooltip
    // của Material là "戻る" (localizationsDelegates, Chương 15) → bấm thẳng widget BackButton của AppBar.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('変更を破棄しますか？'), findsOneWidget);

    await tester.tap(find.byKey(const Key('keepEditingButton')));
    await tester.pumpAndSettle();
    expect(find.text('プロフィール編集'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('discardButton')));
    await tester.pumpAndSettle();
    expect(find.text('プロフィール編集'), findsNothing);
    expect(result, isFalse);
  });
}
