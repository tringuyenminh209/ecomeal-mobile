import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ecomeal_mobile/features/home/customer_home_page.dart';
import 'package:ecomeal_mobile/features/home/home_gateway.dart';
import 'package:ecomeal_mobile/features/home/batch_detail_page.dart';
import 'package:ecomeal_mobile/core/line_official_account.dart';
import 'package:ecomeal_mobile/features/profile/profile_gateway.dart';
import '../../helpers/test_app.dart';

class MockHomeGateway extends Mock implements HomeGateway {}

void main() {
  late MockHomeGateway gateway;
  late bool unsubscribed;
  late VoidCallback onTrucks;
  late VoidCallback onListings;
  final listing = BatchListing(
    batchId: 'b1',
    routeStopId: 'rs1',
    unitPrice: 450,
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
    stopName: '大阪駅前',
    plannedPickupTime: DateTime.now(),
    stopLat: 34.69,
    stopLng: 135.50,
    remainingQty: 4,
    truckId: 't1',
  );
  setUp(() {
    gateway = MockHomeGateway();
    unsubscribed = false;
    when(() => gateway.watchChanges(onTrucks: any(named: 'onTrucks'), onListings: any(named: 'onListings'))).thenAnswer((invocation) {
      onTrucks = invocation.namedArguments[#onTrucks] as VoidCallback;
      onListings = invocation.namedArguments[#onListings] as VoidCallback;
      return () {
        unsubscribed = true;
      };
    });
    when(() => gateway.fetchActiveListings()).thenAnswer((_) async => [listing]);
    when(() => gateway.fetchTodayTrucks()).thenAnswer((_) async => []);
    when(
      () => gateway.calcCurrentPrice(
        unitPrice: any(named: 'unitPrice'),
        expiresAt: any(named: 'expiresAt'),
      ),
    ).thenAnswer((_) async => const CurrentPriceResult(currentPrice: 320, tier: '50%', minutesRemaining: 42));
    when(() => gateway.fetchBatchDetail('b1')).thenAnswer(
      (_) async =>
          BatchDetail(batchId: 'b1', unitPrice: 450, expiresAt: listing.expiresAt, allergens: [], ingredients: []),
    );
    when(() => gateway.fetchTodayReservationCount()).thenAnswer((_) async => 0);
  });
  Future<void> pump(
    WidgetTester tester, {
    Object? locationError,
    bool lineLinked = false,
    bool isActive = true,
    Future<bool> Function()? openLine,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeGatewayProvider.overrideWithValue(gateway),
          currentPositionProvider.overrideWith((ref) => Future.error(locationError ?? Exception('GPS denied'))),
          lineLinkedProvider.overrideWith((ref) async => lineLinked),
          openLineOfficialAccountProvider.overrideWithValue(openLine),
        ],
        child: testApp(CustomerHomePage(isActive: isActive)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('GPS denied keeps batches available; selected pair opens detail', (tester) async {
    await pump(tester);
    expect(find.text('位置情報を取得できませんでした\n端末の位置情報の設定とネットワーク接続を確認してください。'), findsOneWidget);
    expect(find.text('¥320'), findsOneWidget);
    await tester.tap(find.byKey(const Key('listingCard_b1_rs1')));
    await tester.pumpAndSettle();
    final detail = tester.widget<BatchDetailPage>(find.byType(BatchDetailPage));
    expect(detail.batchId, 'b1');
    expect(detail.routeStopId, 'rs1');
    expect(detail.stopName, '大阪駅前');
  });
  testWidgets('empty state uses real query result', (tester) async {
    when(() => gateway.fetchActiveListings()).thenAnswer((_) async => []);
    await pump(tester);
    expect(find.text('本日はまだ販売予定がありません'), findsOneWidget);
    expect(find.text(l10nJa.homeEmptyBody), findsOneWidget); // chưa liên kết → vẫn mời liên kết LINE
  });
  testWidgets('empty + đã liên kết LINE → không mời cài lại, nút LINEを開く mở Official Account', (tester) async {
    when(() => gateway.fetchActiveListings()).thenAnswer((_) async => []);
    var opened = 0;
    await pump(
      tester,
      lineLinked: true,
      openLine: () async {
        opened++;
        return true;
      },
    );

    expect(find.text(l10nJa.homeEmptyBodyLinked), findsOneWidget);
    expect(find.text(l10nJa.setupLineNotify), findsNothing);
    await tester.tap(find.text(l10nJa.openLine));
    await tester.pumpAndSettle();
    expect(opened, 1);
  });
  testWidgets('network failure retry reloads list', (tester) async {
    when(() => gateway.fetchActiveListings()).thenThrow(Exception('offline'));
    await pump(tester);
    expect(find.text('読み込めませんでした'), findsOneWidget);
    when(() => gateway.fetchActiveListings()).thenAnswer((_) async => [listing]);
    await tester.tap(find.widgetWithText(OutlinedButton, '再試行'));
    await tester.pumpAndSettle();
    expect(find.text('¥320'), findsOneWidget);
  });
  // U01: GPS (onTrucks) chỉ tải lại xe — không gọi lại danh sách món; đổi lô (onListings) chỉ tải lại món
  testWidgets('Realtime: GPS reloads trucks only, batch change reloads listings only', (tester) async {
    await pump(tester);
    clearInteractions(gateway);
    onTrucks();
    await tester.pump(const Duration(milliseconds: 251));
    await tester.pumpAndSettle();
    verify(() => gateway.fetchTodayTrucks()).called(1);
    verifyNever(() => gateway.fetchActiveListings());
    onListings();
    await tester.pumpAndSettle();
    verify(() => gateway.fetchActiveListings()).called(1);
    verifyNever(() => gateway.fetchTodayTrucks());
  });
  testWidgets('Realtime invalidates data and subscription is removed on dispose', (tester) async {
    await pump(tester);
    when(() => gateway.fetchActiveListings()).thenAnswer((_) async => []);
    onListings();
    await tester.pumpAndSettle();
    expect(find.text('本日はまだ販売予定がありません'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(unsubscribed, true);
  });
  testWidgets('periodic refresh removes expired batches without a Realtime event', (tester) async {
    await pump(tester);
    when(() => gateway.fetchActiveListings()).thenAnswer((_) async => []);
    await tester.pump(const Duration(seconds: 31));
    await tester.pumpAndSettle();
    expect(find.text('本日はまだ販売予定がありません'), findsOneWidget);
  });
  testWidgets('permanently denied GPS offers Settings while batches remain available', (tester) async {
    await pump(tester, locationError: LocationPermission.deniedForever);
    expect(find.text('設定を開く'), findsOneWidget);
    expect(find.text('¥320'), findsOneWidget);
  });

  // ── Chọn xe (Figma 246:2016, レビュー第68回) ─────────────────────────────────────────────
  RouteStopInfo stop(String id, String name, int minutes, {bool departed = false}) => RouteStopInfo(
    routeStopId: id,
    stopName: name,
    plannedTime: DateTime.now().add(Duration(minutes: minutes)),
    departed: departed,
  );
  BatchListing listingAt(String batchId, String stopId, String stopName, {String truckId = 't1'}) => BatchListing(
    batchId: batchId,
    routeStopId: stopId,
    unitPrice: 450,
    expiresAt: DateTime.now().add(const Duration(hours: 2)),
    stopName: stopName,
    plannedPickupTime: DateTime.now(),
    stopLat: 34.69,
    stopLng: 135.50,
    remainingQty: 3,
    truckId: truckId,
  );
  final truckRoute = TruckRoute(
    truckId: 't1',
    position: null,
    stops: [stop('rs0', '梅田公園', -40, departed: true), stop('rs1', '大阪駅前', 20), stop('rs2', '中之島公園', 70)],
  );

  testWidgets('chạm thẻ xe → lộ trình xe đó: điểm đã qua, điểm kế tiếp, thẻ lô theo từng điểm; đóng → về danh sách', (
    tester,
  ) async {
    when(() => gateway.fetchTodayTrucks()).thenAnswer((_) async => [truckRoute]);
    when(() => gateway.fetchActiveListings()).thenAnswer(
      (_) async => [
        listingAt('b1', 'rs1', '大阪駅前'),
        listingAt('b2', 'rs2', '中之島公園'),
        listingAt('bx', 'rs9', '他のトラックの停車地', truckId: 't2'),
      ],
    );
    await pump(tester);
    expect(find.text(l10nJa.truckNextStop('大阪駅前')), findsOneWidget);

    await tester.tap(find.byKey(const Key('truckStatusCard')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('truckRoute_t1')), findsOneWidget);
    expect(find.text(l10nJa.truckNumber(1)), findsOneWidget);
    expect(find.text(l10nJa.truckRouteSummary(3)), findsOneWidget);
    expect(find.text(l10nJa.stopPassed), findsOneWidget);
    expect(
      find.descendant(of: find.byKey(const Key('routeStop_rs1')), matching: find.text(l10nJa.nextStopBadge)),
      findsOneWidget,
    );
    expect(find.byKey(const Key('listingCard_b1_rs1')), findsOneWidget);
    expect(find.byKey(const Key('listingCard_b2_rs2')), findsOneWidget);
    expect(find.byKey(const Key('listingCard_bx_rs9')), findsNothing); // lô của xe khác

    await tester.tap(find.byKey(const Key('truckRouteClose')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('truckRoute_t1')), findsNothing);
    expect(find.text(l10nJa.nearbyBatches), findsOneWidget);
  });

  testWidgets('chọn thẻ lô trong lộ trình → chi tiết đúng cặp (lô, điểm nhận) của điểm đó', (tester) async {
    when(() => gateway.fetchTodayTrucks()).thenAnswer((_) async => [truckRoute]);
    when(() => gateway.fetchActiveListings()).thenAnswer((_) async => [listingAt('b2', 'rs2', '中之島公園')]);
    await pump(tester);
    await tester.tap(find.byKey(const Key('truckStatusCard')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('listingCard_b2_rs2')));
    await tester.pumpAndSettle();
    final detail = tester.widget<BatchDetailPage>(find.byType(BatchDetailPage));
    expect(detail.routeStopId, 'rs2');
    expect(detail.stopName, '中之島公園');
  });

  testWidgets('xe không còn lô nào đang bán → báo rõ, không hiện thẻ', (tester) async {
    when(() => gateway.fetchTodayTrucks()).thenAnswer((_) async => [truckRoute]);
    when(() => gateway.fetchActiveListings()).thenAnswer((_) async => [listingAt('bx', 'rs9', 'x', truckId: 't2')]);
    await pump(tester);
    await tester.tap(find.byKey(const Key('truckStatusCard')));
    await tester.pumpAndSettle();

    expect(find.text(l10nJa.truckNoBatches), findsOneWidget);
  });

  testWidgets('xe đã đi hết điểm dừng → không vẽ thẻ xe (không bịa trạng thái)', (tester) async {
    when(() => gateway.fetchTodayTrucks()).thenAnswer(
      (_) async => [
        TruckRoute(truckId: 't1', position: null, stops: [stop('rs0', '梅田公園', -40, departed: true)]),
      ],
    );
    await pump(tester);
    expect(find.byKey(const Key('truckStatusCard')), findsNothing);
  });

  // Sheet 3 mức (Figma 881:1929 / 2041 / 2137): màn thử cao 844 → 低 = 120/844, 高 = 0.9; 中 vừa khít nội dung
  // (tiêu đề + thẻ xe + hàng thẻ ngang — 2026-10-18, trước là 0.46 cố định và hàng thẻ bị cắt dưới thanh tab)
  double sheetTop(WidgetTester tester) => tester.getTopLeft(find.byKey(const Key('homeSheet'))).dy;
  double cardBottom(WidgetTester tester) => tester.getBottomLeft(find.byKey(const Key('listingCard_b1_rs1')).first).dy;

  testWidgets('中: cả hàng thẻ ngang nằm trong sheet (không bị cắt), kể cả chữ hệ thống lớn', (tester) async {
    when(() => gateway.fetchTodayTrucks()).thenAnswer((_) async => [truckRoute]);
    for (final scale in [1.0, 1.3]) {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      await pump(tester);
      expect(find.byKey(const Key('truckStatusCard')), findsOneWidget);
      expect(cardBottom(tester), lessThanOrEqualTo(844), reason: 'textScale $scale');
      // vẫn chừa bản đồ phía trên (không lên tới 高)
      expect(sheetTop(tester), greaterThan(844 * (1 - 0.9) + 20), reason: 'textScale $scale');
    }
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });

  testWidgets('kéo lên → 高: danh sách dọc, không còn thẻ xe; kéo xuống → về 中', (tester) async {
    when(() => gateway.fetchTodayTrucks()).thenAnswer((_) async => [truckRoute]);
    await pump(tester);
    final midTop = sheetTop(tester);
    expect(cardBottom(tester), lessThanOrEqualTo(844));
    expect(find.byKey(const Key('truckStatusCard')), findsOneWidget);

    await tester.drag(find.text(l10nJa.nearbyBatches), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(sheetTop(tester), closeTo(844 * (1 - 0.9), 1));
    expect(find.byKey(const Key('truckStatusCard')), findsNothing);
    // Hàng gọn: chưa có GPS → chỉ tên điểm nhận (không có phút đi bộ)
    expect(
      find.descendant(of: find.byKey(const Key('listingCard_b1_rs1')), matching: find.text('大阪駅前')),
      findsOneWidget,
    );

    await tester.drag(find.text(l10nJa.nearbyBatches), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(sheetTop(tester), closeTo(midTop, 1));
    expect(find.byKey(const Key('truckStatusCard')), findsOneWidget);
  });

  testWidgets('kéo xuống → 低: 1 dòng tóm tắt xe, rung nhẹ khi dừng; chạm dòng → lộ trình xe ở 中', (tester) async {
    final haptics = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') haptics.add(call.arguments);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    when(() => gateway.fetchTodayTrucks()).thenAnswer((_) async => [truckRoute]);
    await pump(tester);
    final midTop = sheetTop(tester);
    // mở app: sheet tự lên mức 中 vừa đo — không rung (người dùng chưa chạm gì)
    expect(haptics, isEmpty);

    await tester.drag(find.text(l10nJa.nearbyBatches), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(sheetTop(tester), closeTo(844 - 120, 1));
    expect(haptics, ['HapticFeedbackType.selectionClick']);
    expect(find.byKey(const Key('listingCard_b1_rs1')), findsNothing);
    final peek = find.byKey(const Key('truckPeekLine'));
    expect(find.descendant(of: peek, matching: find.textContaining('次は大阪駅前')), findsOneWidget);

    await tester.tap(peek);
    await tester.pumpAndSettle();
    expect(sheetTop(tester), closeTo(midTop, 1));
    expect(find.byKey(const Key('truckRoute_t1')), findsOneWidget);
  });

  // 2026-10-18 lỗi thật trên iPhone: thả tay ở 中 thì sheet nảy lên xuống 1〜2 giây. snapSizes là list mới mỗi lần dựng →
  // DraggableScrollableSheet coi như đổi mức dừng và cho trượt lại từ đầu; trang dựng lại liên tục (vị trí, dữ liệu, đồng hồ).
  testWidgets('thả tay gần 中 trong lúc trang đang dựng lại liên tục → trượt thẳng về 中, không nảy ngược', (
    tester,
  ) async {
    when(() => gateway.fetchTodayTrucks()).thenAnswer((_) async => [truckRoute]);
    await pump(tester);
    final midTop = sheetTop(tester);
    final container = ProviderScope.containerOf(tester.element(find.byType(CustomerHomePage)));

    await tester.drag(find.text(l10nJa.nearbyBatches), const Offset(0, -60));
    final tops = <double>[];
    for (var i = 0; i < 40; i++) {
      container.invalidate(todayTrucksProvider); // dựng lại như khi dữ liệu / vị trí cập nhật
      await tester.pump(const Duration(milliseconds: 16));
      tops.add(sheetTop(tester));
    }
    await tester.pumpAndSettle();
    expect(sheetTop(tester), closeTo(midTop, 1));
    // khoảng cách tới 中 chỉ giảm dần (không đổi chiều)
    for (var i = 1; i < tops.length; i++) {
      expect(
        (tops[i] - midTop).abs(),
        lessThanOrEqualTo((tops[i - 1] - midTop).abs() + 0.5),
        reason: 'frame $i: ${tops.take(i + 1).toList()}',
      );
    }
  });

  testWidgets('F05: GPS bursts produce one refresh per window', (tester) async {
    await pump(tester);
    clearInteractions(gateway);
    for (var i = 0; i < 20; i++) { onTrucks(); }
    await tester.pump(const Duration(milliseconds: 249));
    verifyNever(() => gateway.fetchTodayTrucks());
    await tester.pump(const Duration(milliseconds: 2));
    await tester.pumpAndSettle();
    verify(() => gateway.fetchTodayTrucks()).called(1);
    verifyNever(() => gateway.fetchActiveListings());
  });

  testWidgets('F05: background stops refresh and subscription; resume refreshes', (tester) async {
    await pump(tester);
    clearInteractions(gateway);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 31));
    onTrucks(); onListings();
    await tester.pump(const Duration(milliseconds: 251));
    verifyNever(() => gateway.fetchTodayTrucks());
    verifyNever(() => gateway.fetchActiveListings());
    expect(unsubscribed, true);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    verify(() => gateway.fetchTodayTrucks()).called(1);
    verify(() => gateway.fetchActiveListings()).called(1);
  });

  testWidgets('F05: inactive Home has no timer or subscription', (tester) async {
    await pump(tester, isActive: false);
    verifyNever(() => gateway.watchChanges(onTrucks: any(named: 'onTrucks'), onListings: any(named: 'onListings')));
    clearInteractions(gateway);
    await tester.pump(const Duration(seconds: 31));
    verifyNever(() => gateway.fetchTodayTrucks());
    verifyNever(() => gateway.fetchActiveListings());
  });
}
