import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ecomeal_mobile/features/home/batch_card.dart';
import 'package:ecomeal_mobile/features/home/batch_detail_page.dart';
import 'package:ecomeal_mobile/features/home/home_gateway.dart';
import '../../helpers/test_app.dart';

class _MockHomeGateway extends Mock implements HomeGateway {}

Future<double> _rowHeight(WidgetTester tester, double scale) async {
  late double h;
  await tester.pumpWidget(MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: Builder(builder: (context) {
        h = BatchCard.rowHeight(context);
        return const SizedBox();
      }),
    ),
  ));
  return h;
}

void main() {
  testWidgets('hàng thẻ cao 168 (Figma) và cao theo cỡ chữ hệ thống, tối đa 1.8 lần', (tester) async {
    expect(await _rowHeight(tester, 1.0), 168);
    expect(await _rowHeight(tester, 1.5), closeTo(252, 0.01));
    expect(await _rowHeight(tester, 3.0), closeTo(168 * 1.8, 0.01));
  });

  testWidgets('hàng gọn (sheet 高): điểm nhận + phút đi bộ, giá hiện tại, số túi; chạm → chi tiết', (tester) async {
    final gateway = _MockHomeGateway();
    when(
      () => gateway.calcCurrentPrice(unitPrice: any(named: 'unitPrice'), expiresAt: any(named: 'expiresAt')),
    ).thenAnswer((_) async => const CurrentPriceResult(currentPrice: 320, tier: '50%', minutesRemaining: 42));
    final listing = BatchListing(
      batchId: 'b1',
      routeStopId: 'rs1',
      unitPrice: 450,
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      stopName: '大阪駅前',
      plannedPickupTime: DateTime.now(),
      stopLat: 34.69,
      stopLng: 135.50,
      availableQty: 4,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [homeGatewayProvider.overrideWithValue(gateway)],
        child: testApp(
          Scaffold(body: BatchCard(listing: listing, compact: true, width: double.infinity, walkMinutes: 6)),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(l10nJa.stopWalk('大阪駅前', 6)), findsOneWidget);
    expect(find.text('¥320'), findsOneWidget);
    expect(find.text(l10nJa.remainingBags(4)), findsOneWidget);
    await tester.tap(find.byKey(const Key('listingCard_b1_rs1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(BatchDetailPage), findsOneWidget);
  });
}
