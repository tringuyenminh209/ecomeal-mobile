import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../payment/card_widgets.dart';
import '../payment/payment_gateway.dart';

// review = màn xác nhận; 4 trạng thái còn lại là các frame kết quả của SCR-M05 (06 §SCR-M05 カード決済).
enum PaymentPhase { review, processing, done, declined, unknown }

// Figma 389:913 処理中 / 389:935 完了 / 389:959 カード拒否 / 389:985 結果確認待ち — cùng bố cục: biểu tượng tròn,
// tiêu đề, mô tả, thẻ tóm tắt (món × 1, số tiền · thẻ), ghi chú, nút ở đáy.
class PaymentResultView extends StatelessWidget {
  const PaymentResultView({
    super.key,
    required this.phase,
    required this.amount,
    required this.card,
    required this.stopName,
    required this.pickupWindow,
    required this.cardExpired,
    required this.rechecking,
    required this.onViewReservation,
    required this.onPayWithAnotherCard,
    required this.onBackToReview,
    required this.onRecheck,
  });

  final PaymentPhase phase;
  final int amount;
  final PaymentMethod? card;
  final String stopName;
  final String pickupWindow;
  final bool cardExpired;
  final bool rechecking;
  final VoidCallback onViewReservation;
  final VoidCallback onPayWithAnotherCard;
  final VoidCallback onBackToReview;
  final VoidCallback onRecheck;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final (Widget icon, Color tint, Color soft, String title, String body) = switch (phase) {
      PaymentPhase.processing => (
          SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 3, color: eco.primary)),
          eco.primary,
          eco.primarySoft,
          l10n.paymentProcessingTitle,
          l10n.paymentProcessingBody,
        ),
      PaymentPhase.done => (Icon(Icons.check, size: 34, color: eco.primary), eco.primary, eco.primarySoft, l10n.paymentDoneTitle, l10n.paymentDoneBody),
      PaymentPhase.declined => (
          Icon(Icons.priority_high, size: 34, color: eco.error),
          eco.error,
          eco.errorSoft,
          l10n.paymentDeclinedTitle,
          cardExpired ? l10n.paymentCardExpiredBody : l10n.paymentDeclinedBody,
        ),
      _ => (Icon(Icons.more_horiz, size: 34, color: eco.onAmber), eco.amber, eco.amberSoft, l10n.paymentUnknownTitle, l10n.paymentUnknownBody),
    };
    final note = switch (phase) {
      PaymentPhase.processing => l10n.paymentProcessingNote,
      PaymentPhase.done => '${l10n.pickupPlaceLine(stopName)}\n${l10n.pickupTimeLine(pickupWindow)}',
      PaymentPhase.declined => l10n.paymentNotCompletedNote,
      _ => l10n.paymentUnknownNote,
    };
    final paidCard = card;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(phase == PaymentPhase.done ? l10n.reservationCompleteTitle : l10n.paymentTitle),
      ),
      body: ListView(
        key: Key('paymentResult-${phase.name}'),
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        children: [
          Center(
            child: Container(
              width: 76,
              height: 76,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: soft, shape: BoxShape.circle),
              child: icon,
            ),
          ),
          const SizedBox(height: 20),
          Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(body, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, height: 1.65, color: eco.textSecondary)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: eco.surface,
              border: Border.all(color: eco.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${l10n.mysteryBag} × 1', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  l10n.paymentSummaryLine('¥$amount', paidCard == null ? '' : cardLabel(paidCard.brand, paidCard.last4)),
                  key: const Key('paymentSummaryLine'),
                  style: TextStyle(fontSize: 12, color: eco.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: soft, borderRadius: BorderRadius.circular(10)),
            child: Text(note, style: TextStyle(fontSize: 12, height: 1.6, color: phase == PaymentPhase.declined ? tint : eco.textPrimary)),
          ),
        ],
      ),
      bottomNavigationBar: phase == PaymentPhase.processing
          ? null
          : SafeArea(
              minimum: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: switch (phase) {
                  PaymentPhase.done => [
                      FilledButton(key: const Key('viewReservationButton'), onPressed: onViewReservation, child: Text(l10n.viewReservation)),
                    ],
                  PaymentPhase.declined => [
                      FilledButton(key: const Key('payWithAnotherCardButton'), onPressed: onPayWithAnotherCard, child: Text(l10n.payWithAnotherCard)),
                      const SizedBox(height: 8),
                      OutlinedButton(key: const Key('backToReviewButton'), onPressed: onBackToReview, child: Text(l10n.backToReview)),
                    ],
                  _ => [
                      FilledButton(
                        key: const Key('recheckPaymentButton'),
                        onPressed: rechecking ? null : onRecheck,
                        child: rechecking
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surface))
                            : Text(l10n.recheckPayment),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(key: const Key('viewHistoryButton'), onPressed: onViewReservation, child: Text(l10n.viewReservationHistory)),
                    ],
                },
              ),
            ),
    );
  }
}
