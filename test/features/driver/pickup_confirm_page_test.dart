import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ecomeal_mobile/features/driver/driver_gateway.dart';
import 'package:ecomeal_mobile/features/driver/pickup_confirm_page.dart';
import '../../helpers/test_app.dart';
import 'driver_test_data.dart';

class MockDriverGateway extends Mock implements DriverGateway {}

void main() {
  late MockDriverGateway gateway;
  final batch = RouteBatch(id: 'batch-1', restaurantId: 'rest-B', estimatedQty: 30, confirmedQty: null, sellByAt: DateTime.utc(2026, 10, 2, 9, 30));

  setUp(() => gateway = MockDriverGateway());

  void stubConfirm() {
    when(() => gateway.confirmWithTemperature(
          batchId: any(named: 'batchId'),
          confirmedQty: any(named: 'confirmedQty'),
          routeStopIds: any(named: 'routeStopIds'),
          celsius: any(named: 'celsius'),
        )).thenAnswer((_) async => const ConfirmResult(allocatedOrderCount: 12, refundedOrderCount: 3));
  }

  // Mở D02 bằng push từ 1 màn có Scaffold (giống D07 thật) để nhận lại kết quả khi pop.
  Future<void> pumpPage(WidgetTester tester, {void Function(PickupOutcome?)? onResult, Locale locale = const Locale('ja')}) async {
    tester.view.physicalSize = const Size(1080, 2400); // màn dọc như điện thoại — D02 dài
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [driverGatewayProvider.overrideWithValue(gateway)],
        child: testApp(
          Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  final r = await Navigator.of(context).push<PickupOutcome>(MaterialPageRoute(
                    builder: (_) => PickupConfirmPage(route: routeFixture, collectionStop: routeFixture.stops[2], batch: batch),
                  ));
                  onResult?.call(r);
                },
                child: const Text('open'),
              ),
            ),
          ),
          locale: locale,
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('bỏ chọn 1 điểm → 1 RPC nhận đúng số lượng + điểm còn lại theo thứ tự tuyến + nhiệt độ', (tester) async {
    PickupOutcome? result;
    stubConfirm();
    await pumpPage(tester, onResult: (r) => result = r);

    await tester.enterText(find.byKey(const Key('confirmedQtyField')), '28');
    await tester.enterText(find.byKey(const Key('temperatureField')), '5.2');
    await tester.tap(find.byKey(const Key('distStop_p3')));
    await tester.pump();
    expect(find.text('選択した停車地（1箇所）に分配されます。'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirmPickupButton')));
    await tester.pumpAndSettle();

    verify(() => gateway.confirmWithTemperature(batchId: 'batch-1', confirmedQty: 28, routeStopIds: ['p2'], celsius: 5.2)).called(1);
    expect((result?.batchId, result?.confirmedQty, result?.celsius, result?.result.allocatedOrderCount), ('batch-1', 28, 5.2, 12));
  });

  testWidgets('chưa nhập nhiệt độ → nút xác nhận disabled', (tester) async {
    await pumpPage(tester);
    final button = tester.widget<FilledButton>(find.byKey(const Key('confirmPickupButton')));
    expect(button.onPressed, isNull);
  });

  testWidgets('bỏ chọn hết điểm phân phối → nút xác nhận disabled (06 §SCR-D02: 1つ以上)', (tester) async {
    await pumpPage(tester);
    await tester.enterText(find.byKey(const Key('temperatureField')), '5.2');
    await tester.tap(find.byKey(const Key('distStop_p2')));
    await tester.tap(find.byKey(const Key('distStop_p3')));
    await tester.pump();

    final button = tester.widget<FilledButton>(find.byKey(const Key('confirmPickupButton')));
    expect(button.onPressed, isNull);
  });

  testWidgets('RPC trả E-ORDER-009 → hiện câu lỗi API-006', (tester) async {
    when(() => gateway.confirmWithTemperature(
          batchId: any(named: 'batchId'),
          confirmedQty: any(named: 'confirmedQty'),
          routeStopIds: any(named: 'routeStopIds'),
          celsius: any(named: 'celsius'),
        )).thenThrow(Exception('E-ORDER-009: batch is already confirmed and cannot be reconfirmed'));
    await pumpPage(tester);
    await tester.enterText(find.byKey(const Key('temperatureField')), '4.0');
    await tester.pump();
    await tester.tap(find.byKey(const Key('confirmPickupButton')));
    await tester.pumpAndSettle();

    expect(find.text('この料理の数量はすでに確定しています'), findsOneWidget);
  });

  // レビュー第30回: lỗi mạng → server đã rollback cả 2 việc, nên lần bấm sau gửi lại ĐẦY ĐỦ (số lượng + nhiệt độ).
  // Không còn trạng thái "đã chốt nhưng thiếu nhiệt độ" để phải nhớ trong RAM.
  testWidgets('lỗi mạng → vẫn ở D02, giữ nguyên dữ liệu đã nhập; bấm lại gửi lại cùng 1 RPC', (tester) async {
    var calls = 0;
    when(() => gateway.confirmWithTemperature(
          batchId: any(named: 'batchId'),
          confirmedQty: any(named: 'confirmedQty'),
          routeStopIds: any(named: 'routeStopIds'),
          celsius: any(named: 'celsius'),
        )).thenAnswer((_) async {
      calls++;
      if (calls == 1) throw Exception('network');
      return const ConfirmResult(allocatedOrderCount: 0, refundedOrderCount: 0);
    });
    await pumpPage(tester);
    await tester.enterText(find.byKey(const Key('temperatureField')), '6.5');
    await tester.pump();

    await tester.tap(find.byKey(const Key('confirmPickupButton')));
    await tester.pumpAndSettle();
    expect(find.text('数量を確定できませんでした。もう一度お試しください'), findsOneWidget);
    expect(find.text('30食の受け取りを確定'), findsOneWidget); // nút giữ nguyên, không đổi sang "chỉ gửi nhiệt độ"

    await tester.tap(find.byKey(const Key('confirmPickupButton')));
    await tester.pumpAndSettle();

    verify(() => gateway.confirmWithTemperature(batchId: 'batch-1', confirmedQty: 30, routeStopIds: ['p2', 'p3'], celsius: 6.5)).called(2);
  });

  // Audit D03: đang gửi → khoá ô nhập + điểm; màn kết quả dùng đúng số đã gửi (không đọc lại ô sau khi chờ server)
  testWidgets('D03: đang gửi → khoá ô; ô đổi trong lúc chờ thì kết quả vẫn là số đã gửi', (tester) async {
    final pending = Completer<ConfirmResult>();
    when(() => gateway.confirmWithTemperature(
          batchId: any(named: 'batchId'),
          confirmedQty: any(named: 'confirmedQty'),
          routeStopIds: any(named: 'routeStopIds'),
          celsius: any(named: 'celsius'),
        )).thenAnswer((_) => pending.future);
    PickupOutcome? outcome;
    await pumpPage(tester, onResult: (o) => outcome = o);
    await tester.enterText(find.byKey(const Key('temperatureField')), '6.5');
    await tester.pump();

    await tester.tap(find.byKey(const Key('confirmPickupButton')));
    await tester.pump();
    expect(tester.widget<TextField>(find.byKey(const Key('confirmedQtyField'))).enabled, isFalse);
    expect(tester.widget<TextField>(find.byKey(const Key('temperatureField'))).enabled, isFalse);

    // Ô bị đổi trong lúc chờ (vd bản cũ còn cho sửa) → kết quả không được lấy số mới
    tester.widget<TextField>(find.byKey(const Key('confirmedQtyField'))).controller!.text = '20';
    tester.widget<TextField>(find.byKey(const Key('temperatureField'))).controller!.text = '';
    pending.complete(const ConfirmResult(allocatedOrderCount: 0, refundedOrderCount: 0));
    await tester.pumpAndSettle();

    expect(outcome?.confirmedQty, 30);
    expect(outcome?.celsius, 6.5);
  });

  // 0042: 10℃超 → nút đổi thành 「回収しない」, hỏi lại trước khi gửi; huỷ thì không gọi RPC
  testWidgets('10℃超 → 確認ダイアログ、キャンセルなら RPC を呼ばない', (tester) async {
    stubConfirm();
    await pumpPage(tester);
    await tester.enterText(find.byKey(const Key('temperatureField')), '12.5');
    await tester.pump();
    expect(find.text('基準（10℃以下）を超えています。この料理は回収・販売できません。'), findsOneWidget);
    expect(find.text('回収しない（温度基準外）'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirmPickupButton')));
    await tester.pumpAndSettle();
    expect(find.text('この料理を回収しませんか？'), findsOneWidget);
    expect(find.textContaining('中心温度が12.5℃で'), findsOneWidget);
    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();

    verifyNever(() => gateway.confirmWithTemperature(
          batchId: any(named: 'batchId'),
          confirmedQty: any(named: 'confirmedQty'),
          routeStopIds: any(named: 'routeStopIds'),
          celsius: any(named: 'celsius'),
        ));
  });

  testWidgets('10℃超 → 「回収しない」で送信、サーバーが回収しなかった結果を伝える', (tester) async {
    PickupOutcome? result;
    when(() => gateway.confirmWithTemperature(
          batchId: any(named: 'batchId'),
          confirmedQty: any(named: 'confirmedQty'),
          routeStopIds: any(named: 'routeStopIds'),
          celsius: any(named: 'celsius'),
        )).thenAnswer((_) async => const ConfirmResult(allocatedOrderCount: 0, refundedOrderCount: 4, rejectedForTemperature: true));
    await pumpPage(tester, onResult: (r) => result = r);
    await tester.enterText(find.byKey(const Key('temperatureField')), '12.5');
    await tester.pump();
    await tester.tap(find.byKey(const Key('confirmPickupButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('rejectPickupConfirm')));
    await tester.pumpAndSettle();

    verify(() => gateway.confirmWithTemperature(batchId: 'batch-1', confirmedQty: 30, routeStopIds: ['p2', 'p3'], celsius: 12.5)).called(1);
    expect((result?.result.rejectedForTemperature, result?.result.refundedOrderCount), (true, 4));
  });

  testWidgets('10.0℃ ちょうどは基準内 → 通常の確定ボタン', (tester) async {
    await pumpPage(tester);
    await tester.enterText(find.byKey(const Key('temperatureField')), '10.0');
    await tester.pump();
    expect(find.text('30食の受け取りを確定'), findsOneWidget);
    expect(find.text('回収しない（温度基準外）'), findsNothing);
  });

  // REQ-015: màn tài xế ở tiếng Anh
  testWidgets('locale en → nhãn, nút, cảnh báo nhiệt độ bằng tiếng Anh', (tester) async {
    await pumpPage(tester, locale: const Locale('en'));
    await tester.enterText(find.byKey(const Key('temperatureField')), '12.5');
    await tester.pump();

    expect(find.text('Confirm pickup'), findsOneWidget);
    expect(find.text("Don't collect (over temperature limit)"), findsOneWidget);
    expect(find.text("Above the limit (10℃ or below). This food can't be collected or sold."), findsOneWidget);
    expect(find.text('集荷を確認'), findsNothing);
  });
}
