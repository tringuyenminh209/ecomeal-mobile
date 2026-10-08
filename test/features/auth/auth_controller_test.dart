import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show Session, User, AuthState, AuthChangeEvent;
import 'package:ecomeal_mobile/features/auth/auth_controller.dart';
import 'package:ecomeal_mobile/features/auth/auth_gateway.dart';

class MockAuthGateway extends Mock implements AuthGateway {}

class MockSession extends Mock implements Session {}

class MockUser extends Mock implements User {}

void main() {
  late MockAuthGateway gateway;
  late MockSession session;
  late MockUser user;

  setUp(() {
    gateway = MockAuthGateway();
    session = MockSession();
    user = MockUser();
    when(() => session.user).thenReturn(user);
    when(() => user.id).thenReturn('u-1');
    // Không cần phát sự kiện thật qua stream cho các test này — chỉ cần initialize() không treo.
    when(
      () => gateway.onAuthStateChange,
    ).thenAnswer((_) => const Stream<AuthState>.empty());
  });

  test('đồng bộ ngôn ngữ lỗi → vẫn vào đúng role, không kẹt ở role=null', () async {
    when(() => gateway.currentSession).thenReturn(session);
    when(
      () => gateway.fetchProfile('u-1'),
    ).thenAnswer((_) async => (role: 'driver', languageCode: 'en'));
    final controller = AuthController(
      gateway,
      onLanguageChanged: (_) async => throw Exception('prefs write failed'),
    );
    addTearDown(controller.dispose);
    await controller.initialize();
    expect(controller.state.role, AppRole.driver);
    expect(controller.state.isInitializing, false);
  });

  test('áp dụng ngôn ngữ server sau khi đọc profile', () async {
    when(() => gateway.currentSession).thenReturn(session);
    when(
      () => gateway.fetchProfile('u-1'),
    ).thenAnswer((_) async => (role: 'customer', languageCode: 'en'));
    String? language;
    final controller = AuthController(
      gateway,
      onLanguageChanged: (value) async {
        language = value;
      },
    );
    addTearDown(controller.dispose);
    await controller.initialize();
    expect(language, 'en');
    expect(controller.state.role, AppRole.customer);
  });

  test(
    'initialize(): chưa có session → role=null, isInitializing=false',
    () async {
      when(() => gateway.currentSession).thenReturn(null);
      final controller = AuthController(gateway);

      await controller.initialize();

      expect(controller.state.session, isNull);
      expect(controller.state.role, isNull);
      expect(controller.state.isInitializing, isFalse);
    },
  );

  test(
    'initialize(): có session → gọi fetchRole() và map đúng chuỗi DB sang AppRole',
    () async {
      when(() => gateway.currentSession).thenReturn(session);
      when(
        () => gateway.fetchProfile('u-1'),
      ).thenAnswer((_) async => (role: 'restaurant_owner', languageCode: 'en'));
      final controller = AuthController(gateway);

      await controller.initialize();

      expect(controller.state.role, AppRole.restaurantOwner);
      expect(controller.state.isInitializing, isFalse);
    },
  );

  test(
    'initialize(): fetchRole() lỗi (vd mất mạng) → vẫn kết thúc isInitializing, KHÔNG treo mãi',
    () async {
      when(() => gateway.currentSession).thenReturn(session);
      when(
        () => gateway.fetchProfile('u-1'),
      ).thenThrow(Exception('network error'));
      final controller = AuthController(gateway);

      await controller.initialize();

      expect(controller.state.isInitializing, isFalse);
      expect(controller.state.role, isNull);
    },
  );

  test(
    'signIn() gọi đúng gateway.signInWithPassword với email/password',
    () async {
      when(() => gateway.currentSession).thenReturn(null);
      when(
        () => gateway.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {});
      final controller = AuthController(gateway);
      await controller.initialize();

      await controller.signIn(email: 'a@test.local', password: 'password123');

      verify(
        () => gateway.signInWithPassword(
          email: 'a@test.local',
          password: 'password123',
        ),
      ).called(1);
    },
  );

  test(
    'signUp() gửi kèm preferred_language trong data (xem box-warn đầu chương)',
    () async {
      when(() => gateway.currentSession).thenReturn(null);
      when(
        () => gateway.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async {});
      final controller = AuthController(gateway);
      await controller.initialize();

      await controller.signUp(
        email: 'b@test.local',
        password: 'password123',
        name: '山田太郎',
        languageCode: 'en',
      );

      verify(
        () => gateway.signUp(
          email: 'b@test.local',
          password: 'password123',
          data: {'name': '山田太郎', 'preferred_language': 'en'},
        ),
      ).called(1);
    },
  );

  // ── UC-28 Đặt lại mật khẩu ───────────────────────────────────────────────────────
  test(
    'verifyRecoveryCode: cờ isRecoveringPassword bật trước khi gọi, giữ qua sự kiện signedIn, tắt sau updatePassword',
    () async {
      final authEvents = StreamController<AuthState>();
      when(() => gateway.onAuthStateChange).thenAnswer((_) => authEvents.stream);
      when(() => gateway.currentSession).thenReturn(null);
      when(() => gateway.fetchProfile('u-1')).thenAnswer((_) async => (role: 'customer', languageCode: 'ja'));
      final controller = AuthController(gateway);
      addTearDown(controller.dispose);
      await controller.initialize();
      bool? flagDuringCall;
      when(
        () => gateway.verifyRecoveryCode(email: 'a@test.local', code: '123456'),
      ).thenAnswer((_) async {
        flagDuringCall = controller.state.isRecoveringPassword;
        authEvents.add(AuthState(AuthChangeEvent.signedIn, session));
        await pumpEventQueue();
      });
      when(() => gateway.updatePassword('newpass123')).thenAnswer((_) async {});

      await controller.verifyRecoveryCode(email: 'a@test.local', code: '123456');

      expect(flagDuringCall, isTrue);
      expect(controller.state.session, same(session)); // _syncSession không làm mất cờ
      expect(controller.state.role, AppRole.customer);
      expect(controller.state.isRecoveringPassword, isTrue);

      await controller.updatePassword('newpass123');
      expect(controller.state.isRecoveringPassword, isFalse);
      await authEvents.close();
    },
  );

  test('verifyRecoveryCode lỗi → tắt cờ và ném lại lỗi cho màn hình', () async {
    when(() => gateway.currentSession).thenReturn(null);
    when(
      () => gateway.verifyRecoveryCode(email: any(named: 'email'), code: any(named: 'code')),
    ).thenThrow(Exception('otp_expired'));
    final controller = AuthController(gateway);
    addTearDown(controller.dispose);
    await controller.initialize();

    await expectLater(controller.verifyRecoveryCode(email: 'a@test.local', code: '000000'), throwsException);
    expect(controller.state.isRecoveringPassword, isFalse);
  });

  test('updatePassword lỗi → GIỮ cờ (mã đã dùng, chỉ cần nhập lại mật khẩu)', () async {
    when(() => gateway.currentSession).thenReturn(null);
    when(() => gateway.verifyRecoveryCode(email: any(named: 'email'), code: any(named: 'code'))).thenAnswer((_) async {});
    when(() => gateway.updatePassword(any())).thenThrow(Exception('same_password'));
    final controller = AuthController(gateway);
    addTearDown(controller.dispose);
    await controller.initialize();
    await controller.verifyRecoveryCode(email: 'a@test.local', code: '123456');

    await expectLater(controller.updatePassword('oldpass123'), throwsException);
    expect(controller.state.isRecoveringPassword, isTrue);
  });

  test('cancelPasswordRecovery có session → signOut và tắt cờ; chưa có session → không signOut', () async {
    when(() => gateway.currentSession).thenReturn(null);
    when(() => gateway.signOut()).thenAnswer((_) async {});
    when(() => gateway.verifyRecoveryCode(email: any(named: 'email'), code: any(named: 'code'))).thenAnswer((_) async {});
    final controller = AuthController(gateway);
    addTearDown(controller.dispose);
    await controller.initialize();

    await controller.verifyRecoveryCode(email: 'a@test.local', code: '123456');
    await controller.cancelPasswordRecovery(); // chưa có sự kiện signedIn → session null
    verifyNever(() => gateway.signOut());
    expect(controller.state.isRecoveringPassword, isFalse);

    when(() => gateway.fetchProfile('u-1')).thenAnswer((_) async => (role: 'customer', languageCode: 'ja'));
    when(() => gateway.currentSession).thenReturn(session);
    final withSession = AuthController(gateway);
    addTearDown(withSession.dispose);
    await withSession.initialize();
    await withSession.verifyRecoveryCode(email: 'a@test.local', code: '123456');
    await withSession.cancelPasswordRecovery();
    verify(() => gateway.signOut()).called(1);
    expect(withSession.state.isRecoveringPassword, isFalse);
  });

  // ── Race condition (box-warn bước 4) ─────────────────────────────────────────────
  // Completer giữ fetchRole() "treo" để test tự quyết định thứ tự trả về, StreamController
  // phát sự kiện auth đúng lúc mong muốn — tái hiện chính xác 2 tình huống review đã chỉ ra.
  test(
    'fetchRole() của session cũ trả về SAU khi signOut → KHÔNG ghi đè lại session cũ',
    () async {
      final authEvents = StreamController<AuthState>();
      final roleOfA = Completer<AuthProfile>();
      when(
        () => gateway.onAuthStateChange,
      ).thenAnswer((_) => authEvents.stream);
      when(() => gateway.currentSession).thenReturn(session);
      when(() => gateway.fetchProfile('u-1')).thenAnswer((_) => roleOfA.future);
      final controller = AuthController(gateway);

      final init = controller.initialize(); // đang chờ fetchRole của A
      authEvents.add(AuthState(AuthChangeEvent.signedOut, null));
      await pumpEventQueue();
      expect(controller.state.session, isNull);

      roleOfA.complete((role: 'customer', languageCode: 'en')); // A trả về muộn
      await init;

      expect(controller.state.session, isNull);
      expect(controller.state.role, isNull);
      await authEvents.close();
    },
  );

  test(
    'session A trả về SAU session B → state giữ B (lượt mới nhất thắng)',
    () async {
      final authEvents = StreamController<AuthState>();
      final roleOfA = Completer<AuthProfile>();
      final sessionB = MockSession();
      final userB = MockUser();
      when(() => sessionB.user).thenReturn(userB);
      when(() => userB.id).thenReturn('u-2');
      when(
        () => gateway.onAuthStateChange,
      ).thenAnswer((_) => authEvents.stream);
      when(() => gateway.currentSession).thenReturn(session);
      when(() => gateway.fetchProfile('u-1')).thenAnswer((_) => roleOfA.future);
      when(
        () => gateway.fetchProfile('u-2'),
      ).thenAnswer((_) async => (role: 'admin', languageCode: 'ja'));
      final controller = AuthController(gateway);

      final init = controller.initialize();
      authEvents.add(AuthState(AuthChangeEvent.signedIn, sessionB));
      await pumpEventQueue();
      expect(controller.state.role, AppRole.admin);

      roleOfA.complete((role: 'customer', languageCode: 'en'));
      await init;

      expect(controller.state.session, same(sessionB));
      expect(controller.state.role, AppRole.admin);
      await authEvents.close();
    },
  );
}
