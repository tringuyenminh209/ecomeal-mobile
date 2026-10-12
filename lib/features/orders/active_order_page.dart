import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/jst_date.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import 'order_gateway.dart';
import 'order_helpers.dart';

// 受け取りの案内（SCR-M18、review page 02）: đơn đã giữ chỗ — gom điểm nhận, giờ, xe đang ở giai đoạn nào,
// cách tìm xe và QR lớn vào 1 màn (trước đây nằm rải giữa bản đồ và thẻ trong lịch sử).

enum PickupStage { before, window, over }

// Giai đoạn theo giờ dự kiến của điểm dừng (khung +20 phút như pickupWindowLabel) và việc xe đã rời điểm hay chưa.
// Không có giờ xe đến thật ở DB (chỉ actual_departure_at) — nên "đang đỗ" là theo lịch, không phải GPS.
PickupStage pickupStage({required DateTime now, required DateTime plannedTime, DateTime? departedAt}) {
  if (departedAt != null) return PickupStage.over;
  if (now.isBefore(plannedTime)) return PickupStage.before;
  if (now.isBefore(plannedTime.add(pickupWindowLength))) return PickupStage.window;
  return PickupStage.over;
}

class ActiveOrderPage extends StatelessWidget {
  const ActiveOrderPage({super.key, required this.order, this.now});
  final OrderSummary order;
  final DateTime? now; // test

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = now ?? DateTime.now();
    final stage = pickupStage(now: current, plannedTime: order.plannedPickupTime, departedAt: order.stopDepartedAt);
    final hm = DateFormat('HH:mm');
    final start = toTokyo(order.plannedPickupTime);
    final statusText = switch (stage) {
      PickupStage.before => l10n.activeOrderBefore(hm.format(start), remainingMinutes(order.plannedPickupTime, current)),
      PickupStage.window => l10n.activeOrderWindow(hm.format(start.add(pickupWindowLength))),
      PickupStage.over => l10n.activeOrderOver,
    };
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
              color: stage == PickupStage.over ? AppColors.surface : AppColors.primarySoft,
              border: Border.all(color: stage == PickupStage.over ? AppColors.border : AppColors.primary),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  stage == PickupStage.window ? Icons.local_shipping : Icons.schedule,
                  color: stage == PickupStage.over ? AppColors.textSecondary : AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(statusText, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.5))),
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
          PickupQrBlock(orderId: order.id, size: 220),
          const SizedBox(height: 20),
          Text(l10n.activeOrderFindTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(l10n.activeOrderFindBody, style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.textSecondary)),
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
