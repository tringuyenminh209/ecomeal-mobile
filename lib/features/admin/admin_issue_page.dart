import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import '../../core/jst_date.dart';
import '../../core/rpc_error.dart';
import '../../core/theme/app_theme.dart';
import '../../core/yen.dart';
import '../../l10n/l10n.dart';
import '../../widgets/confirm_dialog.dart';
import '../notifications/notification_inbox.dart' show inboxTimeLabel;
import '../orders/order_helpers.dart';
import 'admin_gateway.dart';
import '../../widgets/error_banner.dart';
import 'admin_tasks_gateway.dart';

// Giới hạn của order_issues.resolution (0050: 1〜500 ký tự)
const _maxResolutionLength = 500;

// null = hợp lệ. Số tiền hoàn: số nguyên 0〜số còn hoàn được (server cũng chặn: E-ISSUE-422)
int? parseRefund(String text, int refundable) {
  final v = int.tryParse(text.trim());
  if (v == null || v < 0 || v > refundable) return null;
  return v;
}

// SCR-A04 問題報告の対応（565:1246 / ¥0 568:1486 / 送信中 568:1544 / 送信エラー 568:1602）
class AdminIssuePage extends ConsumerStatefulWidget {
  // onClose: trong cột chi tiết của iPad (2 cột) — xong / đóng thì bỏ chọn thay vì pop
  const AdminIssuePage({super.key, required this.issue, this.onClose});
  final AdminIssue issue;
  final VoidCallback? onClose;

  @override
  ConsumerState<AdminIssuePage> createState() => _AdminIssuePageState();
}

class _AdminIssuePageState extends ConsumerState<AdminIssuePage> {
  late final _amount = TextEditingController(text: '${widget.issue.refundable}');
  final _answer = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;
  bool _failed = false;
  // Lỗi không có trả lời của server (mất mạng / quá giờ): resolve_order_issue có thể ĐÃ chạy xong (refund + resolved
  // trong 1 transaction) → không được nói 「返金はまだ行われていません」. Gửi lại vẫn an toàn: đã xử lý thì server trả
  // E-ISSUE-409 (audit A03 2026-10-19).
  bool _resultUnknown = false;
  // Nội dung (số tiền + câu trả lời) đã được operator xác nhận ở lần gửi lỗi trước. Chỉ bỏ hộp xác nhận khi gửi lại
  // ĐÚNG nội dung này — đổi số tiền / câu trả lời thì phải xác nhận lại (audit A01 2026-10-19).
  ({int refund, String answer})? _confirmed;
  String? _amountError;
  String? _answerError;

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {})); // nhãn nút đổi theo số tiền
  }

  @override
  void dispose() {
    _amount.dispose();
    _answer.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final issue = widget.issue;
    final refund = parseRefund(_amount.text, issue.refundable);
    final answer = _answer.text.trim();
    setState(() {
      _amountError = refund == null ? l10n.adminIssueErrAmount(formatYen(issue.refundable)) : null;
      _answerError = answer.isEmpty ? l10n.adminIssueErrAnswer : null;
    });
    if (refund == null || answer.isEmpty) return;
    // 返金はお金が動き取り消せない — 注文・店舗・金額を出して確認する。送信エラー後、同じ内容の「もう一度送信する」は確認済みなので聞かない
    final payload = (refund: refund, answer: answer);
    if (payload != _confirmed) {
      final order = orderDisplayNumber(issue.orderId);
      final ok = await showConfirmDialog(
        context,
        title: refund > 0 ? l10n.adminIssueConfirmRefundTitle(formatYen(refund)) : l10n.adminIssueConfirmNoRefundTitle,
        message: refund > 0
            ? l10n.adminIssueConfirmRefundBody(order, issue.restaurantName, formatYen(refund))
            : l10n.adminIssueConfirmNoRefundBody(order, issue.restaurantName),
        cancelLabel: l10n.back,
        confirmLabel: refund > 0 ? l10n.adminIssueConfirmRefundAction : l10n.adminIssueSubmitNoRefund,
        confirmKey: const Key('adminIssueConfirm'),
      );
      if (ok != true || !mounted) return;
    }
    setState(() {
      _sending = true;
      _failed = false;
    });
    try {
      await ref.read(adminTasksGatewayProvider).resolveIssue(issue.id, refund: refund, resolution: answer);
      ref.invalidate(adminIssuesProvider);
      ref.invalidate(adminBadgesProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.adminIssueResolvedToast)));
      _close();
    } catch (e) {
      if (!mounted) return;
      if (rpcErrorCode(e) == 'E-ISSUE-409') {
        // Người khác đã xử lý (Web / admin khác): không gửi lại được — báo và tải lại danh sách
        ref.invalidate(adminIssuesProvider);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.adminIssueErrAlready)));
        _close();
        return;
      }
      // Giữ nguyên số tiền và câu trả lời để gửi lại (bài học 第50回)
      setState(() {
        _failed = true;
        _resultUnknown = e is! PostgrestException;
        _confirmed = payload;
      });
      // Khung lỗi nằm cuối danh sách, sát thanh nút cố định — cuộn tới để đọc được hết
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _close() => widget.onClose != null ? widget.onClose!() : Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final locale = Localizations.localeOf(context).languageCode;
    final issue = widget.issue;
    final noRefund = int.tryParse(_amount.text.trim()) == 0;
    final pickup = toTokyo(issue.plannedTime);

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: eco.textSecondary)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.onClose == null,
        titleSpacing: widget.onClose == null ? 0 : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(orderDisplayNumber(issue.orderId), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            Text(
              '${issueCategoryLabel(issue.category, l10n)}・${inboxTimeLabel(issue.createdAt, DateTime.now(), l10n, locale)}',
              style: TextStyle(fontSize: 12, color: eco.textSecondary),
            ),
          ],
        ),
      ),
      body: AbsorbPointer(
        absorbing: _sending,
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: eco.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: eco.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(issue.message, style: const TextStyle(fontSize: 14, height: 1.6)),
                  Divider(height: 24, color: eco.border),
                  row(l10n.adminIssueOrder, l10n.adminIssueOrderValue(formatYen(issue.pricePaid))),
                  row(
                    l10n.adminIssuePickup,
                    '${DateFormat.MMMd(locale).format(pickup)} ${DateFormat('HH:mm').format(pickup)}${issue.stopName == null ? '' : '・${issue.stopName}'}',
                  ),
                  row(l10n.adminIssueRestaurant, issue.restaurantName),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.adminIssueRefundLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            TextField(
              key: const Key('adminIssueAmount'),
              controller: _amount,
              enabled: !_sending,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
              decoration: InputDecoration(
                prefixText: '¥ ',
                errorText: _amountError,
                suffix: TextButton(
                  key: const Key('adminIssueFull'),
                  onPressed: _sending ? null : () => _amount.text = '${issue.refundable}',
                  child: Text(l10n.adminIssueFull),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              noRefund ? l10n.adminIssueNoRefundHint : l10n.adminIssueRefundHint(formatYen(issue.refundable)),
              key: const Key('adminIssueAmountHint'),
              style: TextStyle(fontSize: 12, color: eco.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(l10n.adminIssueAnswerLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            TextField(
              key: const Key('adminIssueAnswer'),
              controller: _answer,
              enabled: !_sending,
              minLines: 4,
              maxLines: 8,
              maxLength: _maxResolutionLength,
              decoration: InputDecoration(errorText: _answerError),
            ),
            if (_failed)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ErrorBanner(
                  key: const Key('adminIssueError'),
                  title: _resultUnknown ? l10n.adminIssueUnknownTitle : l10n.adminIssueErrorTitle,
                  message: _resultUnknown ? l10n.adminIssueUnknownBody : l10n.adminIssueErrorBody,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            key: const Key('adminIssueSubmit'),
            onPressed: _sending ? null : _submit,
            child: Text(
              _sending
                  ? l10n.adminIssueSending
                  : _failed
                  ? l10n.adminIssueRetry
                  : noRefund
                  ? l10n.adminIssueSubmitNoRefund
                  : l10n.adminIssueSubmitRefund,
            ),
          ),
        ),
      ),
    );
  }
}
