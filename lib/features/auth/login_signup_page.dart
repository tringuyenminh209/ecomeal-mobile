import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;
import 'auth_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/ecomeal_logo.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/labeled_field.dart';
import 'auth_widgets.dart';
import '../legal/legal_pages.dart';
import '../legal/terms_gateway.dart';
import 'locale_controller.dart';
import 'reset_password_view.dart';
import 'social_login.dart';

// SCR-M02 ログイン・新規登録 — khớp các frame Figma "SCR-M02 *": logo, 2 tab dạng nút bo tròn, tiêu đề lớn,
// form nhãn-trên-ô, nút chính full-width, dòng chuyển tab ở đáy màn.
class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({super.key});

  @override
  State<LoginSignupPage> createState() => _LoginSignupPageState();
}

enum _AuthMode { login, signup, resetPassword }

class _LoginSignupPageState extends State<LoginSignupPage> {
  _AuthMode _mode = _AuthMode.login;

  void _showLogin() => setState(() => _mode = _AuthMode.login);
  void _showSignup() => setState(() => _mode = _AuthMode.signup);
  void _showResetPassword() => setState(() => _mode = _AuthMode.resetPassword);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          // Màn đủ cao: dòng chuyển tab dính đáy như Figma. Bàn phím mở/màn thấp: cả trang cuộn được.
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 60),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: EcoMealLogo(),
                    ),
                    const SizedBox(height: 24),
                    // Figma "パスワード再設定 / *": thay 2 tab bằng link quay lại.
                    if (_mode != _AuthMode.resetPassword) ...[
                      Row(
                        children: [
                          _AuthTab(
                            label: context.l10n.loginTab,
                            selected: _mode == _AuthMode.login,
                            onTap: _showLogin,
                          ),
                          const SizedBox(width: 8),
                          _AuthTab(
                            label: context.l10n.signupTab,
                            selected: _mode == _AuthMode.signup,
                            onTap: _showSignup,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                    Expanded(
                      child: switch (_mode) {
                        _AuthMode.login => LoginForm(
                          onGoToSignup: _showSignup,
                          onForgotPassword: _showResetPassword,
                          belowSubmit: const SocialLoginButtons(), // 0057: chỉ app khách
                        ),
                        _AuthMode.signup => _SignupTab(onBackToLogin: _showLogin),
                        _AuthMode.resetPassword => ResetPasswordView(onBackToLogin: _showLogin),
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// "Authentication tab" của Figma: nút cao 40 bo tròn; đang chọn = nền Primary chữ trắng,
// chưa chọn = nền trắng viền Border chữ Text-secondary.
class _AuthTab extends StatelessWidget {
  const _AuthTab({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.surface : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// Form đăng nhập (email + mật khẩu) dùng chung cho SCR-M02 (app khách) và SCR-D00 (app tài xế, ADR-007).
// [onGoToSignup] null = không có dòng 新規登録 (tài khoản tài xế do運営 phát hành) — khi đó hiện [footerNote] nếu có.
class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({
    super.key,
    required this.onForgotPassword,
    this.onGoToSignup,
    this.lead,
    this.footerNote,
    this.belowSubmit,
    this.forgotBelowSubmit = false,
  });
  final VoidCallback onForgotPassword;
  final VoidCallback? onGoToSignup;
  final String? lead; // null = câu dẫn của SCR-M02
  final String? footerNote;
  final Widget? belowSubmit; // 0057: nút LINE・Apple (SCR-M02). App tài xế (SCR-D00) không có
  // true: 「パスワードを忘れた方は こちら」 ngay dưới nút, cả dòng màu nhấn (Figma SCR-S00 552:2 / SCR-A00 562:861).
  // false: ở đáy màn như SCR-M02 / SCR-D00
  final bool forgotBelowSubmit;

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  bool _passwordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      // Không tự điều hướng ở đây — RoleGate (bước 8) lắng nghe authControllerProvider và tự
      // chuyển màn khi session+role sẵn sàng, giống cách HomeGate.tsx làm ở Web Admin (Chương 10).
    } on AuthException catch (err) {
      final isUnconfirmed =
          err.code == 'email_not_confirmed' ||
          err.message.toLowerCase().contains('email not confirmed');
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = err.statusCode == '429'
            ? context
                  .l10n
                  .errorRateLimited // E-AUTH-429 (Figma: SCR-M02 / Error E-AUTH-429)
            : isUnconfirmed
            ? context
                  .l10n
                  .errorEmailNotConfirmed // E-AUTH-410
            : context.l10n.errorInvalidCredentials;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = context.l10n.errorNetwork);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // UC-28 (レビュー第64回): trước đây dòng này bị bỏ vì chưa có UC/API đặt lại mật khẩu.
    final forgot = AuthSwitchPrompt(
      key: const Key('forgotPasswordLink'),
      prompt: context.l10n.forgotPasswordPrompt,
      action: context.l10n.forgotPasswordAction,
      onTap: widget.onForgotPassword,
      allAccent: widget.forgotBelowSubmit,
    );
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthHeading(title: context.l10n.loginTab, lead: widget.lead ?? context.l10n.loginLead),
          const SizedBox(height: 24),
          // Lỗi của cả form (sai mật khẩu, E-AUTH-410/429, mạng) hiện ở banner ĐẦU form — 06 §SCR-M02, Figma.
          if (_errorMessage != null) ...[
            ErrorBanner(message: _errorMessage!),
            const SizedBox(height: 16),
          ],
          LabeledField(
            label: context.l10n.emailLabel,
            child: TextFormField(
              key: const Key('loginEmailField'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(hintText: context.l10n.emailLabel),
              validator: (value) => validateAuthEmail(value, context.l10n),
            ),
          ),
          const SizedBox(height: 16),
          LabeledField(
            label: context.l10n.passwordLabel,
            child: TextFormField(
              key: const Key('loginPasswordField'),
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: context.l10n.passwordLabel,
                suffixIcon: PasswordVisibilityToggle(
                  key: const Key('loginPasswordToggle'),
                  visible: _passwordVisible,
                  onToggle: () => setState(() => _passwordVisible = !_passwordVisible),
                ),
              ),
              obscureText: !_passwordVisible,
              validator: (value) => (value == null || value.isEmpty)
                  ? context.l10n.errorPasswordRequired
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('loginSubmitButton'),
            onPressed: _isSubmitting ? null : _submit,
            child: authSubmitChild(_isSubmitting, context.l10n.loginButton),
          ),
          if (widget.belowSubmit != null) widget.belowSubmit!,
          if (widget.forgotBelowSubmit) ...[const SizedBox(height: 4), forgot],
          const Spacer(),
          const SizedBox(height: 24),
          if (!widget.forgotBelowSubmit) forgot,
          if (widget.onGoToSignup != null)
            AuthSwitchPrompt(
              prompt: context.l10n.noAccountPrompt,
              action: context.l10n.signupTab,
              onTap: widget.onGoToSignup!,
            ),
          if (widget.footerNote != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.footerNote!,
              key: const Key('loginFooterNote'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, height: 1.6, color: context.eco.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _SignupTab extends ConsumerStatefulWidget {
  const _SignupTab({required this.onBackToLogin});
  final VoidCallback onBackToLogin;

  @override
  ConsumerState<_SignupTab> createState() => _SignupTabState();
}

class _SignupTabState extends ConsumerState<_SignupTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _passwordVisible = false;
  bool _agreedToTerms = false; // UC-36: chưa tick thì 「登録する」 disabled (Figma 420:1077)
  String? _errorMessage; // lỗi của cả form → banner
  String? _emailError; // E-AUTH-409 → viền đỏ + chữ đỏ dưới ô email (Figma "新規登録 / Error")
  bool _confirmationSent = false; // UC-25 bước⑤: trạng thái "確認メール送信済み"

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _emailError = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final languageCode = ref.read(localeControllerProvider).languageCode;
      await ref
          .read(authControllerProvider.notifier)
          .signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
            languageCode: languageCode,
            termsVersion: currentTermsVersion,
          );
      if (mounted) setState(() => _confirmationSent = true);
    } on AuthException catch (err) {
      if (!mounted) return;
      setState(() {
        // E-AUTH-429 phải xét TRƯỚC: Supabase Auth trả HTTP 429 (statusCode '429', code
        // over_request_rate_limit / over_email_send_rate_limit) khi đăng ký dồn dập — nếu rơi xuống
        // nhánh cuối, người dùng thấy "入力内容をご確認" và sửa input vô ích thay vì chờ.
        if (err.statusCode == '429') {
          _errorMessage = context.l10n.errorRateLimited; // E-AUTH-429
        } else if (err.code == 'user_already_exists' ||
            err.code == 'email_exists' ||
            err.message.toLowerCase().contains('already registered')) {
          _emailError = context.l10n.errorEmailAlreadyRegistered; // E-AUTH-409
        } else {
          _errorMessage = context.l10n.errorSignupFailed;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = context.l10n.errorNetwork);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_confirmationSent) {
      // 06_画面設計.md §SCR-M02: "見出し「確認メールを送信しました」..." — nguyên văn, không rẽ màn mới.
      // Bố cục theo Figma "新規登録 / 確認メール送信済み": card trắng, icon thư trong vòng tròn xanh nhạt.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_read_outlined,
                      size: 28,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.l10n.signupConfirmationTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.l10n.signupConfirmationBody(
                      _emailController.text.trim(),
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.65,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: widget.onBackToLogin,
                    child: Text(context.l10n.backToLogin),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          const SizedBox(height: 24),
          Text(
            context.l10n.signupSpamFolderNote,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, height: 1.5, color: AppColors.textSecondary),
          ),
        ],
      );
    }
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthHeading(title: context.l10n.signupTab, lead: context.l10n.signupLead),
          const SizedBox(height: 24),
          if (_errorMessage != null) ...[
            ErrorBanner(message: _errorMessage!),
            const SizedBox(height: 16),
          ],
          // Thứ tự ô theo Figma: メールアドレス → パスワード → 表示名.
          LabeledField(
            label: context.l10n.emailLabel,
            child: TextFormField(
              key: const Key('signupEmailField'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(
                hintText: context.l10n.emailHint,
                errorText: _emailError,
              ),
              validator: (value) => validateAuthEmail(value, context.l10n),
            ),
          ),
          const SizedBox(height: 16),
          LabeledField(
            label: context.l10n.passwordLabel,
            child: TextFormField(
              key: const Key('signupPasswordField'),
              controller: _passwordController,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                hintText: context.l10n.passwordHint,
                helperText: context.l10n.passwordMin8Helper,
                suffixIcon: PasswordVisibilityToggle(
                  key: const Key('signupPasswordToggle'),
                  visible: _passwordVisible,
                  onToggle: () => setState(() => _passwordVisible = !_passwordVisible),
                ),
              ),
              validator: (value) => (value == null || value.length < 8)
                  ? context.l10n.errorPasswordMin8
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          LabeledField(
            label: context.l10n.displayNameLabel,
            child: TextFormField(
              key: const Key('signupNameField'),
              controller: _nameController,
              decoration: InputDecoration(hintText: context.l10n.displayNameHint),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? context.l10n.errorDisplayNameRequired
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          _TermsConsentField(
            value: _agreedToTerms,
            onChanged: (v) => setState(() => _agreedToTerms = v),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('signupSubmitButton'),
            onPressed: _isSubmitting || !_agreedToTerms ? null : _submit,
            child: authSubmitChild(_isSubmitting, context.l10n.signupButton),
          ),
          const Spacer(),
          const SizedBox(height: 24),
          AuthSwitchPrompt(
            prompt: context.l10n.haveAccountPrompt,
            action: context.l10n.loginTab,
            onTap: widget.onBackToLogin,
          ),
        ],
      ),
    );
  }
}

// Ô đồng ý của SCR-M02 新規登録 (Figma 420:1077): checkbox + câu có 2 link (利用規約 → SCR-M10, プライバシーポリシー → SCR-M11).
// Mở link là push trang mới nên form đăng ký vẫn giữ nội dung đã nhập khi quay lại.
class _TermsConsentField extends StatelessWidget {
  const _TermsConsentField({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const linkStyle = TextStyle(
      color: AppColors.primary,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
    );
    // Vùng chạm ≥ 44px quanh chữ 13px (review page 02: link và ô tick quá nhỏ để bấm)
    Widget link(String label, LegalDocument doc, Key key) => InkWell(
          key: key,
          onTap: () => openLegalDocument(context, doc),
          borderRadius: BorderRadius.circular(6),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Align(widthFactor: 1, child: Text(label, style: linkStyle.copyWith(fontSize: 13))),
            ),
          ),
        );
    // Chữ thường của câu đồng ý cũng bật/tắt ô tick (giống nhãn của checkbox)
    Widget plain(String text) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(!value),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Align(widthFactor: 1, child: Text(text, style: const TextStyle(fontSize: 13))),
          ),
        );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          key: const Key('signupTermsCheckbox'),
          value: value,
          onChanged: (v) => onChanged(v ?? false),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wrap thay cho TextSpan + recognizer: mỗi link là 1 widget riêng → bấm được, test tìm được theo Key.
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (l10n.signupConsentBefore.isNotEmpty) plain(l10n.signupConsentBefore),
                    link(l10n.legalTermsTitle, LegalDocument.terms, const Key('signupTermsLink')),
                    plain(l10n.signupConsentBetween),
                    link(l10n.legalPrivacyTitle, LegalDocument.privacy, const Key('signupPrivacyLink')),
                    if (l10n.signupConsentAfter.isNotEmpty) plain(l10n.signupConsentAfter),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.signupConsentHint,
                  style: const TextStyle(fontSize: 11, height: 1.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
