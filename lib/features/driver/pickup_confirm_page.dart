import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/jst_date.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/labeled_field.dart';
import 'driver_gateway.dart';
import 'driver_route_helpers.dart';
import '../../core/haptics.dart';

// Figma: "冷蔵品は10°C以下を確認してください"。サーバー（0042 confirm_surplus_batch_with_temperature）と同じ基準——
// 超えたロットはサーバーが確定数量0で確定し、予約をすべて返金する。画面はその前に確認を求めるだけ（判定の正はサーバー）。
const _coldChainLimit = 10.0;

// SCR-D02 集荷を確認 — 06_画面設計 §SCR-D02 (viết mới ở レビュー第28回), khớp frame Figma 16:16808 (thường) / 137:1199 (温度超過).
// 1 lệnh ghi duy nhất: confirm_surplus_batch_with_temperature (API-026) — chốt số lượng và ghi nhiệt độ
// trong cùng 1 transaction (box-why đầu chương). Lỗi thì không có gì được ghi → bấm lại là gửi lại cả 2.
class PickupConfirmPage extends ConsumerStatefulWidget {
  const PickupConfirmPage({super.key, required this.route, required this.collectionStop, required this.batch});
  final TonightRoute route;
  final DriverStop collectionStop;
  final PickupBatch batch;

  @override
  ConsumerState<PickupConfirmPage> createState() => _PickupConfirmPageState();
}

class _PickupConfirmPageState extends ConsumerState<PickupConfirmPage> {
  late final TextEditingController _qtyController;
  final _tempController = TextEditingController();
  late final List<DriverStop> _candidates;
  late final Set<String> _selected;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: '${widget.batch.estimatedQty}')..addListener(_refresh);
    _tempController.addListener(_refresh);
    _candidates = distributableStopsAfter(widget.route.stops, widget.collectionStop);
    _selected = _candidates.map((s) => s.routeStopId).toSet(); // mặc định chọn hết
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _tempController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  String? get _qtyError => validateConfirmedQty(_qtyController.text, context.l10n);
  String? get _tempError => validateTemperature(_tempController.text, context.l10n);
  bool get _canSubmit => !_submitting && _tempError == null && _qtyError == null && _selected.isNotEmpty;

  bool get _overLimit {
    final temp = double.tryParse(_tempController.text.trim());
    return temp != null && temp > _coldChainLimit;
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (_overLimit) {
      final ok = await showConfirmDialog(
        context,
        title: l10n.rejectPickupDialogTitle,
        message: l10n.rejectPickupDialogBody(_tempController.text.trim()),
        cancelLabel: l10n.cancelButton,
        confirmLabel: l10n.rejectPickupConfirm,
        confirmKey: const Key('rejectPickupConfirm'),
        destructive: true,
      );
      if (ok != true || !mounted) return;
    }
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      final r = await ref.read(driverGatewayProvider).confirmWithTemperature(
            batchId: widget.batch.id,
            confirmedQty: int.parse(_qtyController.text.trim()),
            // Giữ đúng thứ tự tuyến — distribute_qty_to_stops (Chương 03) dồn phần dư vào điểm đầu tiên.
            routeStopIds: _candidates.where((s) => _selected.contains(s.routeStopId)).map((s) => s.routeStopId).toList(),
            celsius: double.parse(_tempController.text.trim()),
          );
      Haptics.success();
      if (!mounted) return;
      Navigator.of(context).pop(
        r.rejectedForTemperature
            ? l10n.pickupRejectedToast(r.refundedOrderCount)
            : l10n.pickupConfirmedToast(int.parse(_qtyController.text.trim()), r.allocatedOrderCount, r.refundedOrderCount),
      );
    } catch (e) {
      Haptics.error();
      if (mounted) {
        setState(() {
          _submitting = false;
          _errorMessage = confirmErrorMessage(e, l10n);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final position = pickupPositionOf(widget.route.stops, widget.collectionStop);
    final overLimit = _overLimit;
    final timeFormat = DateFormat('HH:mm');
    final textTheme = Theme.of(context).textTheme;
    final tempError = _tempController.text.isEmpty ? null : _tempError;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.pickupConfirmTitle),
            Text(l10n.pickupSubtitle(widget.collectionStop.name, position.index, position.total), style: textTheme.bodySmall),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        children: [
          _Box(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.collectionStop.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(widget.collectionStop.address ?? '', style: TextStyle(fontSize: 11, color: context.eco.textSecondary)),
                    ],
                  ),
                ),
                Text(l10n.estimatedMeals(widget.batch.estimatedQty), style: TextStyle(fontSize: 11, color: context.eco.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          LabeledField(
            label: l10n.confirmedQtyLabel,
            child: TextField(
              key: const Key('confirmedQtyField'),
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(suffixText: l10n.mealUnit, errorText: _qtyError),
            ),
          ),
          const SizedBox(height: 14),
          LabeledField(
            label: l10n.coreTemperatureLabel,
            child: TextField(
              key: const Key('temperatureField'),
              controller: _tempController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              // Figma 137:1199: vượt 10℃ → viền ô đỏ. 0042: nút đổi thành 「回収しない」 (lô không được bán).
              decoration: InputDecoration(
                suffixText: '℃',
                errorText: tempError,
                enabledBorder: overLimit
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: context.eco.error),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // "Temperature guideline" của Figma: khung xanh nhạt; vượt chuẩn → khung đỏ nhạt chữ đỏ.
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: overLimit ? context.eco.errorSoft : context.eco.primarySoft,
              border: Border.all(color: overLimit ? context.eco.error.withValues(alpha: 0.4) : context.eco.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.thermostat, size: 20, color: overLimit ? context.eco.error : context.eco.primary),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    overLimit ? l10n.coldChainOverLimit : l10n.coldChainNotice,
                    key: const Key('coldChainNotice'),
                    style: TextStyle(fontSize: 11, height: 1.5, color: overLimit ? context.eco.error : context.eco.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.distributionStopsLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(l10n.distributionStopsHint, style: textTheme.bodySmall),
          const SizedBox(height: 10),
          if (_candidates.isEmpty) ErrorBanner(message: l10n.noDistributableStops),
          for (final (i, stop) in _candidates.indexed) ...[
            _StopRow(
              key: Key('distStop_${stop.routeStopId}'),
              order: i + 1,
              name: stop.name,
              subtitle: l10n.distributionStopSubtitle(
                i == 0 ? l10n.nextStopLabel : l10n.nthStopLabel(i + 1),
                timeFormat.format(toTokyo(stop.plannedTime)),
              ),
              selected: _selected.contains(stop.routeStopId),
              onTap: () => setState(() {
                if (!_selected.remove(stop.routeStopId)) _selected.add(stop.routeStopId);
              }),
            ),
            const SizedBox(height: 8),
          ],
          // "Allocation note" của Figma: khung xanh nhạt + icon info.
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.eco.primarySoft,
              border: Border.all(color: context.eco.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: context.eco.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.selectedStopsCount(_selected.length), style: const TextStyle(fontSize: 12))),
              ],
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            ErrorBanner(key: const Key('pickupError'), message: _errorMessage!),
          ],
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: context.eco.surface,
          border: Border(top: BorderSide(color: context.eco.border)),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: FilledButton(
            key: const Key('confirmPickupButton'),
            style: overLimit ? FilledButton.styleFrom(backgroundColor: context.eco.error) : null,
            onPressed: _canSubmit ? _submit : null,
            child: _submitting
                ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: context.eco.surface))
                : Text(overLimit ? l10n.rejectPickupButton : l10n.confirmPickupButton(_qtyController.text.trim())),
          ),
        ),
      ),
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

// "Stop row" của Figma: ô vuông bo 6 (chọn = nền xanh + dấu check), tên + giờ dự kiến, số thứ tự trong viên.
// Dòng được chọn có viền Primary — chọn/bỏ bằng cách chạm cả dòng.
class _StopRow extends StatelessWidget {
  const _StopRow({
    super.key,
    required this.order,
    required this.name,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final int order;
  final String name;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.eco.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: selected ? context.eco.primary : context.eco.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: selected ? context.eco.primary : context.eco.surface,
                  border: Border.all(color: selected ? context.eco.primary : context.eco.border),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: selected ? Icon(Icons.check, size: 14, color: context.eco.surface) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 11, color: context.eco.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: selected ? context.eco.primarySoft : context.eco.background,
                  border: selected ? null : Border.all(color: context.eco.border),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$order',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected ? context.eco.primary : context.eco.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
