import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/state_panel.dart';
import '../home/batch_card.dart';
import '../home/customer_home_page.dart';
import 'favorite_stops.dart';

// SCR-M16 → 受取地点のフードバッグ（Figma 714:1601 / なし 714:1675）: chạm 1 điểm yêu thích → các フードバッグ nhận được
// ở điểm đó tối nay. Cùng dữ liệu với danh sách của SCR-M03 (API-019 activeListings), lọc theo stop_locations.id —
// không thêm API. Chạm thẻ → SCR-M04 như ở ホーム. ★ ở góc phải để bỏ thích ngay tại đây.
class FavoriteStopBagsPage extends ConsumerWidget {
  const FavoriteStopBagsPage({super.key, required this.stop});
  final FavoriteStop stop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final eco = context.eco;
    final listingsAsync = ref.watch(activeListingsProvider);
    final address = stop.address;
    return Scaffold(
      appBar: AppBar(
        title: Text(stop.name),
        actions: [
          FavoriteStarButton(stopLocationId: stop.stopLocationId),
          const SizedBox(width: 12),
        ],
      ),
      body: listingsAsync.when(
        loading: () => const SkeletonList(heights: [168, 168], padding: EdgeInsets.fromLTRB(20, 48, 20, 24)),
        error: (_, _) => Center(
          child: StatePanel.error(
            title: l10n.errorLoadTitle,
            message: l10n.errorLoadBody,
            actionLabel: l10n.retry,
            onAction: () => ref.invalidate(activeListingsProvider),
          ),
        ),
        data: (all) {
          final here = all.where((l) => l.stopLocationId == stop.stopLocationId).toList()
            ..sort((a, b) => a.plannedPickupTime.compareTo(b.plannedPickupTime));
          return RefreshIndicator(
            onRefresh: () => ref.refresh(activeListingsProvider.future),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                if (address != null && address.isNotEmpty)
                  Text(address, style: TextStyle(fontSize: 12, color: eco.textSecondary)),
                const SizedBox(height: 12),
                if (here.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 120),
                    child: StatePanel(
                      icon: Icons.shopping_bag_outlined,
                      title: l10n.stopBagsEmptyTitle,
                      message: l10n.stopBagsEmptyBody,
                    ),
                  )
                else ...[
                  Text(l10n.stopBagsHeading, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  for (final listing in here) ...[
                    SizedBox(
                      height: BatchCard.rowHeight(context),
                      child: BatchCard(listing: listing, heroScope: 'favorite', width: double.infinity),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
