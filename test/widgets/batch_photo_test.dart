import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/widgets/batch_photo.dart';
import '../helpers/test_app.dart';

void main() {
  testWidgets('không có ảnh → ảnh minh hoạ chung (không đọc cho trình đọc màn hình)', (tester) async {
    await tester.pumpWidget(testApp(const BatchPhoto(photoUrl: null, width: 72, height: 72)));
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<AssetImage>());
    expect((image.image as AssetImage).assetName, BatchPhoto.fallbackAsset);
    expect(image.excludeFromSemantics, isTrue);
  });

  testWidgets('có ảnh → tải ảnh thật, có nhãn 「料理の写真」', (tester) async {
    await tester.pumpWidget(testApp(const BatchPhoto(photoUrl: 'https://x/batch_photos/r/a.jpg', width: 72, height: 72)));
    final image = tester.widget<Image>(find.byType(Image).first);
    // Ảnh trong thẻ giải mã nhỏ (cạnh dài 2 × 96 × dpr), không giải mã nguyên ảnh 1600px
    expect(image.image, isA<ResizeImage>());
    final resized = image.image as ResizeImage;
    expect(resized.imageProvider, isA<NetworkImage>());
    expect(resized.policy, ResizeImagePolicy.fit);
    expect(image.semanticLabel, l10nJa.mealPhotoLabel);
  });

  testWidgets('ảnh lớn (đầu trang chi tiết) → giữ ảnh gốc; ảnh thẻ 60 và 72 dùng cùng 1 cỡ giải mã (cùng cache)', (tester) async {
    await tester.pumpWidget(testApp(const BatchPhoto(photoUrl: 'https://x/a.jpg', height: 210)));
    expect(tester.widget<Image>(find.byType(Image).first).image, isA<NetworkImage>());
    ResizeImage thumb() => tester.widget<Image>(find.byType(Image).first).image as ResizeImage;
    await tester.pumpWidget(testApp(const BatchPhoto(photoUrl: 'https://x/a.jpg', width: 60, height: 60)));
    final small = thumb();
    await tester.pumpWidget(testApp(const BatchPhoto(photoUrl: 'https://x/a.jpg', width: 72, height: 72)));
    final large = thumb();
    expect((small.width, small.height, small.policy, small.imageProvider), (large.width, large.height, large.policy, large.imageProvider));
  });
}
