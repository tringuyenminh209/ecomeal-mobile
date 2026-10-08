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
    expect(image.image, isA<NetworkImage>());
    expect(image.semanticLabel, l10nJa.mealPhotoLabel);
  });
}
