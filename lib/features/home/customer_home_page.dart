import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/haptics.dart';
import '../../core/motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/jst_date.dart';
import '../../core/line_official_account.dart';
import '../../core/location.dart';
import '../../core/maps.dart';
import '../../l10n/l10n.dart';
import '../../widgets/ecomeal_logo.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/state_panel.dart';
import '../../widgets/status_badge.dart';
import '../profile/profile_gateway.dart';
import 'batch_card.dart';
import 'home_gateway.dart';
import 'sort_by_proximity.dart';
import '../notifications/notification_inbox.dart';
import 'truck_glide.dart';
import 'truck_route_section.dart';
import '../../widgets/skeleton.dart';

final activeListingsProvider = FutureProvider.autoDispose<List<BatchListing>>((
  ref,
) {
  return ref.watch(homeGatewayProvider).fetchActiveListings();
});

final todayTrucksProvider = FutureProvider.autoDispose<List<TruckRoute>>((ref) {
  return ref.watch(homeGatewayProvider).fetchTodayTrucks();
});

// Xe đang được chọn trên bản đồ/thẻ xe (レビュー第68回). null = danh sách "近くのフードバッグ" như cũ.
final selectedTruckIdProvider = StateProvider.autoDispose<String?>((ref) => null);

final currentPositionProvider = FutureProvider.autoDispose<Position>((ref) {
  // Logic xin quyền + lấy toạ độ nằm ở core/location.dart (Chương 19) — GPS tài xế dùng chung.
  return getCurrentPositionWithPermission();
});


// SCR-M03 — khớp frame Figma 16:16388 (Default) / 125:294 (Empty) / 125:379 (Error): bản đồ toàn màn +
// thẻ logo nổi góc trên, bottom sheet trắng bo 24 chứa thẻ xe và các thẻ lô cuộn ngang.
class CustomerHomePage extends ConsumerStatefulWidget {
  // onOpenMyPage: nút "LINE通知を設定する" ở trạng thái Empty mở tab マイページ (SCR-M07). Trang này
  // không tự biết tab — CustomerShell (Chương 17, giữ cả Bottom Navigation) truyền vào; null thì không vẽ nút.
  const CustomerHomePage({super.key, this.onOpenMyPage, this.onOpenOrders, this.userId});
  final VoidCallback? onOpenMyPage;
  // Người đang đăng nhập — có thì hiện chuông お知らせ (SCR-M20)
  final String? userId;
  // Chạm 1 thông báo ở SCR-M20 (hoàn tiền, xe sắp tới, trả lời báo cáo) → tab 予約
  final VoidCallback? onOpenOrders;

  @override
  ConsumerState<CustomerHomePage> createState() => _CustomerHomePageState();
}

// 3 mức dừng của sheet SCR-M03 (Figma 881:1929 低 / 881:2041 中 / 881:2137 高)
enum _SheetLevel { peek, mid, full }

// Mức 中 = bố cục cũ (thẻ xe + thẻ ngang). 低 và 高 tính theo chiều cao màn hình (xem build).
const _midSize = 0.46;
// 低: tay cầm + tiêu đề + 1 dòng tóm tắt xe (nhân theo cỡ chữ hệ thống)
const _peekHeight = 120.0;
// 高: đáy sheet dừng dưới thẻ logo (12 lề + 46 thẻ + 12 khoảng trống), vẫn thấy một dải bản đồ
const _topBarHeight = 70.0;

class _CustomerHomePageState extends ConsumerState<CustomerHomePage> {
  VoidCallback? _unsubscribe;
  Timer? _refreshTimer;
  final _sheet = DraggableScrollableController();
  _SheetLevel _level = _SheetLevel.mid;
  // Sheet đang nằm đúng 1 mức dừng — rung nhẹ 1 lần khi vừa tới mức (không rung liên tục lúc kéo)
  bool _atStop = true;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      ref.invalidate(activeListingsProvider);
      ref.invalidate(todayTrucksProvider);
      ref.invalidate(inboxUnreadProvider); // chấm đỏ ở chuông (SCR-M20)
    });
    _unsubscribe = ref
        .read(homeGatewayProvider)
        .watchChanges(
          onChange: () {
            if (!mounted) return;
            ref.invalidate(activeListingsProvider);
            ref.invalidate(todayTrucksProvider);
          },
        );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _unsubscribe?.call();
    _sheet.dispose();
    super.dispose();
  }

  // Chỉ setState khi đổi mức (không phải mỗi khung hình lúc kéo)
  void _onSheetMoved(double extent, List<double> stops) {
    final (low, mid, high) = (stops[0], stops[1], stops[2]);
    final level = extent < (low + mid) / 2
        ? _SheetLevel.peek
        : extent > (mid + high) / 2
        ? _SheetLevel.full
        : _SheetLevel.mid;
    if (level != _level) setState(() => _level = level);
    final atStop = stops.any((s) => (extent - s).abs() < 0.002);
    if (atStop && !_atStop) Haptics.selection();
    _atStop = atStop;
  }

  // Chọn xe (marker / dòng tóm tắt) → về 中 để thấy lộ trình xe đó
  void _showMid() {
    if (!_sheet.isAttached || _level == _SheetLevel.mid) return;
    if (Motion.reduced(context)) {
      _sheet.jumpTo(_midSize);
    } else {
      _sheet.animateTo(_midSize, duration: Motion.small, curve: Motion.move);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trucksAsync = ref.watch(todayTrucksProvider);
    final positionAsync = ref.watch(currentPositionProvider);
    final topInset = MediaQuery.paddingOf(context).top;
    final userId = widget.userId;
    ref.listen<String?>(selectedTruckIdProvider, (_, id) {
      if (id != null) _showMid();
    });

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          final low = (MediaQuery.textScalerOf(context).scale(_peekHeight) / h).clamp(0.12, 0.3);
          final high = (1 - (topInset + _topBarHeight) / h).clamp(_midSize + 0.1, 0.9);
          final stops = [low, _midSize, high];
          return Stack(
        children: [
          Positioned.fill(
            child: trucksAsync.when(
              loading: () => const ColoredBox(color: AppColors.chip),
              error: (_, __) => const ColoredBox(color: AppColors.chip),
              data: (trucks) => _Map(
                trucks: trucks,
                selectedTruckId: ref.watch(selectedTruckIdProvider),
                onSelectTruck: (id) => ref.read(selectedTruckIdProvider.notifier).state = id,
                myPosition: positionAsync.valueOrNull,
                // Nút vị trí đứng ngay trên mép sheet; ở 高 sheet che gần hết bản đồ nên ẩn (Figma 881:2137)
                locateBottom: (_level == _SheetLevel.peek ? low : _midSize) * h + 12,
                showLocate: _level != _SheetLevel.full,
              ),
            ),
          ),
          Positioned(
            top: topInset + 12,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo bên trái, chuông お知らせ bên phải (Figma SCR-M03 "Notification bell" → SCR-M20)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FloatingLogo(),
                    const Spacer(),
                    if (userId != null)
                      InboxBellButton(
                        userId: userId,
                        floating: true,
                        emptyBody: context.l10n.inboxEmptyBodyCustomer,
                        // Lô mới ở điểm yêu thích → ở lại ホーム (đã đang ở đây); các loại khác là về đơn đã đặt
                        onOpen: (n) {
                          if (n.type != 'new_batch') widget.onOpenOrders?.call();
                        },
                      ),
                  ],
                ),
                // Mất GPS chỉ làm danh sách mất thứ tự theo khoảng cách (vẫn sắp theo giờ hết hạn) —
                // không chặn cả sheet; báo ở banner nổi để người dùng thử lại (xem box-why bước 5).
                if (positionAsync.hasError) ...[
                  const SizedBox(height: 8),
                  ErrorBanner(
                    message:
                        '${context.l10n.errorLocationUnavailable}\n${context.l10n.errorLocationBody}',
                    retryLabel:
                        positionAsync.error == LocationPermission.deniedForever
                        ? context.l10n.openLocationSettings
                        : context.l10n.retry,
                    onRetry: () async {
                      if (positionAsync.error ==
                          LocationPermission.deniedForever) {
                        await Geolocator.openAppSettings();
                      }
                      ref.invalidate(currentPositionProvider);
                    },
                  ),
                ],
              ],
            ),
          ),
          // Thả tay → trượt tới mức gần nhất; vuốt nhanh → mức kế tiếp theo hướng vuốt (snap của Flutter)
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (n) {
              _onSheetMoved(n.extent, stops);
              return false;
            },
            child: DraggableScrollableSheet(
              controller: _sheet,
              initialChildSize: _midSize,
              minChildSize: low,
              maxChildSize: high,
              snap: true,
              snapSizes: const [_midSize],
              // Flutter không nhận 0 → 1ms khi người dùng tắt chuyển động
              snapAnimationDuration: Motion.reduced(context) ? const Duration(milliseconds: 1) : Motion.small,
              builder: (context, scrollController) => _HomeSheet(
                scrollController: scrollController,
                level: _level,
                myPosition: positionAsync.valueOrNull,
                onOpenMyPage: widget.onOpenMyPage,
              ),
            ),
          ),
        ],
      );
        },
      ),
    );
  }
}

class _FloatingLogo extends StatelessWidget {
  const _FloatingLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F1B1B1B),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const EcoMealLogo(height: 30),
    );
  }
}

class _HomeSheet extends ConsumerWidget {
  const _HomeSheet({
    required this.scrollController,
    required this.level,
    required this.myPosition,
    required this.onOpenMyPage,
  });
  final ScrollController scrollController;
  // 低: chỉ tiêu đề + dòng tóm tắt xe · 中: thẻ xe + thẻ ngang · 高: danh sách dọc gần nhất trước
  final _SheetLevel level;
  final Position? myPosition;
  final VoidCallback? onOpenMyPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(activeListingsProvider);
    final l10n = context.l10n;
    final count = listingsAsync.valueOrNull?.length;
    final trucks = ref.watch(todayTrucksProvider).valueOrNull ?? const <TruckRoute>[];
    final selectedId = ref.watch(selectedTruckIdProvider);
    final selectedIndex = trucks.indexWhere((t) => t.truckId == selectedId);

    return Container(
      key: const Key('homeSheet'),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x241B1B1B),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      // ListView nhận scrollController của sheet: kéo nội dung = kéo sheet lên/xuống.
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Xe đã chọn biến mất (hết tuyến hôm nay) → tự về danh sách thường thay vì sheet rỗng.
          if (selectedIndex >= 0)
            TruckRouteSection(
              truck: trucks[selectedIndex],
              number: selectedIndex + 1,
              listings: listingsAsync.valueOrNull ?? const [],
              onClose: () => ref.read(selectedTruckIdProvider.notifier).state = null,
            )
          else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.nearbyBatches,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (count != null && count > 0) ...[
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      l10n.countItems(count),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                StatusBadge(label: l10n.liveUpdating, tone: BadgeTone.soft),
              ],
            ),
          ),
          if (level == _SheetLevel.peek) ...[
            const SizedBox(height: 8),
            const _TruckPeekLine(),
          ] else ...[
          const SizedBox(height: 16),
          ...listingsAsync.when(
            loading: () => const [_SheetSkeleton()],
            error: (_, __) => [
              StatePanel.error(
                title: l10n.errorLoadTitle,
                message: l10n.errorLoadBody,
                actionLabel: l10n.retry,
                filledAction: false, // Figma: 再試行 là nút viền
                onAction: () => ref.invalidate(activeListingsProvider),
              ),
            ],
            data: (listings) {
              if (listings.isEmpty) {
                // Đã liên kết LINE thì mời cài lại là sai (Figma 239:638, レビュー第66回): đổi câu + nút mở LINE.
                // Chưa biết (đang tải/lỗi) thì giữ lời mời cũ — dẫn sang SCR-M07, nơi hiện trạng thái thật.
                final isLineLinked = ref.watch(lineLinkedProvider).valueOrNull == true;
                final canOpenLine = ref.watch(openLineOfficialAccountProvider) != null;
                return [
                  StatePanel(
                    icon: Icons.notifications_none_rounded,
                    title: l10n.homeEmptyTitle,
                    message: isLineLinked ? l10n.homeEmptyBodyLinked : l10n.homeEmptyBody,
                    actionLabel: isLineLinked ? (canOpenLine ? l10n.openLine : null) : l10n.setupLineNotify,
                    onAction: isLineLinked ? () => openLineOfficialAccount(context, ref) : onOpenMyPage,
                  ),
                ];
              }
              final sorted = sortListingsByProximity(
                listings,
                myLat: myPosition?.latitude,
                myLng: myPosition?.longitude,
              );
              if (level == _SheetLevel.full) {
                return [
                  for (final l in sorted)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: BatchCard(
                        listing: l,
                        compact: true,
                        width: double.infinity,
                        walkMinutes: walkMinutes(l, myLat: myPosition?.latitude, myLng: myPosition?.longitude),
                      ),
                    ),
                ];
              }
              return [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: _TruckStatusCard(),
                ),
                SizedBox(
                  height: BatchCard.rowHeight(context),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: sorted.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) =>
                        BatchCard(listing: sorted[index]),
                  ),
                ),
              ];
            },
          ),
          ],
          ],
        ],
      ),
    );
  }
}

// Xe đầu tiên còn điểm dừng phía trước — thẻ xe (中) và dòng tóm tắt (低) cùng dùng
({String truckId, String stopName, String time, int minutes})? _nextTruckStop(List<TruckRoute> trucks) {
  for (final t in trucks) {
    final next = t.nextStop;
    if (next == null) continue;
    final minutes = next.plannedTime.difference(DateTime.now()).inMinutes;
    return (
      truckId: t.truckId,
      stopName: next.stopName,
      time: DateFormat('HH:mm').format(toTokyo(next.plannedTime)),
      minutes: minutes < 0 ? 0 : minutes,
    );
  }
  return null;
}

// Mức 低 (Figma 881:1929): 1 dòng "Eco-Truck 運行中 · 次は… HH:mm（あと n 分）"; chạm = mở lộ trình xe (→ 中)
class _TruckPeekLine extends ConsumerWidget {
  const _TruckPeekLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = _nextTruckStop(ref.watch(todayTrucksProvider).valueOrNull ?? const []);
    if (next == null) return const SizedBox.shrink();
    return InkWell(
      key: const Key('truckPeekLine'),
      onTap: () => ref.read(selectedTruckIdProvider.notifier).state = next.truckId,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.local_shipping, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.truckPeek(next.stopName, next.time, next.minutes),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// TruckStatusCard của Figma: icon xe + "Eco-Truck 運行中" + điểm dừng kế tiếp + giờ đến dự kiến.
// Không có điểm kế tiếp (chưa có route hôm nay / xe đã đi hết) thì không vẽ thẻ — không bịa trạng thái.
// Nhiều xe: thẻ của xe đầu tiên còn điểm phía trước; chạm thẻ (hoặc marker) để mở lộ trình xe đó (Figma 16:16388).
class _TruckStatusCard extends ConsumerWidget {
  const _TruckStatusCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = _nextTruckStop(ref.watch(todayTrucksProvider).valueOrNull ?? const []);
    if (next == null) return const SizedBox.shrink();
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            key: const Key('truckStatusCard'),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => ref.read(selectedTruckIdProvider.notifier).state = next.truckId,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping, size: 44, color: AppColors.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.truckRunning,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.truckNextStop(next.stopName),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.truckEta(next.time, next.minutes),
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(l10n.truckTapHint, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// Loading của Figma: giữ khung (thẻ xe + 1 thẻ lô) bằng khối xám — sheet không nhảy bố cục khi dữ liệu về.
class _SheetSkeleton extends StatelessWidget {
  const _SheetSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget block(double height, {double? width}) => SkeletonBox(height: height, width: width, radius: 16);
    return SkeletonPulse(
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          block(96),
          const SizedBox(height: 16),
          block(168, width: 300),
        ],
      ),
      ),
    );
  }
}

class _Map extends StatefulWidget {
  const _Map({
    required this.trucks,
    required this.selectedTruckId,
    required this.onSelectTruck,
    required this.myPosition,
    required this.locateBottom,
    required this.showLocate,
  });
  final List<TruckRoute> trucks;
  final String? selectedTruckId;
  final ValueChanged<String> onSelectTruck;
  final Position? myPosition;
  final double locateBottom;
  final bool showLocate;
  @override
  State<_Map> createState() => _MapState();
}

class _MapState extends State<_Map> with SingleTickerProviderStateMixin {
  GoogleMapController? _controller;
  BitmapDescriptor? _truckIcon;

  // Xe trượt tới vị trí mới (truck_glide.dart): _from → vị trí lúc bắt đầu trượt, _shown → vị trí đang vẽ.
  // Chỉ setState khi sang bước mới (truckGlideSteps), không phải mỗi frame.
  late final AnimationController _glide;
  final Map<String, LatLng> _from = {};
  final Map<String, LatLng> _shown = {};
  int _glideStep = truckGlideSteps;

  @override
  void initState() {
    super.initState();
    // Tạo ngay (không lazy): nếu lần đầu chạm tới ở dispose() thì tạo Ticker trên cây đã gỡ → lỗi
    _glide = AnimationController(vsync: this, duration: Motion.marker)..addListener(_onGlideTick);
    _loadTruckIcon();
    for (final t in widget.trucks) {
      if (t.position case final p?) _shown[t.truckId] = LatLng(p.lat, p.lng);
    }
  }

  LatLng? _target(String truckId) {
    for (final t in widget.trucks) {
      if (t.truckId == truckId && t.position != null) return LatLng(t.position!.lat, t.position!.lng);
    }
    return null;
  }

  void _startGlide() {
    final reduced = Motion.reduced(context);
    var gliding = false;
    _from.clear();
    for (final t in widget.trucks) {
      final p = t.position;
      if (p == null) continue;
      final to = LatLng(p.lat, p.lng);
      final from = _shown[t.truckId];
      if (!reduced && from != null && shouldGlide(from, to)) {
        _from[t.truckId] = from;
        gliding = true;
      } else {
        _shown[t.truckId] = to;
      }
    }
    _shown.removeWhere((id, _) => _target(id) == null);
    if (gliding) {
      _glideStep = 0;
      _glide.forward(from: 0);
    }
  }

  void _onGlideTick() {
    final step = (_glide.value * truckGlideSteps).floor();
    if (step == _glideStep) return;
    final t = Motion.move.transform(_glide.value);
    setState(() {
      _glideStep = step;
      for (final MapEntry(key: id, value: from) in _from.entries) {
        final to = _target(id);
        if (to != null) _shown[id] = lerpLatLng(from, to, t);
      }
    });
  }

  Future<void> _loadTruckIcon() async {
    final icon = await loadTruckMarkerIcon();
    if (mounted) setState(() => _truckIcon = icon);
  }

  @override
  void didUpdateWidget(covariant _Map oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.myPosition == null && widget.myPosition != null) _locate();
    if (!identical(oldWidget.trucks, widget.trucks)) _startGlide();
  }

  void _locate() {
    final position = widget.myPosition;
    if (position != null) {
      _controller?.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
      );
    }
  }

  @override
  void dispose() {
    _glide.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isGoogleMapsConfigured) {
      return ColoredBox(
        color: AppColors.primarySoft,
        child: Align(
          alignment: const Alignment(0, -0.4),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              context.l10n.mapSetupRequired,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    final position = widget.myPosition;
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (controller) {
            _controller = controller;
          },
          initialCameraPosition: CameraPosition(
            target: position != null
                ? LatLng(position.latitude, position.longitude)
                : osakaCenter,
            zoom: 14,
          ),
          myLocationEnabled: position != null,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          padding: EdgeInsets.only(
            bottom: MediaQuery.sizeOf(context).height * 0.42,
          ),
          markers: {
            for (final (index, truck) in widget.trucks.indexed)
              if (truck.position case final p?)
                Marker(
                  markerId: MarkerId('truck_${truck.truckId}'),
                  position: _shown[truck.truckId] ?? LatLng(p.lat, p.lng),
                  icon: _truckIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                  // Xe đang chọn nổi lên trên các xe khác; nhãn "n号車" khớp tiêu đề sheet.
                  zIndexInt: truck.truckId == widget.selectedTruckId ? 1 : 0,
                  infoWindow: InfoWindow(title: context.l10n.truckNumber(index + 1)),
                  onTap: () => widget.onSelectTruck(truck.truckId),
                ),
          },
        ),
        AnimatedPositioned(
          duration: Motion.of(context, Motion.small),
          curve: Motion.move,
          right: 16,
          bottom: widget.locateBottom,
          child: IgnorePointer(
            ignoring: !widget.showLocate,
            child: AnimatedOpacity(
              duration: Motion.of(context, Motion.small),
              opacity: widget.showLocate ? 1 : 0,
              child: FloatingActionButton.small(
                heroTag: 'locateMe',
                tooltip: context.l10n.locateMe,
                onPressed: position == null ? null : _locate,
                child: const Icon(Icons.my_location),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
