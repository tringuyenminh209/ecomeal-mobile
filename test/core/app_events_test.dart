import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/core/app_events.dart';

// 0051: sự kiện đo chuyển đổi — ghi 1 lần khi mở màn, lỗi ghi không làm hỏng màn hình
void main() {
  testWidgets('LogAppEventOnce: ghi đúng 1 lần dù build lại', (tester) async {
    final calls = <String>[];
    final counter = ValueNotifier(0);
    await tester.pumpWidget(ProviderScope(
      overrides: [appEventLoggerProvider.overrideWithValue((e, id) async => calls.add('${e.name}/$id'))],
      child: MaterialApp(
        home: LogAppEventOnce(
          event: AppEvent.batchView,
          surplusBatchId: 'b-1',
          child: ValueListenableBuilder<int>(valueListenable: counter, builder: (_, v, __) => Text('$v')),
        ),
      ),
    ));
    counter.value = 1;
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(calls, ['batchView/b-1']);
  });

  testWidgets('ghi lỗi (mất mạng) → bỏ qua, màn hình vẫn hiện', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [appEventLoggerProvider.overrideWithValue((e, id) => Future.error(Exception('offline')))],
      child: const MaterialApp(home: LogAppEventOnce(event: AppEvent.checkoutView, surplusBatchId: null, child: Text('ok'))),
    ));
    await tester.pump();
    expect(find.text('ok'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chưa khởi tạo Supabase (provider mặc định lỗi) → bỏ qua', (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: LogAppEventOnce(event: AppEvent.batchView, surplusBatchId: 'b', child: Text('ok'))),
    ));
    expect(find.text('ok'), findsOneWidget);
  });
}
