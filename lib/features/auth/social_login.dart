import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../core/line_login_bridge.dart';
import '../../l10n/l10n.dart';
import '../../widgets/error_banner.dart';
import 'auth_controller.dart';
import 'auth_gateway.dart';
import 'locale_controller.dart';

// UC-45「LINEでログイン」「Appleでサインイン」(0057, ADR-013, Figma section「M02 ログイン」211:605 —
// 483:1395 thường / 483:1462 lỗi). Chỉ ở app khách (SCR-M02). Lần đầu → server tạo tài khoản khách; điều khoản thì
// RoleGate đưa sang SCR-M10 (users.terms_version còn trống) như người dùng cũ khi điều khoản đổi.

// LINE: cần channel (LINE_CHANNEL_ID trong env.json, app.dart gọi LineSDK.setup). Apple: chỉ iPhone, và chỉ khi đã cấu hình
// provider Apple ở Supabase + Apple Developer (APPLE_SIGN_IN_ENABLED=true) — App Store bắt buộc có Apple khi có LINE (4.8).
final lineLoginAvailableProvider = Provider<bool>((ref) => !kIsWeb && const String.fromEnvironment('LINE_CHANNEL_ID').isNotEmpty);
final appleLoginAvailableProvider = Provider<bool>(
  (ref) => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS && const bool.fromEnvironment('APPLE_SIGN_IN_ENABLED'),
);

typedef AppleCredential = ({String idToken, String rawNonce, String? fullName});

abstract class AppleSignInBridge {
  // null = người dùng đã đóng màn của Apple
  Future<AppleCredential?> obtainCredential();
}

class NativeAppleSignInBridge implements AppleSignInBridge {
  @override
  Future<AppleCredential?> obtainCredential() async {
    // Nonce: Apple ký SHA-256 của nonce vào ID token; Supabase so với nonce gốc → token không dùng lại được ở app khác
    final random = Random.secure();
    final rawNonce = base64Url.encode(List<int>.generate(32, (_) => random.nextInt(256)));
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [AppleIDAuthorizationScopes.fullName, AppleIDAuthorizationScopes.email],
        nonce: sha256.convert(utf8.encode(rawNonce)).toString(),
      );
      final idToken = credential.identityToken;
      if (idToken == null) throw StateError('Apple không trả về identityToken');
      final name = [credential.familyName, credential.givenName].whereType<String>().where((s) => s.trim().isNotEmpty).join(' ');
      return (idToken: idToken, rawNonce: rawNonce, fullName: name.isEmpty ? null : name);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      rethrow;
    }
  }
}

final appleSignInBridgeProvider = Provider<AppleSignInBridge>((ref) => NativeAppleSignInBridge());

// Mã lỗi → câu cho người dùng. Huỷ ở màn LINE/Apple không phải lỗi (không gọi hàm này).
String socialLoginErrorMessage(Object error, AppLocalizations l10n, {required bool isLine}) {
  if (error is SocialLoginException) {
    if (error.code == 'E-AUTH-403') return l10n.socialLoginNotCustomer;
    if (error.code == 'E-RATE-429') return l10n.errorRateLimited;
  }
  return isLine ? l10n.lineLoginFailed : l10n.appleLoginFailed;
}

// LINE SDK báo người dùng huỷ bằng PlatformException mã CANCEL (Android: "CANCEL", iOS: "3003"/cancel).
bool isLineCancel(Object error) =>
    error is PlatformException && (error.code.toUpperCase().contains('CANCEL') || error.code == '3003');

class SocialLoginButtons extends ConsumerStatefulWidget {
  const SocialLoginButtons({super.key});

  @override
  ConsumerState<SocialLoginButtons> createState() => _SocialLoginButtonsState();
}

enum _Busy { none, line, apple }

class _SocialLoginButtonsState extends ConsumerState<SocialLoginButtons> {
  _Busy _busy = _Busy.none;
  String? _error;

  Future<void> _run(_Busy which, Future<void> Function() action) async {
    setState(() {
      _busy = which;
      _error = null;
    });
    try {
      await action();
      // RoleGate tự đổi màn khi có phiên — không điều hướng ở đây
    } catch (e) {
      if (!mounted || (which == _Busy.line && isLineCancel(e))) return;
      setState(() => _error = socialLoginErrorMessage(e, context.l10n, isLine: which == _Busy.line));
    } finally {
      if (mounted) setState(() => _busy = _Busy.none);
    }
  }

  Future<void> _line() => _run(_Busy.line, () async {
        final idToken = await ref.read(lineLoginBridgeProvider).obtainIdToken();
        await ref.read(authControllerProvider.notifier).signInWithLine(
              idToken: idToken,
              languageCode: ref.read(localeControllerProvider).languageCode,
            );
      });

  Future<void> _apple() => _run(_Busy.apple, () async {
        final credential = await ref.read(appleSignInBridgeProvider).obtainCredential();
        if (credential == null) return; // đã đóng màn của Apple
        await ref.read(authControllerProvider.notifier).signInWithApple(
              idToken: credential.idToken,
              rawNonce: credential.rawNonce,
              fullName: credential.fullName,
            );
      });

  @override
  Widget build(BuildContext context) {
    final line = ref.watch(lineLoginAvailableProvider);
    final apple = ref.watch(appleLoginAvailableProvider);
    if (!line && !apple) return const SizedBox.shrink();
    final l10n = context.l10n;
    final busy = _busy != _Busy.none;
    Widget spinner() => const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(l10n.socialLoginDivider, style: const TextStyle(fontSize: 12)),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 12),
        if (_error != null) ...[
          ErrorBanner(key: const Key('socialLoginError'), message: _error!),
          const SizedBox(height: 12),
        ],
        if (line)
          FilledButton.icon(
            key: const Key('lineLoginButton'),
            // Màu thương hiệu LINE (#06C755, LINE Login button guidelines)
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF06C755), foregroundColor: Colors.white),
            onPressed: busy ? null : _line,
            icon: _busy == _Busy.line ? spinner() : const Icon(Icons.chat_bubble, size: 20),
            label: Text(l10n.lineLoginButton),
          ),
        if (line && apple) const SizedBox(height: 12),
        if (apple)
          FilledButton.icon(
            key: const Key('appleLoginButton'),
            style: FilledButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
            onPressed: busy ? null : _apple,
            icon: _busy == _Busy.apple ? spinner() : const Icon(Icons.apple, size: 22),
            label: Text(l10n.appleLoginButton),
          ),
        const SizedBox(height: 8),
        Text(l10n.socialLoginNote, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
