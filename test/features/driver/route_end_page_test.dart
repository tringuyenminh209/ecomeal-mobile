import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:ecomeal_mobile/features/driver/driver_gateway.dart';
import 'package:ecomeal_mobile/features/driver/handoff_gateway.dart';
import 'package:ecomeal_mobile/features/driver/route_end_page.dart';
import '../../helpers/test_app.dart';
import 'driver_test_data.dart';

class MockDriverGateway extends Mock implements DriverGateway {}

class MockHandoffGateway extends Mock implements HandoffGateway {}

// Cùng tuyến mẫu nhưng tài xế đã 出発 khỏi MỌI điểm bán (p2, p3) — điều kiện để được ghi tặng.
final endedRoute = TonightRoute(
  truck: routeFixture.truck,
  routeId: routeFixture.routeId,
  stops: [
    for (final s in routeFixture.stops)
      s.type == 'public' && s.departedAt == null
          ? stopFixture(s.routeStopId, type: s.type, sequence: s.sequence, departed: true, pickedUp: s.pickedUpCount)
          : s,
  ],
);

void main() {
  late MockDriverGateway driverGateway;
  late MockHandoffGateway handoffGateway;

  setUp(() {
    driverGateway = MockDriverGateway();
    handoffGateway = MockHandoffGateway();
    when(() => driverGateway.fetchTonightRoute()).thenAnswer((_) async => endedRoute);
    when(() => handoffGateway.fetchConfirmedBatches('route-1'))
        .thenAnswer((_) async => const [DonationBatch(id: 'batch-1', restaurantId: 'rest-B', confirmedQty: 28, remainingQty: 6)]);
  });

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [driverGatewayProvider.overrideWithValue(driverGateway), handoffGatewayProvider.overrideWithValue(handoffGateway)],
      child: testApp(const RouteEndPage()),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> fillDonation(WidgetTester tester, String qty) async {
    await tester.tap(find.byKey(const Key('donationBatchField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stop rB（確定 28食・残り 6食）').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('donationQtyField')), qty);
    await tester.enterText(find.byKey(const Key('donationNoteField')), 'しぶやフードサポート');
    await tester.ensureVisible(find.byKey(const Key('handedOverCheckbox')));
    await tester.tap(find.byKey(const Key('handedOverCheckbox')));
    await tester.pump();
  }

  // レビュー第30回: tặng giữa tuyến rồi quay lại bán → sold + donated vượt confirmed_qty. Form khoá cho tới khi
  // mọi điểm bán đã 出発 (server cũng tự chặn bằng E-INV-004).
  testWidgets('còn điểm bán chưa 出発 → cảnh báo + form tặng bị khoá', (tester) async {
    when(() => driverGateway.fetchTonightRoute()).thenAnswer((_) async => routeFixture);
    await pumpPage(tester);

    expect(find.text('18食'), findsOneWidget); // picked_up chỉ có ở p1 trong dữ liệu mẫu
    expect(find.text('1 / 3'), findsOneWidget); // 3 điểm bán p1/p2/p3, mới rời p1 — điểm thu gom không tính
    expect(find.byKey(const Key('openStopsWarning')), findsOneWidget);
    expect(find.byKey(const Key('donationLockedNotice')), findsOneWidget);
    expect(tester.widget<TextField>(find.byKey(const Key('donationQtyField'))).enabled, isFalse);
    expect(tester.widget<FilledButton>(find.byKey(const Key('recordDonationButton'))).onPressed, isNull);
  });

  testWidgets('đã rời mọi điểm bán → ghi tặng: chọn lô + số lượng + nơi nhận + xác nhận → record_donation', (tester) async {
    when(() => handoffGateway.recordDonation(batchId: 'batch-1', quantity: 6, note: 'しぶやフードサポート', requestId: any(named: 'requestId')))
        .thenAnswer((_) async => (remaining: 0, replayed: false));
    await pumpPage(tester);
    expect(find.text('3 / 3'), findsOneWidget);
    expect(find.byKey(const Key('openStopsWarning')), findsNothing);
    expect(tester.widget<FilledButton>(find.byKey(const Key('recordDonationButton'))).onPressed, isNull);

    await fillDonation(tester, '6');
    await tester.tap(find.byKey(const Key('recordDonationButton')));
    await tester.pumpAndSettle();

    verify(() => handoffGateway.recordDonation(batchId: 'batch-1', quantity: 6, note: 'しぶやフードサポート', requestId: any(named: 'requestId')))
        .called(1);
    expect(find.text('寄付を記録しました（この料理の残り 0食）'), findsOneWidget);
  });

  // Audit D03: đang lưu → khoá lô / số lượng / nơi nhận (trước đây vẫn sửa được, lưu xong lại xoá số vừa nhập)
  testWidgets('D03: đang ghi tặng → khoá các ô cho tới khi server trả lời', (tester) async {
    final pending = Completer<DonationResult>();
    when(() => handoffGateway.recordDonation(
          batchId: any(named: 'batchId'),
          quantity: any(named: 'quantity'),
          note: any(named: 'note'),
          requestId: any(named: 'requestId'),
        )).thenAnswer((_) => pending.future);
    await pumpPage(tester);
    await fillDonation(tester, '6');
    await tester.tap(find.byKey(const Key('recordDonationButton')));
    await tester.pump();

    expect(tester.widget<TextField>(find.byKey(const Key('donationQtyField'))).enabled, isFalse);
    expect(tester.widget<TextField>(find.byKey(const Key('donationNoteField'))).enabled, isFalse);

    pending.complete((remaining: 0, replayed: false));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byKey(const Key('donationQtyField'))).enabled, isTrue);
  });

  testWidgets('server từ chối E-INV-001 (số còn lại vừa đổi) → câu lỗi API-016, không có băng "chưa rõ"', (tester) async {
    when(() => handoffGateway.recordDonation(
          batchId: any(named: 'batchId'),
          quantity: any(named: 'quantity'),
          note: any(named: 'note'),
          requestId: any(named: 'requestId'),
        )).thenThrow(const PostgrestException(message: 'E-INV-001: quantity exceeds remaining stock'));
    await pumpPage(tester);
    await fillDonation(tester, '5');
    await tester.tap(find.byKey(const Key('recordDonationButton')));
    await tester.pumpAndSettle();

    expect(find.text('寄付数量が残り在庫を超えています'), findsOneWidget);
    expect(find.byKey(const Key('donationUnknownBanner')), findsNothing);
  });

  // Audit D06: thấy số còn lại trước khi nhập; nhập quá → báo ngay, nút khoá (không phải gửi rồi mới biết)
  testWidgets('D06: nhãn lô có số còn lại; nhập 7 khi còn 6 → 「残りは 6食です…」, không gửi được', (tester) async {
    await pumpPage(tester);
    await fillDonation(tester, '7');

    expect(find.text('Stop rB（確定 28食・残り 6食）'), findsOneWidget);
    expect(find.text('残りは 6食です。6食以下で入力してください'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byKey(const Key('recordDonationButton'))).onPressed, isNull);
  });

  testWidgets('D06: lô đã hết → 「（残りなし）」 và không chọn được', (tester) async {
    when(() => handoffGateway.fetchConfirmedBatches('route-1'))
        .thenAnswer((_) async => const [DonationBatch(id: 'batch-1', restaurantId: 'rest-B', confirmedQty: 28, remainingQty: 0)]);
    await pumpPage(tester);
    await tester.tap(find.byKey(const Key('donationBatchField')));
    await tester.pumpAndSettle();

    final item = tester.widget<DropdownMenuItem<String>>(find.byType(DropdownMenuItem<String>).last);
    expect(item.enabled, isFalse);
    expect(find.text('Stop rB（残りなし）'), findsWidgets);
  });

  // Audit D04: mất phản hồi → băng "chưa rõ", giữ nhập liệu; gửi lại dùng CÙNG khoá → server báo đã ghi (replayed)
  testWidgets('D04: mất mạng → băng chưa rõ; gửi lại cùng khoá → 「この寄付は記録済みでした」', (tester) async {
    final keys = <String>[];
    var calls = 0;
    when(() => handoffGateway.recordDonation(
          batchId: any(named: 'batchId'),
          quantity: any(named: 'quantity'),
          note: any(named: 'note'),
          requestId: any(named: 'requestId'),
        )).thenAnswer((inv) async {
      keys.add(inv.namedArguments[#requestId] as String);
      if (calls++ == 0) throw Exception('SocketException: connection reset');
      return (remaining: 0, replayed: true);
    });
    await pumpPage(tester);
    await fillDonation(tester, '6');
    await tester.tap(find.byKey(const Key('recordDonationButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('donationUnknownBanner')), findsOneWidget);
    expect(tester.widget<TextField>(find.byKey(const Key('donationQtyField'))).controller!.text, '6');

    await tester.tap(find.byKey(const Key('recordDonationButton')));
    await tester.pumpAndSettle();

    expect(keys, hasLength(2));
    expect(keys[1], keys[0], reason: 'gửi lại phải dùng cùng khoá để server không ghi thêm');
    expect(find.text('この寄付は記録済みでした（この料理の残り 0食）'), findsOneWidget);
    expect(find.byKey(const Key('donationUnknownBanner')), findsNothing);
  });
}
