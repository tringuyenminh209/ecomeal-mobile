import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart' show ImageSource;
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:ecomeal_mobile/core/photo_picker.dart';
import 'package:ecomeal_mobile/features/store/store_gateway.dart';
import 'package:ecomeal_mobile/features/store/store_register_logic.dart';
import 'package:ecomeal_mobile/features/store/store_register_page.dart';
import '../../helpers/fake_store_gateway.dart';
import '../../helpers/test_app.dart';

// 1x1 の透明 PNG（Image.memory がデコードできる本物の画像）
final _png1x1 = base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==');

const _names = {
  'egg': '卵', 'milk': '乳', 'wheat': '小麦', 'buckwheat': 'そば', 'peanut': '落花生（ピーナッツ）', 'shrimp': 'えび', 'crab': 'かに',
  'walnut': 'くるみ', 'almond': 'アーモンド', 'abalone': 'あわび', 'squid': 'いか', 'salmon_roe': 'いくら', 'orange': 'オレンジ',
  'cashew': 'カシューナッツ', 'kiwi': 'キウイフルーツ', 'beef': '牛肉', 'sesame': 'ごま', 'salmon': 'さけ', 'mackerel': 'さば',
  'soybean': '大豆', 'chicken': '鶏肉', 'banana': 'バナナ', 'pork': '豚肉', 'matsutake': 'まつたけ', 'peach': 'もも',
  'mountain_yam': 'やまいも', 'apple': 'りんご', 'gelatin': 'ゼラチン',
};

// DB は順序を保証しない → 逆順で返す
final _catalog = [
  for (final e in _names.entries.toList().reversed) AllergenType(id: 'id-${e.key}', code: e.key, nameJa: e.value, nameEn: e.key),
];

StoreRestaurant _restaurant() => StoreRestaurant(
  id: 'r-1',
  name: 'キッチン青葉',
  address: '大阪市',
  closingTime: '21:30:00',
  isApproved: true,
  rejectedAt: null,
  rejectionReason: null,
  appliedAt: DateTime.utc(2026, 10, 1),
  applicantName: '青葉 太郎',
);

void main() {
  group('logic', () {
    test('sortAllergens: seed の順（表示義務8 → 推奨20）、未知のコードは最後', () {
      final sorted = sortAllergens([..._catalog, const AllergenType(id: 'x', code: 'new_code', nameJa: '新', nameEn: 'new')]);
      expect(sorted.map((t) => t.code).take(8), allergenCodeOrder.take(8));
      expect(sorted.last.code, 'new_code');
      expect(sorted.length, 29);
    });

    test('allergenChipLabel: 括弧の補足を外す', () {
      expect(allergenChipLabel('落花生（ピーナッツ）'), '落花生');
      expect(allergenChipLabel('卵'), '卵');
    });

    test('sellByAtJst: JST の日付＋時刻 → UTC（日付の境目も JST で判定）', () {
      final now = DateTime.utc(2026, 10, 10, 16); // JST 10/11 01:00
      expect(sellByAtJst(now: now, tomorrow: false, hour: 21, minute: 0), DateTime.utc(2026, 10, 11, 12));
      expect(sellByAtJst(now: now, tomorrow: true, hour: 9, minute: 30), DateTime.utc(2026, 10, 12, 0, 30));
    });

    test('defaultSellByTime: 閉店時刻、読めなければ 21:00', () {
      expect(defaultSellByTime('21:30:00'), (hour: 21, minute: 30));
      expect(defaultSellByTime('bad'), (hour: 21, minute: 0));
      expect(defaultSellByTime('25:00:00'), (hour: 21, minute: 0));
    });

    test('registerBatchErrorMessage: コードごとの文言、写真の失敗、不明', () {
      expect(registerBatchErrorMessage(const PostgrestException(message: 'E-ROUTE-004: departed'), l10nJa), l10nJa.storeErrTruckDeparted);
      expect(registerBatchErrorMessage(const PostgrestException(message: 'E-REST-008: past'), l10nJa), l10nJa.storeErrSellByPast);
      expect(registerBatchErrorMessage(const BatchPhotoUploadException('net'), l10nJa), l10nJa.storeErrPhotoUpload);
      // Audit S01: không có trả lời của server → kết quả chưa rõ (lô có thể đã tạo), không nói 「登録できませんでした」
      expect(registerBatchErrorMessage(Exception('timeout'), l10nJa), l10nJa.storeErrResultUnknown);
      expect(registerBatchErrorMessage(const PostgrestException(message: 'E-XXX-999: other'), l10nJa), l10nJa.storeErrRegisterFailed);
    });
  });

  group('SCR-S02', () {
    late FakeStoreGateway gateway;
    late List<String> registered;
    var previewFails = false;
    setUp(() {
      gateway = FakeStoreGateway(allergenTypes: _catalog);
      previewFails = false;
      registered = [];
      // Giờ quán đăng món (15:00 JST hôm nay) — kết quả không phụ thuộc giờ chạy test (quán thử đóng cửa 21:30)
      final jst = DateTime.now().toUtc().add(const Duration(hours: 9));
      storeClock = () => DateTime.utc(jst.year, jst.month, jst.day, 6);
    });
    tearDown(() => storeClock = DateTime.now);


    Future<void> pump(WidgetTester tester, {PhotoPicker? picker, Size size = const Size(1170, 7200)}) async {
      // フォーム全体が一度に描画される高さ（ListView は画面外の項目を作らない）
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          storeGatewayProvider.overrideWithValue(gateway),
          photoPickerProvider.overrideWithValue(picker ?? (_) async => null),
          // 値段は calc_current_price（サーバー）— テストでは 7割の値段を返す
          storePricePreviewProvider.overrideWith((ref, k) async {
            if (previewFails) throw Exception('rpc');
            return (k.unitPrice * 0.7).floor();
          }),
        ],
        child: testApp(StoreRegisterPage(restaurant: _restaurant(), onRegistered: registered.add)),
      ));
      await tester.pumpAndSettle();
    }

    Future<void> openSheetAndConfirm(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('storeReviewButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('storeConfirmSubmit')));
      await tester.pumpAndSettle();
    }

    Future<void> tapNoAllergens(WidgetTester tester) async {
      await tester.ensureVisible(find.byKey(const Key('storeNoAllergens')));
      await tester.tap(find.byKey(const Key('storeNoAllergens')));
      await tester.pumpAndSettle();
    }

    testWidgets('アレルゲンを選ばず「含まれていません」も無い → エラー、確認シートを開かない（0068）', (tester) async {
      await pump(tester);
      await tester.enterText(find.byKey(const Key('storePriceField')), '500');
      await tester.tap(find.byKey(const Key('storeReviewButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('storeAllergenError')), findsOneWidget);
      expect(find.text(l10nJa.storeConfirmTitle), findsNothing);
    });

    testWidgets('「含まれていません」→ アレルゲンなしで送る。アレルゲンを選ぶと確認は外れる（どちらか一方）', (tester) async {
      await pump(tester);
      await tester.tap(find.widgetWithText(FilterChip, '卵'));
      await tapNoAllergens(tester);
      expect(tester.widget<FilterChip>(find.widgetWithText(FilterChip, '卵')).selected, isFalse);
      await tester.tap(find.widgetWithText(FilterChip, '乳'));
      await tester.pump();
      expect(tester.widget<CheckboxListTile>(find.byKey(const Key('storeNoAllergens'))).value, isFalse);
      await tester.tap(find.widgetWithText(FilterChip, '乳'));
      await tapNoAllergens(tester);

      await tester.enterText(find.byKey(const Key('storePriceField')), '500');
      await openSheetAndConfirm(tester);
      final d = gateway.drafts.single;
      expect(d.allergenTypeIds, isEmpty);
      expect(d.noAllergens, isTrue);
    });

    testWidgets('確認: お客様に見える今の値段と、お店の取り分の目安（数 × 今の値段 × 取り分）', (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(const Key('storeQtyPlus')));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('storePriceField')), '600');
      await tapNoAllergens(tester);
      await tester.tap(find.byKey(const Key('storeReviewButton')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.storeConfirmPreviewTitle), findsOneWidget);
      expect(find.text(l10nJa.storeConfirmPreviewPrice('¥420')), findsOneWidget);
      // 2食 × ¥420 × 20% = ¥168
      expect(find.text(l10nJa.storeConfirmEstimateValue('¥168')), findsOneWidget);
      expect(find.text(l10nJa.storeConfirmEstimateNote('20')), findsOneWidget);
    });

    testWidgets('確認: 値段を計算できなくても登録はできる', (tester) async {
      previewFails = true;
      await pump(tester);
      await tester.enterText(find.byKey(const Key('storePriceField')), '600');
      await tapNoAllergens(tester);
      await openSheetAndConfirm(tester);
      expect(gateway.drafts, hasLength(1));
    });

    testWidgets('よく使う12品目を Figma の順で表示、閉店時刻が販売期限の初期値', (tester) async {
      await pump(tester);
      final labels = tester.widgetList<FilterChip>(find.byType(FilterChip)).map((c) => (c.label as Text).data).toList();
      expect(labels, ['卵', '乳', '小麦', 'えび', 'かに', 'そば', '落花生', 'くるみ', '大豆', '鶏肉', '豚肉', 'ごま']);
      expect(find.text('21:30'), findsOneWidget);
    });

    testWidgets('単価が空 → エラー、確認シートを開かない', (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(const Key('storeReviewButton')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.storeErrPrice), findsOneWidget);
      expect(find.text(l10nJa.storeConfirmTitle), findsNothing);
    });

    testWidgets('0071: 単価 ¥199 → エラー（下限 ¥200）、確認シートを開かない', (tester) async {
      await pump(tester);
      await tester.enterText(find.byKey(const Key('storePriceField')), '199');
      await tester.tap(find.byKey(const Key('storeReviewButton')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.storeErrPrice), findsOneWidget);
      expect(find.text(l10nJa.storeConfirmTitle), findsNothing);
    });

    testWidgets('すべて表示: 28品目を2つに分けて表示、シートでの選択が登録画面に残る', (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(const Key('storeAllergenShowAll')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.storeAllergenMandatory), findsOneWidget);
      expect(find.text('落花生（ピーナッツ）'), findsOneWidget); // シートは正式名
      await tester.tap(find.byKey(const Key('allergen-egg')));
      await tester.scrollUntilVisible(find.byKey(const Key('allergen-gelatin')), 100,
          scrollable: find.descendant(of: find.byType(DraggableScrollableSheet), matching: find.byType(Scrollable)));
      await tester.tap(find.byKey(const Key('allergen-gelatin')));
      await tester.pump();
      expect(find.text(l10nJa.storeAllergenDone(2)), findsOneWidget);
      // 決定を押さずに閉じても残る
      Navigator.of(tester.element(find.byKey(const Key('storeAllergenClear')))).pop();
      await tester.pumpAndSettle();
      final egg = tester.widget<FilterChip>(find.widgetWithText(FilterChip, '卵'));
      expect(egg.selected, isTrue);
      expect(find.textContaining(l10nJa.storeAllergenSelected(2)), findsOneWidget);
    });

    // Audit S04 (Figma 972:21374): chọn ảnh lỗi → báo dưới ảnh + đường sửa, nhập liệu giữ nguyên
    testWidgets('S04: カメラが許可されていない → 「カメラを使えません」+ 設定を開く・写真から選ぶ、入力はそのまま', (tester) async {
      final sources = <ImageSource>[];
      await pump(tester, picker: (source) async {
        sources.add(source);
        if (source == ImageSource.camera) throw PlatformException(code: 'camera_access_denied');
        return PickedPhoto(bytes: _png1x1, extension: 'png');
      });
      await tester.enterText(find.byKey(const Key('storePriceField')), '780');
      await tester.tap(find.byKey(const Key('storePhotoField')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('storePhotoCamera')));
      await tester.pumpAndSettle();

      expect(find.text(l10nJa.storePhotoCameraDenied), findsOneWidget);
      expect(find.byKey(const Key('storePhotoOpenSettings')), findsOneWidget);
      expect(find.text('780'), findsOneWidget);

      await tester.tap(find.byKey(const Key('storePhotoOtherSource')));
      await tester.pumpAndSettle();
      expect(sources, [ImageSource.camera, ImageSource.gallery]);
      expect(find.byKey(const Key('storePhotoProblem')), findsNothing);
    });

    testWidgets('S04: 写真を読み込めない → 「写真を読み込めませんでした」（設定ボタンなし）; キャンセルは何も出さない', (tester) async {
      var fail = true;
      await pump(tester, picker: (_) async => fail ? throw Exception('io') : null);
      await tester.tap(find.byKey(const Key('storePhotoField')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('storePhotoLibrary')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.photoReadFailed), findsOneWidget);
      expect(find.byKey(const Key('storePhotoOpenSettings')), findsNothing);

      fail = false; // lần sau: người dùng huỷ chọn
      await tester.tap(find.byKey(const Key('storePhotoField')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('storePhotoLibrary')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('storePhotoProblem')), findsNothing);
    });

    testWidgets('登録: 数・単価・アレルゲン・原材料・写真を送り、完了で onRegistered、フォームはリセット', (tester) async {
      await pump(tester, picker: (_) async => PickedPhoto(bytes: _png1x1, extension: 'png'));
      await tester.tap(find.byKey(const Key('storePhotoField')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('storePhotoCamera')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('storeQtyPlus')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('storeQtyPlus')));
      await tester.pump();
      expect(tester.widget<Text>(find.byKey(const Key('storeQtyValue'))).textSpan!.toPlainText(), '3 食');
      await tester.enterText(find.byKey(const Key('storePriceField')), '780');
      await tester.tap(find.widgetWithText(FilterChip, '卵'));
      await tester.tap(find.byKey(const Key('storeIngredientAdd')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('storeIngredientName')), '鶏肉');
      await tester.enterText(find.byKey(const Key('storeIngredientOrigin')), '国産（鹿児島県）');
      await tester.tap(find.byKey(const Key('storeIngredientSave')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('storeReviewButton')));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.storeConfirmQtyValue(3)), findsOneWidget);
      expect(find.text('¥780'), findsOneWidget);
      expect(find.text('鶏肉（国産（鹿児島県））'), findsOneWidget);
      await tester.tap(find.byKey(const Key('storeConfirmSubmit')));
      await tester.pumpAndSettle();

      final d = gateway.drafts.single;
      expect(d.estimatedQty, 3);
      expect(d.unitPrice, 780);
      expect(d.allergenTypeIds, ['id-egg']);
      expect(d.noAllergens, isFalse);
      expect(d.ingredients.single.name, '鶏肉');
      expect(d.photo?.extension, 'png');
      expect(d.sellByAt.isAfter(storeClock()), isTrue);
      expect(registered, ['new-batch']);
      expect(tester.widget<TextField>(find.byKey(const Key('storePriceField'))).controller!.text, '');
    });

    testWidgets('サーバーのエラー → 理由を表示し、入力は残す（再送できる）', (tester) async {
      gateway.registerError = const PostgrestException(message: 'E-ROUTE-004: departed');
      await pump(tester);
      await tester.enterText(find.byKey(const Key('storePriceField')), '500');
      await tapNoAllergens(tester);
      await openSheetAndConfirm(tester);
      // Audit S06: lỗi hiện TRONG sheet xác nhận, sheet không đóng (Figma 618:2343)
      expect(find.descendant(of: find.byType(BottomSheet), matching: find.text(l10nJa.storeErrTruckDeparted)), findsOneWidget);
      expect(find.text(l10nJa.storeConfirmTitle), findsOneWidget);
      expect(tester.widget<TextField>(find.byKey(const Key('storePriceField'))).controller!.text, '500');
      expect(registered, isEmpty);
    });

    // Audit S06 (Figma 972:21512): bấm nút ở cuối form có lỗi → cuộn về ô lỗi đầu tiên + tóm tắt trên nút
    testWidgets('S06: フォームの下で「内容を確認する」→ 最初のエラー（単価）まで戻り、ボタンの上に「確認してください（2か所）」', (tester) async {
      await pump(tester, size: const Size(1170, 1500)); // 画面が低い（キーボード表示中など）→ 単価が画面の外に出る
      await tester.drag(find.byKey(const Key('storeRegisterForm')), const Offset(0, -3000));
      await tester.pumpAndSettle();
      // 単価は画面の外（ListView は作ってあるが offstage）
      expect(find.byKey(const Key('storePriceField')), findsNothing);
      expect(find.byKey(const Key('storePriceField'), skipOffstage: false), findsOneWidget);

      await tester.tap(find.byKey(const Key('storeReviewButton')));
      await tester.pumpAndSettle();
      final view = tester.view.physicalSize / tester.view.devicePixelRatio;
      final price = tester.getRect(find.byKey(const Key('storePriceField')));
      expect(price.top >= 0 && price.bottom <= view.height, isTrue, reason: 'storePriceField = $price');
      expect(find.text(l10nJa.storeErrSummary(2)), findsOneWidget); // 単価 + アレルゲン
      expect(find.text(l10nJa.storeConfirmTitle), findsNothing);
    });

    // Audit S01 (2026-10-19, 0076): gửi lại sau lỗi dùng CÙNG khoá → server trả lô đã tạo thay vì tạo lô thứ 2;
    // đăng xong thì form mới có khoá mới (lần đăng mới có chủ ý vẫn ra lô riêng)
    testWidgets('S06: 単価は正しくアレルゲンが未選択 → 画面の下のアレルゲンまで進む（1か所）', (tester) async {
      await pump(tester, size: const Size(1170, 1500));
      await tester.ensureVisible(find.byKey(const Key('storePriceField'), skipOffstage: false));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('storePriceField')), '500');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.drag(find.byKey(const Key('storeRegisterForm')), const Offset(0, 3000)); // いちばん上へ
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('storeNoAllergens')), findsNothing); // まだ画面の外

      await tester.tap(find.byKey(const Key('storeReviewButton')));
      await tester.pumpAndSettle();
      final view = tester.view.physicalSize / tester.view.devicePixelRatio;
      final error = tester.getRect(find.byKey(const Key('storeAllergenError')));
      expect(error.top >= 0 && error.bottom <= view.height, isTrue, reason: 'storeAllergenError = $error');
      expect(find.text(l10nJa.storeErrSummary(1)), findsOneWidget);
    });

    testWidgets('通信エラーの後の再送は同じ client_request_id、登録できたら次の出品は新しいキー', (tester) async {
      gateway.registerError = Exception('network');
      await pump(tester);
      await tester.enterText(find.byKey(const Key('storePriceField')), '500');
      await tapNoAllergens(tester);
      await openSheetAndConfirm(tester);
      // Mất phản hồi: không biết server đã tạo lô chưa → không nói 「登録できませんでした」 (Figma 953:5970)
      expect(find.text(l10nJa.storeErrResultUnknown), findsOneWidget);
      expect(find.text(l10nJa.storeErrRegisterFailed), findsNothing);
      gateway.registerError = null;
      // Gửi lại ngay trong sheet (sheet vẫn mở — audit S06)
      await tester.tap(find.byKey(const Key('storeConfirmSubmit')));
      await tester.pumpAndSettle();
      expect(registered, ['new-batch']);
      expect(gateway.drafts, hasLength(2));
      expect(gateway.drafts[1].requestId, gateway.drafts[0].requestId);

      await tester.enterText(find.byKey(const Key('storePriceField')), '600');
      await tapNoAllergens(tester);
      await openSheetAndConfirm(tester);
      expect(gateway.drafts, hasLength(3));
      expect(gateway.drafts[2].requestId, isNot(gateway.drafts[0].requestId));
    });

    testWidgets('販売の終わり: 翌日 + 時刻の入力（Figma 871:4434）→ その時刻で登録。キャンセルは元のまま', (tester) async {
      await pump(tester);
      await tester.tap(find.text(l10nJa.storeSellByTomorrow));
      await tester.pump();
      await tester.tap(find.byKey(const Key('storeSellByTime')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sellByPreset_21:30')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('sellByConfirm')));
      await tester.pumpAndSettle();
      expect(find.descendant(of: find.byKey(const Key('storeSellByTime')), matching: find.text('21:30')), findsOneWidget);

      await tester.tap(find.byKey(const Key('storeSellByTime')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sellByPreset_20:00')));
      await tester.tap(find.byKey(const Key('sellByCancel')));
      await tester.pumpAndSettle();
      expect(find.descendant(of: find.byKey(const Key('storeSellByTime')), matching: find.text('21:30')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('storePriceField')), '500');
      await tapNoAllergens(tester);
      await openSheetAndConfirm(tester);
      expect(
        gateway.drafts.single.sellByAt,
        sellByAtJst(now: storeClock(), tomorrow: true, hour: 21, minute: 30),
      );
    });

    testWidgets('アレルゲンの一覧を読めない → 登録できない（「なし」として送らない）', (tester) async {
      gateway = _FailingCatalogGateway();
      await pump(tester);
      expect(find.text(l10nJa.storeAllergenLoadFailed), findsOneWidget);
      expect(tester.widget<FilledButton>(find.byKey(const Key('storeReviewButton'))).onPressed, isNull);
    });
  });
}

class _FailingCatalogGateway extends FakeStoreGateway {
  @override
  Future<List<AllergenType>> fetchAllergenTypes() async => throw Exception('network');
}
