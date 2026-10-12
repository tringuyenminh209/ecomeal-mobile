import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
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

// Trạng thái mới nhất của 1 đơn khi SCR-M18 đang mở (API-011 danh sách đơn của mình). Dừng hỏi khi đã nhận
// (picked_up) hoặc rời màn (autoDispose). Lỗi mạng 1 lần thì bỏ qua, lần sau hỏi lại — màn vẫn hiện QR như cũ.
// Timer (không phải Future.delayed trong async*) để rời màn là huỷ được ngay, không để lại hẹn giờ chờ.
final activeOrderStatusProvider = StreamProvider.autoDispose.family<String, String>((ref, orderId) {
  final gateway = ref.watch(orderGatewayProvider);
  final controller = StreamController<String>();
  Timer? timer;
  var disposed = false;
  Future<void> poll() async {
    String? status;
    try {
      status = (await gateway.fetchMyOrders()).where((o) => o.id == orderId).firstOrNull?.status;
    } catch (_) {
      status = null;
    }
    if (disposed) return;
    if (status != null) controller.add(status);
    if (status == 'picked_up') return;
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
    final status = ref.watch(activeOrderStatusProvider(order.id)).valueOrNull ?? order.status;
    final pickedUp = status == 'picked_up';
    // Vừa chuyển sang picked_up khi đang xem màn → rung (mở màn khi đã nhận rồi thì không rung)
    ref.listen(activeOrderStatusProvider(order.id), (previous, next) {
      final before = previous?.valueOrNull;
      if (before != null && before != 'picked_up' && next.valueOrNull == 'picked_up') Haptics.success();
    });
    final stage = pickupStage(now: current, plannedTime: order.plannedPickupTime, departedAt: order.stopDepartedAt);
    final hm = DateFormat('HH:mm');
    final start = toTokyo(order.plannedPickupTime);
    final statusText = pickedUp
        ? l10n.activeOrderPickedUp
        : switch (stage) {
            PickupStage.before => l10n.activeOrderBefore(hm.format(start), remainingMinutes(order.plannedPickupTime, current)),
            PickupStage.window => l10n.activeOrderWindow(hm.format(start.add(pickupWindowLength))),
            PickupStage.over => l10n.activeOrderOver,
          };
    final highlighted = pickedUp || stage != PickupStage.over;
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
            _PickupComplete(order: order)
          else ...[
            PickupQrBlock(orderId: order.id, size: 220),
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
