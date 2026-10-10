import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../notifications/notification_inbox.dart' show inboxTimeLabel;
import 'admin_gateway.dart';
import 'admin_tasks_gateway.dart';

// Giới hạn lý do từ chối (0036: 1〜500 ký tự sau khi bỏ khoảng trắng hai đầu; server: E-REST-012)
const maxRejectionReasonLength = 500;

// Mở PDF bảo hiểm PL bằng trình duyệt ngoài (signed URL 5 phút). Test thay bằng hàm giả.
final openExternalUrlProvider = Provider<Future<bool> Function(String url)>((ref) {
  return (url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
});

// SCR-A03 審査の詳細（563:1259）/ 却下の理由（シート）（563:1325）
class AdminRestaurantPage extends ConsumerStatefulWidget {
  const AdminRestaurantPage({super.key, required this.restaurant});
  final AdminRestaurant restaurant;

  @override
  ConsumerState<AdminRestaurantPage> createState() => _AdminRestaurantPageState();
}

class _AdminRestaurantPageState extends ConsumerState<AdminRestaurantPage> {
  bool _busy = false;

  Future<void> _openPl(String path) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = context.l10n.adminRestPlFailed;
    var opened = false;
    try {
      final url = await ref.read(adminTasksGatewayProvider).plDocUrl(path);
      opened = await ref.read(openExternalUrlProvider)(url);
    } catch (_) {}
    if (!opened) messenger.showSnackBar(SnackBar(content: Text(failed)));
  }

  Future<void> _decide({required bool approve, String? reason}) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final r = widget.restaurant;
    setState(() => _busy = true);
    try {
      final notified = await ref
          .read(adminTasksGatewayProvider)
          .decideRestaurant(r.id, approve: approve, reason: reason);
      ref.invalidate(adminRestaurantsProvider);
      ref.invalidate(adminBadgesProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            notified
                ? l10n.adminRestDecided(r.name, approve ? l10n.adminRestApproved : l10n.adminRestRejected)
                : l10n.adminRestNotifyFailed,
          ),
        ),
      );
      navigator.pop();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminSaveFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject() async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AdminReasonSheet(
        title: context.l10n.adminRestRejectTitle,
        note: context.l10n.adminRestRejectNote,
        presets: [
          context.l10n.adminRestReasonPl,
          context.l10n.adminRestReasonContact,
          context.l10n.adminRestReasonOther,
        ],
        sendLabel: context.l10n.adminRestRejectSend,
      ),
    );
    if (reason != null) await _decide(approve: false, reason: reason);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final locale = Localizations.localeOf(context).languageCode;
    final r = widget.restaurant;
    final closing = r.closingTime.length >= 5 ? r.closingTime.substring(0, 5) : r.closingTime;

    Widget row(String label, String? value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(fontSize: 13, color: eco.textSecondary)),
          ),
          Expanded(
            child: Text(
              value ?? '—',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            Text(
              l10n.adminRestApplied(inboxTimeLabel(r.createdAt, DateTime.now(), l10n, locale)),
              style: TextStyle(fontSize: 12, color: eco.textSecondary),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: eco.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: eco.border),
            ),
            child: Column(
              children: [
                row(l10n.adminRestName, r.nameKana == null ? r.name : '${r.name}（${r.nameKana}）'),
                row(l10n.adminRestAddress, r.address),
                row(l10n.adminRestContact, r.contact),
                row(l10n.adminRestClosing, closing),
                row(l10n.adminRestApplicant, r.applicantName),
                if (r.rejectedAt != null) row(l10n.adminRestRejectionReason, r.rejectionReason),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.adminRestPlDoc, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (r.plDocPath == null)
            Text(l10n.adminRestNoPl, style: TextStyle(fontSize: 13, color: eco.textSecondary))
          else
            Material(
              color: eco.surface,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                key: const Key('adminRestPl'),
                borderRadius: BorderRadius.circular(16),
                onTap: () => _openPl(r.plDocPath!),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: eco.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf_outlined, size: 32, color: eco.textSecondary),
                      const SizedBox(height: 6),
                      Text(
                        l10n.adminRestPlOpen,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: eco.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: !r.isPending
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        key: const Key('adminRestReject'),
                        onPressed: _busy ? null : _reject,
                        child: Text(l10n.adminRestReject),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        key: const Key('adminRestApprove'),
                        onPressed: _busy ? null : () => _decide(approve: true),
                        child: Text(l10n.adminRestApprove),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// Lý do từ chối / trả lại (SCR-A03 quán, SCR-A05 bằng lái): câu mẫu tuỳ chọn + ô tự do. Chọn mẫu thì điền sẵn câu
// (vẫn sửa được; mẫu cuối là「その他」không điền). Trả về lý do đã bỏ khoảng trắng, hoặc null nếu đóng.
class AdminReasonSheet extends StatefulWidget {
  const AdminReasonSheet({
    super.key,
    required this.title,
    required this.note,
    required this.sendLabel,
    this.presets = const [],
  });
  final String title;
  final String note;
  final String sendLabel;
  final List<String> presets;

  @override
  State<AdminReasonSheet> createState() => _AdminReasonSheetState();
}

class _AdminReasonSheetState extends State<AdminReasonSheet> {
  final _text = TextEditingController();
  int? _preset;
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final presets = widget.presets;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(widget.note, style: TextStyle(fontSize: 12, color: eco.textSecondary)),
            const SizedBox(height: 8),
            for (final (i, p) in presets.indexed)
              RadioListTile<int>(
                key: Key('adminRejectPreset-$i'),
                value: i,
                groupValue: _preset,
                contentPadding: EdgeInsets.zero,
                title: Text(p, style: const TextStyle(fontSize: 14)),
                onChanged: (v) => setState(() {
                  _preset = v;
                  // 「その他」以外は文面をそのまま入れる（編集可）
                  if (v != null && v < presets.length - 1) _text.text = presets[v];
                }),
              ),
            TextField(
              key: const Key('adminRejectReason'),
              controller: _text,
              minLines: 3,
              maxLines: 6,
              maxLength: maxRejectionReasonLength,
              decoration: InputDecoration(errorText: _error),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('adminRejectSend'),
              style: FilledButton.styleFrom(backgroundColor: eco.error),
              onPressed: () {
                final reason = _text.text.trim();
                if (reason.isEmpty || reason.length > maxRejectionReasonLength) {
                  setState(() => _error = l10n.adminRestErrReason);
                  return;
                }
                Navigator.pop(context, reason);
              },
              child: Text(widget.sendLabel),
            ),
          ],
        ),
      ),
    );
  }
}
