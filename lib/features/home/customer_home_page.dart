import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
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
  const CustomerHomePage({super.key, this.onOpenMyPage});
  final VoidCallback? onOpenMyPage;

  @override
  ConsumerState<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends ConsumerState<CustomerHomePage> {
  VoidCallback? _unsubscribe;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      ref.invalidate(activeListingsProvider);
      ref.invalidate(todayTrucksProvider);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trucksAsync = ref.watch(todayTrucksProvider);
    final positionAsync = ref.watch(currentPositionProvider);
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: Stack(
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
                const _FloatingLogo(),
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
          DraggableScrollableSheet(
            initialChildSize: 0.46,
            minChildSize: 0.16,
            maxChildSize: 0.8,
            builder: (context, scrollController) => _HomeSheet(
              scrollController: scrollController,
              myPosition: positionAsync.valueOrNull,
              onOpenMyPage: widget.onOpenMyPage,
            ),
          ),
        ],
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
    required this.myPosition,
    required this.onOpenMyPage,
  });
  final ScrollController scrollController;
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
    final trucks = ref.watch(todayTrucksProvider).valueOrNull ?? const <TruckRoute>[];
    TruckRoute? truck;
    for (final t in trucks) {
      if (t.nextStop != null) {
        truck = t;
        break;
      }
    }
    final next = truck?.nextStop;
    if (truck == null || next == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final minutes = next.plannedTime.difference(DateTime.now()).inMinutes;
    final truckId = truck.truckId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            key: const Key('truckStatusCard'),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => ref.read(selectedTruckIdProvider.notifier).state = truckId,
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
                            l10n.truckEta(
                              DateFormat('HH:mm').format(toTokyo(next.plannedTime)),
                              minutes < 0 ? 0 : minutes,
                            ),
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
  });
  final List<TruckRoute> trucks;
  final String? selectedTruckId;
  final ValueChanged<String> onSelectTruck;
  final Position? myPosition;
  @override
  State<_Map> createState() => _MapState();
}

class _MapState extends State<_Map> {
  GoogleMapController? _controller;
  BitmapDescriptor? _truckIcon;

  @override
  void initState() {
    super.initState();
    _loadTruckIcon();
  }

  Future<void> _loadTruckIcon() async {
    final icon = await loadTruckMarkerIcon();
    if (mounted) setState(() => _truckIcon = icon);
  }

  @override
  void didUpdateWidget(covariant _Map oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.myPosition == null && widget.myPosition != null) _locate();
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
                  position: LatLng(p.lat, p.lng),
                  icon: _truckIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                  // Xe đang chọn nổi lên trên các xe khác; nhãn "n号車" khớp tiêu đề sheet.
                  zIndexInt: truck.truckId == widget.selectedTruckId ? 1 : 0,
                  infoWindow: InfoWindow(title: context.l10n.truckNumber(index + 1)),
                  onTap: () => widget.onSelectTruck(truck.truckId),
                ),
          },
        ),
        Positioned(
          right: 16,
          bottom: MediaQuery.sizeOf(context).height * 0.48,
          child: FloatingActionButton.small(
            heroTag: 'locateMe',
            tooltip: context.l10n.locateMe,
            onPressed: position == null ? null : _locate,
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}
