import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import 'order_gateway.dart';
import 'order_helpers.dart';

// SCR-M15 問題を報告 (UC-40, 06 §SCR-M15, Figma 443:1191). Mở từ nút 「問題を報告」 ở thẻ đơn đã nhận / hết hạn (SCR-M06).
// Gửi xong → quay lại SCR-M06 (pop true) — thẻ đó đổi sang 「問題を報告しました（確認中）」.
const _maxMessageLength = 500; // report_order_issue: 1〜500 ký tự (E-ISSUE-422)

class ReportIssuePage extends ConsumerStatefulWidget {
  const ReportIssuePage({super.key, required this.order});
  final OrderSummary order;

  @override
  ConsumerState<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends ConsumerState<ReportIssuePage> {
  final _message = TextEditingController();
  String? _category;
  String? _error;
  bool _sending = false;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final message = _message.text.trim();
    if (_category == null) return setState(() => _error = l10n.errorReportIssueSelect);
    if (message.isEmpty || message.runes.length > _maxMessageLength) return setState(() => _error = l10n.errorReportIssueDetail);
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref.read(orderGatewayProvider).reportIssue(orderId: widget.order.id, category: _category!, message: message);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      final text = e is PostgrestException ? e.message : '';
      setState(() {
        _error = text.contains('E-ISSUE-410')
            ? l10n.errorReportIssueLate
            : text.contains('E-ISSUE-409')
                ? l10n.errorReportIssueDuplicate
                : l10n.errorReportIssue;
        _sending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final order = widget.order;
    final options = [for (final c in issueCategories) (c, issueCategoryLabel(c, l10n))];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportIssueTitle), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${l10n.mysteryBag} ・ ${l10n.orderNumber(orderDisplayNumber(order.id))}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('${orderTimeLabel(order.plannedPickupTime, l10n)} ・ ${l10n.priceTaxIncluded('¥${order.pricePaid}')}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.reportIssueQuestion, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          for (final (value, label) in options)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(
                    color: _category == value ? AppColors.primary : AppColors.border,
                    width: _category == value ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: RadioListTile<String>(
                  key: Key('issueCategory_$value'),
                  value: value,
                  groupValue: _category,
                  onChanged: (v) => setState(() {
                    _category = v;
                    _error = null;
                  }),
                  dense: true,
                  title: Text(label, style: const TextStyle(fontSize: 13)),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(l10n.reportIssueDetailLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            key: const Key('issueMessageField'),
            controller: _message,
            minLines: 4,
            maxLines: 8,
            maxLength: _maxMessageLength,
            decoration: InputDecoration(hintText: l10n.reportIssueDetailHint),
          ),
          const SizedBox(height: 8),
          Text(l10n.reportIssueNote, style: const TextStyle(fontSize: 11, height: 1.6, color: AppColors.textSecondary)),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Lỗi đặt ngay trên nút (vùng cố định, luôn nhìn thấy dù bàn phím đang mở / danh sách đã cuộn)
              if (_error != null) ...[
                Text(_error!, key: const Key('issueError'), style: const TextStyle(fontSize: 12, color: AppColors.error)),
                const SizedBox(height: 8),
              ],
              FilledButton(
                key: const Key('submitIssueButton'),
                onPressed: _sending ? null : _submit,
                child: _sending
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surface))
                    : Text(l10n.reportIssueSubmit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
