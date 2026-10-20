import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart' show ImageSource;
import 'package:mocktail/mocktail.dart';
import 'package:ecomeal_mobile/features/profile/profile_avatar.dart';
import 'package:ecomeal_mobile/features/profile/profile_edit_page.dart';
import 'package:ecomeal_mobile/features/profile/profile_gateway.dart';
import '../../helpers/test_app.dart';

class MockProfileGateway extends Mock implements ProfileGateway {}

// UC-35 / API-049 ảnh đại diện ở SCR-M08 (Figma 419:970〜419:1202).
void main() {
  setUpAll(() => registerFallbackValue(Uint8List(0)));

  group('squareAvatarJpeg', () {
    test('ảnh chữ nhật → cắt vuông ở giữa, 512×512 JPEG', () {
      final source = img.Image(width: 300, height: 200);
      // nửa trái đỏ / nửa phải xanh: cắt giữa (x 50..250) thì cột giữa vẫn là ranh giới
      img.fillRect(source, x1: 0, y1: 0, x2: 149, y2: 199, color: img.ColorRgb8(255, 0, 0));
      img.fillRect(source, x1: 150, y1: 0, x2: 299, y2: 199, color: img.ColorRgb8(0, 0, 255));
      final out = squareAvatarJpeg(Uint8List.fromList(img.encodePng(source)));

      final decoded = img.decodeJpg(out!)!;
      expect((decoded.width, decoded.height), (avatarSide, avatarSide));
      expect(decoded.getPixel(10, 256).r, greaterThan(200)); // mép trái vẫn đỏ
      expect(decoded.getPixel(500, 256).b, greaterThan(200)); // mép phải vẫn xanh
    });

    test('không phải ảnh → null', () {
      expect(squareAvatarJpeg(Uint8List.fromList(List.filled(64, 7))), isNull);
    });

    test('quá 10MB → null (không giải mã)', () async {
      expect(await prepareAvatarJpeg(Uint8List(maxAvatarSourceBytes + 1)), isNull);
    });
  });

  late MockProfileGateway gateway;
  final jpeg = Uint8List.fromList([1, 2, 3]);

  setUp(() => gateway = MockProfileGateway());

  Future<void> pumpPage(
    WidgetTester tester, {
    String? avatarPath,
    AvatarImagePicker? picker,
    Future<Uint8List?> Function(Uint8List)? preparer,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileGatewayProvider.overrideWithValue(gateway),
          avatarImagePickerProvider.overrideWithValue(picker ?? (_) async => Uint8List.fromList([9])),
          avatarJpegPreparerProvider.overrideWithValue(preparer ?? (_) async => jpeg),
          // URL ký giả: Image.network trong test luôn lỗi → hiện chữ cái đầu (errorBuilder), không treo
          avatarUrlProvider.overrideWith((ref, path) async => 'https://example.test/$path'),
        ],
        child: testApp(
          ProfileEditPage(
            initial: UserProfile(name: '春香 美香', nameKana: null, email: 'mika@example.jp', avatarPath: avatarPath),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('chưa có ảnh: 「写真を設定」, sheet không có 「写真を削除」', (tester) async {
    await pumpPage(tester);
    expect(find.text('写真を設定'), findsOneWidget);
    expect(find.text('JPEG・PNG（10MBまで）。正方形に切り抜いて表示します。'), findsOneWidget);

    await tester.tap(find.byKey(const Key('profilePhotoAvatar')));
    await tester.pumpAndSettle();
    expect(find.text('写真を撮る'), findsOneWidget);
    expect(find.text('ライブラリから選ぶ'), findsOneWidget);
    expect(find.byKey(const Key('photoDeleteOption')), findsNothing);
  });

  testWidgets('chọn từ thư viện → tải lên → 「写真を変更」; 保存する vẫn disabled (độc lập)', (tester) async {
    ImageSource? usedSource;
    when(() => gateway.uploadAvatar(any(), previousPath: any(named: 'previousPath')))
        .thenAnswer((_) async => 'u-1/new.jpg');
    await pumpPage(tester, picker: (source) async {
      usedSource = source;
      return Uint8List.fromList([9]);
    });

    await tester.tap(find.byKey(const Key('profilePhotoButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('photoLibraryOption')));
    await tester.pumpAndSettle();

    expect(usedSource, ImageSource.gallery);
    verify(() => gateway.uploadAvatar(jpeg, previousPath: null)).called(1);
    expect(find.text('写真を変更'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byKey(const Key('saveProfileButton'))).onPressed, isNull);
  });

  testWidgets('đã có ảnh → đổi ảnh gửi kèm đường dẫn cũ để xoá', (tester) async {
    when(() => gateway.uploadAvatar(any(), previousPath: any(named: 'previousPath')))
        .thenAnswer((_) async => 'u-1/new.jpg');
    await pumpPage(tester, avatarPath: 'u-1/old.jpg');
    expect(find.text('写真を変更'), findsOneWidget);

    await tester.tap(find.byKey(const Key('profilePhotoAvatar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('photoTakeOption')));
    await tester.pumpAndSettle();

    verify(() => gateway.uploadAvatar(jpeg, previousPath: 'u-1/old.jpg')).called(1);
  });

  testWidgets('tải lên lỗi → câu lỗi đỏ thay dòng gợi ý (419:1146), vẫn 「写真を設定」', (tester) async {
    when(() => gateway.uploadAvatar(any(), previousPath: any(named: 'previousPath'))).thenThrow(Exception('network'));
    await pumpPage(tester);

    await tester.tap(find.byKey(const Key('profilePhotoAvatar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('photoLibraryOption')));
    await tester.pumpAndSettle();

    expect(find.text('写真をアップロードできませんでした。通信状況を確認して、もう一度お試しください。'), findsOneWidget);
    expect(find.text('写真を設定'), findsOneWidget);
  });

  testWidgets('đang tải lên → 「写真をアップロードしています…」, không mở được sheet', (tester) async {
    final upload = Completer<String>();
    when(() => gateway.uploadAvatar(any(), previousPath: any(named: 'previousPath'))).thenAnswer((_) => upload.future);
    await pumpPage(tester);

    await tester.tap(find.byKey(const Key('profilePhotoAvatar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('photoLibraryOption')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('写真をアップロードしています…'), findsOneWidget);
    await tester.tap(find.byKey(const Key('profilePhotoAvatar')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('写真を撮る'), findsNothing);

    upload.complete('u-1/n.jpg');
    await tester.pumpAndSettle();
    expect(find.text('写真を変更'), findsOneWidget);
  });

  testWidgets('không phải ảnh / quá 10MB → SnackBar, KHÔNG tải lên', (tester) async {
    await pumpPage(tester, preparer: (_) async => null);

    await tester.tap(find.byKey(const Key('profilePhotoAvatar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('photoLibraryOption')));
    await tester.pumpAndSettle();

    expect(find.text('10MB以下のJPEG・PNGを選んでください'), findsOneWidget);
    verifyNever(() => gateway.uploadAvatar(any(), previousPath: any(named: 'previousPath')));
  });

  testWidgets('huỷ chọn ảnh → không làm gì', (tester) async {
    await pumpPage(tester, picker: (_) async => null);

    await tester.tap(find.byKey(const Key('profilePhotoAvatar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('photoLibraryOption')));
    await tester.pumpAndSettle();

    verifyNever(() => gateway.uploadAvatar(any(), previousPath: any(named: 'previousPath')));
    expect(find.text('写真を設定'), findsOneWidget);
  });

  testWidgets('bị từ chối quyền camera → dialog 「設定を開く」', (tester) async {
    await pumpPage(tester, picker: (_) async => throw PlatformException(code: 'camera_access_denied'));

    await tester.tap(find.byKey(const Key('profilePhotoAvatar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('photoTakeOption')));
    await tester.pumpAndSettle();

    expect(find.text('カメラと写真へのアクセスが許可されていません'), findsOneWidget);
    expect(find.byKey(const Key('openSettingsButton')), findsOneWidget);
  });

  // Audit S04 (cùng loại): lỗi đọc ảnh trước đây im lặng
  testWidgets('đọc ảnh lỗi (không phải quyền) → 「写真を読み込めませんでした」, không tải lên', (tester) async {
    await pumpPage(tester, picker: (_) async => throw Exception('io'));
    await tester.tap(find.byKey(const Key('profilePhotoAvatar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('photoLibraryOption')));
    await tester.pumpAndSettle();
    expect(find.textContaining('写真を読み込めませんでした'), findsOneWidget);
    verifyNever(() => gateway.uploadAvatar(any(), previousPath: any(named: 'previousPath')));
  });

  testWidgets('写真を削除 → removeAvatar → về chữ cái đầu + SnackBar', (tester) async {
    when(() => gateway.removeAvatar('u-1/old.jpg')).thenAnswer((_) async {});
    await pumpPage(tester, avatarPath: 'u-1/old.jpg');

    await tester.tap(find.byKey(const Key('profilePhotoAvatar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('photoDeleteOption')));
    await tester.pumpAndSettle();

    verify(() => gateway.removeAvatar('u-1/old.jpg')).called(1);
    expect(find.text('写真を削除しました'), findsOneWidget);
    expect(find.text('写真を設定'), findsOneWidget);
  });
}
