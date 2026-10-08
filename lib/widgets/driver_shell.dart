import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../features/driver/driver_gateway.dart';
import '../features/driver/driver_home_page.dart';
import '../features/driver/gps_reporter.dart';
import '../features/driver/route_end_page.dart';
import '../l10n/l10n.dart';
import 'skeleton.dart';
import 'state_panel.dart';

// Thanh tab tài xế, khớp Figma "Driver navigation" (運行/受取/販売/終了): nền xanh rất đậm, tab đang chọn
// màu Amber, tab khác chữ trắng mờ — khác hẳn thanh tab trắng của khách (CustomerShell). Đồng thời là nơi "bật ドライバーモード" (UC-10 事前条件):
// GPS chỉ gửi khi shell này đang hiển thị, tự dừng khi rời (đăng xuất) nhờ autoDispose.
class DriverShell extends ConsumerStatefulWidget {
  const DriverShell({super.key});

  @override
  ConsumerState<DriverShell> createState() => _DriverShellState();
}

class _DriverShellState extends ConsumerState<DriverShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Có xe (truck_id) là bắt đầu gửi GPS — kể cả khi tối nay chưa có tuyến (khách vẫn thấy xe ở đâu).
    ref.listenManual<AsyncValue<TonightRoute?>>(tonightRouteProvider, (_, next) {
      final truckId = next.valueOrNull?.truck.id;
      if (truckId != null) ref.read(gpsReporterProvider.notifier).start(truckId);
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(gpsReporterProvider); // giữ GpsReporter sống suốt thời gian ở chế độ tài xế

    final l10n = context.l10n;
    final pages = [
      const DriverHomePage(),
      _StopsTab(type: 'restaurant', title: l10n.stopKindPickup, emptyIcon: Icons.inventory_2_outlined, emptyTitle: l10n.noPickupsTonight),
      // SCR-D03 (Chương 20)
      _StopsTab(type: 'public', title: l10n.driverTabSales, emptyIcon: Icons.storefront_outlined, emptyTitle: l10n.noSalesTonight),
      const RouteEndPage(), // SCR-D04 (Chương 20)
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBarTheme(
        data: _driverNavTheme,
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(icon: const Icon(Icons.route_outlined), label: context.l10n.driverTabRoute),
            NavigationDestination(icon: const Icon(Icons.inventory_2_outlined), label: context.l10n.driverTabPickup),
            NavigationDestination(icon: const Icon(Icons.shopping_bag_outlined), label: context.l10n.driverTabSales),
            NavigationDestination(icon: const Icon(Icons.fact_check_outlined), label: context.l10n.driverTabEnd),
          ],
        ),
      ),
    );
  }
}

// Ghi đè navigationBarTheme (Chương 15) chỉ cho shell này.
final _driverNavTheme = NavigationBarThemeData(
  backgroundColor: AppColors.driverNav,
  indicatorColor: Colors.transparent,
  height: 72,
  labelTextStyle: WidgetStateProperty.resolveWith(
    (states) => TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: states.contains(WidgetState.selected) ? AppColors.amber : AppColors.surface.withValues(alpha: 0.65),
    ),
  ),
  iconTheme: WidgetStateProperty.resolveWith(
    (states) => IconThemeData(
      size: 22,
      color: states.contains(WidgetState.selected) ? AppColors.amber : AppColors.surface.withValues(alpha: 0.65),
    ),
  ),
);

// Tab 受取 / 販売: các điểm dừng tối nay theo loại (restaurant = thu gom → SCR-D02, public = điểm bán → SCR-D03).
// Đang tải → khung xương; lỗi → nút thử lại (trước đây cả 2 trường hợp đều rơi vào "今夜は〜ありません", tài xế tưởng
// tối nay không có việc trong khi thật ra mạng chậm).
class _StopsTab extends ConsumerWidget {
  const _StopsTab({required this.type, required this.title, required this.emptyIcon, required this.emptyTitle});
  final String type;
  final String title;
  final IconData emptyIcon;
  final String emptyTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ref.watch(tonightRouteProvider).when(
            loading: () => const SkeletonList(heights: [88, 88, 88]),
            error: (_, __) => Center(
              child: StatePanel.error(
                title: l10n.errorLoadTitle,
                message: l10n.errorLoadBody,
                actionLabel: l10n.retry,
                onAction: () => ref.invalidate(tonightRouteProvider),
              ),
            ),
            data: (route) {
              final stops = route?.stops.where((s) => s.type == type).toList() ?? const <DriverStop>[];
              if (route == null || stops.isEmpty) {
                return Center(child: StatePanel(icon: emptyIcon, title: emptyTitle));
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(tonightRouteProvider),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [RouteStopList(stops: stops, onTapStop: (stop) => openStop(context, ref, route, stop))],
                ),
              );
            },
          ),
    );
  }
}
