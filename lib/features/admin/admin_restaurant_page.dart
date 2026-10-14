import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/jst_date.dart';
import '../../core/theme/app_theme.dart';
import '../../core/wide_layout.dart';
import '../../core/yen.dart';
import '../../l10n/l10n.dart';
import '../../widgets/confirm_dialog.dart';
import '../notifications/notification_inbox.dart' show inboxTimeLabel;
import '../store/store_gateway.dart';
import '../../widgets/error_banner.dart';
import 'admin_gateway.dart';
import 'admin_tasks_gateway.dart';

// Giới hạn lý do từ chối (0036: 1〜500 ký tự sau khi bỏ khoảng trắng hai đầu; server: E-REST-012)
const maxRejectionReasonLength = 500;
// 店舗の詳細に出す精算の件数（新しい順）
const recentSettlementCount = 3;

// Mở PDF bảo hiểm PL bằng trình duyệt ngoài (signed URL 5 phút). Test thay bằng hàm giả.
final openExternalUrlProvider = Provider<Future<bool> Function(String url)>((ref) {
  return (url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
});

// SCR-A03 審査の詳細（563:1259）/ 却下の理由（シート）（563:1325）
// 2026-10-13（SCR-W21 と同じ内容）: 担当者（メール）はどの状態でも、承認済みなら今月の売上・評価・最近の出品・精算も出す。見るだけ
class AdminRestaurantPage extends ConsumerStatefulWidget {
  // onClose: trong cột chi tiết của iPad — xong thì bỏ chọn thay vì pop
  const AdminRestaurantPage({super.key, required this.restaurant, this.onClose});
  final AdminRestaurant restaurant;
  final VoidCallback? onClose;

  @override
  ConsumerState<AdminRestaurantPage> createState() => _AdminRestaurantPageState();
}

class _AdminRestaurantPageState extends ConsumerState<AdminRestaurantPage> {
  bool _busy = false;
  // Lần gửi trước thất bại: true = 承認, false = 却下 (lý do giữ ở _lastReason để gửi lại không phải nhập lại)
  bool? _failedApprove;
  String? _lastReason;

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
    final close = widget.onClose ?? Navigator.of(context).pop;
    final r = widget.restaurant;
    setState(() {
      _busy = true;
      _failedApprove = null;
      _lastReason = reason;
    });
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
      close();
    } catch (_) {
      // Báo ngay trong trang (Figma 797:3990 承認 / 802:4367 却下) — 却下 thì giữ lý do để gửi lại
      if (mounted) setState(() => _failedApprove = approve);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // 承認は取り消せず通知メールも飛ぶ — 対象の店舗名を出して確認してから実行する
  Future<void> _approve() async {
    final l10n = context.l10n;
    final ok = await showConfirmDialog(
      context,
      title: l10n.adminRestApproveConfirmTitle(widget.restaurant.name),
      message: l10n.adminRestApproveConfirmBody,
      cancelLabel: l10n.back,
      confirmLabel: l10n.adminRestApprove,
      confirmKey: const Key('adminRestApproveConfirm'),
    );
    if (ok == true && mounted) await _decide(approve: true);
  }

  Future<void> _reject() async {
    final l10n = context.l10n;
    final reason = await showAdminReasonSheet(
      context,
      AdminReasonSheet(
        title: l10n.adminRestRejectTitle,
        note: l10n.adminRestRejectNote,
        presets: [l10n.adminRestReasonPl, l10n.adminRestReasonContact, l10n.adminRestReasonOther],
        sendLabel: l10n.adminRestRejectSend,
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
        automaticallyImplyLeading: widget.onClose == null,
        titleSpacing: widget.onClose == null ? 0 : null,
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
          const SizedBox(height: 20),
          _MembersSection(restaurantId: r.id),
          if (r.isApproved) ...[
            _MonthSection(restaurantId: r.id),
            _RatingsSection(restaurantId: r.id),
            _BatchesSection(restaurantId: r.id),
            _SettlementsSection(restaurantId: r.id),
          ],
          if (_failedApprove != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ErrorBanner(
                key: const Key('adminRestError'),
                title: l10n.adminIssueErrorTitle,
                message: _failedApprove! ? l10n.adminRestErrorBody : l10n.adminRestRejectErrorBody,
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
                        // 却下の送信に失敗: 同じ理由でそのまま再送
                        onPressed: _busy
                            ? null
                            : _failedApprove == false
                            ? () => _decide(approve: false, reason: _lastReason)
                            : _reject,
                        child: Text(_failedApprove == false ? l10n.adminRestRetryReject : l10n.adminRestReject),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        key: const Key('adminRestApprove'),
                        onPressed: _busy ? null : _approve,
                        child: Text(_failedApprove == true ? l10n.adminRestRetryApprove : l10n.adminRestApprove),
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
// 1 mục: tiêu đề + thẻ; dữ liệu async → đang tải / lỗi / nội dung
class _Section<T> extends StatelessWidget {
  const _Section({required this.title, required this.value, required this.builder});
  final String title;
  final AsyncValue<T> value;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) {
    final eco = context.eco;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: eco.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: eco.border),
            ),
            child: value.when(
              data: builder,
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (_, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(context.l10n.errorLoad, style: TextStyle(fontSize: 13, color: eco.error)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Dòng nhãn trái / giá trị phải (giống bảng thông tin ở trên)
class _Line extends StatelessWidget {
  const _Line(this.label, this.value, {this.trailing});
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 13, color: context.eco.textSecondary)),
        ),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    ),
  );
}

Widget _empty(BuildContext context, String text) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: Text(text, style: TextStyle(fontSize: 13, color: context.eco.textSecondary)),
);

Widget _tag(BuildContext context, String text, {required bool strong}) {
  final eco = context.eco;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(color: strong ? eco.primarySoft : eco.chip, borderRadius: BorderRadius.circular(999)),
    child: Text(
      text,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: strong ? eco.primary : eco.textSecondary),
    ),
  );
}

class _MembersSection extends ConsumerWidget {
  const _MembersSection({required this.restaurantId});
  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final eco = context.eco;
    return _Section<List<AdminRestaurantMember>>(
      title: l10n.adminRestMembers,
      value: ref.watch(adminRestaurantMembersProvider(restaurantId)),
      builder: (members) => members.isEmpty
          ? _empty(context, l10n.adminRestNoMembers)
          : Column(
              children: [
                for (final m in members)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                              if (m.email != null)
                                InkWell(
                                  onTap: () => ref.read(openExternalUrlProvider)('mailto:${m.email}'),
                                  child: Text(m.email!, style: TextStyle(fontSize: 13, color: eco.primary)),
                                ),
                            ],
                          ),
                        ),
                        _tag(context, m.isOwner ? l10n.adminRestOwner : l10n.adminRestStaff, strong: m.isOwner),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _MonthSection extends ConsumerWidget {
  const _MonthSection({required this.restaurantId});
  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return _Section<StoreRevenue>(
      title: l10n.adminRestMonth,
      value: ref.watch(storeMonthRevenueProvider(restaurantId)),
      builder: (m) => Column(
        children: [
          _Line(l10n.adminRestSales, formatYen(m.revenue)),
          _Line(l10n.adminRestPayout, formatYen(m.payout)),
          _Line(l10n.adminRestSold, l10n.mealsCount(m.orders)),
          _Line(l10n.adminRestShare, l10n.adminRestSharePct(NumberFormat('0.##').format(m.sharePct))),
        ],
      ),
    );
  }
}

class _RatingsSection extends ConsumerWidget {
  const _RatingsSection({required this.restaurantId});
  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return _Section<StoreRatings>(
      title: l10n.adminRestRatings,
      value: ref.watch(storeRatingsProvider(restaurantId)),
      builder: (r) => r.count == 0 || r.average == null
          ? _empty(context, l10n.adminRestNoRatings)
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.adminRestRatingsValue(r.average!.toStringAsFixed(1), r.count),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
    );
  }
}

class _BatchesSection extends ConsumerWidget {
  const _BatchesSection({required this.restaurantId});
  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    return _Section<List<AdminBatch>>(
      title: l10n.adminRestBatches,
      value: ref.watch(adminRecentBatchesProvider(restaurantId)),
      builder: (batches) => batches.isEmpty
          ? _empty(context, l10n.adminRestNoBatches)
          : Column(
              children: [
                for (final b in batches)
                  _Line(
                    formatServiceDate(dateInTokyo(b.sellByAt), locale),
                    l10n.adminRestBatchLine(b.quantity, formatYen(b.unitPrice)),
                    trailing: _tag(
                      context,
                      b.isConfirmed ? l10n.adminRestBatchConfirmed : l10n.adminRestBatchEstimated,
                      strong: b.isConfirmed,
                    ),
                  ),
              ],
            ),
    );
  }
}

class _SettlementsSection extends ConsumerWidget {
  const _SettlementsSection({required this.restaurantId});
  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    return _Section<List<StoreSettlement>>(
      title: l10n.adminRestSettlements,
      value: ref.watch(storeSettlementsProvider(restaurantId)),
      builder: (rows) => rows.isEmpty
          ? _empty(context, l10n.adminRestNoSettlements)
          : Column(
              children: [
                for (final s in rows.take(recentSettlementCount))
                  _Line(
                    DateFormat.yMMM(locale).format(DateTime.parse(s.periodMonth)),
                    formatYen(s.payout),
                    trailing: _tag(
                      context,
                      s.paidAt != null ? l10n.storeSettlementPaid : l10n.adminRestSettlementConfirmed,
                      strong: s.paidAt != null,
                    ),
                  ),
              ],
            ),
    );
  }
}

// Lý do (却下・差し戻し・運行の連絡の対応): iPad ngang hiện giữa màn như dialog (Figma 797:3705), điện thoại là bottom sheet
Future<String?> showAdminReasonSheet(BuildContext context, AdminReasonSheet sheet) {
  if (isWideLayout(context)) {
    return showDialog<String>(
      context: context,
      builder: (_) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: sheet),
      ),
    );
  }
  return showModalBottomSheet<String>(context: context, isScrollControlled: true, builder: (_) => sheet);
}

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
