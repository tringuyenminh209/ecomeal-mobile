import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/jst_date.dart';
import '../../core/maps.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/state_panel.dart';
import '../../widgets/status_badge.dart';
import 'driver_gateway.dart';
import 'driver_profile_page.dart';
import 'driver_route_helpers.dart';
import 'gps_reporter.dart';
import 'pickup_confirm_page.dart';
import 'stop_handoff_page.dart';
import '../../widgets/skeleton.dart';

// SCR-D01 ドライバーホーム — 06_画面設計 §SCR-D01, khớp frame Figma 16:16731: tiêu đề + trạng thái GPS +
// nút 設定, bản đồ bo 12, 2 ô số liệu, khung danh sách điểm dừng dạng dòng thời gian, viên "GPS送信中" nổi.
class DriverHomePage extends ConsumerWidget {
  const DriverHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeAsync = ref.watch(tonightRouteProvider);
    final gps = ref.watch(gpsReporterProvider);
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: routeAsync.when(
          // Khung: header xe, bản đồ 220, 3 thẻ tóm tắt / điểm dừng
          loading: () => const SkeletonList(heights: [56, 220, 72, 88, 88], padding: EdgeInsets.fromLTRB(16, 8, 16, 24)),
          error: (_, __) => Center(
            child: StatePanel.error(
              title: l10n.errorLoadTitle,
              message: l10n.errorLoadBody,
              actionLabel: l10n.retry,
              onAction: () => ref.invalidate(tonightRouteProvider),
            ),
          ),
          data: (route) {
            if (route == null) {
              return Center(
                child: StatePanel(icon: Icons.local_shipping_outlined, title: l10n.noTruckAssigned),
              );
            }
            return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(tonightRouteProvider),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      _Header(truck: route.truck),
                      SizedBox(height: 220, child: _DriverMap(stops: route.stops, gps: gps)),
                      const SizedBox(height: 12),
                      if (route.stops.isEmpty)
                        StatePanel(icon: Icons.route_outlined, title: l10n.noRouteTonight)
                      else ...[
                        RouteSummaryCards(stops: route.stops),
                        const SizedBox(height: 12),
                        RouteStopList(
                          stops: route.stops,
                          onTapStop: (stop) => openStop(context, ref, route, stop),
                        ),
                      ],
                    ],
                  ),
                );
          },
        ),
      ),
    );
  }
}

// 05_画面遷移図: D01 →(飲食店到着) D02 / →(停車地点到着) D03. Dùng chung cho tab 受取 (driver_shell).
Future<void> openStop(BuildContext context, WidgetRef ref, TonightRoute route, DriverStop stop) async {
  final l10n = context.l10n;
  if (stop.type != 'restaurant') {
    // Điểm bán → SCR-D03 (Chương 20). Quay về với message khi đã "出発" (close_route_stop).
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => StopHandoffPage(route: route, stop: stop)),
    );
    if (!context.mounted) return;
    if (message != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    ref.invalidate(tonightRouteProvider); // số đơn/đã giao ở D01 thay đổi dù có 出発 hay không
    return;
  }
  final List<PickupBatch> batches;
  try {
    batches = await ref.read(driverGatewayProvider).fetchPendingBatches(routeId: route.routeId!, restaurantId: stop.restaurantId!);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorLoad)));
    }
    return;
  }
  if (!context.mounted) return;
  if (batches.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.noPendingPickup)));
    return;
  }
  // 1 nhà hàng có thể đăng ký ước tính nhiều lô trong 1 tối — hỏi lô nào khi có hơn 1.
  final batch = batches.length == 1
      ? batches.first
      : await showDialog<PickupBatch>(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text(l10n.selectBatchToPickUp),
            children: [
              for (final b in batches)
                SimpleDialogOption(onPressed: () => Navigator.of(context).pop(b), child: Text(l10n.estimatedMeals(b.estimatedQty))),
            ],
          ),
        );
  if (batch == null || !context.mounted) return;
  final message = await Navigator.of(context).push<String>(
    MaterialPageRoute(builder: (_) => PickupConfirmPage(route: route, collectionStop: stop, batch: batch)),
  );
  if (message != null && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    ref.invalidate(tonightRouteProvider);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.truck});
  final DriverTruck truck;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 0, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.tonightRouteTitle, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(truck.plateNumber, style: Theme.of(context).textTheme.bodySmall),
                // ja: 10月2日(金) / en: Fri, Oct 2 — "đêm nay" theo giờ Nhật, mẫu ngày theo locale
                Text(DateFormat.MMMEd(l10n.localeName).format(toTokyo(DateTime.now())), style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          OutlinedButton(
            key: const Key('driverSettingsButton'),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DriverProfilePage())),
            child: Text(l10n.settings),
          ),
        ],
      ),
    );
  }
}

// Figma 16:16731: bản đồ bo 12, marker xe Eco-Truck ở vị trí gửi gần nhất, viên GPS ở góc dưới trái.
// Chưa có key Maps (hoặc chạy web) → khung hướng dẫn, giống SCR-M03 — viên GPS vẫn hiện vì GPS vẫn gửi.
class _DriverMap extends StatefulWidget {
  const _DriverMap({required this.stops, required this.gps});
  final List<DriverStop> stops;
  final GpsState gps;

  @override
  State<_DriverMap> createState() => _DriverMapState();
}

class _DriverMapState extends State<_DriverMap> {
  BitmapDescriptor? _truckIcon;

  @override
  void initState() {
    super.initState();
    if (isGoogleMapsConfigured) {
      loadTruckMarkerIcon().then((icon) {
        if (mounted) setState(() => _truckIcon = icon);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gps = widget.gps;
    final stops = widget.stops;
    final Widget map;
    if (!isGoogleMapsConfigured) {
      map = ColoredBox(
        color: context.eco.primarySoft,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(context.l10n.mapSetupRequired, textAlign: TextAlign.center),
          ),
        ),
      );
    } else {
      final markers = <Marker>{
        for (final s in stops)
          Marker(
            markerId: MarkerId(s.routeStopId),
            position: LatLng(s.lat, s.lng),
            infoWindow: InfoWindow(title: s.name),
            icon: BitmapDescriptor.defaultMarkerWithHue(s.type == 'restaurant' ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueGreen),
          ),
        if (gps.lat != null)
          Marker(
            markerId: const MarkerId('truck'),
            position: LatLng(gps.lat!, gps.lng!),
            icon: _truckIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            zIndexInt: 1,
          ),
      };
      final center = gps.lat != null
          ? LatLng(gps.lat!, gps.lng!)
          : (stops.isNotEmpty ? LatLng(stops.first.lat, stops.first.lng) : osakaCenter);
      map = GoogleMap(
        initialCameraPosition: CameraPosition(target: center, zoom: 13),
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        markers: markers,
        style: mapStyleFor(Theme.of(context).brightness),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Positioned.fill(child: map),
          Positioned(left: 12, bottom: 12, child: _GpsPill(status: gps.status)),
        ],
      ),
    );
  }
}

// "GPS transmission status" của Figma: viên nền xanh đậm (cùng màu thanh tab tài xế), chấm xanh + "GPS送信中".
// GPS lỗi → chấm đỏ + "位置情報取得不可" (06 §SCR-D01 状態). Chưa bắt đầu gửi (idle) → không vẽ.
class _GpsPill extends StatelessWidget {
  const _GpsPill({required this.status});
  final GpsStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == GpsStatus.idle) return const SizedBox.shrink();
    final isError = status == GpsStatus.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.eco.driverNav,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x1AFFFFFF)),
        boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 4))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: isError ? context.eco.error : Color(0xFF4CAF50), shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            isError ? context.l10n.gpsUnavailable : context.l10n.gpsSending,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// 2 ô "次の停車" / "予約注文" — tách public để widget test được mà không cần GoogleMap.
class RouteSummaryCards extends StatelessWidget {
  const RouteSummaryCards({super.key, required this.stops, this.now});
  final List<DriverStop> stops;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final next = nextStopOf(stops);
    final reservedAtNext = next?.reservedCount ?? 0;
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _MetricBox(
            label: l10n.nextStopLabel,
            value: next == null ? '—' : l10n.minutesShort(minutesUntil(next.plannedTime, now: now)),
            valueColor: context.eco.amber,
            caption: next?.name ?? l10n.allStopsCompleted,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricBox(label: l10n.reservedOrdersLabel, value: l10n.countItems(reservedAtNext), caption: l10n.reservedOrdersCaption),
        ),
      ],
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({required this.label, required this.value, required this.caption, this.valueColor});
  final String label;
  final String value;
  final String caption;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final small = TextStyle(fontSize: 11, color: context.eco.textSecondary);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.eco.surface,
        border: Border.all(color: context.eco.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: small),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: valueColor ?? context.eco.textPrimary)),
          const SizedBox(height: 5),
          Text(caption, style: small, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// Khung "Stops" của Figma: tiêu đề + nhãn 運行中/完了, mỗi điểm 1 dòng thời gian (chấm tròn + đường nối).
// Chấm đặc = điểm kế tiếp; chấm rỗng = đã xong hoặc còn sau. Trạng thái luôn có chữ ở dòng phụ (完了/次の停車).
class RouteStopList extends StatelessWidget {
  const RouteStopList({super.key, required this.stops, required this.onTapStop});
  final List<DriverStop> stops;
  final void Function(DriverStop stop) onTapStop;

  String _subtitle(DriverStop stop, DriverStop? next, AppLocalizations l10n) {
    if (stop.departedAt != null) {
      return stop.type == 'restaurant' ? l10n.stopDonePickup : l10n.stopDoneHandoff(stop.pickedUpCount);
    }
    final body = stop.type == 'restaurant' ? l10n.stopKindPickup : l10n.stopReservations(stop.reservedCount);
    return identical(stop, next) ? l10n.nextStopPrefixed(body) : body;
  }

  @override
  Widget build(BuildContext context) {
    final next = nextStopOf(stops);
    final timeFormat = DateFormat('HH:mm');
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.eco.surface,
        border: Border.all(color: context.eco.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.stopCount(stops.length), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              next == null
                  ? StatusBadge(label: l10n.routeDone, tone: BadgeTone.neutral)
                  : StatusBadge(label: l10n.routeInProgress),
            ],
          ),
          const SizedBox(height: 12),
          for (final (i, stop) in stops.indexed)
            InkWell(
              key: Key('stop_${stop.routeStopId}'),
              onTap: () => onTapStop(stop),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 24,
                      child: Column(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: identical(stop, next) ? context.eco.primary : context.eco.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: context.eco.primary, width: 2),
                            ),
                          ),
                          if (i < stops.length - 1) Expanded(child: Container(width: 2, color: context.eco.border)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(stop.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
                                Text(
                                  timeFormat.format(toTokyo(stop.plannedTime)),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: identical(stop, next) ? context.eco.primary : context.eco.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(_subtitle(stop, next, l10n), style: TextStyle(fontSize: 11, color: context.eco.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
