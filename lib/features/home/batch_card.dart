import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/jst_date.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/batch_photo.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/value_change.dart';
import 'batch_detail_page.dart';
import 'home_gateway.dart';

// MysteryBagCard của Figma: tên cửa hàng ẩn (02_要件定義書 §6.1 → "EcoMeal提携店"), nhãn cố định
// "ミステリーバッグ", GIÁ HIỆN TẠI (không phải unit_price), thời gian còn lại, số túi còn.
class BatchCard extends ConsumerWidget {
  const BatchCard({super.key, required this.listing, this.heroScope = 'nearby'});
  final BatchListing listing;
  // Danh sách chứa thẻ — phần của tag Hero (batchPhotoHeroTag)
  final String heroScope;

  // Chiều cao hàng thẻ ngang (Figma 168). Nhân theo cỡ chữ hệ thống: chữ to lên mà hàng giữ 168 thì nội dung thẻ tràn
  // (vạch vàng-đen). Chặn ở 1.8 lần — cỡ chữ lớn nhất của Android/iOS vẫn vừa mà hàng không chiếm hết màn hình.
  static double rowHeight(BuildContext context) {
    const base = 168.0;
    return MediaQuery.textScalerOf(context).scale(base).clamp(base, base * 1.8);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // itemBuilder của ListView ngang chỉ dựng thẻ đang (gần) hiển thị → API-019 chỉ gọi cho các thẻ đó.
    final now = ref.watch(homeClockProvider).valueOrNull ?? DateTime.now();
    final price = ref
        .watch(
          currentPriceProvider((
            unitPrice: listing.unitPrice,
            expiresAt: listing.expiresAt,
          )),
        )
        .valueOrNull;

    final heroTag = batchPhotoHeroTag(batchId: listing.batchId, routeStopId: listing.routeStopId, scope: heroScope);
    return SizedBox(
      width: 300,
      child: Card(
        key: Key('listingCard_${listing.batchId}_${listing.routeStopId}'),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BatchDetailPage(
                  batchId: listing.batchId,
                  routeStopId: listing.routeStopId,
                  stopName: listing.stopName,
                  stopLocationId: listing.stopLocationId,
                  plannedPickupTime: listing.plannedPickupTime,
                  heroTag: listing.photoUrl == null ? null : heroTag,
                  heroPhotoUrl: listing.photoUrl,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ảnh món (nếu quán có đăng, 0038) ở góc phải: lướt danh sách là thấy món, không phải mở từng thẻ
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.partnerStore,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.mysteryBag,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          ValueChange(
                            value: price?.currentPrice ?? -1,
                            child: Text(
                              price == null ? '¥—' : '¥${price.currentPrice}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (listing.photoUrl != null) ...[
                      const SizedBox(width: 12),
                      BatchPhoto(photoUrl: listing.photoUrl, width: 72, height: 72, radius: 12, heroTag: heroTag),
                    ],
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    if (price != null) ...[
                      StatusBadge(
                        label: l10n.minutesRemaining(
                          remainingMinutes(listing.expiresAt, now),
                        ),
                        tone: BadgeTone.warning,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      l10n.remainingBags(listing.availableQty),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
