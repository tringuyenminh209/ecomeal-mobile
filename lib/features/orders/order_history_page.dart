import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/state_panel.dart';
import '../../widgets/status_badge.dart';
import 'order_gateway.dart';
import 'order_helpers.dart';
import 'order_rating.dart';
import 'receipt_page.dart';
import 'report_issue_page.dart';
import '../../widgets/skeleton.dart';
import '../../core/haptics.dart';

final myOrdersProvider = FutureProvider.autoDispose<List<OrderSummary>>((ref) {
  return ref.watch(orderGatewayProvider).fetchMyOrders();
});

// SCR-M06 — khớp frame Figma 16:16592 (数量確認待ち) / 78:192 (取り置き済み・QR) / 67:249 (キャンセル確認).
class OrderHistoryPage extends ConsumerStatefulWidget {
  // onBrowse: nút ở trạng thái Empty quay về tab ホーム (06 §SCR-M06 "SCR-M03への導線") — CustomerShell truyền vào.
  const OrderHistoryPage({super.key, this.onBrowse});
  final VoidCallback? onBrowse;

  @override
  ConsumerState<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends ConsumerState<OrderHistoryPage> {
  OrderFilter _filter = OrderFilter.all;

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(myOrdersProvider);
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.orderHistoryTitle, style: textTheme.titleLarge),
                  const SizedBox(height: 2),
                  Text(l10n.orderHistorySubtitle, style: textTheme.bodySmall),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: Row(
                children: [
                  _FilterChip(label: l10n.filterAll, selected: _filter == OrderFilter.all, onTap: () => setState(() => _filter = OrderFilter.all)),
                  const SizedBox(width: 8),
                  _FilterChip(label: l10n.filterActive, selected: _filter == OrderFilter.active, onTap: () => setState(() => _filter = OrderFilter.active)),
                  const SizedBox(width: 8),
                  _FilterChip(label: l10n.filterCompleted, selected: _filter == OrderFilter.completed, onTap: () => setState(() => _filter = OrderFilter.completed)),
                ],
              ),
            ),
            Expanded(
              child: ordersAsync.when(
                loading: () => const _HistorySkeleton(),
                error: (_, __) => Center(
                  child: StatePanel.error(
                    title: l10n.errorLoadTitle,
                    message: l10n.errorLoadBody,
                    actionLabel: l10n.retry,
                    onAction: () => ref.invalidate(myOrdersProvider),
                  ),
                ),
                data: (orders) {
                  final filtered = filterOrders(orders, _filter, (o) => o.status);
                  // Kéo xuống để tải lại: trạng thái đơn đổi ở server (tài xế xác nhận số lượng → allocated).
                  Future<void> refresh() => ref.refresh(myOrdersProvider.future);
                  if (filtered.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: refresh,
                      // ListView (không phải Center) để vẫn kéo được khi danh sách trống.
                      child: ListView(
                        padding: const EdgeInsets.only(top: 48),
                        children: [
                          StatePanel(
                            icon: Icons.receipt_long_outlined,
                            title: l10n.orderHistoryEmpty,
                            actionLabel: l10n.browseBatches,
                            onAction: widget.onBrowse,
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: refresh,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) => _OrderCard(
                        key: Key('orderCard_${filtered[index].id}'),
                        order: filtered[index],
                        onCancelled: () => ref.invalidate(myOrdersProvider),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// "Filter" của Figma: viên bo 18, đang chọn = nền Primary chữ trắng; còn lại = nền trắng viền Border.
class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      shape: StadiumBorder(side: BorderSide(color: selected ? AppColors.primary : AppColors.border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: selected ? AppColors.surface : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _HistorySkeleton extends StatelessWidget {
  const _HistorySkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, __) => const SkeletonBox(height: 110, radius: 12),
      ),
    );
  }
}

class _OrderCard extends ConsumerStatefulWidget {
  const _OrderCard({super.key, required this.order, required this.onCancelled});
  final OrderSummary order;
  final VoidCallback onCancelled;

  @override
  ConsumerState<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends ConsumerState<_OrderCard> {
  bool _isCancelling = false;

  Future<void> _showCancelDialog() async {
    // BR-003: chỉ đổi NỘI DUNG cảnh báo theo mốc 30 phút, không chặn việc hủy (06_画面設計 §SCR-M06).
    final isFree = isFreeCancellation(widget.order.plannedPickupTime);
    final l10n = context.l10n;
    // "Cancel confirmation modal" của Figma 67:344 — khung kết quả hoàn tiền nằm giữa mô tả và 2 nút.
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.cancelDialogTitle,
      message: isFree ? l10n.cancelDialogFree : l10n.cancelDialogNoRefund,
      messageKey: const Key('cancelDialogMessage'),
      cancelLabel: l10n.back,
      confirmLabel: l10n.cancelConfirmButton,
      confirmKey: const Key('confirmCancelButton'),
      destructive: true,
      extra: _RefundNote(isFree: isFree),
    );
    if (confirmed != true) return;

    setState(() => _isCancelling = true);
    try {
      final result = await ref.read(orderGatewayProvider).cancelOrder(widget.order.id);
      Haptics.success();
      if (mounted) {
        // refund_amount từ server là nguồn quyết định cuối cùng — không dùng lại isFree ở client.
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.refundAmount > 0 ? l10n.cancelledWithRefund(result.refundAmount) : l10n.cancelledNoRefund),
        ));
      }
      widget.onCancelled();
    } catch (_) {
      Haptics.error();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorCancelFailed)));
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  // SCR-M15: gửi xong → báo và tải lại danh sách (thẻ đổi sang 「確認中」)
  Future<void> _openReport() async {
    final sent = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ReportIssuePage(order: widget.order)),
    );
    if (sent != true || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.reportIssueSent)));
    widget.onCancelled();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final l10n = context.l10n;
    final badge = badgeForStatus(order.status, l10n);
    final showCancel = canCancel(order.status);
    final isFree = isFreeCancellation(order.plannedPickupTime);
    final canReport = canReportIssue(status: order.status, hasIssue: order.issue != null, plannedPickupTime: order.plannedPickupTime);
    const secondary = TextStyle(fontSize: 11, color: AppColors.textSecondary);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(label: badge.label, tone: badge.tone),
              // Figma: 「本日 20:10」/「9月28日 19:40」 — giờ Tokyo, mẫu ngày theo locale (order_helpers.dart)
              Text(orderTimeLabel(order.plannedPickupTime, l10n), style: secondary),
            ],
          ),
          const SizedBox(height: 10),
          Text(l10n.mysteryBag, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)), // xem box-warn đầu chương
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.orderNumber(orderDisplayNumber(order.id)), style: secondary),
              Text(
                l10n.priceTaxIncluded('¥${order.pricePaid}'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          // Figma 432:1074: chỉ đơn đã nhận mới có biên lai (đơn chưa nhận còn có thể bị huỷ / hoàn tiền).
          // Figma 463:5600 (0050): 「問題を報告」 cho đơn đã nhận / hết hạn, trong 48 giờ, chưa báo cáo.
          if (order.status == 'picked_up' || canReport) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (order.status == 'picked_up')
                  OutlinedButton(
                    key: const Key('receiptButton'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => ReceiptPage(order: order)),
                    ),
                    child: Text(l10n.receiptButton),
                  ),
                if (canReport)
                  OutlinedButton(
                    key: const Key('reportIssueButton'),
                    onPressed: _openReport,
                    child: Text(l10n.reportIssueButton),
                  ),
              ],
            ),
          ],
          if (order.issue != null) ...[
            const SizedBox(height: 10),
            _IssueNote(issue: order.issue!),
          ],
          // 0054 (Figma 463:5600 / 463:5710): mời đánh giá trong 7 ngày; đã đánh giá thì hiện số sao
          if (canRateOrder(status: order.status, rating: order.rating, plannedPickupTime: order.plannedPickupTime)) ...[
            const SizedBox(height: 10),
            RatingPrompt(order: order, onRated: widget.onCancelled),
          ] else if (order.rating case final rating?) ...[
            const SizedBox(height: 10),
            RatedNote(rating: rating),
          ],
          if (order.status == 'pending') ...[
            const SizedBox(height: 10),
            // "Pending note" của Figma: nền vàng nhạt, viền Amber.
            // 06_画面設計.md §SCR-M06, nguyên văn — diễn giải UC-15 (FIFO) cho khách hàng
            _NoteBox(
              background: AppColors.amberSoft,
              borderColor: AppColors.amber,
              title: l10n.statusPending,
              body: l10n.pendingExplanation,
            ),
          ],
          if (order.status == 'allocated') ...[
            const SizedBox(height: 10),
            _NoteBox(
              background: AppColors.primarySoft,
              borderColor: AppColors.primary,
              title: l10n.statusAllocated,
              body: l10n.allocatedExplanation(order.stopName),
            ),
            const SizedBox(height: 10),
            _PickupQr(orderId: order.id),
          ],
          if (showCancel) ...[
            const SizedBox(height: 10),
            Text(
              isFree ? l10n.freeCancelTitle : l10n.freeCancelExpired,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 11, color: isFree ? AppColors.textSecondary : AppColors.error),
            ),
            const SizedBox(height: 6),
            // Button/Secondary của Figma, canh phải (không kéo full chiều ngang thẻ).
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                key: const Key('cancelOrderButton'),
                onPressed: _isCancelling ? null : _showCancelDialog,
                child: _isCancelling
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.cancelButton),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// 0050: trạng thái báo cáo vấn đề (Figma 463:5600 確認中 / 443:1239 対応済み). Câu trả lời của 運営 hiện bên dưới.
class _IssueNote extends StatelessWidget {
  const _IssueNote({required this.issue});
  final OrderIssue issue;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (!issue.isResolved) {
      return _NoteBox(
        background: AppColors.amberSoft,
        borderColor: AppColors.amber,
        title: l10n.issueOpenTitle,
        body: l10n.issueOpenBody,
      );
    }
    final refund = issue.refundAmount ?? 0;
    return _NoteBox(
      background: AppColors.primarySoft,
      borderColor: AppColors.primary,
      title: refund > 0 ? l10n.issueResolvedRefund(refund) : l10n.issueResolvedNoRefund,
      body: issue.resolution ?? '',
    );
  }
}

class _NoteBox extends StatelessWidget {
  const _NoteBox({required this.background, required this.borderColor, required this.title, required this.body});
  final Color background;
  final Color borderColor;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(fontSize: 11, height: 1.6, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// Khối "受け取りQR" của Figma 78:192: tiêu đề + mã thủ công ở 2 đầu, QR trắng trên nền xanh đậm, chú thích.
class _PickupQr extends StatelessWidget {
  const _PickupQr({required this.orderId});
  final String orderId;

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
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
              // QR mã hoá orders.id đầy đủ — khớp UC-23 "ドライバーがQRコードまたは予約番号を確認" (xem box-warn đầu chương)
              child: QrImageView(data: orderId, size: 140),
            ),
          ),
          const SizedBox(height: 8),
          Text(l10n.pickupQrCaption, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// Khối "全額返金されます" trong modal huỷ: chỉ là dự báo theo mốc 30 phút — số tiền thật lấy từ refund_amount.
class _RefundNote extends StatelessWidget {
  const _RefundNote({required this.isFree});
  final bool isFree;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFree ? AppColors.primarySoft : AppColors.amberSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          StatusBadge(
            label: isFree ? l10n.refundFullBadge : l10n.refundNoneBadge,
            tone: isFree ? BadgeTone.active : BadgeTone.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isFree ? l10n.refundFullNote : l10n.refundNoneNote,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
