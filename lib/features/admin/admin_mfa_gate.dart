import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/state_panel.dart';
import '../auth/auth_controller.dart';
import 'admin_gateway.dart';

// 6 chữ số (bỏ khoảng trắng / gạch nối) — cùng quy tắc Web normalizeTotpCode
String? normalizeTotpCode(String input) {
  final code = input.replaceAll(RegExp(r'[\s-]'), '');
  return RegExp(r'^\d{6}$').hasMatch(code) ? code : null;
}

// Khoá thiết lập chia nhóm 4 ký tự cho dễ đọc / nhập tay（JBSW Y3DP EHPK 3PXP）
String formatTotpSecret(String secret) {
  final groups = <String>[];
  for (var i = 0; i < secret.length; i += 4) {
    groups.add(secret.substring(i, i + 4 > secret.length ? secret.length : i + 4));
  }
  return groups.join(' ');
}

String mfaErrorMessage(Object error, AppLocalizations l10n) {
  if (error is AuthException) {
    if (error.code == 'mfa_verification_failed' || error.code == 'mfa_challenge_expired') return l10n.adminMfaWrongCode;
    if (error.statusCode == '429') return l10n.errorRateLimited;
  }
  return l10n.adminMfaFailed;
}

// Sau khi đăng nhập bằng tài khoản admin: đã aal2 (hoặc không bắt buộc) → [child]; có factor → SCR-A00 コード入力 (562:917);
// chưa có → SCR-A00 初回設定 (562:962).
class AdminMfaGate extends ConsumerWidget {
  const AdminMfaGate({super.key, required this.userId, required this.child});
  final String userId;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    void done() => ref.invalidate(adminMfaStateProvider(userId));
    return ref
        .watch(adminMfaStateProvider(userId))
        .when(
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (_, _) => Scaffold(
            body: SafeArea(
              child: Center(
                child: StatePanel.error(
                  title: l10n.storeLoadErrorTitle,
                  message: l10n.storeLoadErrorBody,
                  actionLabel: l10n.storeReload,
                  onAction: done,
                ),
              ),
            ),
          ),
          data: (state) => switch (state) {
            AdminMfaOk() => child,
            AdminMfaChallenge(:final factorId) => AdminMfaCodePage(factorId: factorId, onVerified: done),
            AdminMfaEnroll() => AdminMfaSetupPage(onVerified: done),
          },
        );
  }
}

class _CodeField extends StatelessWidget {
  const _CodeField({required this.controller, required this.enabled, this.errorText});
  final TextEditingController controller;
  final bool enabled;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('adminMfaCode'),
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      autofillHints: const [AutofillHints.oneTimeCode],
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: 12),
      decoration: InputDecoration(hintText: '000000', errorText: errorText),
    );
  }
}

// Đổi tài khoản = đăng xuất (RoleGate quay về màn đăng nhập)
Future<void> _signOut(WidgetRef ref) => ref.read(authControllerProvider.notifier).signOut();

class AdminMfaCodePage extends ConsumerStatefulWidget {
  const AdminMfaCodePage({super.key, required this.factorId, required this.onVerified});
  final String factorId;
  final VoidCallback onVerified;

  @override
  ConsumerState<AdminMfaCodePage> createState() => _AdminMfaCodePageState();
}

class _AdminMfaCodePageState extends ConsumerState<AdminMfaCodePage> {
  final _code = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final l10n = context.l10n;
    final code = normalizeTotpCode(_code.text);
    if (code == null) {
      setState(() => _error = l10n.adminMfaInvalidCode);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(adminGatewayProvider).verify(widget.factorId, code);
      widget.onVerified();
    } catch (e) {
      if (mounted) setState(() => _error = mfaErrorMessage(e, l10n));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(color: eco.primarySoft, shape: BoxShape.circle),
                    child: Icon(Icons.verified_user_outlined, color: eco.primary, size: 30),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.adminMfaTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.adminMfaLead,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: eco.textSecondary),
                ),
                const SizedBox(height: 20),
                _CodeField(controller: _code, enabled: !_busy, errorText: _error),
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key('adminMfaVerify'),
                  onPressed: _busy ? null : _verify,
                  child: _busy
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.adminMfaVerify),
                ),
                TextButton(
                  key: const Key('adminMfaOtherAccount'),
                  onPressed: _busy ? null : () => _signOut(ref),
                  child: Text(l10n.adminMfaOtherAccount),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdminMfaSetupPage extends ConsumerStatefulWidget {
  const AdminMfaSetupPage({super.key, required this.onVerified});
  final VoidCallback onVerified;

  @override
  ConsumerState<AdminMfaSetupPage> createState() => _AdminMfaSetupPageState();
}

class _AdminMfaSetupPageState extends ConsumerState<AdminMfaSetupPage> {
  final _code = TextEditingController();
  late final Future<TotpEnrollment> _enrollment = ref.read(adminGatewayProvider).startEnrollment();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _finish(TotpEnrollment e) async {
    final l10n = context.l10n;
    final code = normalizeTotpCode(_code.text);
    if (code == null) {
      setState(() => _error = l10n.adminMfaInvalidCode);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(adminGatewayProvider).verify(e.factorId, code);
      widget.onVerified();
    } catch (err) {
      if (mounted) setState(() => _error = mfaErrorMessage(err, l10n));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    Widget step(String n, String text) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: eco.primary,
          child: Text(n, style: TextStyle(fontSize: 12, color: eco.surface)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14, height: 1.6))),
      ],
    );
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<TotpEnrollment>(
          future: _enrollment,
          builder: (context, snap) {
            if (snap.hasError) {
              return Center(
                child: StatePanel.error(
                  title: l10n.adminMfaFailed,
                  actionLabel: l10n.adminMfaOtherAccount,
                  onAction: () => _signOut(ref),
                ),
              );
            }
            final e = snap.data;
            if (e == null) return const Center(child: CircularProgressIndicator());
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(l10n.adminMfaSetupTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(l10n.adminMfaSetupLead, style: TextStyle(fontSize: 13, color: eco.textSecondary)),
                    const SizedBox(height: 16),
                    step('1', l10n.adminMfaSetupStep1),
                    const SizedBox(height: 14),
                    Text(l10n.adminMfaSetupKey, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
                      decoration: BoxDecoration(
                        color: eco.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: eco.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SelectableText(
                              formatTotpSecret(e.secret),
                              key: const Key('adminMfaSecret'),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1),
                            ),
                          ),
                          FilledButton(
                            key: const Key('adminMfaCopy'),
                            style: FilledButton.styleFrom(minimumSize: const Size(0, 36), shape: const StadiumBorder()),
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              await Clipboard.setData(ClipboardData(text: e.secret));
                              messenger.showSnackBar(SnackBar(content: Text(l10n.adminMfaCopied)));
                            },
                            child: Text(l10n.adminMfaCopy),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: QrImageView(data: e.uri, size: 150, backgroundColor: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    step('2', l10n.adminMfaSetupStep2),
                    const SizedBox(height: 10),
                    Text(l10n.adminMfaCodeLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    _CodeField(controller: _code, enabled: !_busy, errorText: _error),
                    const SizedBox(height: 16),
                    FilledButton(
                      key: const Key('adminMfaSetupDone'),
                      onPressed: _busy ? null : () => _finish(e),
                      child: _busy
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(l10n.adminMfaSetupDone),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
