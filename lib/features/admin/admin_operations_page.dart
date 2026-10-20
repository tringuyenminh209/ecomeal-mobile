import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/jst_date.dart';
import '../../core/maps.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/state_panel.dart';
import '../../widgets/status_badge.dart';
import 'admin_gateway.dart';

// Vị trí xe đổi mỗi 5 giây (GPS tài xế) — tải lại mỗi 20 giây khi màn đang mở. Nhãn ghi giờ tải thành công gần nhất
// 「HH:mm 更新（20秒ごと）」, tải lại lỗi thì 「更新できません · HH:mm 時点」 — trước đó luôn ghi 「ライブ」 dù dữ liệu cũ
// (review Web Admin 2026-10-18 F01, cùng kiểu lỗi; Figma 563:1079)
const adminOperationsRefresh = Duration(seconds: 20);

// Bề rộng cột 運行モニタ bên phải ダッシュボード trên iPad (Figma 791:3126)
const adminMonitorPaneWidth = 440.0;
// Từ bề rộng này (bản thân trang, không phải cả màn) trở lên: bản đồ lớn bên trái + danh sách xe bên phải (Figma 791:3350)
const _splitWidth = 720.0;
const _trucksPaneWidth = 380.0;

// SCR-A02 運行モニタ（563:1038）: bản đồ xe + điểm dừng, danh sách xe với điểm kế tiếp và giờ dự kiến
class AdminOperationsPage extends ConsumerStatefulWidget {
  // pollRoutes: false khi nhúng vào ダッシュボード (iPad) — tab 運行 vẫn sống trong IndexedStack và đã tải lại định kỳ
  const AdminOperationsPage({super.key, this.pollRoutes = true});
  final bool pollRoutes;

  @override
  ConsumerState<AdminOperationsPage> createState() => _AdminOperationsPageState();
}

class _AdminOperationsPageState extends ConsumerState<AdminOperationsPage> {
  Timer? _timer;
  // Lúc nhận dữ liệu thành công gần nhất (giờ máy) — cho nhãn cập nhật
  DateTime? _updatedAt;
  BitmapDescriptor? _truckIcon;
  final _date = todayInTokyo();

  @override
  void initState() {
    super.initState();
    ref.listenManual(adminRoutesProvider(_date), (_, next) {
      if (next.hasValue && !next.isLoading && !next.hasError) {
        if (mounted) setState(() => _updatedAt = DateTime.now());
      }
    }, fireImmediately: true);
    if (widget.pollRoutes) {
      _timer = Timer.periodic(adminOperationsRefresh, (_) => ref.invalidate(adminRoutesProvider(_date)));
    }
    if (isGoogleMapsConfigured) {
      loadTruckMarkerIcon().then((icon) {
        if (mounted) setState(() => _truckIcon = icon);
      });
    }
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
    final locale = Localizations.localeOf(context).languageCode;
    final routes = ref.watch(adminRoutesProvider(_date));
    final list = routes.valueOrNull ?? const <AdminRoute>[];
    final updatedAt = _updatedAt == null ? null : tokyoTime(_updatedAt!);
    // Lần tải lại lỗi nhưng vẫn giữ danh sách cũ → báo dữ liệu đã cũ
    final isStale = routes.hasError && routes.hasValue;
    final statusColor = isStale ? AppColors.amberInk : eco.primary;

    final header = Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.adminOpsTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              Text(
                l10n.adminOpsSubtitle(formatServiceDate(_date, locale), list.length),
                style: TextStyle(fontSize: 13, color: eco.textSecondary),
              ),
            ],
          ),
        ),
        if (updatedAt != null) ...[
          Icon(isStale ? Icons.sync_problem_rounded : Icons.sensors_rounded, size: 16, color: statusColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              isStale ? l10n.adminOpsStale(updatedAt) : l10n.adminOpsUpdatedAt(updatedAt),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: statusColor),
            ),
          ),
        ],
      ],
    );
    final trucks = routes.when(
      loading: () => <Widget>[const SkeletonPulse(child: SkeletonBox(height: 160, radius: 16))],
      error: (_, _) => [
        StatePanel.error(
          title: l10n.storeLoadErrorTitle,
          message: l10n.storeLoadErrorBody,
          actionLabel: l10n.storeReload,
          onAction: () => ref.invalidate(adminRoutesProvider(_date)),
        ),
      ],
      data: (rs) => rs.isEmpty
          ? [StatePanel(icon: Icons.local_shipping_outlined, title: l10n.adminNoRouteTonight)]
          : [
              Container(
                decoration: BoxDecoration(
                  color: eco.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: eco.border),
                ),
                child: Column(
                  children: [
                    for (final (i, r) in rs.indexed) ...[
                      if (i > 0) Divider(height: 1, color: eco.border),
                      _RouteTile(route: r),
                    ],
                  ],
                ),
              ),
            ],
    );
    Future<void> refresh() => ref.refresh(adminRoutesProvider(_date).future).then((_) {}, onError: (_) {});

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, box) {
          if (box.maxWidth >= _splitWidth) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        header,
                        const SizedBox(height: 14),
                        Expanded(
                          child: ClipRRect(borderRadius: BorderRadius.circular(16), child: _map(list, l10n, eco)),
                        ),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(width: 1, color: eco.border),
                SizedBox(
                  width: _trucksPaneWidth,
                  child: RefreshIndicator(
                    onRefresh: refresh,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      children: [
                        Text(l10n.adminOpsTrucks, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        ...trucks,
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return RefreshIndicator(
            onRefresh: refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                header,
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(height: 260, child: _map(list, l10n, eco)),
                ),
                const SizedBox(height: 14),
                ...trucks,
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _map(List<AdminRoute> routes, AppLocalizations l10n, EcoPalette eco) {
    if (!isGoogleMapsConfigured) {
      return ColoredBox(
        color: eco.chip,
        child: Center(
          child: Text(l10n.adminOpsMapUnavailable, style: TextStyle(fontSize: 12, color: eco.textSecondary)),
        ),
      );
    }
    final markers = <Marker>{
      for (final r in routes)
        if (r.lat != null && r.lng != null)
          Marker(
            markerId: MarkerId('truck-${r.id}'),
            position: LatLng(r.lat!, r.lng!),
            icon: _truckIcon ?? BitmapDescriptor.defaultMarker,
            alpha: gpsAgeLabel(r.locatedAt, DateTime.now(), l10n).stale ? 0.45 : 1,
            infoWindow: InfoWindow(title: r.plateNumber, snippet: r.driverName),
          ),
      for (final r in routes)
        for (final (i, s) in r.stops.indexed)
          Marker(
            markerId: MarkerId('stop-${r.id}-$i'),
            position: LatLng(s.lat, s.lng),
            alpha: s.departed ? 0.4 : 1,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(title: s.name),
          ),
    };
    final first = routes.where((r) => r.lat != null).firstOrNull;
    return Stack(
      children: [
        Positioned.fill(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: first == null ? osakaCenter : LatLng(first.lat!, first.lng!),
              zoom: 12,
            ),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            gestureRecognizers: mapGestureRecognizers,
            markers: markers,
            // Mỗi tuyến 1 đường nối các điểm theo thứ tự (đường thẳng giữa 2 điểm, không phải đường xe chạy)
            polylines: {
              for (final r in routes)
                if (r.stops.length > 1)
                  Polyline(
                    polylineId: PolylineId('route-${r.id}'),
                    points: [for (final s in r.stops) LatLng(s.lat, s.lng)],
                    width: 4,
                    color: eco.primary.withValues(alpha: 0.8),
                  ),
            },
            // Mở bản đồ → vừa mọi điểm và xe của đêm nay
            onMapCreated: (c) => fitCameraTo(c, [
              for (final r in routes) ...[
                for (final s in r.stops) LatLng(s.lat, s.lng),
                if (r.lat != null && r.lng != null) LatLng(r.lat!, r.lng!),
              ],
            ]),
            style: mapStyleFor(Theme.of(context).brightness),
          ),
        ),
        Positioned(
          left: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: eco.surface, borderRadius: BorderRadius.circular(999)),
            child: Text(
              l10n.adminOpsShowing(routes.where((r) => r.lat != null).length),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

// Tài xế gửi vị trí 5 giây/lần (GpsReporter) → 2 phút không có vị trí mới = đã ngừng gửi (mất mạng, tắt app, hết pin…)
const gpsStaleAfter = Duration(minutes: 2);

// Dòng "vị trí lúc nào" của 1 xe (audit A04, Figma 972:21643). stale = vị trí cũ hơn gpsStaleAfter.
({String text, bool stale}) gpsAgeLabel(DateTime? locatedAt, DateTime now, AppLocalizations l10n) {
  if (locatedAt == null) return (text: l10n.adminGpsNone, stale: false);
  final age = now.difference(locatedAt);
  final minutes = age.inMinutes;
  if (age > gpsStaleAfter) return (text: l10n.adminGpsStale(minutes), stale: true);
  return (text: minutes < 1 ? l10n.adminGpsJustNow : l10n.adminGpsMinutes(minutes), stale: false);
}

class _RouteTile extends StatelessWidget {
  const _RouteTile({required this.route});
  final AdminRoute route;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final r = route;
    final next = r.nextStop;
    // Trang tải lại mỗi 20 giây → dòng này tính lại theo giờ mới
    final gps = gpsAgeLabel(r.locatedAt, DateTime.now(), l10n);
    final (label, tone) = switch (r.status) {
      AdminRouteStatus.running => (l10n.adminOpsRunning, BadgeTone.soft),
      AdminRouteStatus.waiting => (l10n.adminOpsWaiting, BadgeTone.neutral),
      AdminRouteStatus.done => (l10n.adminOpsDone, BadgeTone.neutral),
    };
    return Padding(
      key: Key('adminRoute-${r.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: eco.chip, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.local_shipping_outlined, size: 20, color: eco.textPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(r.plateNumber, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    Flexible(child: StatusBadge(label: label, tone: tone)),
                  ],
                ),
                Text(
                  l10n.adminOpsNext(r.driverName ?? l10n.adminOpsNoDriver, next?.name ?? '—'),
                  style: TextStyle(fontSize: 12, color: eco.textSecondary),
                ),
                if (r.reservedCount != null)
                  Text(
                    l10n.adminOpsReserved(r.reservedCount!),
                    style: TextStyle(fontSize: 11, color: eco.textSecondary),
                  ),
                Text(
                  gps.text,
                  key: Key('adminGps-${r.id}'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: gps.stale ? FontWeight.w700 : FontWeight.w400,
                    color: gps.stale ? eco.amber : eco.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                next == null ? '—' : tokyoTime(next.plannedTime),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: eco.primary),
              ),
              Text(l10n.adminOpsEta, style: TextStyle(fontSize: 10, color: eco.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
