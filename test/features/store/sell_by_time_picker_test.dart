import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/features/store/sell_by_time_picker.dart';
import '../../helpers/test_app.dart';

// SCR-S02 「販売の終了時刻」(Figma 871:4434)
void main() {
  late List<SellByTime?> results;

  Future<void> open(WidgetTester tester, {Size size = const Size(390, 844), bool tomorrow = true}) async {
    results = [];
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      testApp(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async => results.add(
                  await showSellByTimePicker(context, initial: (hour: 20, minute: 0), tomorrow: tomorrow),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('iPhone: sheet từ dưới; giờ ban đầu = giờ trên form, preset trùng giờ được tô', (tester) async {
    await open(tester);
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
    expect(find.text(l10nJa.storeTimeTitle), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.descendant(of: find.byKey(const Key('sellByHour')), matching: find.byType(TextField)))
          .controller!
          .text,
      '20',
    );
    final preset = tester.widget<Material>(
      find.ancestor(of: find.byKey(const Key('sellByPreset_20:00')), matching: find.byType(Material)).first,
    );
    expect(preset.color, const Color(0xFF2E7D32));
  });

  testWidgets('iPad: hộp ở giữa màn hình', (tester) async {
    await open(tester, size: const Size(1194, 834));
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('gõ số: đủ 2 số giờ tự sang ô phút → この時刻にする trả giờ mới', (tester) async {
    await open(tester);
    await tester.enterText(
      find.descendant(of: find.byKey(const Key('sellByHour')), matching: find.byType(TextField)),
      '21',
    );
    await tester.pump();
    final minute = find.descendant(of: find.byKey(const Key('sellByMinute')), matching: find.byType(TextField));
    expect(tester.widget<TextField>(minute).focusNode!.hasFocus, isTrue);
    await tester.enterText(minute, '45');
    await tester.tap(find.byKey(const Key('sellByConfirm')));
    await tester.pumpAndSettle();
    expect(results, [(hour: 21, minute: 45)]);
  });

  testWidgets('chọn giờ hay dùng → trả đúng giờ đó', (tester) async {
    await open(tester);
    await tester.tap(find.byKey(const Key('sellByPreset_21:30')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('sellByConfirm')));
    await tester.pumpAndSettle();
    expect(results, [(hour: 21, minute: 30)]);
  });

  testWidgets('giờ ngoài 00–23 / phút ngoài 00–59 → báo lỗi, không đóng', (tester) async {
    await open(tester);
    await tester.enterText(
      find.descendant(of: find.byKey(const Key('sellByMinute')), matching: find.byType(TextField)),
      '60',
    );
    await tester.tap(find.byKey(const Key('sellByConfirm')));
    await tester.pump();
    expect(find.text(l10nJa.storeTimeInvalid), findsOneWidget);
    expect(results, isEmpty);
  });

  testWidgets('hôm nay mà giờ đã qua → báo lỗi, không đóng', (tester) async {
    await open(tester, tomorrow: false);
    final now = DateTime.now().toUtc().add(const Duration(hours: 9)); // JST
    final past = now.subtract(const Duration(minutes: 1));
    // Ngay sau 00:00 JST thì không có "đã qua trong hôm nay" — bỏ qua phần kiểm tra
    if (past.day != now.day) return;
    await tester.enterText(
      find.descendant(of: find.byKey(const Key('sellByHour')), matching: find.byType(TextField)),
      past.hour.toString().padLeft(2, '0'),
    );
    await tester.enterText(
      find.descendant(of: find.byKey(const Key('sellByMinute')), matching: find.byType(TextField)),
      past.minute.toString().padLeft(2, '0'),
    );
    await tester.tap(find.byKey(const Key('sellByConfirm')));
    await tester.pump();
    expect(find.text(l10nJa.storeErrSellByPast), findsOneWidget);
    expect(results, isEmpty);
  });

  testWidgets('キャンセル hoặc chạm ra ngoài → null (giờ trên form giữ nguyên)', (tester) async {
    await open(tester);
    await tester.tap(find.byKey(const Key('sellByPreset_21:00')));
    await tester.tap(find.byKey(const Key('sellByCancel')));
    await tester.pumpAndSettle();
    expect(results, [null]);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(195, 40));
    await tester.pumpAndSettle();
    expect(results, [null, null]);
  });
}
