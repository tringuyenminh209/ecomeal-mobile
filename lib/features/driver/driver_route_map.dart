import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/clock.dart';
import '../../core/maps.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/state_panel.dart';
import 'driver_gateway.dart';
import 'driver_home_page.dart' show NextTaskCard, RouteStopList, openDirectionsTo, openStop;
import 'driver_route_helpers.dart';
import 'gps_reporter.dart';

// Bản đồ tuyến dùng chung cho bản đồ nhỏ ở ホーム (SCR-D01) và trang toàn màn hình (SCR-D08). Pin có số theo thứ tự server
// giao (đã rời: mờ, kế tiếp: vàng), chấm xe theo GPS gửi gần nhất. Có đường bộ thật (D08 bước 2, chỉ SCR-D08) → nét LIỀN
// theo đường; không có (ホーム, đang tải, tải lỗi) → NÉT ĐỨT nối thẳng các điểm, chỉ thứ tự — không giả làm đường xe chạy.
class DriverRouteMap extends StatefulWidget {
  const DriverRouteMap({
    super.key,
    required this.stops,
    required this.gps,
    this.selectedStopId,
    this.onTapStop,
    this.onTapMap,
    this.onController,
    this.inScrollView = false,
    this.roadPolyline,
  });
  final List<DriverStop> stops;
  final GpsState gps;
  final String? selectedStopId;
  final void Function(DriverStop stop)? onTapStop;
  final VoidCallback? onTapMap;
  final void Function(GoogleMapController controller)? onController;
  // Bản đồ nằm trong danh sách cuộn (ホーム): nhận cử chỉ trước ListView (mapGestureRecognizers)
  final bool inScrollView;
  // Encoded polyline từ API-090 (xe → các điểm còn lại). null → nét đứt
  final String? roadPolyline;

  @override
  State<DriverRouteMap> createState() => _DriverRouteMapState();
}

class _DriverRouteMapState extends State<DriverRouteMap> {
  BitmapDescriptor? _truckIcon;
  Map<String, BitmapDescriptor> _pins = const {};

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPins();
  }

  @override
  void didUpdateWidget(DriverRouteMap old) {
    super.didUpdateWidget(old);
    if (old.stops != widget.stops) _loadPins();
  }

  Future<void> _loadPins() async {
    if (!isGoogleMapsConfigured) return;
    final eco = context.eco;
    final stops = widget.stops;
    final next = nextStopOf(stops);
    final pins = <String, BitmapDescriptor>{};
    for (final (i, s) in stops.indexed) {
      final isNext = identical(s, next);
      pins[s.routeStopId] = await numberedPin(
        i + 1,
        fill: isNext ? eco.amber : (s.departedAt != null ? eco.textSecondary : eco.primary),
        label: isNext ? eco.onAmber : Colors.white,
      );
    }
    if (mounted) setState(() => _pins = pins);
  }

  @override
  Widget build(BuildContext context) {
    final gps = widget.gps;
    final stops = widget.stops;
    if (!isGoogleMapsConfigured) {
      // Chưa có key Maps (hoặc chạy web) → khung hướng dẫn, giống SCR-M03
      return ColoredBox(
        color: context.eco.primarySoft,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(context.l10n.mapSetupRequired, textAlign: TextAlign.center),
          ),
        ),
      );
    }
    final next = nextStopOf(stops);
    final points = [for (final s in stops) LatLng(s.lat, s.lng)];
    final truck = gps.lat == null ? null : LatLng(gps.lat!, gps.lng!);
    final road = widget.roadPolyline == null ? const <LatLng>[] : decodePolyline(widget.roadPolyline!);
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: truck ?? (points.isNotEmpty ? points.first : osakaCenter), zoom: 13),
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      gestureRecognizers: widget.inScrollView ? mapGestureRecognizers : const {},
      markers: {
        for (final (i, s) in stops.indexed)
          Marker(
            markerId: MarkerId(s.routeStopId),
            position: points[i],
            infoWindow: InfoWindow(title: '${i + 1}. ${s.name}'),
            alpha: s.departedAt != null ? 0.5 : 1,
            icon: _pins[s.routeStopId] ??
                BitmapDescriptor.defaultMarkerWithHue(identical(s, next) ? BitmapDescriptor.hueYellow : BitmapDescriptor.hueGreen),
            zIndexInt: s.routeStopId == widget.selectedStopId ? 2 : 0,
            onTap: widget.onTapStop == null ? null : () => widget.onTapStop!(s),
          ),
        if (truck != null)
          Marker(
            markerId: const MarkerId('truck'),
            position: truck,
            icon: _truckIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            zIndexInt: 3,
          ),
      },
      polylines: {
        if (road.length > 1)
          Polyline(
            polylineId: const PolylineId('route-road'),
            points: road,
            width: 5,
            color: context.eco.amber,
            jointType: JointType.round,
          )
        else if (points.length > 1)
          Polyline(
            polylineId: const PolylineId('route-order'),
            points: points,
            width: 4,
            color: context.eco.amber.withValues(alpha: 0.85),
            patterns: [PatternItem.dash(18), PatternItem.gap(10)],
          ),
      },
      onTap: widget.onTapMap == null ? null : (_) => widget.onTapMap!(),
      // Mở bản đồ → vừa cả tuyến + vị trí xe
      onMapCreated: (c) {
        widget.onController?.call(c);
        fitCameraTo(c, [...points, if (truck != null) truck]);
      },
      style: mapStyleFor(Theme.of(context).brightness),
    );
  }
}

// SCR-D08 ルートの地図（全画面）— Figma 966:1785 / chọn điểm 967:1785 (bước 1). Bước 2 (Figma 978:1833 có đường /
// 978:1899 đang tải / 978:1965 tải lỗi): đường bộ thật + 「道で あと n分」 từ API-090. Chạm pin → thẻ của điểm đó;
// chạm chỗ trống → về 「次にやること」.
// Mở / đóng không đụng tới ホーム (trang push lên trên), nên không mất gì đang làm.
class DriverRouteMapPage extends ConsumerStatefulWidget {
  const DriverRouteMapPage({super.key});

  @override
  ConsumerState<DriverRouteMapPage> createState() => _DriverRouteMapPageState();
}

class _DriverRouteMapPageState extends ConsumerState<DriverRouteMapPage> {
  String? _selectedId;
  GoogleMapController? _map;

  void _select(DriverStop? stop) {
    setState(() => _selectedId = stop?.routeStopId);
    if (stop != null) _map?.animateCamera(CameraUpdate.newLatLng(LatLng(stop.lat, stop.lng)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final route = ref.watch(tonightRouteProvider).valueOrNull;
    final gps = ref.watch(gpsReporterProvider);
    final now = ref.watch(clockProvider)();
    if (route == null || route.stops.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.routeMapTitle)),
        body: Center(child: StatePanel(icon: Icons.route_outlined, title: l10n.noRouteTonight)),
      );
    }
    final stops = route.stops;
    final next = nextStopOf(stops);
    final selected = stops.where((s) => s.routeStopId == _selectedId).firstOrNull;
    final cardStop = selected ?? next;
    final truck = gps.lat == null ? null : LatLng(gps.lat!, gps.lng!);
    // Đã rời hết thì không còn đường để hỏi (không tốn phí)
    final roadAsync = next == null ? null : ref.watch(roadRouteProvider(next.routeStopId));
    final road = roadAsync?.valueOrNull;
    final roadFailed = roadAsync != null && roadAsync.hasError && !roadAsync.isLoading;
    final roadPolyline = roadFailed ? null : road?.polyline;
    final secondsToCard = cardStop == null || roadPolyline == null ? null : road!.secondsToStop[cardStop.routeStopId];
    final chipDecoration = BoxDecoration(color: eco.surface, borderRadius: BorderRadius.circular(14));

    Widget pillButton(Key key, String label, VoidCallback? onPressed) => FilledButton.tonal(
      key: key,
      onPressed: onPressed,
      style: FilledButton.styleFrom(backgroundColor: eco.surface, foregroundColor: eco.textPrimary, minimumSize: const Size(0, 40)),
      child: Text(label),
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DriverRouteMap(
              stops: stops,
              gps: gps,
              selectedStopId: _selectedId,
              onTapStop: _select,
              onTapMap: () => _select(null),
              onController: (c) => _map = c,
              roadPolyline: roadPolyline,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton.filled(
                        key: const Key('routeMapBack'),
                        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(backgroundColor: eco.surface, foregroundColor: eco.textPrimary),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: chipDecoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.routeMapTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                              Text(
                                next == null
                                    ? l10n.routeMapAllDone(stops.length)
                                    : l10n.routeMapSubtitle(stops.length, stops.indexOf(next) + 1),
                                key: const Key('routeMapSubtitle'),
                                style: TextStyle(fontSize: 11, color: eco.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      pillButton(
                        const Key('routeMapFitAll'),
                        l10n.routeMapFitAll,
                        () => _map == null ? null : fitCameraTo(_map!, [for (final s in stops) LatLng(s.lat, s.lng), if (truck != null) truck]),
                      ),
                      const SizedBox(width: 8),
                      pillButton(
                        const Key('routeMapMyLocation'),
                        l10n.routeMapMyLocation,
                        truck == null ? null : () => _map?.animateCamera(CameraUpdate.newLatLngZoom(truck, 15)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Trung thực về nét nối: nét liền chỉ khi đã có đường thật; tải lỗi thì nói rõ + cho tải lại
                  if (roadFailed)
                    _RoadFailedStrip(onRetry: () => ref.invalidate(roadRouteProvider(next!.routeStopId)))
                  else
                    _Legend(
                      roadAsync != null && roadAsync.isLoading && !roadAsync.hasValue
                          ? l10n.routeMapRoadLoading
                          : roadPolyline != null
                              ? l10n.routeMapRoadLegend(road!.remainingStops, (road.durationSeconds / 60).ceil(),
                                  (road.distanceMeters / 1000).toStringAsFixed(1))
                              : l10n.routeMapLegend,
                    ),
                ],
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.42,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder: (context, controller) => DecoratedBox(
              decoration: BoxDecoration(
                color: eco.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: eco.border, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (cardStop != null)
                    NextTaskCard(
                      route: route,
                      stop: cardStop,
                      now: now,
                      title: selected == null ? null : l10n.routeMapSelectedStop,
                      arriveLabel: selected == null ? null : l10n.routeMapOpenStop,
                      driveMinutes: secondsToCard == null ? null : (secondsToCard / 60).ceil(),
                      onNavigate: () => openDirectionsTo(context, ref, cardStop),
                      onArrive: () => openStop(context, ref, route, cardStop),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.routeMapListHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: eco.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  // Chạm 1 dòng → chọn điểm đó trên bản đồ (mở điểm bằng nút trên thẻ)
                  RouteStopList(route: route, onTapStop: _select),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final eco = context.eco;
    return Container(
      key: const Key('routeMapLegend'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: eco.surface.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(fontSize: 11, color: eco.textSecondary)),
    );
  }
}

// Figma 978:1965: không tải được đường → giữ nét đứt, nói rõ + 「もう一度」
class _RoadFailedStrip extends StatelessWidget {
  const _RoadFailedStrip({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final eco = context.eco;
    final l10n = context.l10n;
    return Row(
      children: [
        Flexible(
          child: Container(
            key: const Key('routeMapRoadFailed'),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: eco.surface.withValues(alpha: 0.92),
              border: Border.all(color: eco.amber),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(l10n.routeMapRoadFailed, style: TextStyle(fontSize: 11, color: eco.textPrimary)),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          key: const Key('routeMapRoadRetry'),
          onPressed: onRetry,
          style: OutlinedButton.styleFrom(
            backgroundColor: eco.surface,
            foregroundColor: eco.textPrimary,
            side: BorderSide(color: eco.amber),
            minimumSize: const Size(0, 44),
          ),
          child: Text(l10n.routeMapRoadRetry),
        ),
      ],
    );
  }
}
