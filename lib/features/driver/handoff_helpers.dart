import '../../l10n/l10n.dart';
import '../orders/order_helpers.dart';
import 'driver_gateway.dart';
import 'handoff_gateway.dart';

// Hợp đồng mã thủ công (06_画面設計 §SCR-M06, レビュー第25回): so khớp 4 ký tự CHỈ trong các đơn
// allocated của đúng điểm dừng này — không tra cứu toàn hệ thống. Dùng lại pickupManualCode() của
// Chương 17 để khách và tài xế luôn ra cùng 1 mã cho cùng 1 đơn.
List<ReservationAtStop> matchManualCode(List<ReservationAtStop> reservations, String input) {
  final code = input.trim().toUpperCase();
  if (code.length != 4) return const [];
  return reservations.where((r) => r.status == 'allocated' && pickupManualCode(r.orderId) == code).toList();
}

// Mã lỗi RPC (Chương 06/07/08) → câu của 10_API設計 API-013/014/016/020, lấy từ ARB theo ngôn ngữ.
String handoffErrorMessage(Object error, AppLocalizations l10n) {
  final text = error.toString();
  if (text.contains('E-ORDER-006')) return l10n.errorNotHandoverable;
  if (text.contains('E-ORDER-010')) return l10n.errorPaymentNotConfirmed; // 0070: đơn Stripe chưa chốt tiền
  if (text.contains('E-ORDER-007')) return l10n.errorWalkupSoldOut;
  if (text.contains('E-ORDER-008')) return l10n.errorWalkupNotConfirmed;
  if (text.contains('E-ORDER-003')) return l10n.errorBatchExpired;
  if (text.contains('E-ROUTE-409')) return l10n.errorStopClosed;
  if (text.contains('E-INV-001')) return l10n.errorDonationExceedsStock;
  if (text.contains('E-INV-003')) return l10n.errorDonationNotConfirmed;
  if (text.contains('E-INV-004')) return l10n.errorDonationStopsOpen;
  if (text.contains('E-INV-005')) return l10n.errorDonationNoteRequired;
  if (text.contains('E-AUTH-403')) return l10n.errorNotAssignedDriver;
  return l10n.errorGeneric;
}

// SCR-D04: số lượng tặng phải là số nguyên dương (record_donation tự chặn ≤ 0 bằng E-INV-002).
String? validateDonationQty(String raw, AppLocalizations l10n) {
  if (raw.trim().isEmpty) return l10n.errorDonationQtyRequired;
  final value = int.tryParse(raw.trim());
  if (value == null || value <= 0) return l10n.errorPositiveInteger;
  return null;
}

// SCR-D04 chỉ mở form tặng khi MỌI điểm bán (type='public') của tuyến đã 出発 — cùng điều kiện mà
// record_donation kiểm tra ở server (E-INV-004, レビュー第30回). Điểm thu gom (restaurant) không bán gì nên
// không tính.
int openSalesStopCount(List<DriverStop> stops) => stops.where((s) => s.type == 'public' && s.departedAt == null).length;
