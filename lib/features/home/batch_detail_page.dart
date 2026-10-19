import 'dart:async';
import '../../core/app_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/jst_date.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/state_panel.dart';
import '../../widgets/status_badge.dart';
import '../orders/reservation_confirm_page.dart';
import '../favorites/favorite_stops.dart';
import 'home_gateway.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/value_change.dart';
import '../../widgets/batch_photo.dart';

final batchDetailProvider = FutureProvider.autoDispose
    .family<BatchDetail, String>((ref, batchId) {
      return ref.watch(homeGatewayProvider).fetchBatchDetail(batchId);
    });

// Giá hiện tại (API-019) cho 1 cặp unitPrice + expiresAt — dùng chung cho thẻ lô ở SCR-M03 và màn này.
// Khoá family là record (so sánh theo giá trị): cùng lô thì dùng lại kết quả, không gọi lại RPC.
final currentPriceProvider = FutureProvider.autoDispose
    .family<CurrentPriceResult, ({int unitPrice, DateTime expiresAt})>((
      ref,
      params,
    ) {
      final timer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => ref.invalidateSelf(),
      );
      ref.onDispose(timer.cancel);
      return ref
          .watch(homeGatewayProvider)
          .calcCurrentPrice(
            unitPrice: params.unitPrice,
            expiresAt: params.expiresAt,
          );
    });

final todayReservationCountProvider = FutureProvider.autoDispose<int>((ref) {
  return ref.watch(homeGatewayProvider).fetchTodayReservationCount();
});

final homeClockProvider = StreamProvider.autoDispose<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

// SCR-M04 — khớp frame Figma 460:1181 (Default) / 134:713 (予約上限) / 134:649 (Error) / 134:583 (Loading).
// stopName + plannedPickupTime đến từ thẻ lô đã chọn ở SCR-M03: thẻ "Eco-Truckで受け取り" phải là đúng
// điểm dừng sẽ gửi làm p_pickup_route_stop_id ở SCR-M05 (Chương 17), không tự chọn điểm khác.
class BatchDetailPage extends ConsumerWidget {
  const BatchDetailPage({
    super.key,
    required this.batchId,
    required this.routeStopId,
    required this.stopName,
    required this.plannedPickupTime,
    this.stopLocationId,
    this.heroTag,
    this.heroPhotoUrl,
    this.reserved,
  });
  final String batchId;
  final String routeStopId;
  final String stopName;
  final DateTime plannedPickupTime;
  final String? stopLocationId; // 0053: có thì hiện nút ☆ お気に入り ở thẻ 受け取り
  // Mở từ thẻ có ảnh (SCR-M03): ảnh của thẻ "bay" lên thành ảnh đầu trang. Ảnh hiện ngay cả lúc chi tiết còn đang tải
  // (heroPhotoUrl lấy từ thẻ) — nếu đợi tải xong mới có Hero đích thì hiệu ứng không chạy.
  final String? heroTag;
  final String? heroPhotoUrl;
  // Mở từ thẻ đơn ở SCR-M06 (2026-10-15): túi khách đã đặt — hiện số đã trả, không có nút 予約する / đếm giờ,
  // không tự đóng khi hết giờ bán, không tính là "đã xem túi" (0051)
  final ReservedBag? reserved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(batchDetailProvider(batchId));
    final l10n = context.l10n;

    // 0051: đo chuyển đổi — "đã xem túi đồ ăn" (1 lần khi mở màn)
    final page = Scaffold(
      appBar: AppBar(title: Text(l10n.batchDetailTitle)),
      body: detailAsync.when(
        loading: () => _DetailSkeleton(heroTag: heroTag, heroPhotoUrl: heroPhotoUrl),
        error: (_, __) => Center(
          child: StatePanel.error(
            title: l10n.errorLoadTitle,
            message: l10n.errorLoadBody,
            actionLabel: l10n.retry,
            filledAction: false, // Figma: 再試行 là nút viền
            onAction: () => ref.invalidate(batchDetailProvider(batchId)),
          ),
        ),
        data: (batch) => _BatchDetailBody(
          batch: batch,
          routeStopId: routeStopId,
          stopName: stopName,
          plannedPickupTime: plannedPickupTime,
          stopLocationId: stopLocationId,
          heroTag: heroTag,
          reserved: reserved,
        ),
      ),
    );
    if (reserved != null) return page;
    return LogAppEventOnce(event: AppEvent.batchView, surplusBatchId: batchId, child: page);
  }
}

// Đơn đã đặt của túi này: số đơn hiển thị (#EM-xxxx) và số tiền đã trả (orders.price_paid)
typedef ReservedBag = ({String orderNumber, int pricePaid});

class _BatchDetailBody extends ConsumerWidget {
  const _BatchDetailBody({
    required this.batch,
    required this.routeStopId,
    required this.stopName,
    required this.plannedPickupTime,
    this.stopLocationId,
    this.heroTag,
    this.reserved,
  });
  final BatchDetail batch;
  final String routeStopId;
  final String stopName;
  final DateTime plannedPickupTime;
  final String? stopLocationId;
  final String? heroTag;
  final ReservedBag? reserved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final reserved = this.reserved;
    final textTheme = Theme.of(context).textTheme;
    final priceAsync = ref.watch(
      currentPriceProvider((
        unitPrice: batch.unitPrice,
        expiresAt: batch.expiresAt,
      )),
    );
    final reservationCountAsync =
        reserved == null ? ref.watch(todayReservationCountProvider) : const AsyncValue<int>.data(0);
    // BR-002: tối đa 2 đơn/ngày (loại cancelled/refunded) — chỉ là UX sớm, create_order (Chương 17)
    // vẫn tự kiểm tra lại y hệt điều kiện này ở server, không tin tưởng tuyệt đối giá trị client.
    final now = ref.watch(homeClockProvider).valueOrNull ?? DateTime.now();
    final expired = !batch.expiresAt.isAfter(now);
    ref.listen(homeClockProvider, (_, tick) {
      if (reserved == null &&
          tick.valueOrNull != null &&
          !batch.expiresAt.isAfter(tick.requireValue) &&
          // pop() đóng màn TRÊN CÙNG: M04 đang nằm dưới SCR-M05 (đặt chỗ / thanh toán) thì không được tự đóng —
          // M05 tự xử lý (server trả E-ORDER-003), quay lại M04 thì nút đặt đã khoá theo `expired` (audit R01 2026-10-19)
          (ModalRoute.of(context)?.isCurrent ?? false) &&
          Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.batchExpired)));
      }
    });
    final dailyLimitReached = (reservationCountAsync.valueOrNull ?? 0) >= 2;
    final languageCode = Localizations.localeOf(context).languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              BatchPhoto(photoUrl: batch.photoUrl, height: 210, heroTag: heroTag),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                // 02_要件定義書 §6.1: ẩn tên nhà hàng, chỉ hiện nhãn cố định.
                child: StatusBadge(
                  label: l10n.partnerStore,
                  tone: BadgeTone.soft,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.mysteryBag,
                style: textTheme.headlineSmall?.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 8),
              if (reserved != null)
                _PaidPrice(reserved: reserved, unitPrice: batch.unitPrice)
              else
              priceAsync.when(
                loading: () =>
                    Text(l10n.priceCalculating, style: textTheme.bodySmall),
                error: (_, __) => Text(
                  l10n.errorPriceLoad,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.error),
                ),
                data: (price) => Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ValueChange(
                        value: price.currentPrice,
                        child: Text(
                          '¥${price.currentPrice}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.amberInk,
                            height: 1.2,
                          ),
                        ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '¥${batch.unitPrice}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const Spacer(),
                    ValueChange(
                      value: remainingMinutes(batch.expiresAt, now),
                      alignment: Alignment.centerRight,
                      child: StatusBadge(
                        label: l10n.minutesRemaining(
                          remainingMinutes(batch.expiresAt, now),
                        ),
                        tone: BadgeTone.warning,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _PickupCard(
                stopName: stopName,
                plannedPickupTime: plannedPickupTime,
                stopLocationId: stopLocationId,
              ),
              const SizedBox(height: 20),
              _SectionHeading(l10n.allergensHeading),
              batch.allergens.isEmpty
                  ? Text(l10n.allergensNone, style: textTheme.bodySmall)
                  : _ChipWrap(
                      labels: [
                        for (final a in batch.allergens)
                          a.forLanguage(languageCode),
                      ],
                    ),
              if (batch.ingredients.isNotEmpty) ...[
                const SizedBox(height: 16),
                _SectionHeading(l10n.ingredientsHeading),
                // tên/産地 do nhà hàng tự nhập (văn bản tự do) — không dịch được, chỉ dịch nhãn "không rõ"
                _ChipWrap(
                  labels: [
                    for (final ingredient in batch.ingredients)
                      l10n.ingredientWithOrigin(
                        ingredient.name,
                        ingredient.origin.isEmpty
                            ? l10n.originUnknown
                            : ingredient.origin,
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              // Có ảnh quán đăng → nói rõ là ảnh thật (lượng có thể khác); không có → "写真はイメージです" như trước
              Text(
                batch.photoUrl == null ? l10n.detailNote : l10n.detailNotePhoto,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Vùng nút dính đáy của Figma: nền trắng, viền trên, lý do bị khoá (nếu có) nằm ngay trên nút.
        DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.all(16),
            child: reserved != null
                ? _ReservedNote(reserved: reserved)
                : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (reservationCountAsync.hasError) ...[
                  Text(
                    l10n.reservationCountFailed,
                    style: const TextStyle(color: AppColors.error),
                  ),
                  TextButton(
                    onPressed: () =>
                        ref.invalidate(todayReservationCountProvider),
                    child: Text(l10n.retry),
                  ),
                ],
                if (expired)
                  Text(l10n.batchExpired, textAlign: TextAlign.center),
                if (dailyLimitReached) ...[
                  Text(
                    l10n.dailyLimitReached,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                FilledButton(
                  key: const Key('reserveButton'),
                  onPressed:
                      dailyLimitReached ||
                          expired ||
                          priceAsync.hasError ||
                          reservationCountAsync.hasError ||
                          !priceAsync.hasValue ||
                          !reservationCountAsync.hasValue
                      ? null
                      : () {
                          // SCR-M05 (Chương 17): đúng cặp lô + điểm dừng đã chọn ở SCR-M03 → p_* của create_order.
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ReservationConfirmPage(
                                batchId: batch.batchId,
                                routeStopId: routeStopId,
                                stopName: stopName,
                                plannedPickupTime: plannedPickupTime,
                                unitPrice: batch.unitPrice,
                                expiresAt: batch.expiresAt,
                                photoUrl: batch.photoUrl,
                              ),
                            ),
                          );
                        },
                  child: Text(l10n.reserveButton),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// "Eco-Truckで受け取り": điểm dừng + khung giờ nhận — cùng pickupWindowLabel với SCR-M05 (Chương 17).
class _PickupCard extends StatelessWidget {
  const _PickupCard({required this.stopName, required this.plannedPickupTime, this.stopLocationId});
  final String stopName;
  final DateTime plannedPickupTime;
  final String? stopLocationId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.pickupByEcoTruck,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${pickupWindowLabel(plannedPickupTime)}　$stopName',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // 0053 (Figma 460:1181): ☆ お気に入りの受取地点 — bật thì có túi đồ ăn mới ở điểm này sẽ được thông báo
          if (stopLocationId case final id?) ...[
            const SizedBox(width: 12),
            FavoriteStarButton(stopLocationId: id),
          ],
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// Chip của Figma nhỏ hơn Chip mặc định (chữ 11, cao ~26) — vẽ trực tiếp thay vì chỉnh Chip.
class _ChipWrap extends StatelessWidget {
  const _ChipWrap({required this.labels});
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final label in labels)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.chip,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

// Loading của Figma (134:583): giữ đúng khung ảnh / tiêu đề / giá / thẻ nhận hàng bằng khối xám.
class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton({this.heroTag, this.heroPhotoUrl});
  final String? heroTag;
  final String? heroPhotoUrl;

  @override
  Widget build(BuildContext context) {
    Widget block(double height, {double? width, double radius = 8}) =>
        SkeletonBox(height: height, width: width, radius: radius);
    // Ảnh của thẻ (Hero) đứng ngoài nhịp sáng-tối: chỉ phần chữ đang tải mới nhấp nháy
    final heroTag = this.heroTag;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        if (heroTag != null)
          BatchPhoto(photoUrl: heroPhotoUrl, height: 210, heroTag: heroTag)
        else
          SkeletonPulse(child: block(210, radius: 16)),
        const SizedBox(height: 16),
        SkeletonPulse(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: block(24, width: 110, radius: 999),
              ),
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerLeft, child: block(26, width: 180)),
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerLeft, child: block(32, width: 140)),
              const SizedBox(height: 16),
              block(72, radius: 12),
            ],
          ),
        ),
      ],
    );
  }
}

// Túi đã đặt: số khách đã trả (không phải giá đang giảm theo giờ — giá đó không còn liên quan tới đơn này)
class _PaidPrice extends StatelessWidget {
  const _PaidPrice({required this.reserved, required this.unitPrice});
  final ReservedBag reserved;
  final int unitPrice;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '¥${reserved.pricePaid}',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.amberInk, height: 1.2),
        ),
        const SizedBox(width: 8),
        Text(
          '¥$unitPrice',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        const Spacer(),
        StatusBadge(label: context.l10n.reservedPaid, tone: BadgeTone.soft),
      ],
    );
  }
}

// Thay nút 予約する: túi này đã đặt rồi (số đơn trùng với thẻ ở 予約履歴)
class _ReservedNote extends StatelessWidget {
  const _ReservedNote({required this.reserved});
  final ReservedBag reserved;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('reservedNote'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          context.l10n.reservedOrderLabel(reserved.orderNumber),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
        ),
      ],
    );
  }
}
