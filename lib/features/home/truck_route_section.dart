import 'package:flutter/material.dart';
import '../../core/jst_date.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/status_badge.dart';
import 'batch_card.dart';
import 'home_gateway.dart';

// SCR-M03 khi chọn 1 xe (Figma "SCR-M03 トラックマップ / トラック選択" 246:2016, レビュー第68回): lộ trình tối nay
// của xe theo sequence, mỗi điểm chưa rời có băng thẻ các lô bán TẠI điểm đó — chọn thẻ = chọn luôn điểm nhận,
// nên vẫn ra đúng cặp (lô, điểm dừng) mà create_order cần (API-010). Điểm đã rời chỉ hiện để người dùng biết.
class TruckRouteSection extends StatelessWidget {
  const TruckRouteSection({
    super.key,
    required this.truck,
    required this.number,
    required this.listings,
    required this.onClose,
  });
  final TruckRoute truck;
  final int number;
  final List<BatchListing> listings;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final next = truck.nextStop;
    final onTruck = listings.where((l) => l.truckId == truck.truckId).toList();

    return Column(
      key: Key('truckRoute_${truck.truckId}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.truckNumber(number), style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      l10n.truckRouteSummary(truck.stops.length),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                key: const Key('truckRouteClose'),
                tooltip: l10n.closeTruckRoute,
                onPressed: onClose,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final stop in truck.stops) ...[
          _StopRow(stop: stop, isNext: stop.routeStopId == next?.routeStopId),
          if (!stop.departed) ..._cardsAt(context, stop, onTruck),
        ],
        if (onTruck.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(l10n.truckNoBatches, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
      ],
    );
  }

  // Thẻ của các lô bán tại 1 điểm, lô sắp hết hạn trước — cùng BatchCard với danh sách "近くのフードバッグ".
  List<Widget> _cardsAt(BuildContext context, RouteStopInfo stop, List<BatchListing> onTruck) {
    final here = onTruck.where((l) => l.routeStopId == stop.routeStopId).toList()
      ..sort((a, b) => a.expiresAt.compareTo(b.expiresAt));
    if (here.isEmpty) return const [];
    return [
      SizedBox(
        height: BatchCard.rowHeight(context),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: here.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, index) => BatchCard(listing: here[index], heroScope: 'route'),
        ),
      ),
      const SizedBox(height: 8),
    ];
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({required this.stop, required this.isNext});
  final RouteStopInfo stop;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final passed = stop.departed;
    final color = passed ? AppColors.textSecondary : AppColors.textPrimary;
    return Padding(
      key: Key('routeStop_${stop.routeStopId}'),
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isNext ? AppColors.primary : (passed ? AppColors.border : AppColors.surface),
              border: !isNext && !passed ? Border.all(color: AppColors.primary, width: 2) : null,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            tokyoTime(stop.plannedTime),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(stop.stopName, style: TextStyle(fontSize: 14, color: color))),
          if (isNext) Flexible(child: StatusBadge(label: l10n.nextStopBadge)),
          if (passed) Flexible(child: Text(l10n.stopPassed, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        ],
      ),
    );
  }
}
