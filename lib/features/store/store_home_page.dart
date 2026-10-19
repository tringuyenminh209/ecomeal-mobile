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
import '../notifications/notification_inbox.dart';
import 'store_batch_detail_page.dart';
import 'store_gateway.dart';
import 'store_register_logic.dart';
import '../../core/wide_layout.dart';
import 'store_ratings_page.dart';

// Mốc 概算登録 trong ngày (02 §3.1.1「15〜16時頃」) — chỉ là mốc hướng dẫn: server không chặn đăng ký sau 16:00.
const storeRegisterDeadlineHour = 16;

String _hm(DateTime t) => DateFormat('HH:mm').format(toTokyo(t));

// Hạn bán / giờ lấy hàng của lô theo trạng thái (dùng chung cho thẻ ở S01 và đầu trang S03)
String storeBatchStatusLabel(StoreBatchStatus s, AppLocalizations l10n) => switch (s) {
  StoreBatchStatus.estimated => l10n.storeBatchStatusEstimated,
  StoreBatchStatus.onSale => l10n.storeBatchStatusOnSale,
  StoreBatchStatus.ended => l10n.storeBatchStatusEnded,
};

BadgeTone storeBatchStatusTone(StoreBatchStatus s) => switch (s) {
  StoreBatchStatus.estimated => BadgeTone.warning,
  StoreBatchStatus.onSale => BadgeTone.soft,
  StoreBatchStatus.ended => BadgeTone.neutral,
};

// SCR-S01 ホーム（今日）— Figma 553:120 / Loading 553:231 / Empty 553:291 / Error 553:379
class StoreHomePage extends ConsumerWidget {
  const StoreHomePage({
    super.key,
    required this.restaurant,
    required this.userId,
    required this.onRegister,
    this.onOpenNotice,
  });
  final StoreRestaurant restaurant;
  final String userId;
  final VoidCallback onRegister;
  // Chạm 1 dòng ở お知らせ (SCR-S07) → shell mở màn theo loại (storeNoticeAction)
  final InboxOpener? onOpenNotice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final eco = context.eco;
    final locale = Localizations.localeOf(context).languageCode;
    final id = restaurant.id;
    final batches = ref.watch(storeTodayBatchesProvider(id));

    Future<void> refresh() async {
      ref.invalidate(photoRemovalsProvider(id));
      ref.invalidate(storeMonthRevenueProvider(id));
      ref.invalidate(storeRatingsProvider(id));
      ref.invalidate(inboxUnreadProvider(userId));
      await ref.refresh(storeTodayBatchesProvider(id).future).catchError((_) => <StoreBatch>[]);
    }

    final header = Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(formatServiceDate(todayInTokyo(), locale), style: TextStyle(fontSize: 13, color: eco.textSecondary)),
              const SizedBox(height: 2),
              Text(restaurant.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        InboxBellButton(userId: userId, onOpen: onOpenNotice),
      ],
    );
    final main = <Widget>[
      _RegisterCta(onTap: onRegister),
      _PhotoRemovalNotice(restaurantId: id),
      const SizedBox(height: 20),
      Text(l10n.storeTodayBatches, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      ...batches.when(
        loading: () => [
          for (var i = 0; i < 2; i++) ...[
            const SkeletonPulse(child: SkeletonBox(height: 96, radius: 16)),
            const SizedBox(height: 12),
          ],
        ],
        error: (_, _) => [
          StatePanel.error(
            title: l10n.storeLoadErrorTitle,
            message: l10n.storeLoadErrorBody,
            actionLabel: l10n.storeReload,
            onAction: () => ref.invalidate(storeTodayBatchesProvider(id)),
          ),
        ],
        data: (list) => list.isEmpty
            ? [
                StatePanel(
                  icon: Icons.inventory_2_outlined,
                  title: l10n.storeNoBatchesTitle,
                  message: l10n.storeNoBatchesBody,
                ),
              ]
            : [
                for (final b in list) ...[
                  StoreBatchCard(
                    batch: b,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => StoreBatchDetailPage(restaurantId: id, batchId: b.id),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
      ),
    ];
    final wide = isWideLayout(context);
    final side = <Widget>[
      _RevenueCards(restaurantId: id, stacked: wide),
      const SizedBox(height: 12),
      _RatingsRow(restaurantId: id),
    ];

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            header,
            const SizedBox(height: 16),
            // iPad ngang (Figma 559:841): việc hôm nay bên trái, số liệu tháng / đánh giá bên phải
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: main),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 340,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: side),
                  ),
                ],
              )
            else ...[
              ...main,
              const SizedBox(height: 8),
              ...side,
            ],
          ],
        ),
      ),
    );
  }
}

// Nút lớn「今日の余剰を登録」+ đếm ngược tới 16:00 (cập nhật mỗi phút)
class _RegisterCta extends StatefulWidget {
  const _RegisterCta({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_RegisterCta> createState() => _RegisterCtaState();
}

class _RegisterCtaState extends State<_RegisterCta> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final nowJst = toTokyo(DateTime.now());
    final deadline = DateTime.utc(nowJst.year, nowJst.month, nowJst.day, storeRegisterDeadlineHour);
    final left = deadline.difference(nowJst);
    final time = '$storeRegisterDeadlineHour:00';
    final String subtitle;
    if (left.inMinutes <= 0) {
      subtitle = l10n.storeRegisterDeadlinePassed(time);
    } else {
      final h = left.inMinutes ~/ 60;
      final m = left.inMinutes % 60;
      subtitle = l10n.storeRegisterDeadline(time, h > 0 ? l10n.durationHoursMinutes(h, m) : l10n.minutesShort(m));
    }
    return Material(
      color: eco.primary,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        key: const Key('storeRegisterCta'),
        borderRadius: BorderRadius.circular(20),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.storeRegisterCta,
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Thông báo ảnh món bị 運営 gỡ (0040, SCR-W16) — giống PhotoRemovalNotice của Web: hiện tới khi quán bấm 確認しました
class _PhotoRemovalNotice extends ConsumerWidget {
  const _PhotoRemovalNotice({required this.restaurantId});
  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final removals = ref.watch(photoRemovalsProvider(restaurantId)).valueOrNull ?? const [];
    if (removals.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final eco = context.eco;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Container(
        key: const Key('storePhotoRemovalNotice'),
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        decoration: BoxDecoration(
          color: eco.amberSoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: eco.amber),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.image_outlined, size: 22, color: AppColors.amberInk),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.storePhotoRemovedTitle,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.amberInk),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${removals.first.reason}\n${l10n.storePhotoRemovedHint}',
                    style: const TextStyle(fontSize: 13, height: 1.5),
                  ),
                  TextButton(
                    key: const Key('storePhotoRemovalAck'),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: AppColors.amberInk),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final failed = l10n.storeLoadErrorBody;
                      try {
                        await ref.read(storeGatewayProvider).acknowledgePhotoRemovals(restaurantId);
                        ref.invalidate(photoRemovalsProvider(restaurantId));
                      } catch (_) {
                        messenger.showSnackBar(SnackBar(content: Text(failed)));
                      }
                    },
                    child: Text(l10n.storePhotoRemovedAck),
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

// Thẻ lô ở S01 (component "Store/Batch card" 553:119)
class StoreBatchCard extends StatelessWidget {
  const StoreBatchCard({super.key, required this.batch, required this.onTap});
  final StoreBatch batch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final status = batch.statusAt(storeClock());
    final estimated = status == StoreBatchStatus.estimated;
    final planned = batch.collectionPlannedAt;
    final secondary = estimated
        ? (planned == null ? '' : l10n.storeCollectionPlanned(_hm(planned)))
        : l10n.storeSellBy(_hm(batch.sellByAt));
    return Material(
      color: eco.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: eco.border),
          ),
          child: Row(
            children: [
              BatchPhoto(photoUrl: batch.photoUrl, width: 72, height: 72, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StatusBadge(label: storeBatchStatusLabel(status, l10n), tone: storeBatchStatusTone(status)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(secondary, style: TextStyle(fontSize: 12, color: eco.textSecondary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      estimated || batch.confirmedQty == null
                          ? l10n.storeBatchQtyEstimated(batch.estimatedQty)
                          : l10n.storeBatchQtyConfirmed(batch.estimatedQty, batch.confirmedQty!),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      estimated
                          ? l10n.storeBatchReserved(batch.reservedCount)
                          : l10n.storeBatchCounts(batch.reservedCount, batch.pickedUpCount),
                      style: TextStyle(fontSize: 13, color: eco.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: eco.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _RevenueCards extends ConsumerWidget {
  const _RevenueCards({required this.restaurantId, this.stacked = false});
  final String restaurantId;
  final bool stacked; // iPad: 2 thẻ chồng dọc ở cột phải

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final eco = context.eco;
    final locale = Localizations.localeOf(context).languageCode;
    final revenue = ref.watch(storeMonthRevenueProvider(restaurantId)).valueOrNull;
    final today = todayInTokyo();
    final from = DateFormat.MMMd(locale).format(DateTime.parse('${today.substring(0, 8)}01'));

    Widget card(String label, String value, String sub, Key key) => _Flex(
      expand: !stacked,
      child: Container(
        key: key,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: eco.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: eco.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: eco.textSecondary)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(sub, style: TextStyle(fontSize: 11, color: eco.textSecondary)),
          ],
        ),
      ),
    );

    return Flex(
      direction: stacked ? Axis.vertical : Axis.horizontal,
      // stretch chỉ khi chồng dọc (thẻ rộng bằng cột); nằm ngang trong ListView thì chiều cao không giới hạn
      crossAxisAlignment: stacked ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
      children: [
        card(
          l10n.storeMonthSales,
          revenue == null ? '—' : formatYen(revenue.revenue),
          revenue == null ? '' : l10n.storeMonthSalesSub(revenue.orders, from),
          const Key('storeMonthSales'),
        ),
        const SizedBox(width: 12, height: 12),
        card(
          l10n.storeMonthPayout,
          revenue == null ? '—' : formatYen(revenue.payout),
          revenue == null ? '' : l10n.storeSharePct(formatSharePct(revenue.sharePct)),
          const Key('storeMonthPayout'),
        ),
      ],
    );
  }
}

class _RatingsRow extends ConsumerWidget {
  const _RatingsRow({required this.restaurantId});
  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final eco = context.eco;
    final ratings = ref.watch(storeRatingsProvider(restaurantId)).valueOrNull;
    if (ratings == null) return const SizedBox.shrink();
    final average = ratings.average;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => StoreRatingsPage(restaurantId: restaurantId))),
      child: Container(
        key: const Key('storeRatingsRow'),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: eco.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: eco.border),
        ),
        child: Row(
          children: [
            Icon(Icons.star_rounded, color: eco.amber, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    average == null ? l10n.storeRatingsNone : l10n.storeRatingsRow(average.toStringAsFixed(1)),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  if (average != null)
                    Text(l10n.storeRatingsSub(ratings.count), style: TextStyle(fontSize: 12, color: eco.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: eco.textSecondary),
          ],
        ),
      ),
    );
  }
}

// Expanded khi 2 thẻ nằm ngang; giữ nguyên khi chồng dọc (Expanded trong Column không giới hạn chiều cao sẽ lỗi)
class _Flex extends StatelessWidget {
  const _Flex({required this.expand, required this.child});
  final bool expand;
  final Widget child;

  @override
  Widget build(BuildContext context) => expand ? Expanded(child: child) : child;
}
