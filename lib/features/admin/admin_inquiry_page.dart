import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/status_badge.dart';
import '../notifications/notification_inbox.dart' show inboxTimeLabel;
import 'admin_gateway.dart';
import '../../widgets/error_banner.dart';
import 'admin_drafts.dart';
import 'admin_tasks_gateway.dart';

// Giới hạn ghi chú nội bộ (0035: admin_note ≤ 2000 ký tự; server: E-INQ-002)
const _maxAdminNoteLength = 2000;
const inquiryStatuses = ['new', 'in_progress', 'done', 'rejected'];

// Cùng cách chia với Web (lib/inquiry-view.ts): customer / other đều là「お問い合わせ」
String inquiryTypeLabel(String type, AppLocalizations l10n) => switch (type) {
  'restaurant' => l10n.adminInqTypePartner,
  'driver' => l10n.adminInqTypeDriver,
  _ => l10n.adminInqTypeContact,
};

String inquiryStatusLabel(String status, AppLocalizations l10n) => switch (status) {
  'in_progress' => l10n.adminInqStatusInProgress,
  'done' => l10n.adminInqStatusDone,
  'rejected' => l10n.adminInqStatusRejected,
  _ => l10n.adminInqStatusNew,
};

BadgeTone inquiryStatusTone(String status) => switch (status) {
  'new' => BadgeTone.warning,
  'in_progress' => BadgeTone.soft,
  'rejected' => BadgeTone.error,
  _ => BadgeTone.neutral,
};

// SCR-A06 問い合わせ: chi tiết + đổi trạng thái / ghi chú (API-033). Mời tạo tài khoản (API-032) giữ trên Web.
class AdminInquiryPage extends ConsumerStatefulWidget {
  // onClose: trong cột chi tiết của iPad — lưu xong thì bỏ chọn thay vì pop
  const AdminInquiryPage({super.key, required this.inquiry, this.onClose});
  final AdminInquiry inquiry;
  final VoidCallback? onClose;

  @override
  ConsumerState<AdminInquiryPage> createState() => _AdminInquiryPageState();
}

class _AdminInquiryPageState extends ConsumerState<AdminInquiryPage> {
  // Nháp đã viết dở lần trước (mở việc khác / xoay iPad) — không có thì lấy giá trị đã lưu (audit A02)
  late final _draftKey = 'inquiry:${widget.inquiry.id}';
  late final _drafts = ref.read(adminDraftsProvider);
  late final _draft = _drafts[_draftKey] as InquiryDraft?;
  late String _status = _draft?.status ?? widget.inquiry.status;
  late final _note = TextEditingController(text: _draft?.note ?? widget.inquiry.adminNote);
  bool _busy = false;
  bool _failed = false;

  void _keepDraft() => _drafts[_draftKey] = (status: _status, note: _note.text);

  @override
  void initState() {
    super.initState();
    _note.addListener(_keepDraft);
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final close = widget.onClose ?? Navigator.of(context).pop;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      final note = _note.text.trim();
      await ref
          .read(adminTasksGatewayProvider)
          .updateInquiry(widget.inquiry.id, status: _status, note: note.isEmpty ? null : note);
      _drafts.remove(_draftKey);
      ref.invalidate(adminInquiriesProvider);
      ref.invalidate(adminBadgesProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminInqSaved)));
      close();
    } catch (_) {
      // Giữ trạng thái / ghi chú đã chọn để lưu lại — báo ngay trong trang (Figma 796:3142)
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final locale = Localizations.localeOf(context).languageCode;
    final q = widget.inquiry;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.onClose == null,
        titleSpacing: widget.onClose == null ? 0 : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.companyName ?? q.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            Text(
              '${inquiryTypeLabel(q.type, l10n)}・${inboxTimeLabel(q.createdAt, DateTime.now(), l10n, locale)}',
              style: TextStyle(fontSize: 12, color: eco.textSecondary),
            ),
          ],
        ),
      ),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: eco.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: eco.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(q.message, style: const TextStyle(fontSize: 14, height: 1.6)),
                  Divider(height: 24, color: eco.border),
                  SelectableText(q.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  SelectableText(q.email, style: TextStyle(fontSize: 13, color: eco.textSecondary)),
                  if (q.phone != null)
                    SelectableText(q.phone!, style: TextStyle(fontSize: 13, color: eco.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.adminInqStatusLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                for (final s in inquiryStatuses)
                  ChoiceChip(
                    key: Key('adminInqStatus-$s'),
                    label: Text(inquiryStatusLabel(s, l10n)),
                    selected: _status == s,
                    onSelected: (_) {
                      setState(() => _status = s);
                      _keepDraft();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.adminInqNoteLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            TextField(
              key: const Key('adminInqNote'),
              controller: _note,
              minLines: 3,
              maxLines: 6,
              maxLength: _maxAdminNoteLength,
            ),
            Text(l10n.adminInqInviteOnWeb, style: TextStyle(fontSize: 12, color: eco.textSecondary)),
            if (_failed)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ErrorBanner(
                  key: const Key('adminInqError'),
                  title: l10n.adminInqErrorTitle,
                  message: l10n.adminInqErrorBody,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            key: const Key('adminInqSave'),
            onPressed: _busy ? null : _save,
            child: _busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_failed ? l10n.adminInqRetrySave : l10n.adminInqSave),
          ),
        ),
      ),
    );
  }
}
