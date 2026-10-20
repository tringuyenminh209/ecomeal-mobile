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
  const BatchCard({
    super.key,
    required this.listing,
    this.heroScope = 'nearby',
    this.width = 300,
    this.compact = false,
    this.walkMinutes,
  });
  final BatchListing listing;
  // Danh sách chứa thẻ — phần của tag Hero (batchPhotoHeroTag)
  final String heroScope;
  // 300 ở hàng cuộn ngang (Figma); double.infinity khi xếp dọc (danh sách của 1 受取地点)
  final double width;
  // Hàng gọn của danh sách dọc khi kéo sheet SCR-M03 lên cao (Figma 881:2137): ảnh trái, tên + điểm nhận + phút đi bộ,
  // giá + thời gian còn lại + số túi bên phải. Cùng dữ liệu, cùng lúc mở chi tiết với thẻ ngang.
  final bool compact;
  // null = chưa có GPS → chỉ hiện tên điểm nhận
  final int? walkMinutes;

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
      width: width,
      child: Card(
        key: Key('listingCard_${listing.batchId}_${listing.routeStopId}'),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _open(context, heroTag),
          child: compact ? _row(context, price, now, heroTag) : Padding(
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.mysteryBag,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                      // nhãn giờ giữ 1 dòng (thẻ cao cố định); chữ không đủ chỗ thì số túi bên phải bị cắt "…"
                      StatusBadge(
                        label: l10n.minutesRemaining(
                          remainingMinutes(listing.expiresAt, now),
                        ),
                        tone: BadgeTone.warning,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        l10n.remainingBags(listing.remainingQty),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
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

  void _open(BuildContext context, String heroTag) {
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
  }

  Widget _row(BuildContext context, CurrentPriceResult? price, DateTime now, String heroTag) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      child: Row(
        children: [
          if (listing.photoUrl != null)
            BatchPhoto(photoUrl: listing.photoUrl, width: 60, height: 60, radius: 12, heroTag: heroTag)
          else
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.partnerStore,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primary),
                ),
                Text(l10n.mysteryBag, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  walkMinutes == null ? listing.stopName : l10n.stopWalk(listing.stopName, walkMinutes!),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ValueChange(
                value: price?.currentPrice ?? -1,
                child: Text(
                  price == null ? '¥—' : '¥${price.currentPrice}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 4),
              if (price != null)
                StatusBadge(
                  label: l10n.minutesRemaining(remainingMinutes(listing.expiresAt, now)),
                  tone: BadgeTone.warning,
                ),
              const SizedBox(height: 2),
              Text(
                l10n.remainingBags(listing.remainingQty),
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
