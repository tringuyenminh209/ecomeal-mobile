import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'card_input.dart';
import 'payment_gateway.dart';

// 「Visa •••• 3456」— dùng chung ở SCR-M05 / M07 / M09 và màn kết quả thanh toán.
String cardLabel(CardBrand brand, String last4) => '${brand.displayName} •••• $last4';

// Ô logo hãng của Figma (chữ đậm trong khung bo 6). Không dùng logo thật của hãng thẻ.
class CardBrandBadge extends StatelessWidget {
  const CardBrandBadge({super.key, required this.brand});
  final CardBrand? brand;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.eco.surface,
        border: Border.all(color: context.eco.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: brand == null
          ? Icon(Icons.credit_card, size: 18, color: context.eco.textSecondary)
          : Text(
              brand!.badge,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: context.eco.primary, letterSpacing: 0.3),
            ),
    );
  }
}

// 1 dòng thẻ: logo + 「Visa •••• 3456」 + dòng phụ (hạn / 「デフォルトカード」) + phần đuôi tuỳ màn.
class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({super.key, required this.method, required this.subtitle, this.badge, this.trailing, this.onTap});
  final PaymentMethod method;
  final String subtitle;
  final String? badge; // 「デフォルト」
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.eco.surface,
          border: Border.all(color: method.isDefault ? context.eco.primary : context.eco.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CardBrandBadge(brand: method.brand),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cardLabel(method.brand, method.last4), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: context.eco.textSecondary)),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: context.eco.primarySoft, borderRadius: BorderRadius.circular(999)),
                child: Text(badge!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: context.eco.primary)),
              ),
            if (trailing != null) ...[const SizedBox(width: 4), trailing!],
          ],
        ),
      ),
    );
  }
}

// Khung chữ nhỏ nền xám: 「支払い情報は認定決済プロバイダーによって…」 và nhắc môi trường thử nghiệm.
class PaymentNote extends StatelessWidget {
  const PaymentNote({super.key, required this.text, this.icon = Icons.lock_outline});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.eco.chip,
        border: Border.all(color: context.eco.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: context.eco.textSecondary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 11, height: 1.55, color: context.eco.textSecondary))),
        ],
      ),
    );
  }
}
