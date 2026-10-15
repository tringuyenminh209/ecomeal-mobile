import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/jst_date.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/state_panel.dart';
import 'driver_gateway.dart';
import 'driver_home_page.dart';
import 'driver_route_helpers.dart';
import 'pickup_confirm_page.dart';

// Số suất server đã chia cho từng điểm bán sau khi chốt 1 lô (distribute_qty_to_stops) — chỉ đọc, không tự tính.
final batchDropsProvider = FutureProvider.autoDispose.family<List<BatchDrop>, String>((ref, batchId) {
  return ref.watch(driverGatewayProvider).fetchBatchDrops(batchId);
});

// SCR-D02 集荷を確認 / 受け取り完了 (2026-10-16, Figma 896:1844): sau khi chốt, tài xế thấy đã chất bao nhiêu suất,
// giữ / hoàn bao nhiêu đơn, lô này đem tới điểm bán nào mỗi nơi bao nhiêu, và việc kế tiếp (ナビで行く).
class PickupDonePage extends ConsumerWidget {
  const PickupDonePage({super.key, required this.collectionStop, required this.outcome});
  final DriverStop collectionStop;
  final PickupOutcome outcome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final eco = context.eco;
    final route = ref.watch(tonightRouteProvider).valueOrNull;
    final dropsAsync = ref.watch(batchDropsProvider(outcome.batchId));
    final next = route == null ? null : nextStopOf(route.stops);
    final time = DateFormat('HH:mm');
    // Quán còn lô chưa nhận → việc kế tiếp vẫn ở đây: quay lại D07 thay vì về nhà / dẫn đường.
    final sameStop = next?.routeStopId == collectionStop.routeStopId;
    void home() => sameStop ? Navigator.of(context).pop() : Navigator.of(context).popUntil((r) => r.isFirst);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          children: [
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: eco.primary.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: Icon(Icons.check, size: 34, color: eco.primary),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.pickupDoneTitle(outcome.confirmedQty),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.pickupDoneSubtitle(collectionStop.name, outcome.celsius.toStringAsFixed(1)),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: eco.textSecondary),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _Count(label: l10n.securedReservations, value: outcome.result.allocatedOrderCount, color: eco.primary)),
                const SizedBox(width: 8),
                Expanded(child: _Count(label: l10n.refundedReservations, value: outcome.result.refundedOrderCount)),
              ],
            ),
            const SizedBox(height: 12),
            _Box(
              child: dropsAsync.when(
                loading: () => const SkeletonPulse(child: SkeletonBox(height: 88, radius: 8)),
                error: (_, __) => StatePanel.error(
                  title: l10n.errorLoadTitle,
                  message: l10n.errorLoadBody,
                  actionLabel: l10n.retry,
                  onAction: () => ref.invalidate(batchDropsProvider(outcome.batchId)),
                ),
                data: (drops) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.dropsTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    for (final d in drops)
                      if (route?.stops.where((s) => s.routeStopId == d.routeStopId).firstOrNull case final stop?)
                        Padding(
                          key: Key('drop_${d.routeStopId}'),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: eco.primary, width: 1.5)),
                                child: Text(
                                  '${route!.stops.indexOf(stop) + 1}',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: eco.primary),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(stop.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                    Text(
                                      l10n.dropSubtitle(time.format(toTokyo(stop.plannedTime)), d.reservedCount),
                                      style: TextStyle(fontSize: 11, color: eco.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Text(l10n.mealsCount(d.qty), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: eco.primary)),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: eco.surface,
                border: Border.all(color: eco.amber, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.nextTaskLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: eco.amber)),
                  const SizedBox(height: 8),
                  if (next != null)
                    Text(
                      next.type == 'restaurant'
                          ? l10n.nextTaskPickupTitle(next.name)
                          : l10n.nextTaskSalesTitle(next.name),
                      key: const Key('doneNextTitle'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    sameStop
                        ? l10n.moreFoodHereHint
                        : (next?.type == 'restaurant' ? l10n.morePickupsHint : l10n.allPickupsDoneHint),
                    style: TextStyle(fontSize: 12, color: eco.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: OutlinedButton(key: const Key('doneHomeButton'), onPressed: home, child: Text(sameStop ? l10n.back : l10n.backToHome))),
                      if (next != null && !sameStop) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            key: const Key('doneNavigateButton'),
                            onPressed: () => openDirectionsTo(context, ref, next),
                            icon: const Icon(Icons.navigation_outlined, size: 18),
                            label: Text(l10n.navigateButton),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.label, required this.value, this.color});
  final String label;
  final int value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return _Box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: context.eco.textSecondary)),
          const SizedBox(height: 2),
          Text(context.l10n.countItems(value), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
        ],
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.eco.surface,
        border: Border.all(color: context.eco.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
