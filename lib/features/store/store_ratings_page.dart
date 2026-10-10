import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/jst_date.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/state_panel.dart';
import 'store_gateway.dart';

// SCR-S05 お客様の評価（556:518 / Empty 556:636）— API-070 get_restaurant_ratings, 30 ngày. Không có tên khách (0054).
class StoreRatingsPage extends ConsumerWidget {
  const StoreRatingsPage({super.key, required this.restaurantId});
  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final eco = context.eco;
    final locale = Localizations.localeOf(context).languageCode;
    final ratings = ref.watch(storeRatingsProvider(restaurantId));

    Widget stars(double value, {double size = 16}) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            value >= i
                ? Icons.star_rounded
                : value >= i - 0.5
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded,
            size: size,
            color: eco.amber,
          ),
      ],
    );

    BoxDecoration card() => BoxDecoration(
      color: eco.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: eco.border),
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.storeRatingsTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            Text(l10n.storeRatingsPeriod, style: TextStyle(fontSize: 12, color: eco.textSecondary)),
          ],
        ),
      ),
      body: ratings.when(
        loading: () => const SkeletonList(heights: [200, 240]),
        error: (_, _) => Center(
          child: StatePanel.error(
            title: l10n.storeLoadErrorTitle,
            message: l10n.storeLoadErrorBody,
            actionLabel: l10n.storeReload,
            onAction: () => ref.invalidate(storeRatingsProvider(restaurantId)),
          ),
        ),
        data: (r) {
          final average = r.average;
          if (r.count == 0 || average == null) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  decoration: card(),
                  child: StatePanel(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: l10n.storeRatingsNone,
                    message: l10n.storeRatingsEmptyBody,
                  ),
                ),
              ),
            );
          }
          final maxCount = r.distribution.values.fold(1, (m, v) => v > m ? v : m);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: card(),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          average.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            stars(average, size: 22),
                            Text(
                              l10n.storeRatingsCount(r.count),
                              style: TextStyle(fontSize: 12, color: eco.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (var star = 5; star >= 1; star--)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 30,
                              child: Text(
                                l10n.storeRatingStars(star),
                                style: TextStyle(fontSize: 12, color: eco.textSecondary),
                              ),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: (r.distribution[star] ?? 0) / maxCount,
                                  minHeight: 8,
                                  backgroundColor: eco.chip,
                                  color: eco.amber,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 32,
                              child: Text(
                                '${r.distribution[star] ?? 0}',
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: 12, color: eco.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (r.recentComments.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(l10n.storeRatingsRecent, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Container(
                  decoration: card(),
                  child: Column(
                    children: [
                      for (final (i, c) in r.recentComments.indexed) ...[
                        if (i > 0) Divider(height: 1, indent: 16, endIndent: 16, color: eco.border),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  stars(c.rating.toDouble(), size: 14),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat.MMMd(locale).format(DateTime.parse(dateInTokyo(c.createdAt))),
                                    style: TextStyle(fontSize: 11, color: eco.textSecondary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(c.comment, style: const TextStyle(fontSize: 14, height: 1.6)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(l10n.storeRatingsAnonymous, style: TextStyle(fontSize: 12, color: eco.textSecondary)),
            ],
          );
        },
      ),
    );
  }
}
