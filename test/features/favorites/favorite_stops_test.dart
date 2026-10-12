import 'package:ecomeal_mobile/features/favorites/favorite_stops.dart';
import 'package:ecomeal_mobile/features/favorites/favorite_stop_bags_page.dart';
import 'package:ecomeal_mobile/features/favorites/favorite_stops_page.dart';
import 'package:ecomeal_mobile/features/home/batch_card.dart';
import 'package:ecomeal_mobile/features/home/home_gateway.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../helpers/fake_favorite_stops.dart';
import '../../helpers/test_app.dart';

const _dorm = FavoriteStop(stopLocationId: 'stop-1', name: '大阪学生寮前', address: '大阪市北区梅田3丁目');

Widget _app(FakeFavoriteStopsGateway gateway, Widget child) => ProviderScope(
      overrides: [favoriteStopsGatewayProvider.overrideWithValue(gateway)],
      child: testApp(Scaffold(body: Center(child: child))),
    );

class MockHomeGateway extends Mock implements HomeGateway {}

BatchListing _listing(String batchId, String? stopLocationId, DateTime pickup) => BatchListing(
      batchId: batchId,
      routeStopId: 'rs-$batchId',
      unitPrice: 650,
      expiresAt: DateTime.now().add(const Duration(hours: 2)),
      stopName: '大阪学生寮前',
      plannedPickupTime: pickup,
      stopLat: 34.7,
      stopLng: 135.5,
      availableQty: 3,
      stopLocationId: stopLocationId,
    );

MockHomeGateway _home(List<BatchListing> listings) {
  final home = MockHomeGateway();
  when(() => home.fetchActiveListings()).thenAnswer((_) async => listings);
  when(() => home.calcCurrentPrice(unitPrice: any(named: 'unitPrice'), expiresAt: any(named: 'expiresAt')))
      .thenAnswer((_) async => const CurrentPriceResult(currentPrice: 650, tier: '0%', minutesRemaining: 90));
  return home;
}

void main() {
  group('FavoriteStarButton (SCR-M04)', () {
    testWidgets('chưa đăng ký → bấm ☆ → gọi set true, SnackBar báo sẽ nhận thông báo, nút thành ★', (tester) async {
      final gateway = FakeFavoriteStopsGateway([]);
      await tester.pumpWidget(_app(gateway, const FavoriteStarButton(stopLocationId: 'stop-9')));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);

      await tester.tap(find.byKey(const Key('favoriteStarButton')));
      await tester.pumpAndSettle();

      expect(gateway.calls, [('stop-9', true)]);
      expect(find.text('お気に入りに追加しました。この受取地点に新しいフードバッグが出たらお知らせします'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('đã đăng ký → bấm ★ → gọi set false', (tester) async {
      final gateway = FakeFavoriteStopsGateway([_dorm]);
      await tester.pumpWidget(_app(gateway, const FavoriteStarButton(stopLocationId: 'stop-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('favoriteStarButton')));
      await tester.pumpAndSettle();

      expect(gateway.calls, [('stop-1', false)]);
      expect(find.text('お気に入りから外しました'), findsOneWidget);
    });

    testWidgets('đã đủ 5 điểm (E-FAV-409) → câu giới hạn, nút vẫn ☆', (tester) async {
      final gateway = FakeFavoriteStopsGateway([])
        ..error = const PostgrestException(message: 'E-FAV-409: up to 5 favorite pickup points');
      await tester.pumpWidget(_app(gateway, const FavoriteStarButton(stopLocationId: 'stop-9')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('favoriteStarButton')));
      await tester.pumpAndSettle();

      expect(find.text('お気に入りの受取地点は5件まで登録できます。マイページから整理してください'), findsOneWidget);
      expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
    });
  });

  test('favoriteErrorMessage: lỗi khác → câu chung', () {
    expect(favoriteErrorMessage(Exception('network'), l10nJa), 'お気に入りを更新できませんでした。時間をおいて再度お試しください');
  });

  group('FavoriteStopsPage (SCR-M16)', () {
    testWidgets('danh sách: tên + địa chỉ; bỏ ★ thì điểm biến mất', (tester) async {
      final gateway = FakeFavoriteStopsGateway([_dorm]);
      await tester.pumpWidget(ProviderScope(
        overrides: [favoriteStopsGatewayProvider.overrideWithValue(gateway)],
        child: testApp(const FavoriteStopsPage()),
      ));
      await tester.pumpAndSettle();
      expect(find.text('大阪学生寮前'), findsOneWidget);
      expect(find.text('大阪市北区梅田3丁目'), findsOneWidget);

      await tester.tap(find.byKey(const Key('favoriteStarButton')));
      await tester.pumpAndSettle();
      expect(find.text('大阪学生寮前'), findsNothing);
      expect(find.text('お気に入りの受取地点はまだありません'), findsOneWidget);
    });

    testWidgets('chưa có điểm nào → Empty hướng dẫn bấm ☆ ở chi tiết', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [favoriteStopsGatewayProvider.overrideWithValue(FakeFavoriteStopsGateway([]))],
        child: testApp(const FavoriteStopsPage()),
      ));
      await tester.pumpAndSettle();
      expect(find.text('お気に入りの受取地点はまだありません'), findsOneWidget);
      expect(find.byKey(const Key('favoriteStarButton')), findsNothing);
    });
  });

  group('SCR-M16 → 受取地点のフードバッグ (Figma 714:1601)', () {
    testWidgets('chạm 1 điểm → chỉ các フードバッグ của điểm đó, sớm nhất trước', (tester) async {
      final now = DateTime.now();
      final home = _home([
        _listing('late', 'stop-1', now.add(const Duration(hours: 2))),
        _listing('other', 'stop-2', now),
        _listing('early', 'stop-1', now.add(const Duration(hours: 1))),
      ]);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          favoriteStopsGatewayProvider.overrideWithValue(FakeFavoriteStopsGateway([_dorm])),
          homeGatewayProvider.overrideWithValue(home),
        ],
        child: testApp(const FavoriteStopsPage()),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('大阪学生寮前'));
      await tester.pumpAndSettle();
      expect(find.byType(FavoriteStopBagsPage), findsOneWidget);
      expect(find.text(l10nJa.stopBagsHeading), findsOneWidget);
      final cards = tester.widgetList<BatchCard>(find.byType(BatchCard)).map((c) => c.listing.batchId).toList();
      expect(cards, ['early', 'late']);
    });

    testWidgets('điểm chưa có フードバッグ tối nay → câu "sẽ báo khi có"', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          favoriteStopsGatewayProvider.overrideWithValue(FakeFavoriteStopsGateway([_dorm])),
          homeGatewayProvider.overrideWithValue(_home([_listing('x', 'stop-2', DateTime.now())])),
        ],
        child: testApp(const FavoriteStopBagsPage(stop: _dorm)),
      ));
      await tester.pumpAndSettle();
      expect(find.text(l10nJa.stopBagsEmptyTitle), findsOneWidget);
      expect(find.byType(BatchCard), findsNothing);
    });
  });
}
