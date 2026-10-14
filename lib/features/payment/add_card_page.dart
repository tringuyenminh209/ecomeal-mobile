import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/clock.dart';
import '../../core/jst_date.dart';
import '../../core/stripe_payments.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/labeled_field.dart';
import 'card_input.dart';
import 'card_widgets.dart';
import 'payment_api.dart';
import 'payment_gateway.dart';
import '../auth/auth_controller.dart';

// SCR-M09 カードを追加 — 06_画面設計 §SCR-M09, Figma 378:26 (thường) / 389:1011 (入力エラー).
// Số thẻ / CVC chỉ nằm trong TextEditingController của màn này: kiểm tra xong chỉ gửi hãng + 4 số cuối + hạn
// (API-046). Tên chủ thẻ chỉ để khách kiểm tra lại — không gửi, không lưu (thanh toán giả, ADR-006).
// Không có checkbox「このカードを保存」: mọi thẻ thêm ở đây đều được lưu (06 §SCR-M09 差異).
// Trả về id thẻ vừa thêm khi thành công.
// Stripe (0047): thay 4 ô nhập bằng CardField của Stripe — số thẻ đi thẳng tới Stripe, app chỉ nhận pm_… rồi gửi cho
// Edge Function stripe-add-card (API-053), server đọc hãng/4 số cuối/hạn từ Stripe.
class AddCardPage extends ConsumerStatefulWidget {
  const AddCardPage({super.key});

  @override
  ConsumerState<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends ConsumerState<AddCardPage> {
  final _number = TextEditingController();
  final _holder = TextEditingController();
  final _expiry = TextEditingController();
  final _cvc = TextEditingController();
  bool _submitted = false; // lỗi chỉ hiện sau lần bấm đầu tiên, không đỏ ngay khi vừa gõ
  bool _saving = false;
  String? _serverExpiryError;
  bool _stripeComplete = false; // CardField đã nhập đủ và hợp lệ

  @override
  void initState() {
    super.initState();
    for (final c in [_number, _holder, _expiry, _cvc]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_number, _holder, _expiry, _cvc]) {
      c.dispose();
    }
    super.dispose();
  }

  CardBrand? get _brand => detectCardBrand(_number.text);
  DateTime get _nowJst => toTokyo(ref.read(clockProvider)());

  String? _numberError(AppLocalizations l10n) => _submitted ? validateCardNumber(_number.text, l10n) : null;
  String? _holderError(AppLocalizations l10n) => _submitted ? validateCardHolder(_holder.text, l10n) : null;
  String? _expiryError(AppLocalizations l10n) =>
      _submitted ? (validateExpiry(_expiry.text, _nowJst, l10n) ?? _serverExpiryError) : null;
  String? _cvcError(AppLocalizations l10n) => _submitted ? validateCvc(_cvc.text, _brand, l10n) : null;

  Future<void> _submitStripe() async {
    final l10n = context.l10n;
    if (!_stripeComplete) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.stripeCardIncomplete)));
      return;
    }
    setState(() => _saving = true);
    try {
      final pmId = await ref.read(stripeCardTokenizerProvider)();
      final id = await ref.read(paymentGatewayProvider).addStripeCard(pmId);
      ref.invalidate(myPaymentMethodsProvider);
      if (mounted) Navigator.of(context).pop(id);
    } catch (e) {
      if (!mounted) return;
      if (paymentErrorCode(e) == 'E-AUTH-401') {
        // hết phiên, không phải lỗi thẻ (2026-10-14): SessionGuard đóng màn này, về đăng nhập và báo 「ログインし直してください」
        unawaited(ref.read(authControllerProvider.notifier).expireSession());
        return;
      }
      final message = switch (paymentErrorCode(e)) {
        'E-PAY-409' => l10n.errorCardLimit,
        'E-PAY-410' => l10n.cardExpiryInvalid,
        'E-PAY-402' || 'E-PAY-422' => l10n.errorCardDeclined,
        'E-RATE-429' => l10n.errorRateLimited, // 0052: 10 lần/giờ (chống card testing)
        _ => l10n.errorCardAdd,
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _submit() async {
    if (ref.read(stripeEnabledProvider)) return _submitStripe();
    final l10n = context.l10n;
    setState(() {
      _submitted = true;
      _serverExpiryError = null;
    });
    final hasError = validateCardNumber(_number.text, l10n) != null ||
        validateCardHolder(_holder.text, l10n) != null ||
        validateExpiry(_expiry.text, _nowJst, l10n) != null ||
        validateCvc(_cvc.text, _brand, l10n) != null;
    if (hasError) return;

    final digits = digitsOnly(_number.text);
    setState(() => _saving = true);
    try {
      final id = await ref.read(paymentGatewayProvider).addPaymentMethod(
            brand: _brand!,
            last4: digits.substring(digits.length - 4),
            expiry: parseExpiry(_expiry.text)!,
          );
      ref.invalidate(myPaymentMethodsProvider);
      if (mounted) Navigator.of(context).pop(id);
    } catch (e) {
      if (!mounted) return;
      final text = e is PostgrestException ? e.message : '';
      if (text.contains('E-PAY-410')) {
        // Đồng hồ máy lệch so với server — hiện đúng chỗ như lỗi nhập
        setState(() => _serverExpiryError = l10n.cardExpiryInvalid);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text.contains('E-PAY-409') ? l10n.errorCardLimit : l10n.errorCardAdd)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final brand = _brand;
    final stripeMode = ref.watch(stripeEnabledProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            Text(l10n.addCardTitle),
            Text(l10n.addCardSubtitle, style: TextStyle(fontSize: 11, color: context.eco.textSecondary)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        children: [
          Text(l10n.cardInfoSection, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (stripeMode)
            ref.watch(stripeCardInputProvider)((complete) => setState(() => _stripeComplete = complete))
          else ...[
            LabeledField(
              label: l10n.cardNumberLabel,
              child: TextField(
                key: const Key('cardNumberField'),
                controller: _number,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.creditCardNumber],
                inputFormatters: [_FormatFormatter(formatCardNumber)],
                decoration: InputDecoration(
                  hintText: l10n.cardNumberHint,
                  errorText: _numberError(l10n),
                  suffixIcon: Padding(padding: const EdgeInsets.all(8), child: CardBrandBadge(brand: brand)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: l10n.cardHolderLabel,
              child: TextField(
                key: const Key('cardHolderField'),
                controller: _holder,
                textCapitalization: TextCapitalization.characters,
                autofillHints: const [AutofillHints.creditCardName],
                decoration: InputDecoration(hintText: l10n.cardHolderHint, errorText: _holderError(l10n)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LabeledField(
                    label: l10n.cardExpiryLabel,
                    child: TextField(
                      key: const Key('cardExpiryField'),
                      controller: _expiry,
                      keyboardType: TextInputType.number,
                      autofillHints: const [AutofillHints.creditCardExpirationDate],
                      inputFormatters: [_FormatFormatter(formatExpiry)],
                      decoration: InputDecoration(hintText: l10n.cardExpiryHint, errorText: _expiryError(l10n)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LabeledField(
                    label: l10n.cardCvcLabel,
                    child: TextField(
                      key: const Key('cardCvcField'),
                      controller: _cvc,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      autofillHints: const [AutofillHints.creditCardSecurityCode],
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                      decoration: InputDecoration(hintText: l10n.cardCvcHint, errorText: _cvcError(l10n)),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          PaymentNote(text: l10n.cardTokenNote),
          const SizedBox(height: 8),
          if (ref.watch(paymentTestModeProvider)) PaymentNote(text: l10n.testPaymentNote, icon: Icons.science_outlined),
          const SizedBox(height: 12),
          Text(l10n.cardTermsNote, style: TextStyle(fontSize: 11, color: context.eco.textSecondary)),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(color: context.eco.surface, border: Border(top: BorderSide(color: context.eco.border))),
        child: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: FilledButton(
            key: const Key('addCardSubmitButton'),
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surface))
                : Text(l10n.addCardButton),
          ),
        ),
      ),
    );
  }
}

// Định dạng lại toàn bộ ô mỗi lần gõ (nhóm số thẻ, "MM / YY") và đặt con trỏ về cuối.
class _FormatFormatter extends TextInputFormatter {
  _FormatFormatter(this._format);
  final String Function(String) _format;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var raw = newValue.text;
    // Xoá đúng ký tự phân cách (khoảng trắng / " / ") thì phải xoá luôn chữ số đứng trước nó, không thì kẹt
    if (newValue.text.length < oldValue.text.length && digitsOnly(newValue.text) == digitsOnly(oldValue.text)) {
      final d = digitsOnly(raw);
      raw = d.isEmpty ? '' : d.substring(0, d.length - 1);
    }
    final text = _format(raw);
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
