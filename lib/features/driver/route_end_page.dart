import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:uuid/uuid.dart';
import '../../core/jst_date.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/labeled_field.dart';
import '../../widgets/state_panel.dart';
import '../../widgets/status_badge.dart';
import 'driver_gateway.dart';
import 'handoff_gateway.dart';
import 'handoff_helpers.dart';
import '../../widgets/skeleton.dart';

final confirmedBatchesProvider = FutureProvider.autoDispose.family<List<DonationBatch>, String>((ref, routeId) {
  return ref.watch(handoffGatewayProvider).fetchConfirmedBatches(routeId);
});

// SCR-D04 運行を終了 — 06_画面設計 §SCR-D04 (viết mới ở レビュー第29回), khớp frame Figma 16:16927.
// Chức năng duy nhất có API: ghi số suất còn thừa đem tặng (FUNC-020, API-016 record_donation).
class RouteEndPage extends ConsumerWidget {
  const RouteEndPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(tonightRouteProvider).valueOrNull;
    final l10n = context.l10n;
    return Scaffold(
      // Figma: "運行を終了" 20 Bold + dòng phụ "biển số • giờ hiện tại"
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.routeEndTitle),
            if (route != null)
              Text(
                '${route.truck.plateNumber} • ${DateFormat('HH:mm').format(toTokyo(DateTime.now()))}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
      body: route == null || route.routeId == null
          ? Center(child: StatePanel(icon: Icons.route_outlined, title: l10n.noRouteTonight))
          // レビュー第30回: còn điểm bán chưa 出発 → form khoá (server cũng chặn bằng E-INV-004)
          : _RouteEndBody(route: route, locked: openSalesStopCount(route.stops) > 0),
    );
  }
}

class _RouteEndBody extends ConsumerStatefulWidget {
  const _RouteEndBody({required this.route, required this.locked});
  final TonightRoute route;
  final bool locked;

  @override
  ConsumerState<_RouteEndBody> createState() => _RouteEndBodyState();
}

// Giữ state của form ở đây (không ở trong thẻ 寄付) vì nút "寄付を記録する" nằm ở thanh dính đáy màn
// hình như Figma, ngoài vùng cuộn.
class _RouteEndBodyState extends ConsumerState<_RouteEndBody> {
  final _qtyController = TextEditingController();
  final _noteController = TextEditingController();
  String? _batchId;
  bool _handedOver = false; // Figma: "寄付先への引き渡しを確認しました" — chỉ là xác nhận thao tác, không lưu DB
  bool _saving = false;
  String? _resultMessage;
  bool _resultIsError = false;
  // Audit D04: khoá của lần ghi này — giữ qua các lần gửi lại tới khi server xác nhận (ghi mới hoặc replayed).
  String _requestId = const Uuid().v4();
  bool _resultUnknown = false; // mất phản hồi: chưa biết đã ghi hay chưa

  @override
  void initState() {
    super.initState();
    _qtyController.addListener(() => setState(() {}));
    _noteController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  DonationBatch? get _selectedBatch => ref
      .read(confirmedBatchesProvider(widget.route.routeId!))
      .valueOrNull
      ?.where((b) => b.id == _batchId)
      .firstOrNull;

  // Audit D06: ngoài kiểm số nguyên dương, chặn trước khi gửi nếu vượt số còn lại server đã trả (server vẫn kiểm lần cuối)
  String? _qtyError(AppLocalizations l10n) {
    final base = validateDonationQty(_qtyController.text, l10n);
    if (base != null) return base;
    final remaining = _selectedBatch?.remainingQty;
    final qty = int.tryParse(_qtyController.text.trim());
    if (remaining != null && qty != null && qty > remaining) return l10n.donationQtyOverRemaining(remaining);
    return null;
  }

  bool get _canSubmit =>
      !widget.locked &&
      !_saving &&
      _batchId != null &&
      _qtyError(context.l10n) == null &&
      _noteController.text.trim().isNotEmpty &&
      _handedOver;

  Future<void> _submit() async {
    final l10n = context.l10n;
    setState(() {
      _saving = true;
      _resultMessage = null;
      _resultUnknown = false;
    });
    try {
      final result = await ref.read(handoffGatewayProvider).recordDonation(
            batchId: _batchId!,
            quantity: int.parse(_qtyController.text.trim()),
            note: _noteController.text.trim(),
            requestId: _requestId,
          );
      if (!mounted) return;
      ref.invalidate(confirmedBatchesProvider(widget.route.routeId!)); // số còn lại mới cho lần ghi sau
      setState(() {
        _requestId = const Uuid().v4(); // thao tác đã xong → lần ghi sau là việc mới
        _resultIsError = false;
        _resultMessage = result.replayed ? l10n.donationReplayed(result.remaining) : l10n.donationRecorded(result.remaining);
        _qtyController.clear();
        _handedOver = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          // Có mã lỗi từ server = chắc chắn chưa ghi (báo lý do như cũ). Không có (mất mạng) = chưa rõ → giữ khoá + nhập liệu.
          _resultUnknown = e is! PostgrestException;
          _resultIsError = true;
          _resultMessage = _resultUnknown ? null : handoffErrorMessage(e, l10n);
        });
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            children: [
              if (!widget.locked) ...[const _Completed(), const SizedBox(height: 14)],
              _RouteSummary(route: widget.route),
              const SizedBox(height: 14),
              _donationCard(context),
            ],
          ),
        ),
        Container(
          color: context.eco.surface,
          child: SafeArea(
            minimum: const EdgeInsets.all(16),
            child: FilledButton(
              key: const Key('recordDonationButton'),
              onPressed: _canSubmit ? _submit : null,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: _saving
                  ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: context.eco.surface))
                  : Text(context.l10n.recordDonationButton),
            ),
          ),
        ),
      ],
    );
  }

  // 「梅田収集地点（確定 28食・残り 6食）」/ hết thì 「…（残りなし）」 (Figma 16:16927, audit D06)
  String _labelOf(DonationBatch batch, AppLocalizations l10n) {
    final name = widget.route.stops
            .where((s) => s.type == 'restaurant' && s.restaurantId == batch.restaurantId)
            .firstOrNull
            ?.name ??
        l10n.batchLabel;
    return batch.remainingQty > 0
        ? l10n.donationBatchOption(name, batch.confirmedQty, batch.remainingQty)
        : l10n.donationBatchOptionEmpty(name);
  }

  Widget _donationCard(BuildContext context) {
    final batchesAsync = ref.watch(confirmedBatchesProvider(widget.route.routeId!));
    final l10n = context.l10n;
    // Audit D03: đang lưu thì khoá cả lô / số lượng / nơi nhận — trước đây vẫn sửa được, và lúc lưu xong việc xoá ô số
    // lượng xoá luôn số vừa nhập cho lần sau.
    final editable = !widget.locked && !_saving;
    return _Box(
      child: batchesAsync.when(
        loading: () => const SkeletonList(heights: [20, 48, 48], padding: EdgeInsets.zero, scrollable: false),
        error: (_, __) => ErrorBanner(
          message: l10n.errorLoadBody,
          retryLabel: l10n.errorLoadRetry,
          onRetry: () => ref.invalidate(confirmedBatchesProvider(widget.route.routeId!)),
        ),
        data: (batches) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(l10n.donationTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
                StatusBadge(label: l10n.optionalBadge, tone: BadgeTone.neutral),
              ],
            ),
            const SizedBox(height: 6),
            // 0021 expire_stale_orders: 寄付しなかった分は最後の出発の1時間後に「expired」（売れ残り・廃棄）として自動記録 — 寄付の記録はそれまでに
            Text(l10n.leftoverAutoRecordNote, key: const Key('leftoverAutoRecordNote'), style: TextStyle(fontSize: 12, height: 1.5, color: context.eco.textSecondary)),
            const SizedBox(height: 12),
            if (widget.locked) ...[
              ErrorBanner(key: const Key('donationLockedNotice'), message: l10n.donationLockedNotice),
              const SizedBox(height: 12),
            ],
            if (batches.isEmpty)
              Text(l10n.noConfirmedBatches, style: TextStyle(fontSize: 13, color: context.eco.textSecondary))
            else ...[
              LabeledField(
                label: l10n.batchLabel,
                child: DropdownButtonFormField<String>(
                  key: const Key('donationBatchField'),
                  value: _batchId,
                  isExpanded: true, // tên điểm thu gom dài → không tràn ngang trên màn 360dp
                  items: [
                    for (final b in batches)
                      DropdownMenuItem(
                        value: b.id,
                        enabled: b.remainingQty > 0, // hết thì không chọn được
                        child: Text(_labelOf(b, l10n), overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: editable ? (v) => setState(() => _batchId = v) : null,
                ),
              ),
              const SizedBox(height: 12),
              LabeledField(
                label: l10n.donationQtyLabel,
                child: TextField(
                  key: const Key('donationQtyField'),
                  controller: _qtyController,
                  enabled: editable,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    suffixText: l10n.mealUnit,
                    errorText: _qtyController.text.isEmpty ? null : _qtyError(l10n),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              LabeledField(
                label: l10n.donationRecipientLabel,
                child: TextField(
                  key: const Key('donationNoteField'),
                  controller: _noteController,
                  enabled: editable,
                  decoration: InputDecoration(hintText: l10n.donationRecipientHint),
                ),
              ),
              const SizedBox(height: 4),
              CheckboxListTile(
                key: const Key('handedOverCheckbox'),
                value: _handedOver,
                onChanged: editable ? (v) => setState(() => _handedOver = v ?? false) : null,
                title: Text(l10n.donationHandedOverCheck, style: const TextStyle(fontSize: 11)),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              if (_resultUnknown)
                ErrorBanner(
                  key: const Key('donationUnknownBanner'),
                  title: l10n.donationUnknownTitle,
                  message: l10n.donationUnknownBody,
                ),
              if (_resultMessage != null)
                Text(
                  _resultMessage!,
                  key: const Key('donationResult'),
                  style: TextStyle(fontSize: 12, color: _resultIsError ? context.eco.error : context.eco.primary),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// Figma "Success symbol": vòng tròn Primary nhạt 72px có dấu check + câu cảm ơn 20 Bold.
// Chỉ hiện khi mọi điểm bán đã 出発 (lúc đó tuyến mới thật sự xong).
class _Completed extends StatelessWidget {
  const _Completed();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(color: context.eco.primarySoft, shape: BoxShape.circle),
          child: Icon(Icons.check_rounded, size: 34, color: context.eco.primary),
        ),
        const SizedBox(height: 9),
        Text(
          context.l10n.routeEndThanks,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.eco.surface,
        border: Border.all(color: context.eco.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _RouteSummary extends StatelessWidget {
  const _RouteSummary({required this.route});
  final TonightRoute route;

  @override
  Widget build(BuildContext context) {
    // Số suất đã giao tối nay = tổng picked_up (đặt trước + walk-up) ở mọi điểm — cùng nguồn với D01.
    final sold = route.stops.fold<int>(0, (sum, s) => sum + s.pickedUpCount);
    // Chỉ điểm bán: điểm thu gom không có thao tác "出発" ở tab 販売 nên không được tính là "chưa xong".
    final salesStops = route.stops.where((s) => s.type == 'public').length;
    final open = openSalesStopCount(route.stops);
    final l10n = context.l10n;
    return _Box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.routeSummaryTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _Metric(label: l10n.driverTabSales, value: l10n.mealsCount(sold))),
              const SizedBox(width: 12),
              Expanded(child: _Metric(label: l10n.salesStopsLabel, value: '${salesStops - open} / $salesStops')),
            ],
          ),
          if (open > 0) ...[
            const SizedBox(height: 12),
            // close_route_stop chưa chạy ở các điểm này → đơn chờ ở đó sẽ do Cron (BR-004) xử lý sau 15 phút.
            ErrorBanner(key: const Key('openStopsWarning'), message: l10n.openStopsWarning(open)),
          ],
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: context.eco.textSecondary)),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
