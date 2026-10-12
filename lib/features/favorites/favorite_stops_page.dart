import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/state_panel.dart';
import 'favorite_stop_bags_page.dart';
import 'favorite_stops.dart';

// SCR-M16 お気に入りの受取地点 (0053, Figma 460:1352 / Empty 460:1461). Mở từ SCR-M07. Bỏ ★ ở đây là huỷ đăng ký.
class FavoriteStopsPage extends ConsumerWidget {
  const FavoriteStopsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final favoritesAsync = ref.watch(myFavoriteStopsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.favoriteStopsTitle)),
      body: favoritesAsync.when(
        // Khung xương theo bố cục danh sách (Figma SCR-M16 / Loading)
        loading: () => const SkeletonList(heights: [76, 76, 76], padding: EdgeInsets.fromLTRB(20, 16, 20, 24)),
        error: (_, __) => Center(
          child: StatePanel.error(
            title: l10n.errorLoadTitle,
            message: l10n.errorLoadBody,
            actionLabel: l10n.retry,
            onAction: () => ref.invalidate(myFavoriteStopsProvider),
          ),
        ),
        data: (favorites) => favorites.isEmpty
            ? Center(
                child: StatePanel(
                  icon: Icons.star_outline_rounded,
                  title: l10n.favoriteStopsEmptyTitle,
                  message: l10n.favoriteStopsEmptyBody,
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  Text(l10n.favoriteStopsIntro, style: TextStyle(fontSize: 12, color: context.eco.textSecondary)),
                  const SizedBox(height: 16),
                  for (final stop in favorites) ...[
                    _FavoriteStopCard(key: Key('favoriteStop-${stop.stopLocationId}'), stop: stop),
                    const SizedBox(height: 12),
                  ],
                  Text(l10n.favoriteStopsHint, style: TextStyle(fontSize: 11, color: context.eco.textSecondary)),
                ],
              ),
      ),
    );
  }
}

class _FavoriteStopCard extends StatelessWidget {
  const _FavoriteStopCard({super.key, required this.stop});
  final FavoriteStop stop;

  @override
  Widget build(BuildContext context) {
    final address = stop.address;
    // Chạm thẻ → フードバッグ của điểm này tối nay (Figma 714:1601). ★ vẫn là nút riêng (bỏ thích)
    return Material(
      color: context.eco.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: context.eco.border),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => FavoriteStopBagsPage(stop: stop)),
        ),
        child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Row(
        children: [
          Icon(Icons.place_outlined, size: 22, color: context.eco.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stop.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                if (address != null && address.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(address, style: TextStyle(fontSize: 11, color: context.eco.textSecondary)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          FavoriteStarButton(stopLocationId: stop.stopLocationId),
        ],
      ),
        ),
      ),
    );
  }
}
