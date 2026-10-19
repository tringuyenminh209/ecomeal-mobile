import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/clock.dart';
import '../../core/jst_date.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/state_panel.dart';
import '../../widgets/status_badge.dart';
import '../orders/order_helpers.dart';
import 'driver_gateway.dart';
import 'driver_route_helpers.dart';
import 'handoff_gateway.dart';
import 'handoff_helpers.dart';
import 'pickup_stop_page.dart' show DriverStepsCard;
import 'qr_scan_page.dart';
import '../../widgets/skeleton.dart';
import '../../core/haptics.dart';

// SCR-D03 引き渡し・Walk-up — 06_画面設計 §SCR-D03 (viết mới ở レビュー第29回), khớp 2 frame Figma
// (màn chính 16:16867 + dialog 停車地点を出発 78:333). 3 RPC: confirm_pickup (API-014), walk_up_purchase (API-013),
// close_route_stop (API-020).
class StopHandoffPage extends ConsumerStatefulWidget {
  const StopHandoffPage({super.key, required this.route, required this.stop});
  final TonightRoute route;
  final DriverStop stop;

  @override
  ConsumerState<StopHandoffPage> createState() => _StopHandoffPageState();
}

class _StopHandoffPageState extends ConsumerState<StopHandoffPage> {
  int _tab = 0; // 0: 予約引き渡し, 1: Walk-up
  bool _busy = false;
  Timer? _clockTick;

  String get _stopId => widget.stop.routeStopId;

  // レビュー第30回: "停車終了まで n分" tính từ đồng hồ, không phải từ dữ liệu server → phải tự vẽ lại mỗi
  // phút. Chỉ setState (không gọi lại Supabase); huỷ timer khi rời màn hình.
  @override
  void initState() {
    super.initState();
    _clockTick = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clockTick?.cancel();
    super.dispose();
  }

  void _toast(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  // Chạy 1 RPC, báo lỗi bằng câu của API, xong thì tải lại số liệu điểm dừng.
  Future<void> _run(Future<String> Function() action) async {
    setState(() => _busy = true);
    try {
      final message = await action();
      Haptics.success();
      if (mounted) _toast(message);
    } catch (e) {
      Haptics.error();
      if (mounted) _toast(handoffErrorMessage(e, context.l10n));
    } finally {
      if (mounted) {
        ref.invalidate(stopHandoffProvider(_stopId));
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _handOver(ReservationAtStop reservation) => _run(() async {
        final l10n = context.l10n;
        await ref.read(handoffGatewayProvider).confirmPickup(reservation.orderId);
        return l10n.handedOverToast(orderDisplayNumber(reservation.orderId));
      });

  // Audit D01: danh sách đơn đọc lúc mở màn — khách có thể vừa đặt thêm khi xe đang đứng bán. Không thấy đơn trong
  // bản đang có thì đọc lại 1 lần rồi mới kết luận. Đọc lại lỗi → báo lỗi mạng (null), không nói「không phải đơn ở đây」.
  Future<StopHandoff?> _reload() async {
    try {
      return await ref.refresh(stopHandoffProvider(_stopId).future);
    } catch (e) {
      Haptics.error();
      if (mounted) _toast(handoffErrorMessage(e, context.l10n));
      return null;
    }
  }

  Future<void> _scanQr(StopHandoff data) async {
    final scanned = await ref.read(qrScanLauncherProvider)(context);
    if (scanned == null || !mounted) return;
    ReservationAtStop? waitingHere(StopHandoff d) =>
        d.reservations.where((r) => r.orderId == scanned.trim() && r.status == 'allocated').firstOrNull;
    var match = waitingHere(data);
    if (match == null) {
      final fresh = await _reload();
      if (fresh == null || !mounted) return;
      match = waitingHere(fresh);
    }
    // QR của đơn ở điểm KHÁC (hoặc đã giao) → không gọi RPC: confirm_pickup không kiểm tra điểm dừng.
    if (match == null) {
      Haptics.error();
      _toast(context.l10n.errorNotWaitingHere);
      return;
    }
    await _handOver(match);
  }

  Future<void> _enterManualCode(StopHandoff data) async {
    final input = await showDialog<String>(context: context, builder: (_) => const _ManualCodeDialog());
    if (input == null || !mounted) return;
    var matches = matchManualCode(data.reservations, input);
    if (matches.isEmpty) {
      final fresh = await _reload();
      if (fresh == null || !mounted) return;
      matches = matchManualCode(fresh.reservations, input);
    }
    if (matches.isEmpty) {
      Haptics.error();
      _toast(context.l10n.errorNoMatchingReservation);
      return;
    }
    // Trùng mã (hiếm): liệt kê kèm giờ đặt để hỏi lại khách — đúng hợp đồng 06 §SCR-M06.
    final chosen = matches.length == 1
        ? matches.first
        : await showDialog<ReservationAtStop>(
            context: context,
            builder: (context) => SimpleDialog(
              title: Text(context.l10n.duplicateCodeTitle),
              children: [
                for (final r in matches)
                  SimpleDialogOption(
                    onPressed: () => Navigator.of(context).pop(r),
                    child: Text(context.l10n.duplicateCodeOption(orderDisplayNumber(r.orderId), DateFormat('HH:mm').format(toTokyo(r.createdAt)))),
                  ),
              ],
            ),
          );
    if (chosen != null) await _handOver(chosen);
  }

  Future<void> _sellWalkup(WalkupStock stock) => _run(() async {
        final l10n = context.l10n;
        final price = await ref.read(handoffGatewayProvider).walkUpPurchase(batchId: stock.batchId, routeStopId: _stopId);
        return l10n.walkupSoldToast(price);
      });

  Future<void> _depart(StopHandoff data) async {
    final waiting = data.reservations.where((r) => r.status == 'allocated').length;
    final l10n = context.l10n;
    // Figma 78:407: còn đơn chờ → khối nền chip có nhãn "注意" + tiêu đề đậm + câu BR-004
    // (rời điểm → đơn chưa giao thành expired, KHÔNG hoàn tiền).
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.departDialogTitle,
      message: l10n.currentStop(widget.stop.name),
      cancelLabel: l10n.back,
      confirmLabel: l10n.departConfirm,
      confirmKey: const Key('confirmDepartButton'),
      destructive: true,
      extra: waiting == 0 ? null : _DepartWarning(waiting: waiting),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      final expired = await ref.read(handoffGatewayProvider).closeRouteStop(_stopId);
      if (!mounted) return;
      Navigator.of(context).pop(expired > 0 ? l10n.departedWithExpired(expired) : l10n.departed);
    } catch (e) {
      if (mounted) {
        _toast(handoffErrorMessage(e, l10n));
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(stopHandoffProvider(_stopId));
    final data = dataAsync.valueOrNull;
    final l10n = context.l10n;
    final now = ref.watch(clockProvider)();
    return Scaffold(
      // Figma: tên điểm 20 Bold + dòng phụ "停車終了まで n分", bên phải "予約 n" màu Primary
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.stop.name),
            if (data != null)
              Text(
                data.departedAt != null ? l10n.departedLabel : l10n.minutesUntilDeparture(minutesUntil(data.plannedDepartureAt, now: now)),
                key: const Key('stopCountdown'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          if (data != null)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Center(
                child: Text(
                  l10n.reservationsCount(data.reservations.length),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.eco.primary),
                ),
              ),
            ),
        ],
      ),
      body: dataAsync.when(
        loading: () => const SkeletonList(heights: [44, 200, 96, 96]),
        error: (_, __) => Center(
          child: StatePanel.error(
            title: l10n.errorLoadTitle,
            message: l10n.errorLoadBody,
            actionLabel: l10n.errorLoadRetry,
            onAction: () => ref.invalidate(stopHandoffProvider(_stopId)),
          ),
        ),
        data: (data) {
          final handed = data.reservations.where((r) => r.status == 'picked_up').length;
          final waiting = data.reservations.length - handed;
          final closed = data.departedAt != null;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  children: [
                    _HandoutSummary(data: data, route: widget.route),
                    const SizedBox(height: 12),
                    DriverStepsCard(title: l10n.handoutStepsTitle, steps: [l10n.handoutStep1, l10n.handoutStep2, l10n.handoutStep3]),
                    const SizedBox(height: 14),
                    _ModeTabs(
                      labels: [l10n.reservationHandoffTab, l10n.walkupTab],
                      selected: _tab,
                      onSelect: (i) => setState(() => _tab = i),
                    ),
                    const SizedBox(height: 14),
                    if (_tab == 0)
                      _ReservationSection(
                        enabled: !_busy && !closed,
                        onScan: () => _scanQr(data),
                        onManual: () => _enterManualCode(data),
                      )
                    else
                      _WalkupSection(
                        stocks: data.walkupStocks,
                        route: widget.route,
                        enabled: !_busy && !closed,
                        onSell: _sellWalkup,
                      ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: _CountCard(id: 'handed', label: l10n.handedOverLabel, value: handed)),
                        const SizedBox(width: 12),
                        Expanded(child: _CountCard(id: 'waiting', label: l10n.waitingLabel, value: waiting)),
                      ],
                    ),
                  ],
                ),
              ),
              // Figma "Sticky action": nền trắng, nút pill đỏ full width
              Container(
                color: context.eco.surface,
                child: SafeArea(
                  minimum: const EdgeInsets.all(16),
                  child: FilledButton(
                    key: const Key('departButton'),
                    onPressed: _busy || closed ? null : () => _depart(data),
                    style: FilledButton.styleFrom(backgroundColor: context.eco.error, minimumSize: Size.fromHeight(48)),
                    child: Text(l10n.departButton),
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

// restaurants bị RLS ẩn với tài xế → đặt tên lô theo điểm thu gom của nhà hàng đó trên tuyến (Chương 19).
String _batchLabel(TonightRoute route, WalkupStock stock, AppLocalizations l10n) {
  for (final s in route.stops) {
    if (s.type == 'restaurant' && s.restaurantId == stock.restaurantId) return s.name;
  }
  return l10n.batchLabel;
}

// 「この場所で渡すもの」(2026-10-16, Figma 897:1695): tới nơi là biết phải giao gì — số đơn đặt trước (quét QR), số suất
// còn bán được cho khách không đặt (API-025, không tự tính), tổng suất và số của từng lô.
class _HandoutSummary extends StatelessWidget {
  const _HandoutSummary({required this.data, required this.route});
  final StopHandoff data;
  final TonightRoute route;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final total = data.walkupStocks.fold(0, (sum, s) => sum + s.capacity);
    final sellable = data.walkupStocks.fold(0, (sum, s) => sum + s.remaining);
    Widget box(String label, String value, String caption, String id) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: eco.background, borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: eco.textSecondary)),
                Text(value, key: Key('handout_$id'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                Text(caption, style: TextStyle(fontSize: 11, color: eco.textSecondary)),
              ],
            ),
          ),
        );
    return Container(
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
              Expanded(child: Text(l10n.handoutHereTitle, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: eco.amber))),
              Text(l10n.totalMeals(total), key: const Key('handout_total'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              box(l10n.reservedCustomers, l10n.countItems(data.reservations.length), l10n.scanQrToHand, 'reserved'),
              const SizedBox(width: 8),
              box(l10n.walkupSellable, l10n.mealsCount(sellable), l10n.registerOnSpot, 'sellable'),
            ],
          ),
          if (data.walkupStocks.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(l10n.perFoodLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: eco.textSecondary)),
            for (final stock in data.walkupStocks)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Expanded(child: Text(_batchLabel(route, stock, l10n), style: const TextStyle(fontSize: 12))),
                    Text(l10n.batchCapacityRow(stock.capacity, stock.remaining), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// "Segmented" của Figma: rãnh màu chip bo 10, mục đang chọn là ô trắng bo 8 chữ Bold.
class _ModeTabs extends StatelessWidget {
  const _ModeTabs({required this.labels, required this.selected, required this.onSelect});
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: context.eco.chip, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(i),
                child: Container(
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selected ? context.eco.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: i == selected ? FontWeight.w700 : FontWeight.w500,
                      color: i == selected ? context.eco.textPrimary : context.eco.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Figma "QR scanner": khung viền trắng, bên trong là vùng camera nền tối có ô vuông ngắm 106px + câu hướng dẫn.
// Cả vùng tối là nút mở camera (máy quét thật ở QrScanPage). Nút 「コードを手動で入力」 là nút viền full width
// NẰM NGOÀI khung (Figma 16:16867).
class _ReservationSection extends StatelessWidget {
  const _ReservationSection({required this.enabled, required this.onScan, required this.onManual});
  final bool enabled;
  final VoidCallback onScan;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.eco.surface,
            border: Border.all(color: context.eco.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                color: context.eco.driverNav,
                borderRadius: BorderRadius.circular(10),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  key: const Key('scanQrButton'),
                  onTap: enabled ? onScan : null,
                  child: SizedBox(
                    height: 150,
                    child: Center(
                      child: Container(
                        width: 106,
                        height: 106,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.qr_code_scanner,
                          size: 40,
                          color: enabled ? Colors.white : Colors.white38,
                          semanticLabel: l10n.scanPickupQr,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.scanPickupQrHint,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: context.eco.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton(
          key: const Key('manualCodeButton'),
          onPressed: enabled ? onManual : null,
          child: Text(l10n.manualCodeFallback),
        ),
      ],
    );
  }
}

class _WalkupSection extends StatelessWidget {
  const _WalkupSection({required this.stocks, required this.route, required this.enabled, required this.onSell});
  final List<WalkupStock> stocks;
  final TonightRoute route;
  final bool enabled;
  final Future<void> Function(WalkupStock) onSell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (stocks.isEmpty) {
      return StatePanel(icon: Icons.inventory_2_outlined, title: l10n.noWalkupBatches);
    }
    return Column(
      children: [
        for (final stock in stocks)
          Container(
            key: Key('walkup_${stock.batchId}'),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.eco.surface,
              border: Border.all(color: context.eco.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(_batchLabel(route, stock, l10n), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                    StatusBadge(label: l10n.mealsRemaining(stock.remaining), tone: BadgeTone.warning),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.soldLabel, style: TextStyle(fontSize: 11, color: context.eco.textSecondary)),
                          Text('${stock.used} / ${stock.capacity}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    FilledButton(
                      key: Key('sellWalkup_${stock.batchId}'),
                      onPressed: enabled && stock.remaining > 0 ? () => onSell(stock) : null,
                      child: Text(l10n.registerSale),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({required this.id, required this.label, required this.value});
  final String id; // key cố định cho test — nhãn đổi theo ngôn ngữ nên không dùng làm key
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.eco.surface,
        border: Border.all(color: context.eco.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: context.eco.textSecondary)),
          const SizedBox(height: 4),
          Text('$value', key: Key('count_$id'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _DepartWarning extends StatelessWidget {
  const _DepartWarning({required this.waiting});
  final int waiting;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: context.eco.chip, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(label: l10n.cautionBadge, tone: BadgeTone.warning),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l10n.departWarningTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.departWarning(waiting),
            key: const Key('departWarning'),
            style: TextStyle(fontSize: 12, height: 1.5, color: context.eco.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ManualCodeDialog extends StatefulWidget {
  const _ManualCodeDialog();

  @override
  State<_ManualCodeDialog> createState() => _ManualCodeDialogState();
}

class _ManualCodeDialogState extends State<_ManualCodeDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Cùng khung với showConfirmDialog: Dialog bo 16, tiêu đề đậm, ô nhập theme, 2 nút pill ngang nhau.
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.enterPickupCode, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              key: const Key('manualCodeField'),
              controller: _controller,
              autofocus: true,
              maxLength: 4,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 6),
              decoration: InputDecoration(hintText: l10n.pickupCodeHint),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.back)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    key: const Key('submitManualCodeButton'),
                    onPressed: () => Navigator.of(context).pop(_controller.text),
                    child: Text(l10n.verifyCode),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
