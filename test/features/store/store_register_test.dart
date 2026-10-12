import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
      expect(registerBatchErrorMessage(Exception('timeout'), l10nJa), l10nJa.storeErrRegisterFailed);
    });
  });

  group('SCR-S02', () {
    late FakeStoreGateway gateway;
    late List<String> registered;
    setUp(() {
      gateway = FakeStoreGateway(allergenTypes: _catalog);
      registered = [];
    });

    Future<void> pump(WidgetTester tester, {PhotoPicker? picker}) async {
      // フォーム全体が一度に描画される高さ（ListView は画面外の項目を作らない）
      tester.view.physicalSize = const Size(1170, 7200);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          storeGatewayProvider.overrideWithValue(gateway),
          photoPickerProvider.overrideWithValue(picker ?? (_) async => null),
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
      expect(tester.widget<Text>(find.byKey(const Key('storeQtyValue'))).textSpan!.toPlainText(), '3 個');
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
      expect(d.sellByAt.isAfter(DateTime.now()), isTrue);
      expect(registered, ['new-batch']);
      expect(tester.widget<TextField>(find.byKey(const Key('storePriceField'))).controller!.text, '');
    });

    testWidgets('サーバーのエラー → 理由を表示し、入力は残す（再送できる）', (tester) async {
      gateway.registerError = const PostgrestException(message: 'E-ROUTE-004: departed');
      await pump(tester);
      await tester.enterText(find.byKey(const Key('storePriceField')), '500');
      await tapNoAllergens(tester);
      await openSheetAndConfirm(tester);
      expect(find.text(l10nJa.storeErrTruckDeparted), findsOneWidget);
      expect(tester.widget<TextField>(find.byKey(const Key('storePriceField'))).controller!.text, '500');
      expect(registered, isEmpty);
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
