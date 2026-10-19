import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/jst_date.dart';
import '../../core/theme/app_theme.dart';
import '../../core/yen.dart';
import '../../l10n/l10n.dart';
import '../../widgets/batch_photo.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/state_panel.dart';
import '../../widgets/status_badge.dart';
import 'store_gateway.dart';
import 'store_register_logic.dart' show storeClock;
import '../../core/wide_layout.dart';
import 'store_home_page.dart' show storeBatchStatusLabel, storeBatchStatusTone;

String _hm(DateTime t) => DateFormat('HH:mm').format(toTokyo(t));

// Lô chưa kết thúc thì server còn đổi: 概算 → tài xế xác nhận (販売中), số còn lại theo đơn đặt / giao → tải lại định kỳ
// (nhãn「自動更新」của Figma). Mỗi nhịp cũng dựng lại màn để nhãn theo giờ (販売中 → 終了) đổi dù không ai chạm màn —
// đồng hồ trôi không tạo sự kiện ở DB (audit S03 2026-10-19).
const storeBatchRefreshInterval = Duration(seconds: 30);

// SCR-S03 ロット詳細 — Figma 販売中 555:319 / 回収前 555:453
class StoreBatchDetailPage extends ConsumerStatefulWidget {
  const StoreBatchDetailPage({super.key, required this.restaurantId, required this.batchId});
  final String restaurantId;
  final String batchId;

  @override
  ConsumerState<StoreBatchDetailPage> createState() => _StoreBatchDetailPageState();
}

class _StoreBatchDetailPageState extends ConsumerState<StoreBatchDetailPage> with WidgetsBindingObserver {
  Timer? _timer;

  ({String restaurantId, String batchId}) get _key => (restaurantId: widget.restaurantId, batchId: widget.batchId);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(storeBatchRefreshInterval, (_) {
      final batch = ref.read(storeBatchProvider(_key)).valueOrNull;
      if (batch != null && batch.statusAt(storeClock()) != StoreBatchStatus.ended) {
        ref.invalidate(storeBatchProvider(_key));
      }
      setState(() {}); // nhãn theo giờ (statusAt) tính lại
    });
  }

  // Quay lại app từ nền: timer có thể đã lỡ nhiều nhịp → tải lại ngay
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ref.invalidate(storeBatchProvider(_key));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final locale = Localizations.localeOf(context).languageCode;
    final batch = ref.watch(storeBatchProvider(_key));
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.storeBatchDetailTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            if (batch.valueOrNull != null)
              Text(
                formatServiceDate(batch.value!.serviceDate, locale),
                style: TextStyle(fontSize: 12, color: eco.textSecondary),
              ),
          ],
        ),
      ),
      body: batch.when(
        loading: () => const SkeletonList(heights: [150, 220, 200]),
        error: (_, _) => Center(
          child: StatePanel.error(
            title: l10n.storeLoadErrorTitle,
            message: l10n.storeLoadErrorBody,
            actionLabel: l10n.storeReload,
            onAction: () => ref.invalidate(storeBatchProvider(_key)),
          ),
        ),
        data: (b) => b == null
            ? Center(
                child: StatePanel(icon: Icons.search_off_rounded, title: l10n.storeBatchNotFound),
              )
            : RefreshIndicator(
                onRefresh: () => ref.refresh(storeBatchProvider(_key).future),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    if (isWideLayout(context))
                      // iPad ngang (Figma 559:1083): lô + tiến trình bên trái, điểm nhận bên phải
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _SummaryCard(batch: b),
                                const SizedBox(height: 16),
                                _ProgressCard(batch: b),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(child: _stopsOrNote(b, l10n, eco)),
                        ],
                      )
                    else ...[
                      _SummaryCard(batch: b),
                      const SizedBox(height: 16),
                      _ProgressCard(batch: b),
                      const SizedBox(height: 16),
                      _stopsOrNote(b, l10n, eco),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

// Đã lấy hàng: số còn lại theo điểm nhận; chưa lấy: giải thích cách xử lý khi thiếu hàng
Widget _stopsOrNote(StoreBatch b, AppLocalizations l10n, EcoPalette eco) => b.isConfirmed
    ? _StopsCard(batch: b)
    : Text(l10n.storeEstimatedNote, style: TextStyle(fontSize: 12, height: 1.6, color: eco.textSecondary));

BoxDecoration _card(EcoPalette eco) => BoxDecoration(
  color: eco.surface,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: eco.border),
);

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.batch});
  final StoreBatch batch;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final status = batch.statusAt(storeClock());
    final planned = batch.collectionPlannedAt;
    final stats = batch.isConfirmed
        ? [
            (l10n.storeStatConfirmed, '${batch.confirmedQty ?? batch.estimatedQty}', false),
            (l10n.storeStatReserved, '${batch.reservedCount}', false),
            (l10n.storeStatPickedUp, '${batch.pickedUpCount}', true),
            (l10n.storeStatRemaining, '${batch.remainingQty}', false),
          ]
        : [
            (l10n.storeStatEstimated, '${batch.estimatedQty}', false),
            (l10n.storeStatReserved, '${batch.reservedCount}', false),
            (l10n.storeStatPickedUp, '—', false),
            (l10n.storeStatCollection, planned == null ? '—' : _hm(planned), false),
          ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _card(eco),
      child: Column(
        children: [
          Row(
            children: [
              BatchPhoto(photoUrl: batch.photoUrl, width: 64, height: 64, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusBadge(label: storeBatchStatusLabel(status, l10n), tone: storeBatchStatusTone(status)),
                    const SizedBox(height: 6),
                    Text(
                      l10n.storeBatchPriceLine(formatYen(batch.unitPrice), _hm(batch.sellByAt)),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    if (batch.allergens.isNotEmpty)
                      Text(batch.allergens.join('・'), style: TextStyle(fontSize: 12, color: eco.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final (label, value, highlight) in stats)
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: highlight ? eco.primary : eco.textPrimary,
                        ),
                      ),
                      Text(label, style: TextStyle(fontSize: 11, color: eco.textSecondary)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _StepState { done, current, upcoming }

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.batch});
  final StoreBatch batch;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final status = batch.statusAt(storeClock());
    final registered = batch.registeredAt;
    final collected = batch.collectedAt;
    final planned = batch.collectionPlannedAt;

    Widget chip(IconData icon, String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: eco.chip, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: eco.primary),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );

    final temperature = batch.temperatureCelsius;
    final driver = batch.collectedByName;
    final steps = <(_StepState, String, String?, Widget?)>[
      (
        _StepState.done,
        l10n.storeStepEstimated,
        registered == null ? null : _hm(registered),
        Text(l10n.storeStepEstimatedDetail(batch.estimatedQty)),
      ),
      batch.isConfirmed
          ? (
              _StepState.done,
              l10n.storeStepCollected,
              collected == null ? null : _hm(collected),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (temperature != null)
                    chip(Icons.thermostat_rounded, l10n.storeTemperature(temperature.toStringAsFixed(1))),
                  if (driver != null) chip(Icons.local_shipping_outlined, l10n.storeStepCollectedBy(driver)),
                ],
              ),
            )
          : (
              _StepState.current,
              l10n.storeStepCollected,
              planned == null ? null : l10n.storeStepCollectedPlanned(_hm(planned)),
              Text(l10n.storeStepCollectedHint),
            ),
      (
        switch (status) {
          StoreBatchStatus.estimated => _StepState.upcoming,
          StoreBatchStatus.onSale => _StepState.current,
          StoreBatchStatus.ended => _StepState.done,
        },
        l10n.storeStepOnSale,
        l10n.storeStepOnSaleUntil(_hm(batch.sellByAt)),
        Text(l10n.storeStepOnSaleDetail(batch.stops.length)),
      ),
      (
        status == StoreBatchStatus.ended ? _StepState.done : _StepState.upcoming,
        l10n.storeStepEnded,
        null,
        Text(l10n.storeStepEndedDetail),
      ),
    ];

    Widget marker(_StepState s) => switch (s) {
      _StepState.done => Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(color: eco.primary, shape: BoxShape.circle),
        child: const Icon(Icons.check, size: 16, color: Colors.white),
      ),
      _StepState.current => Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: eco.primary, width: 3),
        ),
      ),
      _StepState.upcoming => Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: eco.chip,
          shape: BoxShape.circle,
          border: Border.all(color: eco.border),
        ),
      ),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(eco),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.storeProgress, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          for (final (state, title, time, detail) in steps)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  marker(state),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: state == _StepState.upcoming ? eco.textSecondary : eco.textPrimary,
                              ),
                            ),
                            if (time != null) ...[
                              const SizedBox(width: 8),
                              Text(time, style: TextStyle(fontSize: 12, color: eco.textSecondary)),
                            ],
                          ],
                        ),
                        if (detail != null) ...[
                          const SizedBox(height: 4),
                          DefaultTextStyle.merge(
                            style: TextStyle(fontSize: 12, color: eco.textSecondary),
                            child: detail,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StopsCard extends StatelessWidget {
  const _StopsCard({required this.batch});
  final StoreBatch batch;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final live = batch.statusAt(storeClock()) == StoreBatchStatus.onSale;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(eco),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.storeStopsRemaining,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              if (live) ...[
                Icon(Icons.sensors_rounded, size: 14, color: eco.primary),
                const SizedBox(width: 4),
                Text(
                  l10n.storeAutoUpdate,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: eco.primary),
                ),
              ],
            ],
          ),
          for (final s in batch.stops)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Row(
                children: [
                  Icon(Icons.place_outlined, size: 20, color: eco.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        Text(
                          pickupWindowLabel(s.plannedTime),
                          style: TextStyle(fontSize: 12, color: eco.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.storeStopRemaining(s.remainingQty),
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: eco.primary),
                      ),
                      Text(
                        l10n.storeStopAllocated(s.allocatedQty),
                        style: TextStyle(fontSize: 11, color: eco.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
