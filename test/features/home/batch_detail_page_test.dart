import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ecomeal_mobile/features/home/batch_detail_page.dart';
import 'package:ecomeal_mobile/features/home/home_gateway.dart';
import 'package:ecomeal_mobile/features/favorites/favorite_stops.dart';
import '../../helpers/fake_favorite_stops.dart';
import '../../helpers/test_app.dart';

class MockHomeGateway extends Mock implements HomeGateway {}

void main() {
  late MockHomeGateway gateway;
  late BatchDetail batch;

  setUp(() {
    gateway = MockHomeGateway();
    batch = BatchDetail(
      batchId: 'b-1',
      unitPrice: 450,
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      allergens: const [
        AllergenName(ja: '卵', en: 'Egg'),
        AllergenName(ja: '乳', en: 'Milk'),
      ],
      ingredients: const [IngredientInfo(name: '鶏肉', origin: '国産')],
    );
    when(() => gateway.fetchBatchDetail('b-1')).thenAnswer((_) async => batch);
    when(
      () => gateway.calcCurrentPrice(
        unitPrice: any(named: 'unitPrice'),
        expiresAt: any(named: 'expiresAt'),
      ),
    ).thenAnswer(
      (_) async => const CurrentPriceResult(
        currentPrice: 320,
        tier: '50%',
        minutesRemaining: 42,
      ),
    );
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    Locale locale = const Locale('ja'),
    String? stopLocationId,
  }) {
    tester.view.physicalSize = const Size(390, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeGatewayProvider.overrideWithValue(gateway),
          favoriteStopsGatewayProvider.overrideWithValue(FakeFavoriteStopsGateway([])),
        ],
        // MaterialApp không còn const được: DateTime(...) không phải hằng số.
        child: testApp(
          BatchDetailPage(
            batchId: 'b-1',
            routeStopId: 'rs-1',
            stopName: '大阪学生寮前',
            plannedPickupTime: DateTime.utc(2026, 10, 2, 11, 10), // = 20:10 JST (không phụ thuộc múi giờ máy chạy test)
            stopLocationId: stopLocationId,
          ),
          locale: locale,
        ),
      ),
    );
  }

  testWidgets(
    'còn dưới 2 đơn hôm nay → nút "予約する" bật, hiện đúng giá động + dị ứng',
    (tester) async {
      when(
        () => gateway.fetchTodayReservationCount(),
      ).thenAnswer((_) async => 1);
      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(find.text('¥320'), findsOneWidget);
      expect(find.text('卵'), findsOneWidget);
      // Thẻ "Eco-Truckで受け取り": khung giờ planned_time +20 phút + đúng điểm dừng đã chọn ở SCR-M03.
      expect(find.text('20:10–20:30　大阪学生寮前'), findsOneWidget);
      final button = tester.widget<FilledButton>(
        find.byKey(const Key('reserveButton')),
      );
      expect(button.onPressed, isNotNull);
    },
  );

  testWidgets(
    'đã đạt 2 đơn hôm nay → nút "予約する" bị disable + hiện lý do (BR-002)',
    (tester) async {
      when(
        () => gateway.fetchTodayReservationCount(),
      ).thenAnswer((_) async => 2);
      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(find.text('本日の予約上限（2件）に達しています'), findsOneWidget);
      final button = tester.widget<FilledButton>(
        find.byKey(const Key('reserveButton')),
      );
      expect(button.onPressed, isNull);
    },
  );

  testWidgets(
    'fetchBatchDetail() lỗi → hiện trạng thái Error + nút thử lại, không crash',
    (tester) async {
      when(
        () => gateway.fetchBatchDetail('b-1'),
      ).thenThrow(Exception('network error'));
      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(find.text('データの取得に失敗しました。'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, '再試行'), findsOneWidget);
    },
  );

  // REQ-015: cùng dữ liệu, locale en → nhãn lấy từ app_en.arb, tên dị ứng lấy cột name_en
  testWidgets('locale en → nhãn tiếng Anh + tên dị ứng từ name_en', (
    tester,
  ) async {
    when(() => gateway.fetchTodayReservationCount()).thenAnswer((_) async => 0);
    await pumpPage(tester, locale: const Locale('en'));
    await tester.pumpAndSettle();

    expect(find.text('Allergens'), findsOneWidget);
    expect(find.text('Egg'), findsOneWidget);
    expect(find.text('卵'), findsNothing);
    expect(find.text('Reserve'), findsOneWidget);
  });
  testWidgets('reservation count failure disables CTA and can retry', (
    tester,
  ) async {
    when(
      () => gateway.fetchTodayReservationCount(),
    ).thenThrow(Exception('offline'));
    await pumpPage(tester);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('reserveButton')))
          .onPressed,
      isNull,
    );
    when(() => gateway.fetchTodayReservationCount()).thenAnswer((_) async => 0);
    await tester.tap(find.widgetWithText(TextButton, '再試行'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('reserveButton')))
          .onPressed,
      isNotNull,
    );
  });
  testWidgets('price failure disables CTA', (tester) async {
    when(() => gateway.fetchTodayReservationCount()).thenAnswer((_) async => 0);
    when(
      () => gateway.calcCurrentPrice(
        unitPrice: any(named: 'unitPrice'),
        expiresAt: any(named: 'expiresAt'),
      ),
    ).thenThrow(Exception('offline'));
    await pumpPage(tester);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('reserveButton')))
          .onPressed,
      isNull,
    );
  });
  testWidgets('server price is refreshed after 30 seconds', (tester) async {
    when(() => gateway.fetchTodayReservationCount()).thenAnswer((_) async => 0);
    await pumpPage(tester);
    await tester.pumpAndSettle();
    when(
      () => gateway.calcCurrentPrice(
        unitPrice: any(named: 'unitPrice'),
        expiresAt: any(named: 'expiresAt'),
      ),
    ).thenAnswer(
      (_) async => const CurrentPriceResult(
        currentPrice: 200,
        tier: '50%',
        minutesRemaining: 20,
      ),
    );
    await tester.pump(const Duration(seconds: 31));
    await tester.pumpAndSettle();
    expect(find.text('¥200'), findsOneWidget);
  });
  testWidgets('expiry returns to preceding screen with toast', (tester) async {
    when(() => gateway.fetchTodayReservationCount()).thenAnswer((_) async => 0);
    final ticks = StreamController<DateTime>();
    addTearDown(ticks.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeGatewayProvider.overrideWithValue(gateway),
          homeClockProvider.overrideWith((ref) => ticks.stream),
        ],
        child: testApp(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BatchDetailPage(
                      batchId: 'b-1',
                      routeStopId: 'rs-1',
                      stopName: '大阪駅前',
                      plannedPickupTime: DateTime.now(),
                    ),
                  ),
                ),
                child: const Text('open detail'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open detail'));
    await tester.pumpAndSettle();
    ticks.add(batch.expiresAt.add(const Duration(seconds: 1)));
    await tester.pumpAndSettle();
    expect(find.byType(BatchDetailPage), findsNothing);
    expect(find.text(l10nJa.batchExpired), findsOneWidget);
  });

  testWidgets('quán có đăng ảnh (0038) → hiện ảnh thật + câu "写真は店舗が登録した料理です"; không có → ảnh minh hoạ + "写真はイメージです"', (tester) async {
    when(() => gateway.fetchTodayReservationCount()).thenAnswer((_) async => 0);
    await pumpPage(tester);
    await tester.pumpAndSettle();
    expect(find.text(l10nJa.detailNote), findsOneWidget);
    expect(find.text(l10nJa.detailNotePhoto), findsNothing);

    batch = BatchDetail(
      batchId: 'b-1',
      unitPrice: 450,
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      allergens: const [],
      ingredients: const [],
      photoUrl: 'https://example.supabase.co/storage/v1/object/public/batch_photos/r-1/a.jpg',
    );
    await tester.pumpWidget(const SizedBox());
    await pumpPage(tester);
    await tester.pump();
    await tester.pump();
    expect(find.text(l10nJa.detailNotePhoto), findsOneWidget);
    final photo = tester.widget<Image>(find.byWidgetPredicate((w) => w is Image && w.image is NetworkImage));
    expect((photo.image as NetworkImage).url, endsWith('batch_photos/r-1/a.jpg'));
  });

  testWidgets('0053: có stopLocationId → thẻ 受け取り có nút ☆ お気に入り; không có thì không hiện', (tester) async {
    when(() => gateway.fetchTodayReservationCount()).thenAnswer((_) async => 0);
    await pumpPage(tester, stopLocationId: 'stop-1');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('favoriteStarButton')), findsOneWidget);

    await pumpPage(tester);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('favoriteStarButton')), findsNothing);
  });
}
