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
// giao (đã rời: mờ, kế tiếp: vàng), chấm xe theo GPS gửi gần nhất. Đường nối là NÉT ĐỨT giữa các điểm — chỉ thứ tự, không
// phải đường xe chạy (chưa có dữ liệu đường bộ; audit D08 bước 2 mới vẽ theo đường thật).
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
  });
  final List<DriverStop> stops;
  final GpsState gps;
  final String? selectedStopId;
  final void Function(DriverStop stop)? onTapStop;
  final VoidCallback? onTapMap;
  final void Function(GoogleMapController controller)? onController;
  // Bản đồ nằm trong danh sách cuộn (ホーム): nhận cử chỉ trước ListView (mapGestureRecognizers)
  final bool inScrollView;

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
        if (points.length > 1)
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

// SCR-D08 ルートの地図（全画面）— Figma 966:1785 / chọn điểm 967:1785, audit D08 bước 1. Chỉ dùng dữ liệu đang có
// (tuyến đêm nay + GPS gửi gần nhất), không thêm API. Chạm pin → thẻ của điểm đó; chạm chỗ trống → về 「次にやること」.
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
                  // Trung thực về nét nối: chưa có dữ liệu đường bộ (bước 2)
                  Container(
                    key: const Key('routeMapLegend'),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: eco.surface.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(8)),
                    child: Text(l10n.routeMapLegend, style: TextStyle(fontSize: 11, color: eco.textSecondary)),
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
