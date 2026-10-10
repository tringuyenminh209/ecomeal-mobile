import 'package:intl/intl.dart';
import '../../core/jst_date.dart';
import '../../l10n/l10n.dart';
import '../../widgets/status_badge.dart';

// Suy ra "số đơn" hiển thị từ orders.id (UUID) — KHÔNG phải cột DB, xem box-warn đầu chương.
// Lấy 4 ký tự hex cuối, parse thành số, format 4 chữ số — tất định với cùng 1 id.
String orderDisplayNumber(String orderId) {
  final hex = orderId.replaceAll('-', '');
  final lastFour = hex.substring(hex.length - 4);
  final asNumber = int.parse(lastFour, radix: 16) % 10000;
  return '#EM-${asNumber.toString().padLeft(4, '0')}';
}

// Loại báo cáo sự cố (order_issues.category, 0050) — dùng ở SCR-M15 (khách chọn) và app vận hành (A01 / A04)
const issueCategories = ['wrong_contents', 'quality', 'not_received', 'other'];

String issueCategoryLabel(String category, AppLocalizations l10n) => switch (category) {
  'wrong_contents' => l10n.issueCategoryWrongContents,
  'quality' => l10n.issueCategoryQuality,
  'not_received' => l10n.issueCategoryNotReceived,
  _ => l10n.issueCategoryOther,
};

// Mã nhận hàng dự phòng khi QR không quét được — suy ra từ orders.id, KHÔNG phải khoá xác thực và
// KHÔNG dùng để tra cứu toàn hệ thống (4 ký tự hex không unique). Phía tài xế (SCR-D03) chỉ so khớp
// mã này trong danh sách đơn của ĐÚNG điểm dừng hiện tại mà app tài xế đã tải sẵn (RLS
// orders_select_driver, Chương 06), rồi gọi confirm_pickup bằng orders.id ĐẦY ĐỦ — xem box-warn
// đầu chương.
String pickupManualCode(String orderId) {
  final hex = orderId.replaceAll('-', '').toUpperCase();
  return hex.substring(hex.length - 4);
}

class OrderStatusBadge {
  const OrderStatusBadge({required this.label, required this.tone});
  final String label;
  final BadgeTone tone; // màu do StatusBadge (widgets/status_badge.dart) quyết định — không viết HEX ở đây
}

// Khớp bảng 6 dòng trong 06_画面設計.md §SCR-M06 và frame Figma SCR-M06. Nhãn lấy từ ARB nên hàm
// nhận AppLocalizations — vẫn là hàm thuần, test truyền thẳng bản dịch vào (test/helpers/test_app.dart).
// allocated = Active (xanh): Figma 78:192 tô xanh; bảng 06 trước レビュー第40回 ghi Warning — đã sửa theo Figma.
OrderStatusBadge badgeForStatus(String status, AppLocalizations l10n) {
  switch (status) {
    case 'pending':
      return OrderStatusBadge(label: l10n.statusPending, tone: BadgeTone.warning);
    case 'allocated':
      return OrderStatusBadge(label: l10n.statusAllocated, tone: BadgeTone.active);
    case 'picked_up':
      return OrderStatusBadge(label: l10n.statusPickedUp, tone: BadgeTone.neutral);
    case 'refunded':
      return OrderStatusBadge(label: l10n.statusRefunded, tone: BadgeTone.error);
    case 'expired':
      return OrderStatusBadge(label: l10n.statusExpired, tone: BadgeTone.error);
    case 'cancelled':
      return OrderStatusBadge(label: l10n.statusCancelled, tone: BadgeTone.warning);
    default:
      throw ArgumentError('unknown order status: $status');
  }
}

// Giờ trên thẻ SCR-M06 (Figma: 「本日 20:10」/「9月28日 19:40」). Luôn theo giờ Tokyo — planned_time từ
// Supabase là UTC, DateFormat định dạng đúng giá trị nó nhận nên phải đổi qua toTokyo() trước.
// "本日" = cùng ngày JST với now; mẫu ngày theo locale của intl (ja: 9月28日 / en: Sep 28).
String orderTimeLabel(DateTime plannedPickupTime, AppLocalizations l10n, {DateTime? now}) {
  final local = toTokyo(plannedPickupTime);
  final today = toTokyo(now ?? DateTime.now());
  final time = DateFormat('HH:mm').format(local); // cùng dạng với pickupWindowLabel (Hm của ja ra "1:00")
  final isToday = local.year == today.year && local.month == today.month && local.day == today.day;
  return isToday ? l10n.todayTime(time) : '${DateFormat.MMMd(l10n.localeName).format(local)} $time';
}

// BR-003: pending/allocated LUÔN hủy được (cancel_order cho phép cả sau mốc 30 phút).
// Mốc 30 phút chỉ quyết định CÓ HOÀN TIỀN hay không — xem isFreeCancellation() ngay dưới.
bool canCancel(String status) => status == 'pending' || status == 'allocated';

// Trước mốc (planned_time − 30 phút) → hủy miễn phí, hoàn toàn bộ; từ mốc trở đi → hủy không hoàn
// tiền. Chỉ dùng để chọn câu cảnh báo trong dialog — số tiền hoàn THẬT là refund_amount do
// cancel_order trả về (server dùng now() của DB, đồng hồ máy khách có thể lệch).
bool isFreeCancellation(DateTime plannedPickupTime, {DateTime? now}) {
  final effectiveNow = now ?? DateTime.now();
  return effectiveNow.isBefore(plannedPickupTime.subtract(const Duration(minutes: 30)));
}

enum OrderFilter { all, active, completed }

// 3 chip Figma: すべて/予約中/完了. "予約中" = chưa kết thúc (pending/allocated);
// "完了" = mọi kết cục còn lại (picked_up/refunded/expired/cancelled).
List<T> filterOrders<T>(List<T> orders, OrderFilter filter, String Function(T) statusOf) {
  switch (filter) {
    case OrderFilter.all:
      return orders;
    case OrderFilter.active:
      return orders.where((o) => canCancel(statusOf(o))).toList();
    case OrderFilter.completed:
      return orders.where((o) => !canCancel(statusOf(o))).toList();
  }
}

// 0050 (UC-40): báo cáo vấn đề — đơn đã nhận hoặc hết hạn, chưa báo cáo, trong 48 giờ kể từ giờ nhận dự kiến.
// Cùng điều kiện với report_order_issue (server vẫn kiểm lại bằng now() của DB).
const issueReportWindow = Duration(hours: 48);

// 0054 (UC-42): đánh giá trong 7 ngày kể từ giờ nhận dự kiến, chỉ đơn đã nhận, 1 lần (server kiểm lại: E-RATING-409/410)
const ratingWindow = Duration(days: 7);
bool canRateOrder({required String status, required int? rating, required DateTime plannedPickupTime, DateTime? now}) {
  if (status != 'picked_up' || rating != null) return false;
  return !(now ?? DateTime.now()).isAfter(plannedPickupTime.add(ratingWindow));
}

bool canReportIssue({required String status, required bool hasIssue, required DateTime plannedPickupTime, DateTime? now}) {
  if (hasIssue || (status != 'picked_up' && status != 'expired')) return false;
  return !(now ?? DateTime.now()).isAfter(plannedPickupTime.add(issueReportWindow));
}
