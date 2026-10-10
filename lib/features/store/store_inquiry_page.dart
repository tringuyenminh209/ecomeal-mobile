import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/jst_date.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/status_badge.dart';
import 'store_gateway.dart';

// Giới hạn của inquiries.message (0035: 1〜2000 ký tự)
const _maxInquiryLength = 2000;

// SCR-S06 お問い合わせ（558:452）— API-031 submit-inquiry + lịch sử của chính người gửi. [initialMessage]: mở từ
// 「アカウントの削除を依頼」(S08) thì điền sẵn nội dung.
class StoreInquiryPage extends ConsumerStatefulWidget {
  const StoreInquiryPage({super.key, required this.userId, this.initialMessage});
  final String userId;
  final String? initialMessage;

  @override
  ConsumerState<StoreInquiryPage> createState() => _StoreInquiryPageState();
}

class _StoreInquiryPageState extends ConsumerState<StoreInquiryPage> {
  late final _message = TextEditingController(text: widget.initialMessage);
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = context.l10n;
    final text = _message.text.trim();
    if (text.isEmpty) {
      setState(() => _error = l10n.storeInquiryEmpty);
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref.read(storeGatewayProvider).submitInquiry(text);
      if (!mounted) return;
      _message.clear();
      ref.invalidate(storeInquiriesProvider(widget.userId));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.storeInquirySent)));
    } catch (_) {
      // Giữ nội dung đã nhập để gửi lại (bài học 第50回: thao tác ghi phải cho thấy lỗi)
      if (mounted) setState(() => _error = l10n.storeInquirySendFailed);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final locale = Localizations.localeOf(context).languageCode;
    final history = ref.watch(storeInquiriesProvider(widget.userId));
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.storeInquiryTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            Text(l10n.storeInquirySubtitle, style: TextStyle(fontSize: 12, color: eco.textSecondary)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(l10n.storeInquiryLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (_error != null) ...[
            ErrorBanner(key: const Key('storeInquiryError'), message: _error!),
            const SizedBox(height: 8),
          ],
          TextField(
            key: const Key('storeInquiryField'),
            controller: _message,
            enabled: !_sending,
            minLines: 5,
            maxLines: 10,
            maxLength: _maxInquiryLength,
          ),
          Text(l10n.storeInquiryHint, style: TextStyle(fontSize: 12, color: eco.textSecondary)),
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('storeInquirySend'),
            onPressed: _sending ? null : _send,
            child: _sending
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.storeInquirySend),
          ),
          const SizedBox(height: 24),
          Text(l10n.storeInquiryHistory, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          history.when(
            loading: () => const SkeletonPulse(child: SkeletonBox(height: 120, radius: 16)),
            error: (_, _) => ErrorBanner(
              message: l10n.storeLoadErrorBody,
              retryLabel: l10n.storeReload,
              onRetry: () => ref.invalidate(storeInquiriesProvider(widget.userId)),
            ),
            data: (list) => list.isEmpty
                ? Text(l10n.storeInquiryHistoryEmpty, style: TextStyle(fontSize: 13, color: eco.textSecondary))
                : Container(
                    decoration: BoxDecoration(
                      color: eco.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: eco.border),
                    ),
                    child: Column(
                      children: [
                        for (final (i, q) in list.indexed) ...[
                          if (i > 0) Divider(height: 1, color: eco.border),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      DateFormat.MMMd(locale).format(DateTime.parse(dateInTokyo(q.createdAt))),
                                      style: TextStyle(fontSize: 12, color: eco.textSecondary),
                                    ),
                                    const SizedBox(width: 8),
                                    StatusBadge(
                                      label: switch (q.status) {
                                        InquiryStatus.received => l10n.storeInquiryStatusNew,
                                        InquiryStatus.inProgress => l10n.storeInquiryStatusInProgress,
                                        InquiryStatus.done => l10n.storeInquiryStatusDone,
                                        InquiryStatus.rejected => l10n.storeInquiryStatusRejected,
                                      },
                                      tone: switch (q.status) {
                                        InquiryStatus.received => BadgeTone.warning,
                                        InquiryStatus.inProgress => BadgeTone.soft,
                                        _ => BadgeTone.neutral,
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  q.message,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
