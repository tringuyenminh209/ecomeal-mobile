import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ecomeal_mobile/core/photo_picker.dart';
import 'package:ecomeal_mobile/features/driver/driver_account_cards.dart';
import 'package:ecomeal_mobile/features/driver/driver_account_gateway.dart';
import '../../helpers/test_app.dart';

class MockDriverAccountGateway extends Mock implements DriverAccountGateway {}

Widget _cards(DriverAccountGateway gateway, {PhotoPicker? picker}) => ProviderScope(
      overrides: [
        driverAccountGatewayProvider.overrideWithValue(gateway),
        photoPickerProvider.overrideWithValue(picker ?? (_) async => null),
      ],
      child: testApp(
        Scaffold(body: ListView(children: const [DriverLicenseCard(), UpcomingShiftsCard()])),
      ),
    );

void main() {
  late MockDriverAccountGateway gateway;

  setUpAll(() => registerFallbackValue(Uint8List(0)));

  setUp(() {
    gateway = MockDriverAccountGateway();
    when(() => gateway.fetchUpcomingShifts()).thenAnswer((_) async => const []);
  });

  testWidgets('未提出: 案内 → カメラで撮影 → 自分の画像を提出（拡張子・前の画像なし）→ 提出しましたを表示', (tester) async {
    var license = const DriverLicense(status: LicenseStatus.none);
    when(() => gateway.fetchLicense()).thenAnswer((_) async => license);
    when(() => gateway.submitLicense(bytes: any(named: 'bytes'), extension: any(named: 'extension'), previousPath: any(named: 'previousPath')))
        .thenAnswer((_) async => license = const DriverLicense(status: LicenseStatus.submitted, imagePath: 'u/license-1.jpg'));
    ImageSource? usedSource;
    await tester.pumpWidget(_cards(gateway, picker: (source) async {
      usedSource = source;
      return PickedPhoto(bytes: Uint8List.fromList([1, 2, 3]), extension: 'jpg');
    }));
    await tester.pumpAndSettle();

    expect(find.text('未提出'), findsOneWidget);
    expect(find.textContaining('運営が確認するまでシフトには入れません'), findsOneWidget);
    await tester.tap(find.byKey(const Key('licenseUploadButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('licenseSourceCamera')));
    await tester.pumpAndSettle();

    expect(usedSource, ImageSource.camera);
    verify(() => gateway.submitLicense(bytes: Uint8List.fromList([1, 2, 3]), extension: 'jpg', previousPath: null)).called(1);
    expect(find.text('提出しました。運営の確認をお待ちください。'), findsOneWidget);
    expect(find.text('確認待ち'), findsOneWidget); // 再取得して状態が変わる
  });

  testWidgets('差し戻し: 理由を表示し、再提出では前の画像のパスを渡す（古い画像の掃除用）', (tester) async {
    when(() => gateway.fetchLicense()).thenAnswer(
      (_) async => const DriverLicense(status: LicenseStatus.rejected, rejectReason: '文字が読み取れません', imagePath: 'u/old.jpg'),
    );
    when(() => gateway.submitLicense(bytes: any(named: 'bytes'), extension: any(named: 'extension'), previousPath: any(named: 'previousPath')))
        .thenAnswer((_) async {});
    await tester.pumpWidget(_cards(gateway, picker: (_) async => PickedPhoto(bytes: Uint8List(1), extension: 'png')));
    await tester.pumpAndSettle();

    expect(find.text('差し戻し'), findsOneWidget);
    expect(find.text('運営からのメッセージ'), findsOneWidget);
    expect(find.text('文字が読み取れません'), findsOneWidget);
    await tester.tap(find.byKey(const Key('licenseUploadButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('licenseSourceGallery')));
    await tester.pumpAndSettle();
    verify(() => gateway.submitLicense(bytes: any(named: 'bytes'), extension: 'png', previousPath: 'u/old.jpg')).called(1);
  });

  testWidgets('提出に失敗 → エラーを表示（状態は変わらない）。画像を選ばずに閉じたら何もしない', (tester) async {
    when(() => gateway.fetchLicense()).thenAnswer((_) async => const DriverLicense(status: LicenseStatus.none));
    when(() => gateway.submitLicense(bytes: any(named: 'bytes'), extension: any(named: 'extension'), previousPath: any(named: 'previousPath')))
        .thenThrow(Exception('network'));
    var calls = 0;
    await tester.pumpWidget(_cards(gateway, picker: (_) async {
      calls++;
      return calls == 1 ? null : PickedPhoto(bytes: Uint8List(1), extension: 'jpg');
    }));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('licenseUploadButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('licenseSourceCamera')));
    await tester.pumpAndSettle();
    verifyNever(() => gateway.submitLicense(bytes: any(named: 'bytes'), extension: any(named: 'extension'), previousPath: any(named: 'previousPath')));

    await tester.tap(find.byKey(const Key('licenseUploadButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('licenseSourceCamera')));
    await tester.pumpAndSettle();
    expect(find.text('提出できませんでした。通信状態を確認して、もう一度お試しください。'), findsOneWidget);
    expect(find.text('未提出'), findsOneWidget);
  });

  testWidgets('確認済み: 有効期限と「更新した免許証を提出する」、今後のシフトを日付順に表示', (tester) async {
    when(() => gateway.fetchLicense()).thenAnswer(
      (_) async => const DriverLicense(status: LicenseStatus.verified, expiresOn: '2029-03-31', imagePath: 'u/l.jpg'),
    );
    when(() => gateway.fetchUpcomingShifts()).thenAnswer((_) async => const [
          DriverShift(serviceDate: '2026-10-06', plateNumber: 'なにわ 400 さ 12-34'),
          DriverShift(serviceDate: '2026-10-08', plateNumber: 'なにわ 400 さ 90-12'),
        ]);
    await tester.pumpWidget(_cards(gateway));
    await tester.pumpAndSettle();

    expect(find.text('確認済み'), findsOneWidget);
    expect(find.textContaining('有効期限'), findsOneWidget);
    expect(find.textContaining('2029'), findsOneWidget);
    expect(find.text('更新した免許証を提出する'), findsOneWidget);
    expect(find.text('今後のシフト（14日間）'), findsOneWidget);
    expect(find.text('なにわ 400 さ 12-34'), findsOneWidget);
    expect(find.text('なにわ 400 さ 90-12'), findsOneWidget);
  });

  testWidgets('シフトなし → 案内文', (tester) async {
    when(() => gateway.fetchLicense()).thenAnswer((_) async => const DriverLicense(status: LicenseStatus.submitted));
    await tester.pumpWidget(_cards(gateway));
    await tester.pumpAndSettle();
    expect(find.text('予定されたシフトはありません。運営がシフトを入れると、ここに表示されます。'), findsOneWidget);
    expect(find.textContaining('運営が確認しています'), findsOneWidget);
  });
}
