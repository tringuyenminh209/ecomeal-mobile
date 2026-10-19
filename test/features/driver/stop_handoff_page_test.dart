import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:ecomeal_mobile/core/clock.dart';
import 'package:ecomeal_mobile/features/driver/handoff_gateway.dart';
import 'package:ecomeal_mobile/features/driver/qr_scan_page.dart';
import 'package:ecomeal_mobile/features/driver/stop_handoff_page.dart';
import '../../helpers/test_app.dart';
import 'driver_test_data.dart';

class MockHandoffGateway extends Mock implements HandoffGateway {}

const _waitingA = '11111111-0000-0000-0000-00000000beef';
const _waitingB = '33333333-0000-0000-0000-00000000beef'; // cùng mã thủ công BEEF với _waitingA
const _handed = '22222222-0000-0000-0000-00000000cafe';

void main() {
  late MockHandoffGateway gateway;
  String? nextScan;
  late DateTime fakeNow; // đồng hồ giả (clockProvider) — test được "停車終了まで n分" mà không phụ thuộc giờ máy

  StopHandoff handoff({int remaining = 3, List<ReservationAtStop>? reservations, DateTime? departedAt}) => StopHandoff(
        plannedDepartureAt: DateTime(2026, 10, 2, 19, 22),
        departedAt: departedAt,
        reservations: reservations ??
            [
              ReservationAtStop(orderId: _waitingA, status: 'allocated', createdAt: DateTime.utc(2026, 10, 2, 3, 5)),
              ReservationAtStop(orderId: _handed, status: 'picked_up', createdAt: DateTime.utc(2026, 10, 2, 3, 9)),
            ],
        walkupStocks: [WalkupStock(batchId: 'batch-1', restaurantId: 'rest-B', capacity: 12, used: 12 - remaining, remaining: remaining)],
      );

  setUp(() {
    gateway = MockHandoffGateway();
    nextScan = null;
    fakeNow = DateTime(2026, 10, 2, 19, 0);
    when(() => gateway.confirmPickup(any())).thenAnswer((_) async {});
  });

  // Mở D03 bằng push từ 1 màn có Scaffold (giống D01 thật) để nhận message khi pop sau "出発".
  Future<void> pumpPage(WidgetTester tester, {void Function(String?)? onResult}) async {
    tester.view.physicalSize = const Size(1080, 3600); // D03 dài: thẻ この場所で渡すもの + các bước ở trên
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        handoffGatewayProvider.overrideWithValue(gateway),
        // camera không chạy trong test → "quét" trả thẳng chuỗi đặt trước
        qrScanLauncherProvider.overrideWithValue((_) async => nextScan),
        clockProvider.overrideWithValue(() => fakeNow),
      ],
      child: testApp(
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                final r = await Navigator.of(context).push<String>(
                  MaterialPageRoute(builder: (_) => StopHandoffPage(route: routeFixture, stop: routeFixture.stops[3])),
                );
                onResult?.call(r);
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('この場所で渡すもの: số đơn đặt trước, số suất bán không cần đặt (API-025), tổng và từng lô', (tester) async {
    when(() => gateway.fetchStopHandoff('p2')).thenAnswer((_) async => handoff());
    await pumpPage(tester);

    expect(find.text('この場所で渡すもの'), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('handout_total'))).data, '合計 12食');
    expect(tester.widget<Text>(find.byKey(const Key('handout_reserved'))).data, '2件');
    expect(tester.widget<Text>(find.byKey(const Key('handout_sellable'))).data, '3食');
    // tên lô = điểm thu gom của quán B (restaurants bị RLS ẩn)
    expect(find.text('12食（予約なしの残り 3食）'), findsOneWidget);
    expect(find.text('ここでの流れ'), findsOneWidget);
  });

  testWidgets('quét QR của đơn đang chờ ở điểm này → confirm_pickup đúng order_id', (tester) async {
    when(() => gateway.fetchStopHandoff('p2')).thenAnswer((_) async => handoff());
    await pumpPage(tester);
    expect(find.byKey(const Key('count_handed')), findsOneWidget);

    nextScan = _waitingA;
    await tester.tap(find.byKey(const Key('scanQrButton')));
    await tester.pumpAndSettle();

    verify(() => gateway.confirmPickup(_waitingA)).called(1);
  });

  testWidgets('QR của đơn KHÔNG thuộc điểm này (hoặc đã giao) → báo lỗi, không gọi RPC', (tester) async {
    when(() => gateway.fetchStopHandoff('p2')).thenAnswer((_) async => handoff());
    await pumpPage(tester);

    nextScan = _handed; // đã picked_up
    await tester.tap(find.byKey(const Key('scanQrButton')));
    await tester.pumpAndSettle();

    expect(find.text('この停車地点で引き渡し待ちの予約ではありません'), findsOneWidget);
    verifyNever(() => gateway.confirmPickup(any()));
  });

  testWidgets('điểm đã 出発 → hiện 「出発済み」, quét QR / nhập mã / 出発 đều bị khoá (06 §SCR-D03)', (tester) async {
    when(() => gateway.fetchStopHandoff('p2')).thenAnswer((_) async => handoff(departedAt: DateTime(2026, 10, 2, 19, 5)));
    await pumpPage(tester);

    expect(find.text('出発済み'), findsOneWidget);
    expect(tester.widget<InkWell>(find.byKey(const Key('scanQrButton'))).onTap, isNull);
    expect(tester.widget<OutlinedButton>(find.byKey(const Key('manualCodeButton'))).onPressed, isNull);
    expect(tester.widget<FilledButton>(find.byKey(const Key('departButton'))).onPressed, isNull);
  });

  // Audit D01: khách đặt thêm khi xe đang đứng bán — danh sách lúc mở màn chưa có đơn đó
  const newOrder = '44444444-0000-0000-0000-00000000f00d'; // mã thủ công F00D
  List<ReservationAtStop> withNewOrder() => [
        ReservationAtStop(orderId: _waitingA, status: 'allocated', createdAt: DateTime.utc(2026, 10, 2, 3, 5)),
        ReservationAtStop(orderId: newOrder, status: 'allocated', createdAt: DateTime.utc(2026, 10, 2, 9, 50)),
      ];

  testWidgets('D01: QR của đơn vừa đặt (chưa có lúc mở màn) → đọc lại 1 lần rồi giao, không báo "không phải đơn ở đây"', (tester) async {
    var fetches = 0;
    when(() => gateway.fetchStopHandoff('p2'))
        .thenAnswer((_) async => fetches++ == 0 ? handoff() : handoff(reservations: withNewOrder()));
    await pumpPage(tester);

    nextScan = newOrder;
    await tester.tap(find.byKey(const Key('scanQrButton')));
    await tester.pumpAndSettle();

    expect(find.text('この停車地点で引き渡し待ちの予約ではありません'), findsNothing);
    verify(() => gateway.confirmPickup(newOrder)).called(1);
  });

  testWidgets('D01: mã thủ công của đơn vừa đặt → đọc lại rồi giao', (tester) async {
    var fetches = 0;
    when(() => gateway.fetchStopHandoff('p2'))
        .thenAnswer((_) async => fetches++ == 0 ? handoff() : handoff(reservations: withNewOrder()));
    await pumpPage(tester);

    await tester.tap(find.byKey(const Key('manualCodeButton')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('manualCodeField')), 'f00d');
    await tester.tap(find.byKey(const Key('submitManualCodeButton')));
    await tester.pumpAndSettle();

    verify(() => gateway.confirmPickup(newOrder)).called(1);
  });

  testWidgets('D01: đọc lại bị lỗi mạng → báo lỗi chung, không kết luận "không phải đơn ở đây", không gọi RPC', (tester) async {
    var fetches = 0;
    when(() => gateway.fetchStopHandoff('p2')).thenAnswer((_) async {
      if (fetches++ == 0) return handoff();
      throw Exception('network');
    });
    await pumpPage(tester);

    nextScan = newOrder;
    await tester.tap(find.byKey(const Key('scanQrButton')));
    await tester.pumpAndSettle();

    expect(find.text('この停車地点で引き渡し待ちの予約ではありません'), findsNothing);
    expect(find.text('処理に失敗しました。もう一度お試しください'), findsOneWidget);
    verifyNever(() => gateway.confirmPickup(any()));
  });

  testWidgets('mã thủ công trùng 2 đơn → hiện danh sách để chọn → giao đúng đơn được chọn', (tester) async {
    when(() => gateway.fetchStopHandoff('p2')).thenAnswer((_) async => handoff(reservations: [
          ReservationAtStop(orderId: _waitingA, status: 'allocated', createdAt: DateTime.utc(2026, 10, 2, 3, 5)),
          ReservationAtStop(orderId: _waitingB, status: 'allocated', createdAt: DateTime.utc(2026, 10, 2, 9, 40)), // = 18:40 JST
        ]));
    await pumpPage(tester);

    await tester.tap(find.byKey(const Key('manualCodeButton')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('manualCodeField')), 'beef');
    await tester.tap(find.byKey(const Key('submitManualCodeButton')));
    await tester.pumpAndSettle();

    expect(find.text('同じコードの予約が複数あります'), findsOneWidget);
    await tester.tap(find.textContaining('予約 18:40'));
    await tester.pumpAndSettle();
    verify(() => gateway.confirmPickup(_waitingB)).called(1);
  });

  testWidgets('Walk-up: bán 1 suất → walk_up_purchase; hết suất thì nút 販売を登録 bị khoá', (tester) async {
    var remaining = 1;
    when(() => gateway.fetchStopHandoff('p2')).thenAnswer((_) async => handoff(remaining: remaining));
    when(() => gateway.walkUpPurchase(batchId: 'batch-1', routeStopId: 'p2', requestId: any(named: 'requestId')))
        .thenAnswer((_) async {
      remaining = 0;
      return (price: 500, replayed: false);
    });
    await pumpPage(tester);

    await tester.tap(find.text('予約なし販売'));
    await tester.pumpAndSettle();
    expect(find.text('残り 1食'), findsOneWidget);
    // tên lô = tên điểm thu gom của nhà hàng đó (ở thẻ この場所で渡すもの và ở thẻ Walk-up)
    expect(find.text('Stop rB'), findsNWidgets(2));

    await tester.tap(find.byKey(const Key('sellWalkup_batch-1')));
    await tester.pumpAndSettle();

    verify(() => gateway.walkUpPurchase(batchId: 'batch-1', routeStopId: 'p2', requestId: any(named: 'requestId'))).called(1);
    expect(find.text('残り 0食'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byKey(const Key('sellWalkup_batch-1'))).onPressed, isNull);
  });

  // Audit D04: bán mất phản hồi → băng "chưa rõ"; bấm lại gửi CÙNG khoá → server trả lần bán cũ (replayed), không bán thêm.
  // Lần bán sau đó là việc mới → khoá mới.
  testWidgets('D04: mất mạng khi bán → băng chưa rõ; bấm lại dùng cùng khoá → 「前回の販売は登録済みでした」; lần sau khoá mới', (tester) async {
    final keys = <String>[];
    var calls = 0;
    when(() => gateway.fetchStopHandoff('p2')).thenAnswer((_) async => handoff(remaining: 3));
    when(() => gateway.walkUpPurchase(batchId: 'batch-1', routeStopId: 'p2', requestId: any(named: 'requestId')))
        .thenAnswer((inv) async {
      keys.add(inv.namedArguments[#requestId] as String);
      if (calls++ == 0) throw Exception('SocketException: connection reset');
      return (price: 500, replayed: calls == 2);
    });
    await pumpPage(tester);
    await tester.tap(find.text('予約なし販売'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('sellWalkup_batch-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('walkupUnknownBanner')), findsOneWidget);

    await tester.tap(find.byKey(const Key('sellWalkup_batch-1')));
    await tester.pumpAndSettle();
    expect(keys[1], keys[0], reason: 'gửi lại cùng 1 lần bán phải dùng cùng khoá');
    expect(find.text('前回の販売は登録済みでした（¥500）'), findsOneWidget);
    expect(find.byKey(const Key('walkupUnknownBanner')), findsNothing);

    await tester.tap(find.byKey(const Key('sellWalkup_batch-1')));
    await tester.pumpAndSettle();
    expect(keys[2], isNot(keys[0]), reason: 'bán cho khách tiếp theo là việc mới');
  });

  testWidgets('D04: server từ chối (hết suất) → câu lỗi cũ, không có băng "chưa rõ"', (tester) async {
    when(() => gateway.fetchStopHandoff('p2')).thenAnswer((_) async => handoff(remaining: 3));
    when(() => gateway.walkUpPurchase(batchId: 'batch-1', routeStopId: 'p2', requestId: any(named: 'requestId')))
        .thenThrow(const PostgrestException(message: 'E-ORDER-007: sold out at this pickup stop'));
    await pumpPage(tester);
    await tester.tap(find.text('予約なし販売'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sellWalkup_batch-1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('walkupUnknownBanner')), findsNothing);
    expect(find.text('この停車地点で予約なしで販売できる分は売り切れです'), findsOneWidget);
  });

  testWidgets('D05: màn camera lỗi có câu cách sửa + 2 nút; 「コードを手動で入力」 gọi đúng callback', (tester) async {
    var manual = 0;
    await tester.pumpWidget(testApp(Scaffold(body: CameraUnavailablePanel(onManualEntry: () => manual++))));
    expect(find.text(l10nJa.cameraUnavailableTitle), findsOneWidget);
    expect(find.byKey(const Key('cameraOpenSettings')), findsOneWidget);
    await tester.tap(find.byKey(const Key('cameraManualEntry')));
    expect(manual, 1);
  });

  // Audit D05: camera không dùng được → màn quét trả qrManualEntry → mở ngay hộp nhập mã 4 ký tự
  testWidgets('D05: chọn 「コードを手動で入力」 ở màn camera lỗi → mở hộp nhập mã', (tester) async {
    when(() => gateway.fetchStopHandoff('p2')).thenAnswer((_) async => handoff());
    await pumpPage(tester);
    nextScan = qrManualEntry;
    await tester.tap(find.byKey(const Key('scanQrButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('manualCodeField')), findsOneWidget);
    verifyNever(() => gateway.confirmPickup(any()));
  });

  testWidgets('出発: còn đơn chờ → dialog cảnh báo no-show (BR-004) → close_route_stop → quay về với message', (tester) async {
    String? result;
    when(() => gateway.fetchStopHandoff('p2')).thenAnswer((_) async => handoff());
    when(() => gateway.closeRouteStop('p2')).thenAnswer((_) async => 1);
    await pumpPage(tester, onResult: (r) => result = r);

    await tester.tap(find.byKey(const Key('departButton')));
    await tester.pumpAndSettle();
    expect(find.text('1件の予約が引き渡し待ちです。出発すると、これらの予約は「受け取りなし（失効）」として扱われ、返金されません。'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirmDepartButton')));
    await tester.pumpAndSettle();

    verify(() => gateway.closeRouteStop('p2')).called(1);
    expect(result, '出発しました（未受取1件を失効）');
  });

  // レビュー第30回: "停車終了まで n分" phải tự giảm khi màn hình để yên — không chờ dữ liệu khác thay đổi
  testWidgets('đồng hồ đếm ngược tự cập nhật mỗi phút, không gọi lại Supabase', (tester) async {
    when(() => gateway.fetchStopHandoff('p2')).thenAnswer((_) async => handoff());
    await pumpPage(tester);
    expect(find.text('停車終了まで 22分'), findsOneWidget);

    fakeNow = fakeNow.add(const Duration(minutes: 1));
    await tester.pump(const Duration(minutes: 1)); // Timer.periodic(1 phút) bắn → setState
    expect(find.text('停車終了まで 21分'), findsOneWidget);
    verify(() => gateway.fetchStopHandoff('p2')).called(1); // chỉ vẽ lại, không tải lại
  });

  testWidgets('rung phản hồi: giao xong → rung nhẹ (mediumImpact); QR không thuộc điểm này → rung mạnh (heavyImpact)', (tester) async {
    final haptics = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') haptics.add(call.arguments);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    when(() => gateway.fetchStopHandoff('p2')).thenAnswer((_) async => handoff());
    await pumpPage(tester);

    nextScan = _waitingA;
    await tester.tap(find.byKey(const Key('scanQrButton')));
    await tester.pumpAndSettle();
    expect(haptics, ['HapticFeedbackType.mediumImpact']);

    nextScan = 'not-at-this-stop';
    await tester.tap(find.byKey(const Key('scanQrButton')));
    await tester.pumpAndSettle();
    expect(haptics.last, 'HapticFeedbackType.heavyImpact');
  });

}
