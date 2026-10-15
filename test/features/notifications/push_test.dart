import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/core/push_notifications.dart';
import 'package:ecomeal_mobile/features/notifications/push_registration.dart';
import 'package:ecomeal_mobile/widgets/customer_shell.dart';
import '../../helpers/fake_push_client.dart';
import '../../helpers/test_app.dart';

class FakeTokenGateway implements PushTokenGateway {
  final registered = <String>[];
  final unregistered = <String>[];
  @override
  Future<void> register(String token, String platform) async => registered.add('$token/$platform');
  @override
  Future<void> unregister(String token) async => unregistered.add(token);
}

// 0048: SCR-M07「アプリの通知」と、CustomerShell を包む PushRegistrar
void main() {
  late FakeTokenGateway gateway;
  setUp(() => gateway = FakeTokenGateway());

  Widget statusProbe() => Consumer(
        builder: (context, ref, _) => Text('${ref.watch(pushStatusProvider).valueOrNull}'),
      );

  testWidgets('chưa cấu hình Firebase → unavailable (thẻ ẩn)', (tester) async {
    await tester.pumpWidget(ProviderScope(child: testApp(statusProbe())));
    await tester.pumpAndSettle();
    expect(find.text('PushStatus.unavailable'), findsOneWidget);
  });

  testWidgets('enablePush: hỏi quyền → cho phép → lưu token → on', (tester) async {
    final client = FakePushClient(PushPermission.notDetermined);
    late WidgetRef captured;
    await tester.pumpWidget(ProviderScope(
      overrides: [pushClientProvider.overrideWithValue(client), pushTokenGatewayProvider.overrideWithValue(gateway)],
      child: testApp(Consumer(builder: (context, ref, _) {
        captured = ref;
        return Text('${ref.watch(pushStatusProvider).valueOrNull}');
      })),
    ));
    await tester.pumpAndSettle();
    expect(find.text('PushStatus.off'), findsOneWidget);

    final result = await enablePush(captured);
    await tester.pumpAndSettle();
    expect(result, PushStatus.on);
    expect(client.requests, 1);
    expect(gateway.registered, ['device-token-1/android']);
    expect(find.text('PushStatus.on'), findsOneWidget);
  });

  testWidgets('enablePush: từ chối → denied, không lưu token', (tester) async {
    final client = FakePushClient(PushPermission.notDetermined, afterRequest: PushPermission.denied);
    late WidgetRef captured;
    await tester.pumpWidget(ProviderScope(
      overrides: [pushClientProvider.overrideWithValue(client), pushTokenGatewayProvider.overrideWithValue(gateway)],
      child: testApp(Consumer(builder: (context, ref, _) {
        captured = ref;
        return const SizedBox();
      })),
    ));
    expect(await enablePush(captured), PushStatus.denied);
    expect(gateway.registered, isEmpty);
  });

  testWidgets('PushRegistrar: đã được phép → lưu token khi mở app, lưu lại khi token đổi, thông báo lúc đang mở → SnackBar, chạm → tab 予約', (tester) async {
    final client = FakePushClient(PushPermission.granted);
    await tester.pumpWidget(ProviderScope(
      overrides: [pushClientProvider.overrideWithValue(client), pushTokenGatewayProvider.overrideWithValue(gateway)],
      child: testApp(Scaffold(
        body: PushRegistrar(
          onMessage: refreshOrdersAfterPush,
          onOpened: openOrdersFromPush,
          child: Consumer(builder: (context, ref, _) => Text('tab ${ref.watch(customerTabProvider)}')),
        ),
      )),
    ));
    await tester.pumpAndSettle();
    expect(gateway.registered, ['device-token-1/android']);

    client.refresh.add('device-token-2');
    await tester.pump();
    expect(gateway.registered.last, 'device-token-2/android');

    client.foreground.add((title: '返金しました', body: '全額を返金しました。'));
    await tester.pump(); // giao sự kiện stream
    await tester.pump(const Duration(milliseconds: 100)); // SnackBar hiện lên
    expect(find.text('返金しました\n全額を返金しました。'), findsOneWidget);

    client.opened.add(null);
    await tester.pump();
    expect(find.text('tab ${CustomerTab.orders}'), findsOneWidget);
  });

  testWidgets('PushRegistrar: chưa được phép → không lưu token', (tester) async {
    final client = FakePushClient(PushPermission.notDetermined);
    await tester.pumpWidget(ProviderScope(
      overrides: [pushClientProvider.overrideWithValue(client), pushTokenGatewayProvider.overrideWithValue(gateway)],
      child: testApp(const PushRegistrar(onMessage: refreshOrdersAfterPush, onOpened: openOrdersFromPush, child: SizedBox())),
    ));
    await tester.pumpAndSettle();
    expect(gateway.registered, isEmpty);
  });

  testWidgets('unregisterPush: xoá token của máy này (gọi trước khi đăng xuất)', (tester) async {
    final client = FakePushClient(PushPermission.granted);
    late WidgetRef captured;
    await tester.pumpWidget(ProviderScope(
      overrides: [pushClientProvider.overrideWithValue(client), pushTokenGatewayProvider.overrideWithValue(gateway)],
      child: testApp(Consumer(builder: (context, ref, _) {
        captured = ref;
        return const SizedBox();
      })),
    ));
    await unregisterPush(captured);
    expect(gateway.unregistered, ['device-token-1']);
  });
}
