import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/jst_date.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/state_panel.dart';
import '../legal/legal_pages.dart';
import 'coupons.dart';

// SCR-M19 クーポン・友だち紹介 (0056, Figma「M19 クーポン・友だち紹介」470:1317 — nhập mã 470:1518 / đã nhập 470:1579).
// Mở từ SCR-M07. Mã của mình: sao chép / gửi qua LINE (không cần thêm plugin chia sẻ: line.me/R/share mở app LINE).

String couponValidUntil(Coupon c, BuildContext context) =>
    context.l10n.couponValidUntil(DateFormat.MMMd(Localizations.localeOf(context).toString()).format(toTokyo(c.expiresAt)));

Uri lineShareUri(String text) => Uri.https('line.me', '/R/share', {'text': text});

class CouponsPage extends ConsumerWidget {
  const CouponsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final referralAsync = ref.watch(myReferralProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.couponsTitle)),
      body: referralAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: StatePanel.error(
            title: l10n.errorLoadTitle,
            message: l10n.errorLoadBody,
            actionLabel: l10n.retry,
            onAction: () => ref.invalidate(myReferralProvider),
          ),
        ),
        data: (referral) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            _MyCodeCard(code: referral.code),
            const SizedBox(height: 16),
            if (referral.canApply) ...[
              const _ApplyCodeCard(),
              const SizedBox(height: 16),
            ] else if (referral.appliedCode case final code?) ...[
              Container(
                key: const Key('referralApplied'),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: AppColors.chip, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.check, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(l10n.referralApplied(code), style: const TextStyle(fontSize: 12))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            const _CouponList(),
          ],
        ),
      ),
    );
  }
}

class _MyCodeCard extends ConsumerWidget {
  const _MyCodeCard({required this.code});
  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.referralMyCodeLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          SelectableText(
            code,
            key: const Key('myReferralCode'),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 2),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(
                key: const Key('copyReferralCode'),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: code));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.referralCopied)));
                  }
                },
                child: Text(l10n.referralCopy),
              ),
              FilledButton(
                key: const Key('shareReferralLine'),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final failed = l10n.errorOpenLine;
                  var opened = false;
                  try {
                    opened = await ref.read(openExternalUrlProvider)(lineShareUri(l10n.referralShareText(code)).toString());
                  } catch (_) {}
                  if (!opened) messenger.showSnackBar(SnackBar(content: Text(failed)));
                },
                child: Text(l10n.referralShareLine),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(l10n.referralHowItWorks, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ApplyCodeCard extends ConsumerStatefulWidget {
  const _ApplyCodeCard();

  @override
  ConsumerState<_ApplyCodeCard> createState() => _ApplyCodeCardState();
}

class _ApplyCodeCardState extends ConsumerState<_ApplyCodeCard> {
  final _controller = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final l10n = context.l10n;
    final code = _controller.text.trim().toUpperCase();
    if (code.length != 6) {
      setState(() => _error = l10n.referralErrorFormat);
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref.read(couponsGatewayProvider).applyReferralCode(code);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.referralAppliedToast)));
      ref.invalidate(myReferralProvider);
      ref.invalidate(usableCouponsProvider);
    } catch (e) {
      if (mounted) setState(() => _error = referralErrorMessage(e, l10n));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.referralEnterLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('referralCodeInput'),
                  controller: _controller,
                  enabled: !_sending,
                  maxLength: 6,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(hintText: l10n.referralEnterHint, counterText: '', errorText: _error),
                  onSubmitted: (_) => _apply(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                key: const Key('applyReferralButton'),
                onPressed: _sending ? null : _apply,
                child: Text(l10n.referralApply),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(l10n.referralEnterNote, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _CouponList extends ConsumerWidget {
  const _CouponList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final coupons = ref.watch(usableCouponsProvider).valueOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.couponsUsableHeading, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        if (coupons != null && coupons.isEmpty)
          Text(l10n.couponsNone, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        for (final c in coupons ?? const <Coupon>[]) ...[
          CouponTile(key: Key('coupon-${c.id}'), coupon: c),
          const SizedBox(height: 8),
        ],
        Text(l10n.couponsAutoNote, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

// Dùng ở SCR-M19 (danh sách) và SCR-M05 (coupon đang áp dụng, kèm công tắc).
class CouponTile extends StatelessWidget {
  const CouponTile({super.key, required this.coupon, this.trailing});
  final Coupon coupon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppColors.amberSoft, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(Icons.confirmation_number_outlined, size: 22, color: AppColors.amberInk),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(couponTitle(coupon, l10n), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(couponValidUntil(coupon, context), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          trailing ??
              Text(l10n.couponAmountOff(coupon.amount),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.amberInk)),
        ],
      ),
    );
  }
}
