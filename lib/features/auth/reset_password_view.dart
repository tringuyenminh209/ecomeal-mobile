import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;
import '../../l10n/l10n.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/labeled_field.dart';
import 'auth_controller.dart';
import 'auth_widgets.dart';

// Supabase cho đặt độ dài mã OTP 6–10 chữ số (Auth → Email OTP Length). Chặn định dạng ở client để
// không tốn 1 lượt verify (bị giới hạn tần suất) cho chuỗi chắc chắn sai.
final _codePattern = RegExp(r'^\d{6,10}$');

// SCR-M02 パスワード再設定 (UC-28, Figma "SCR-M02 パスワード再設定 / *"): 2 bước trong cùng màn —
// ① nhập email → gửi mã (API-028), ② nhập mã + mật khẩu mới → verify (API-029) rồi đổi mật khẩu (API-030).
// Không dùng link trong mail: app chưa có deep link (05 §UC-25), mã giữ người dùng ở lại trong app.
class ResetPasswordView extends ConsumerStatefulWidget {
  const ResetPasswordView({super.key, required this.onBackToLogin});
  final VoidCallback onBackToLogin;

  @override
  ConsumerState<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends ConsumerState<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _codeSentTo; // != null → bước ②
  bool _codeVerified = false; // mã đã dùng (có session) → chỉ còn nhập lại mật khẩu
  bool _passwordVisible = false;
  bool _isSubmitting = false;
  String? _errorMessage; // banner đầu form
  String? _passwordError; // E-AUTH-413 → dưới ô mật khẩu

  AuthController get _auth => ref.read(authControllerProvider.notifier);

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Bọc 1 thao tác gửi: bật spinner, xoá lỗi cũ, mọi lỗi không phải AuthException → lỗi mạng.
  Future<void> _run(Future<void> Function() action, String Function(AuthException) onAuthError) async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _passwordError = null;
    });
    try {
      await action();
    } on AuthException catch (err) {
      if (mounted) setState(() => _errorMessage = onAuthError(err));
    } catch (_) {
      if (mounted) setState(() => _errorMessage = context.l10n.errorNetwork);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    await _run(() async {
      await _auth.requestPasswordReset(email);
      if (mounted) setState(() => _codeSentTo = email);
    }, _requestErrorMessage);
  }

  Future<void> _resendCode() async {
    final messenger = ScaffoldMessenger.of(context);
    final sent = context.l10n.codeResent;
    await _run(() async {
      await _auth.requestPasswordReset(_codeSentTo!);
      messenger.showSnackBar(SnackBar(content: Text(sent)));
    }, _requestErrorMessage);
  }

  String _requestErrorMessage(AuthException err) => err.statusCode == '429'
      ? context.l10n.errorRateLimited // E-AUTH-429
      : context.l10n.errorResetRequestFailed;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    // Lấy trước khi await: đổi mật khẩu xong RoleGate thay cả trang này bằng màn chính.
    final messenger = ScaffoldMessenger.of(context);
    final done = context.l10n.passwordResetDone;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _passwordError = null;
    });
    try {
      if (!_codeVerified) {
        try {
          await _auth.verifyRecoveryCode(email: _codeSentTo!, code: _codeController.text.trim());
        } on AuthException catch (err) {
          if (!mounted) return;
          setState(
            () => _errorMessage = err.statusCode == '429'
                ? context.l10n.errorRateLimited
                : context.l10n.errorVerificationCodeInvalid, // E-AUTH-412 (sai hoặc hết hạn — Supabase không phân biệt)
          );
          return;
        }
        if (mounted) setState(() => _codeVerified = true);
      }
      await _auth.updatePassword(_passwordController.text);
      messenger.showSnackBar(SnackBar(content: Text(done)));
    } on AuthException catch (err) {
      if (!mounted) return;
      setState(() {
        if (err.code == 'same_password') {
          _passwordError = context.l10n.errorSamePassword; // E-AUTH-413
        } else if (err.statusCode == '429') {
          _errorMessage = context.l10n.errorRateLimited;
        } else {
          _errorMessage = context.l10n.errorResetFailed;
        }
      });
    } catch (_) {
      if (mounted) setState(() => _errorMessage = context.l10n.errorNetwork);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // Mã đã đúng (đang có session) mà quay lại → đăng xuất, nếu không người dùng vào app mà chưa có mật khẩu mới.
  Future<void> _back() async {
    if (_codeVerified) await _auth.cancelPasswordRecovery();
    widget.onBackToLogin();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final codeSentTo = _codeSentTo;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const Key('resetBackButton'),
              onPressed: _isSubmitting ? null : _back,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: Text(l10n.backToLogin),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AuthHeading(
            title: l10n.resetPasswordTitle,
            lead: codeSentTo == null ? l10n.resetPasswordRequestLead : l10n.resetPasswordCodeLead(codeSentTo),
          ),
          const SizedBox(height: 24),
          if (_errorMessage != null) ...[
            ErrorBanner(message: _errorMessage!),
            const SizedBox(height: 16),
          ],
          if (codeSentTo == null) ...[
            LabeledField(
              label: l10n.emailLabel,
              child: TextFormField(
                key: const Key('resetEmailField'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(hintText: l10n.emailLabel),
                validator: (value) => validateAuthEmail(value, l10n),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('resetSendCodeButton'),
              onPressed: _isSubmitting ? null : _sendCode,
              child: authSubmitChild(_isSubmitting, l10n.resetPasswordSendCodeButton),
            ),
          ] else ...[
            LabeledField(
              label: l10n.verificationCodeLabel,
              child: TextFormField(
                key: const Key('resetCodeField'),
                controller: _codeController,
                enabled: !_codeVerified,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                decoration: InputDecoration(hintText: l10n.verificationCodeHint),
                validator: (value) =>
                    _codeVerified || _codePattern.hasMatch(value?.trim() ?? '') ? null : l10n.errorVerificationCodeFormat,
              ),
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: l10n.newPasswordLabel,
              child: TextFormField(
                key: const Key('resetPasswordField'),
                controller: _passwordController,
                obscureText: !_passwordVisible,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(
                  hintText: l10n.newPasswordHint,
                  helperText: l10n.passwordMin8Helper,
                  errorText: _passwordError,
                  suffixIcon: PasswordVisibilityToggle(
                    key: const Key('resetPasswordToggle'),
                    visible: _passwordVisible,
                    onToggle: () => setState(() => _passwordVisible = !_passwordVisible),
                  ),
                ),
                validator: (value) => (value == null || value.length < 8) ? l10n.errorPasswordMin8 : null,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('resetSubmitButton'),
              onPressed: _isSubmitting ? null : _resetPassword,
              child: authSubmitChild(_isSubmitting, l10n.resetPasswordButton),
            ),
          ],
          const Spacer(),
          const SizedBox(height: 24),
          if (codeSentTo != null && !_codeVerified)
            AuthSwitchPrompt(
              key: const Key('resendCodeLink'),
              prompt: l10n.resendCodePrompt,
              action: l10n.resendCodeAction,
              onTap: _isSubmitting ? () {} : _resendCode,
            ),
        ],
      ),
    );
  }
}
