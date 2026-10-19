import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/clock.dart';
import '../../core/directions.dart';
import '../../core/jst_date.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../core/location.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/state_panel.dart';
import 'driver_gateway.dart';
import 'driver_profile_page.dart';
import 'driver_report.dart';
import 'driver_route_map.dart';
import 'driver_route_helpers.dart';
import 'gps_reporter.dart';
import 'pickup_stop_page.dart';
import 'stop_handoff_page.dart';
import '../../widgets/skeleton.dart';

// SCR-D01 ドライバーホーム v2 (2026-10-16, Figma 894:1695 集荷中 / 897:1795 販売中): tài xế cần biết NGAY bây giờ đi đâu,
// lấy / giao gì, bao nhiêu. Thứ tự: tiêu đề + 運営に連絡 + 設定 → 今夜の進み具合 → thẻ 次にやること (ナビで行く / 着いた)
// → bản đồ → danh sách chia 2 phần (お店で受け取る / お客様に渡す).
class DriverHomePage extends ConsumerWidget {
  const DriverHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeAsync = ref.watch(tonightRouteProvider);
    final gps = ref.watch(gpsReporterProvider);
    final l10n = context.l10n;
    final now = ref.watch(clockProvider)();
    void reload() => ref.invalidate(tonightRouteProvider);

    // Audit D02: mọi trạng thái (lỗi tải, chưa được gán xe, chưa có tuyến) vẫn có tiêu đề + 設定 — nơi nộp bằng lái, xem ca,
    // đăng xuất — và cách tải lại khi vận hành vừa gán xe (Figma Empty 197:571). Trước đây 2 nhánh đầu chỉ có 1 câu ở giữa.
    Widget page(List<Widget> children) => RefreshIndicator(
      onRefresh: () async => reload(),
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: children),
    );

    return Scaffold(
      body: SafeArea(
        child: routeAsync.when(
          // Khung: tiêu đề, tiến độ, thẻ việc kế tiếp, bản đồ, danh sách
          loading: () => const SkeletonList(heights: [56, 72, 200, 160, 160], padding: EdgeInsets.fromLTRB(16, 8, 16, 24)),
          error: (_, __) => page([
            const _Header(truck: null, canReport: false),
            StatePanel.error(
              title: l10n.errorLoadTitle,
              message: l10n.errorLoadBody,
              actionLabel: l10n.retry,
              onAction: reload,
            ),
          ]),
          data: (route) {
            if (route == null) {
              return page([
                const _Header(truck: null, canReport: false),
                StatePanel(
                  icon: Icons.local_shipping_outlined,
                  title: l10n.noTruckAssigned,
                  actionLabel: l10n.storeReload,
                  onAction: reload,
                ),
              ]);
            }
            final next = nextStopOf(route.stops);
            return page([
                  // SCR-D06: chỉ khi đêm nay có tuyến (server cũng chặn: E-REPORT-404)
                  _Header(truck: route.truck, canReport: route.routeId != null),
                  if (gps.problem case final problem?) ...[_GpsProblemBanner(problem: problem), const SizedBox(height: 12)],
                  if (route.stops.isEmpty)
                    StatePanel(
                      icon: Icons.route_outlined,
                      title: l10n.noRouteTonight,
                      actionLabel: l10n.storeReload,
                      onAction: reload,
                    )
                  else ...[
                    RouteProgressCard(stops: route.stops),
                    const SizedBox(height: 12),
                    next == null
                        ? const _AllDoneCard()
                        : NextTaskCard(
                            route: route,
                            stop: next,
                            now: now,
                            onNavigate: () => openDirectionsTo(context, ref, next),
                            onArrive: () => openStop(context, ref, route, next),
                          ),
                    const SizedBox(height: 12),
                    SizedBox(height: 160, child: _DriverMap(stops: route.stops, gps: gps)),
                    const SizedBox(height: 12),
                    RouteStopList(route: route, onTapStop: (stop) => openStop(context, ref, route, stop)),
                  ],
                ]);
          },
        ),
      ),
    );
  }
}

// 05_画面遷移図: D01 →(飲食店) D07 集荷先の詳細 → D02 / →(停車地点) D03. Dùng chung cho tab 受取・販売 (driver_shell).
Future<void> openStop(BuildContext context, WidgetRef ref, TonightRoute route, DriverStop stop) async {
  if (stop.type == 'restaurant') {
    // D07 tự đọc lại tuyến (tonightRouteProvider) sau mỗi lần chốt — chỉ cần biết điểm nào.
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PickupStopPage(routeStopId: stop.routeStopId)));
    if (context.mounted) ref.invalidate(tonightRouteProvider);
    return;
  }
  // Điểm bán → SCR-D03. Quay về với message khi đã "出発" (close_route_stop).
  final message = await Navigator.of(context).push<String>(
    MaterialPageRoute(builder: (_) => StopHandoffPage(route: route, stop: stop)),
  );
  if (!context.mounted) return;
  if (message != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  ref.invalidate(tonightRouteProvider); // số đơn/đã giao ở D01 thay đổi dù có 出発 hay không
}

// 「ナビで行く」: mở app bản đồ dẫn đường tới điểm dừng (D01・D07・D02 受け取り完了 dùng chung).
Future<void> openDirectionsTo(BuildContext context, WidgetRef ref, DriverStop stop) async {
  final opened = await ref.read(openDirectionsProvider)(stop.lat, stop.lng);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.navigationFailed)));
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.truck, required this.canReport});
  final DriverTruck? truck; // null: chưa gán xe / tải lỗi — không có biển số
  final bool canReport;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final small = Theme.of(context).textTheme.bodySmall;
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
                if (truck case final truck?) Text(truck.plateNumber, style: small),
                // ja: 10月2日(金) / en: Fri, Oct 2 — "đêm nay" theo giờ Nhật, mẫu ngày theo locale
                Text(DateFormat.MMMEd(l10n.localeName).format(toTokyo(DateTime.now())), style: small),
              ],
            ),
          ),
          if (canReport) ...[
            OutlinedButton(
              key: const Key('driverReportButton'),
              onPressed: () => openDriverReportSheet(context),
              child: Text(l10n.driverReportShort),
            ),
            const SizedBox(width: 8),
          ],
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

// 「今夜の進み具合」: số điểm đã rời / tổng + thanh chia ô (xong = xanh, điểm kế tiếp = vàng, còn lại = viền).
class RouteProgressCard extends StatelessWidget {
  const RouteProgressCard({super.key, required this.stops});
  final List<DriverStop> stops;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final p = routeProgressOf(stops);
    final next = nextStopOf(stops);
    final small = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: eco.textSecondary);
    return _Panel(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.driverProgressTitle, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: eco.textSecondary)),
              ),
              Text(l10n.driverProgressCount(p.done, p.total), key: const Key('progressCount'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final (i, s) in stops.indexed) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: s.departedAt != null ? eco.primary : (identical(s, next) ? eco.amber : eco.border),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(l10n.driverProgressPickup(p.pickupDone, p.pickupTotal), style: small),
              const SizedBox(width: 12),
              Text(l10n.driverProgressSales(p.salesDone, p.salesTotal), style: small),
            ],
          ),
        ],
      ),
    );
  }
}

// 「次にやること」: điểm kế tiếp — đi đâu (tên + địa chỉ), lúc nào (giờ dự kiến + còn mấy phút), lấy / giao bao nhiêu,
// 2 nút: ナビで行く (app bản đồ) / 着いた (mở D07 hoặc D03). Viền vàng để nổi hơn các thẻ khác.
class NextTaskCard extends StatelessWidget {
  const NextTaskCard({
    super.key,
    required this.route,
    required this.stop,
    required this.onNavigate,
    required this.onArrive,
    this.now,
    this.title,
    this.arriveLabel,
  });
  final TonightRoute route;
  final DriverStop stop;
  final VoidCallback onNavigate;
  final VoidCallback onArrive;
  final DateTime? now;
  // D08: bản đồ toàn màn hình dùng lại thẻ này cho điểm vừa chọn — 「選んだ地点」 + 「この地点を開く」
  final String? title;
  final String? arriveLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final time = DateFormat('HH:mm');
    final isPickup = stop.type == 'restaurant';
    final position = route.stops.indexOf(stop) + 1;

    final String amount;
    final String detail;
    if (isPickup) {
      final pending = batchesAt(route, stop).where((b) => !b.isPickedUp).toList();
      amount = l10n.approxMeals(pending.fold(0, (sum, b) => sum + b.estimatedQty));
      detail = pending.isEmpty
          ? l10n.nothingToPickUp
          : l10n.nextTaskPickupDetail(pending.length, time.format(toTokyo(pending.first.sellByAt)));
    } else {
      final capacity = route.capacityAtStop[stop.routeStopId];
      amount = capacity == null ? l10n.stopReservations(stop.reservedCount) : l10n.mealsCount(capacity);
      detail = l10n.nextTaskSalesDetail(stop.reservedCount);
    }

    return Container(
      key: const Key('nextTaskCard'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: eco.surface,
        border: Border.all(color: eco.amber, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title ?? l10n.nextTaskLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: eco.amber))),
              _Tag(label: isPickup ? l10n.stepBadgePickup(position) : l10n.stepBadgeSales(position), color: eco.amber),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isPickup ? l10n.nextTaskPickupTitle(stop.name) : l10n.nextTaskSalesTitle(stop.name),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          if (stop.address != null) ...[
            const SizedBox(height: 4),
            Text(stop.address!, style: TextStyle(fontSize: 12, color: eco.textSecondary)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _Fact(label: l10n.arriveByLabel, value: time.format(toTokyo(stop.plannedTime)), color: eco.amber)),
              const SizedBox(width: 8),
              Expanded(child: _Fact(label: l10n.timeLeftLabel, value: l10n.minutesShort(minutesUntil(stop.plannedTime, now: now)))),
              const SizedBox(width: 8),
              Expanded(child: _Fact(label: isPickup ? l10n.pickupAmountLabel : l10n.handoutAmountLabel, value: amount)),
            ],
          ),
          const SizedBox(height: 10),
          Text(detail, key: const Key('nextTaskDetail'), style: TextStyle(fontSize: 12, color: eco.textSecondary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('navigateButton'),
                  onPressed: onNavigate,
                  icon: const Icon(Icons.navigation_outlined, size: 18),
                  label: Text(l10n.navigateButton),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  key: const Key('arriveButton'),
                  onPressed: onArrive,
                  child: Text(arriveLabel ?? (isPickup ? l10n.arrivedPickupButton : l10n.arrivedSalesButton)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AllDoneCard extends StatelessWidget {
  const _AllDoneCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _Panel(
      key: const Key('allDoneCard'),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: context.eco.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.allStopsDoneTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(l10n.allStopsDoneBody, style: TextStyle(fontSize: 12, color: context.eco.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(color: context.eco.background, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: context.eco.textSecondary)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color ?? context.eco.textPrimary)),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({super.key, required this.child, this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.eco.surface,
        border: Border.all(color: context.eco.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

// Figma 16:16731: bản đồ bo 12, viên GPS ở góc dưới trái. Audit D08: chạm bản đồ hoặc nút phóng to → SCR-D08 toàn màn hình
// (cùng widget DriverRouteMap: pin có số, nét đứt theo thứ tự). Chưa có key Maps → khung hướng dẫn, nút vẫn mở trang.
class _DriverMap extends StatelessWidget {
  const _DriverMap({required this.stops, required this.gps});
  final List<DriverStop> stops;
  final GpsState gps;

  @override
  Widget build(BuildContext context) {
    void open() => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const DriverRouteMapPage()));
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Positioned.fill(child: DriverRouteMap(stops: stops, gps: gps, inScrollView: true, onTapMap: open)),
          Positioned(left: 12, bottom: 12, child: _GpsPill(status: gps.status)),
          Positioned(
            right: 8,
            top: 8,
            child: IconButton.filled(
              key: const Key('openRouteMap'),
              tooltip: context.l10n.routeMapOpen,
              onPressed: open,
              style: IconButton.styleFrom(backgroundColor: context.eco.surface, foregroundColor: context.eco.textPrimary),
              icon: const Icon(Icons.open_in_full, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// Audit D05 (Figma 963:1997, ghi chú 963:21461): băng trên cùng theo nguyên nhân. Thiếu quyền / dịch vụ định vị tắt → nút
// 「設定を開く」 đúng trang; lỗi mạng → không nút (5 giây sau tự gửi lại). Không tự bật hộp xin quyền lặp lại.
class _GpsProblemBanner extends StatelessWidget {
  const _GpsProblemBanner({required this.problem});
  final GpsProblem problem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (title, body, fix) = switch (problem) {
      GpsProblem.permission => (l10n.gpsPermissionTitle, l10n.gpsPermissionBody, LocationProblem.permission),
      GpsProblem.serviceOff => (l10n.gpsServiceOffTitle, l10n.gpsServiceOffBody, LocationProblem.serviceOff),
      GpsProblem.notSent => (l10n.gpsNotSentTitle, l10n.gpsNotSentBody, null),
    };
    return ErrorBanner(
      key: Key('gpsProblem-${problem.name}'),
      title: title,
      message: body,
      retryLabel: fix == null ? null : l10n.openSettings,
      onRetry: fix == null ? null : () => openLocationFixSettings(fix),
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

// Danh sách điểm dừng chia 2 phần: ① お店で受け取る（集荷） ② お客様に渡す（販売）. Mỗi dòng: ô số thứ tự trên tuyến
// (xong = ✓ mờ, kế tiếp = nền vàng), tên, việc ở đó + số lượng, giờ dự kiến. onlyType: tab 受取 / 販売 chỉ hiện 1 phần.
class RouteStopList extends StatelessWidget {
  const RouteStopList({super.key, required this.route, required this.onTapStop, this.onlyType});
  final TonightRoute route;
  final void Function(DriverStop stop) onTapStop;
  final String? onlyType;

  String _detail(DriverStop stop, DriverStop? next, AppLocalizations l10n) {
    final String body;
    if (stop.type == 'restaurant') {
      final load = pickupLoadOf(route, stop);
      body = stop.departedAt != null || load.toPick == 0 ? l10n.stopPickupDone(load.picked) : l10n.stopPickupPending(load.toPick);
    } else if (stop.departedAt != null) {
      body = l10n.stopDoneHandoff(stop.pickedUpCount);
    } else {
      final capacity = route.capacityAtStop[stop.routeStopId];
      body = capacity == null ? l10n.stopReservations(stop.reservedCount) : l10n.stopSalesLoad(stop.reservedCount, capacity);
    }
    return identical(stop, next) ? l10n.nextStopPrefixed(body) : body;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final next = nextStopOf(route.stops);
    final groups = [
      ('restaurant', l10n.routePhasePickup),
      ('public', l10n.routePhaseSales),
    ].where((g) => onlyType == null || g.$1 == onlyType);
    return _Panel(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (type, title) in groups) ...[
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Row(
                children: [
                  Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
                  Text(
                    l10n.placesCount(route.stops.where((s) => s.type == type).length),
                    style: TextStyle(fontSize: 11, color: context.eco.textSecondary),
                  ),
                ],
              ),
            ),
            for (final (i, stop) in route.stops.indexed)
              if (stop.type == type) _StopRow(number: i + 1, stop: stop, isNext: identical(stop, next), detail: _detail(stop, next, l10n), onTap: () => onTapStop(stop)),
          ],
        ],
      ),
    );
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({required this.number, required this.stop, required this.isNext, required this.detail, required this.onTap});
  final int number;
  final DriverStop stop;
  final bool isNext;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final eco = context.eco;
    final done = stop.departedAt != null;
    final accent = isNext ? eco.amber : eco.textSecondary;
    return InkWell(
      key: Key('stop_${stop.routeStopId}'),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done ? eco.border : (isNext ? eco.amber : eco.surface),
                shape: BoxShape.circle,
                border: done || isNext ? null : Border.all(color: eco.primary, width: 1.5),
              ),
              child: done
                  ? Icon(Icons.check, size: 14, color: eco.textSecondary)
                  : Text(
                      '$number',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isNext ? eco.background : eco.primary),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stop.name,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: done ? eco.textSecondary : eco.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(detail, style: TextStyle(fontSize: 11, color: isNext ? eco.amber : eco.textSecondary)),
                ],
              ),
            ),
            Text(
              DateFormat('HH:mm').format(toTokyo(stop.plannedTime)),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: accent),
            ),
            Icon(Icons.chevron_right, size: 18, color: eco.textSecondary),
          ],
        ),
      ),
    );
  }
}
