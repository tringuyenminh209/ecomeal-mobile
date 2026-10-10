import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/jst_date.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../profile/profile_gateway.dart';
import 'order_gateway.dart';
import 'order_helpers.dart';

// SCR-M13 領収書 (docs/proposals/2026-10-09 #3, 06 §SCR-M13, Figma 432:1164). Mở từ nút 「領収書」 của đơn đã nhận
// (picked_up) ở SCR-M06. Biên lai thường (không phải 適格請求書 — nhóm chưa có số đăng ký T…). Số tiền, thuế suất và tiền
// thuế lấy từ chính đơn hàng (orders.tax_rate / tax_amount, 0046), không tự tính lại.
class ReceiptPage extends ConsumerWidget {
  const ReceiptPage({super.key, required this.order});
  final OrderSummary order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = l10n.localeName;
    // Tên người nhận (宛名). Chưa tải được thì bỏ dòng 宛名, biên lai vẫn hiển thị.
    final name = ref.watch(myProfileProvider).valueOrNull?.name;
    final usedOn = toTokyo(order.plannedPickupTime).toIso8601String().substring(0, 10);
    final amount = '¥${order.pricePaid}';

    Widget line(String label, String value, {Key? key}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              Text(value, key: key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.receiptTitle), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.receiptTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                if (name != null) ...[
                  const SizedBox(height: 14),
                  Text(l10n.receiptAddressee(name), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
                const SizedBox(height: 14),
                Text(
                  l10n.priceTaxIncluded(amount),
                  key: const Key('receiptAmount'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.receiptPurpose,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const Divider(height: 28),
                line(l10n.receiptTaxableLine(order.taxRate), amount),
                // 0056: coupon do EcoMeal chịu — số tiền nhận (amount) là số khách thật sự trả
                if (order.discountAmount > 0)
                  line(l10n.receiptCouponLine, '−¥${order.discountAmount}', key: const Key('receiptCoupon')),
                line(l10n.taxIncludedLine(order.taxRate), '¥${order.taxAmount}', key: const Key('receiptTax')),
                line(l10n.receiptUsedOn, formatDateWithYear(usedOn, locale)),
                line(l10n.receiptOrderNumber, orderDisplayNumber(order.id)),
                line(l10n.receiptPaymentMethod, l10n.receiptPaymentCard),
                line(l10n.receiptIssuedOn, formatDateWithYear(todayInTokyo(), locale)),
                const Divider(height: 28),
                Text(l10n.receiptIssuer, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.receiptNote, style: const TextStyle(fontSize: 11, height: 1.6, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
