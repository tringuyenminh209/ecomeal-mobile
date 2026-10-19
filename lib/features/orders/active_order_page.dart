import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/screen_brightness.dart';
import '../../core/haptics.dart';
import '../../core/jst_date.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/animated_check.dart';
import '../../widgets/value_change.dart';
import 'order_gateway.dart';
import 'order_helpers.dart';
import 'order_history_page.dart';
import 'order_rating.dart';
import '../../widgets/customer_shell.dart' show customerTabProvider, CustomerTab;

// 受け取りの案内（SCR-M18、review page 02）: đơn đã giữ chỗ — gom điểm nhận, giờ, xe đang ở giai đoạn nào,
// cách tìm xe và QR lớn vào 1 màn (trước đây nằm rải giữa bản đồ và thẻ trong lịch sử).
// Màn mở lâu (đứng chờ xe) vẫn đúng: "あと○分" đổi mỗi 30 giây, trạng thái đơn hỏi lại mỗi 15 giây — tài xế quét QR
// xong (picked_up) thì QR được thay bằng ✓ 受け取り完了 + rung + mời đánh giá (Figma "SCR-M18 / 受け取り完了").

enum PickupStage { before, window, over }

// Giai đoạn theo giờ dự kiến của điểm dừng (khung +20 phút như pickupWindowLabel) và việc xe đã rời điểm hay chưa.
// Không có giờ xe đến thật ở DB (chỉ actual_departure_at) — nên "đang đỗ" là theo lịch, không phải GPS.
PickupStage pickupStage({required DateTime now, required DateTime plannedTime, DateTime? departedAt}) {
  if (departedAt != null) return PickupStage.over;
  if (now.isBefore(plannedTime)) return PickupStage.before;
  if (now.isBefore(plannedTime.add(pickupWindowLength))) return PickupStage.window;
  return PickupStage.over;
}

const _statusPollInterval = Duration(seconds: 15);

// Đơn đã kết thúc: không đổi nữa → thôi hỏi. Ngoài picked_up còn hủy / hoàn tiền /失効 (audit C01 2026-10-19).
const _finalStatuses = {'picked_up', 'refunded', 'expired', 'cancelled'};

// Bản ghi mới nhất của 1 đơn khi SCR-M18 đang mở (API-011 danh sách đơn của mình) — CẢ bản ghi, không chỉ status:
// giờ xe rời điểm (stopDepartedAt) cũng đổi trong lúc mở màn (audit C01). Dừng hỏi khi đơn đã kết thúc hoặc rời màn
// (autoDispose). Lỗi mạng 1 lần thì bỏ qua, lần sau hỏi lại — màn vẫn hiện như cũ.
// Timer (không phải Future.delayed trong async*) để rời màn là huỷ được ngay, không để lại hẹn giờ chờ.
final activeOrderProvider = StreamProvider.autoDispose.family<OrderSummary, String>((ref, orderId) {
  final gateway = ref.watch(orderGatewayProvider);
  final controller = StreamController<OrderSummary>();
  Timer? timer;
  var disposed = false;
  Future<void> poll() async {
    OrderSummary? latest;
    try {
      latest = (await gateway.fetchMyOrders()).where((o) => o.id == orderId).firstOrNull;
    } catch (_) {
      latest = null;
    }
    if (disposed) return;
    if (latest != null) controller.add(latest);
    if (latest != null && _finalStatuses.contains(latest.status)) return;
    timer = Timer(_statusPollInterval, poll);
  }

  ref.onDispose(() {
    disposed = true;
    timer?.cancel();
    controller.close();
  });
  poll();
  return controller.stream;
});

// Đồng hồ của màn: 30 giây 1 lần là đủ cho "あと○分" (không dựng lại QR mỗi giây)
final _pickupClockProvider = StreamProvider.autoDispose<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 30), (_) => DateTime.now());
});

class ActiveOrderPage extends ConsumerWidget {
  const ActiveOrderPage({super.key, required this.order, this.now});
  final OrderSummary order;
  final DateTime? now; // test

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = now ?? ref.watch(_pickupClockProvider).valueOrNull ?? DateTime.now();
    final latest = ref.watch(activeOrderProvider(order.id)).valueOrNull ?? order;
    final status = latest.status;
    final pickedUp = status == 'picked_up';
    // Hủy / hoàn tiền / 失効: QR không còn dùng được → thay bằng lý do + đường về lịch sử (Figma 949:1695)
    final ended = _finalStatuses.contains(status) && !pickedUp;
    // Vừa chuyển sang picked_up khi đang xem màn → rung (mở màn khi đã nhận rồi thì không rung)
    ref.listen(activeOrderProvider(order.id), (previous, next) {
      final before = previous?.valueOrNull?.status;
      if (before != null && before != 'picked_up' && next.valueOrNull?.status == 'picked_up') Haptics.success();
    });
    final stage = pickupStage(now: current, plannedTime: latest.plannedPickupTime, departedAt: latest.stopDepartedAt);
    final hm = DateFormat('HH:mm');
    final start = toTokyo(order.plannedPickupTime);
    final statusText = pickedUp
        ? l10n.activeOrderPickedUp
        : ended
        ? l10n.activeOrderEndedStatus
        : switch (stage) {
            PickupStage.before => l10n.activeOrderBefore(hm.format(start), remainingMinutes(order.plannedPickupTime, current)),
            PickupStage.window => l10n.activeOrderWindow(hm.format(start.add(pickupWindowLength))),
            PickupStage.over => l10n.activeOrderOver,
          };
    final highlighted = pickedUp || (!ended && stage != PickupStage.over);
    const label = TextStyle(fontSize: 12, color: AppColors.textSecondary);
    const value = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.activeOrderTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Container(
            key: const Key('activeOrderStatus'),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: highlighted ? AppColors.primarySoft : AppColors.surface,
              border: Border.all(color: highlighted ? AppColors.primary : AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  pickedUp
                      ? Icons.check_circle
                      : ended
                      ? Icons.event_busy
                      : stage == PickupStage.window
                          ? Icons.local_shipping
                          : Icons.schedule,
                  color: highlighted ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ValueChange(
                    value: statusText,
                    child: Text(statusText, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.5)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(l10n.activeOrderPlace, style: label), const SizedBox(height: 4), Text(order.stopName, style: value)],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.activeOrderTime, style: label),
                    const SizedBox(height: 4),
                    Text(pickupWindowLabel(order.plannedPickupTime), style: value),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (pickedUp)
            _PickupComplete(order: latest)
          else if (ended)
            _PickupEnded(status: status)
          else ...[
            // QR đang hiện → màn sáng tối đa (trả lại khi đã nhận / rời màn)
            MaxBrightness(child: PickupQrBlock(orderId: order.id, size: 220)),
            const SizedBox(height: 20),
            Text(l10n.activeOrderFindTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(l10n.activeOrderFindBody, style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

// Thay khối QR khi đã nhận: ✓ được vẽ ra, lời cảm ơn, mời đánh giá (đã đánh giá → RatedNote)
class _PickupComplete extends ConsumerStatefulWidget {
  const _PickupComplete({required this.order});
  final OrderSummary order;

  @override
  ConsumerState<_PickupComplete> createState() => _PickupCompleteState();
}

class _PickupCompleteState extends ConsumerState<_PickupComplete> {
  bool _rated = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rating = widget.order.rating;
    return Container(
      key: const Key('pickupComplete'),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: AnimatedCheck(size: 72, color: Colors.white, background: AppColors.primary)),
          const SizedBox(height: 16),
          Text(l10n.pickupCompleteTitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(l10n.pickupCompleteBody, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          if (rating != null)
            RatedNote(rating: rating)
          else if (_rated)
            Text(l10n.ratingSent, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))
          else
            RatingPrompt(
              order: widget.order,
              onRated: () {
                setState(() => _rated = true);
                ref.invalidate(myOrdersProvider); // thẻ ở 予約履歴 cũng chuyển sang "đã đánh giá"
              },
            ),
        ],
      ),
    );
  }
}

// Thay khối QR khi đơn đã kết thúc mà không nhận (Figma 949:1695, ghi chú 949:1963): lý do theo trạng thái + nút về
// tab 予約 (đóng màn này dù mở từ lịch sử hay từ LINE/banner). Câu hoàn tiền dùng chung với thông báo (N02).
class _PickupEnded extends ConsumerWidget {
  const _PickupEnded({required this.status});
  final String status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final (title, body) = switch (status) {
      'refunded' => (l10n.noticeRefundedTitle, l10n.noticeRefundedBody),
      'cancelled' => (l10n.activeOrderEndedCancelledTitle, l10n.activeOrderEndedCancelledBody),
      _ => (l10n.activeOrderEndedExpiredTitle, l10n.activeOrderEndedExpiredBody),
    };
    return Container(
      key: const Key('pickupEnded'),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: AppColors.chip, shape: BoxShape.circle),
              child: const Icon(Icons.event_busy, size: 36, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(body, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          FilledButton(
            key: const Key('pickupEndedBack'),
            onPressed: () {
              ref.invalidate(myOrdersProvider);
              ref.read(customerTabProvider.notifier).state = CustomerTab.orders;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(l10n.activeOrderEndedBack),
          ),
        ],
      ),
    );
  }
}

// Khối "受け取りQR" (Figma 78:192): tiêu đề + mã thủ công, QR trắng trên nền xanh đậm, chú thích.
class PickupQrBlock extends StatelessWidget {
  const PickupQrBlock({super.key, required this.orderId, this.size = 140});
  final String orderId;
  final double size;

  // Nền xanh đậm chỉ dùng cho khối QR (tăng tương phản khi tài xế quét) — không phải token chung.
  static const _qrBackground = Color(0xFF1F3A2B);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.pickupQrTitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              Text(
                l10n.manualCodeLabel(pickupManualCode(orderId)),
                key: const Key('pickupManualCode'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(color: _qrBackground, borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
              // QR mã hoá orders.id đầy đủ — khớp UC-23 "ドライバーがQRコードまたは予約番号を確認"
              child: QrImageView(data: orderId, size: size),
            ),
          ),
          const SizedBox(height: 8),
          Text(l10n.pickupQrCaption, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
