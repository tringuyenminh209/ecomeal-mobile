import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/state_panel.dart';
import 'add_card_page.dart';
import 'card_widgets.dart';
import 'payment_gateway.dart';

// SCR-M09 支払い方法・カード管理 — 06_画面設計 §SCR-M09, Figma 378:3 (未登録) / 378:54 (登録済み) /
// 405:5440 (カード操作) / 405:5501 (カード削除確認). 2 lối vào (Figma 389:1086):
//   - từ SCR-M07 (selectedId == null): quản lý — chạm 1 thẻ → bottom sheet đặt mặc định / xoá.
//   - từ SCR-M05 (selectedId != null): chọn thẻ để trả — chạm 1 thẻ hoặc thêm thẻ mới → pop(id thẻ).
// Không có Bottom Navigation (§0: chỉ tab gốc có thanh tab).
class PaymentMethodsPage extends ConsumerWidget {
  const PaymentMethodsPage({super.key, this.selectedId, this.isSelecting = false});
  final String? selectedId;
  final bool isSelecting;

  Future<void> _addCard(BuildContext context) async {
    final navigator = Navigator.of(context);
    final id = await navigator.push<String>(MaterialPageRoute(builder: (_) => const AddCardPage()));
    if (id != null && isSelecting) navigator.pop(id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final methodsAsync = ref.watch(myPaymentMethodsProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            Text(l10n.paymentMethodsTitle),
            Text(l10n.paymentMethodsSubtitle, style: TextStyle(fontSize: 11, color: context.eco.textSecondary)),
          ],
        ),
      ),
      body: methodsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: StatePanel.error(
            title: l10n.errorPaymentMethodsLoad,
            actionLabel: l10n.retry,
            onAction: () => ref.invalidate(myPaymentMethodsProvider),
          ),
        ),
        data: (methods) => methods.isEmpty
            ? _EmptyView(onAdd: () => _addCard(context))
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  Text(l10n.registeredCards, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  for (final m in methods) ...[
                    PaymentMethodTile(
                      key: Key('paymentMethod-${m.id}'),
                      method: m,
                      subtitle: l10n.cardExpiresOn(m.expiryLabel),
                      badge: m.isDefault ? l10n.defaultBadge : null,
                      trailing: isSelecting
                          ? Icon(
                              m.id == selectedId ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: m.id == selectedId ? context.eco.primary : context.eco.textSecondary,
                            )
                          : Icon(Icons.more_horiz, color: context.eco.textSecondary),
                      onTap: isSelecting ? () => Navigator.of(context).pop(m.id) : () => _showActions(context, ref, m),
                    ),
                    const SizedBox(height: 10),
                  ],
                  OutlinedButton(
                    key: const Key('addAnotherCardButton'),
                    onPressed: () => _addCard(context),
                    child: Text(l10n.addAnotherCard),
                  ),
                  const SizedBox(height: 20),
                  _SafetyCard(),
                ],
              ),
      ),
    );
  }

  Future<void> _showActions(BuildContext context, WidgetRef ref, PaymentMethod method) async {
    final l10n = context.l10n;
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(cardLabel(method.brand, method.last4), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              if (!method.isDefault)
                ListTile(
                  key: const Key('setDefaultCardAction'),
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(l10n.setDefaultCard),
                  onTap: () => Navigator.of(sheetContext).pop('default'),
                ),
              ListTile(
                key: const Key('deleteCardAction'),
                leading: Icon(Icons.delete_outline, color: context.eco.error),
                title: Text(l10n.deleteCard, style: TextStyle(color: context.eco.error)),
                onTap: () => Navigator.of(sheetContext).pop('delete'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(onPressed: () => Navigator.of(sheetContext).pop(), child: Text(l10n.cancelButton)),
            ],
          ),
        ),
      ),
    );
    if (!context.mounted || action == null) return;
    if (action == 'delete') {
      final ok = await showConfirmDialog(
        context,
        title: l10n.deleteCardTitle,
        message: l10n.deleteCardBody(cardLabel(method.brand, method.last4)),
        cancelLabel: l10n.back,
        confirmLabel: l10n.deleteConfirm,
        confirmKey: const Key('confirmDeleteCardButton'),
        destructive: true,
      );
      if (ok != true || !context.mounted) return;
    }
    final messenger = ScaffoldMessenger.of(context);
    try {
      final gateway = ref.read(paymentGatewayProvider);
      if (action == 'delete') {
        await gateway.deletePaymentMethod(method.id);
      } else {
        await gateway.setDefaultPaymentMethod(method.id);
      }
      ref.invalidate(myPaymentMethodsProvider);
      messenger.showSnackBar(SnackBar(content: Text(action == 'delete' ? l10n.cardDeleted : l10n.defaultCardChanged)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    }
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      children: [
        StatePanel(
          icon: Icons.credit_card,
          title: l10n.paymentMethodsEmptyTitle,
          message: l10n.paymentMethodsEmptyBody,
          actionLabel: l10n.addCreditCard,
          onAction: onAdd,
          filledAction: true,
        ),
        const SizedBox(height: 24),
        PaymentNote(text: l10n.paymentProviderNote),
      ],
    );
  }
}

class _SafetyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.eco.primarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, size: 16, color: context.eco.primary),
              const SizedBox(width: 6),
              Text(l10n.paymentSafetyTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          Text(l10n.paymentSafetyBody, style: TextStyle(fontSize: 11, height: 1.6, color: context.eco.textSecondary)),
        ],
      ),
    );
  }
}
