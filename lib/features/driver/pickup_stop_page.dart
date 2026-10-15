import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/jst_date.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/batch_photo.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/state_panel.dart';
import '../../widgets/status_badge.dart';
import 'driver_gateway.dart';
import 'driver_home_page.dart';
import 'driver_route_helpers.dart';
import 'pickup_confirm_page.dart';
import 'pickup_done_page.dart';

// SCR-D07 集荷先の詳細 (2026-10-16, Figma 896:1695): trước khi chốt số lượng ở D02, tài xế thấy ở điểm thu gom này
// có những lô nào, mỗi lô quán dự kiến bao nhiêu suất, quán ngừng bán lúc mấy giờ, có chất gây dị ứng gì — và lô nào
// đã nhận. Đọc từ tonightRouteProvider (đã có sẵn các lô của tuyến) nên chốt xong chỉ cần invalidate là danh sách đổi.
class PickupStopPage extends ConsumerWidget {
  const PickupStopPage({super.key, required this.routeStopId});
  final String routeStopId;

  Future<void> _pickUp(BuildContext context, WidgetRef ref, TonightRoute route, DriverStop stop, RouteBatch batch) async {
    final outcome = await Navigator.of(context).push<PickupOutcome>(
      MaterialPageRoute(builder: (_) => PickupConfirmPage(route: route, collectionStop: stop, batch: batch)),
    );
    if (outcome == null || !context.mounted) return;
    ref.invalidate(tonightRouteProvider);
    if (outcome.result.rejectedForTemperature) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.pickupRejectedToast(outcome.result.refundedOrderCount))),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => PickupDonePage(collectionStop: stop, outcome: outcome)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final routeAsync = ref.watch(tonightRouteProvider);
    final route = routeAsync.valueOrNull;
    final stop = route?.stops.where((s) => s.routeStopId == routeStopId).firstOrNull;
    final time = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stop?.name ?? ''),
            if (route != null && stop != null)
              Text(
                () {
                  final p = pickupPositionOf(route.stops, stop);
                  return l10n.pickupStopSubtitle(p.index, p.total, time.format(toTokyo(stop.plannedTime)));
                }(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
      body: routeAsync.when(
        loading: () => const SkeletonList(heights: [150, 120, 120]),
        error: (_, __) => Center(
          child: StatePanel.error(
            title: l10n.errorLoadTitle,
            message: l10n.errorLoadBody,
            actionLabel: l10n.retry,
            onAction: () => ref.invalidate(tonightRouteProvider),
          ),
        ),
        data: (route) {
          if (route == null || stop == null) {
            return Center(child: StatePanel(icon: Icons.inventory_2_outlined, title: l10n.nothingToPickUp));
          }
          final batches = batchesAt(route, stop);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              _AddressCard(
                address: stop.address,
                onNavigate: () => openDirectionsTo(context, ref, stop),
              ),
              const SizedBox(height: 16),
              Text(l10n.foodsToPickUp(batches.length), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if (batches.isEmpty) StatePanel(icon: Icons.inventory_2_outlined, title: l10n.nothingToPickUp),
              for (final b in batches) ...[
                _BatchCard(batch: b, onPickUp: () => _pickUp(context, ref, route, stop, b)),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 4),
              DriverStepsCard(title: l10n.pickupStepsTitle, steps: [l10n.pickupStep1, l10n.pickupStep2, l10n.pickupStep3]),
            ],
          );
        },
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address, required this.onNavigate});
  final String? address;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _Box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.addressLabel, style: TextStyle(fontSize: 11, color: context.eco.textSecondary)),
          const SizedBox(height: 2),
          Text(address ?? '—', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('navigateButton'),
                  onPressed: onNavigate,
                  icon: const Icon(Icons.navigation_outlined, size: 18),
                  label: Text(l10n.navigateButton),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  key: const Key('copyAddressButton'),
                  onPressed: address == null
                      ? null
                      : () async {
                          await Clipboard.setData(ClipboardData(text: address!));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.addressCopied)));
                          }
                        },
                  child: Text(l10n.copyAddressButton),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BatchCard extends StatelessWidget {
  const _BatchCard({required this.batch, required this.onPickUp});
  final RouteBatch batch;
  final VoidCallback onPickUp;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final lang = Localizations.localeOf(context).languageCode;
    return _Box(
      key: Key('pickupBatch_${batch.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BatchPhoto(photoUrl: batch.photoUrl, width: 64, height: 64, radius: 10),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: [
                        Text(l10n.approxMeals(batch.estimatedQty), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        Text(l10n.shopPlannedQty, style: TextStyle(fontSize: 11, color: eco.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.shopSellByLabel(DateFormat('HH:mm').format(toTokyo(batch.sellByAt))),
                      style: TextStyle(fontSize: 12, color: eco.textSecondary),
                    ),
                    if (batch.allergens.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          for (final a in batch.allergens) StatusBadge(label: a.forLanguage(lang), tone: BadgeTone.neutral),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (batch.isPickedUp)
            Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(label: l10n.pickedUpChip(batch.confirmedQty!), tone: BadgeTone.soft),
            )
          else
            FilledButton(key: Key('pickUpBatch_${batch.id}'), onPressed: onPickUp, child: Text(l10n.pickUpThisFood)),
        ],
      ),
    );
  }
}

// Thẻ "các bước" dùng chung cho D07 (受け取りの流れ) và D03 (ここでの流れ).
class DriverStepsCard extends StatelessWidget {
  const DriverStepsCard({super.key, required this.title, required this.steps});
  final String title;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return _Box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (final (i, s) in steps.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('${i + 1}. $s', style: TextStyle(fontSize: 12, height: 1.5, color: context.eco.textSecondary)),
            ),
        ],
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({super.key, required this.child});
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
