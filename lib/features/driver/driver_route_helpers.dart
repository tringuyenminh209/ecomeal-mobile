import '../../l10n/l10n.dart';
import 'driver_gateway.dart';

// Điểm dừng kế tiếp = điểm đầu tiên (theo sequence) chưa rời đi. null: đã đi hết tuyến.
DriverStop? nextStopOf(List<DriverStop> stops) {
  for (final stop in stops) {
    if (stop.departedAt == null) return stop;
  }
  return null;
}

// "次の停車 8分" — chỉ là planned_time − bây giờ (không có API dẫn đường thật), không âm.
int minutesUntil(DateTime plannedTime, {DateTime? now}) {
  final diff = plannedTime.difference(now ?? DateTime.now()).inMinutes;
  return diff < 0 ? 0 : diff;
}

// Danh sách điểm bán ĐƯỢC PHÉP chọn ở SCR-D02: điểm public, sau điểm thu gom của chính nhà hàng này,
// chưa rời đi. Đây chỉ là gợi ý cho ô chọn — confirm_surplus_batch (Chương 04) tự kiểm tra lại
// đúng 3 điều kiện này ở server (E-ORDER-004), client không phải nơi quyết định.
List<DriverStop> distributableStopsAfter(List<DriverStop> stops, DriverStop collectionStop) {
  return stops
      .where((s) => s.type == 'public' && s.sequence > collectionStop.sequence && s.departedAt == null)
      .toList();
}

// "集荷 2/5" — thứ tự của điểm thu gom này trong các điểm thu gom (type='restaurant') của tuyến.
({int index, int total}) pickupPositionOf(List<DriverStop> stops, DriverStop collectionStop) {
  final restaurantStops = stops.where((s) => s.type == 'restaurant').toList();
  return (index: restaurantStops.indexWhere((s) => s.routeStopId == collectionStop.routeStopId) + 1, total: restaurantStops.length);
}

// Mã lỗi RPC (raise 'E-XXX: ...') → câu của 10_API設計 API-006/026, lấy từ ARB theo ngôn ngữ đang dùng.
String confirmErrorMessage(Object error, AppLocalizations l10n) {
  final text = error.toString();
  if (text.contains('E-ORDER-009')) return l10n.errorBatchAlreadyConfirmed;
  if (text.contains('E-ORDER-004')) return l10n.errorStopNotOnRoute;
  if (text.contains('E-ROUTE-409')) return l10n.errorStopClosed;
  if (text.contains('E-TEMP-001')) return l10n.errorTemperatureRange;
  return l10n.errorConfirmFailed;
}

// SCR-D02 nhiệt độ: numeric(4,1) ở DB. Giới hạn -30〜99.9 chỉ để chặn gõ nhầm (vd 520 thay vì 5.2) —
// không đặt trần thấp hơn vì món giữ nóng có thể trên 60℃. Ngưỡng an toàn 10℃ là CẢNH BÁO, không chặn.
// Cùng khoảng với kiểm tra E-TEMP-001 của RPC 0033 — server vẫn tự chặn lại.
String? validateTemperature(String raw, AppLocalizations l10n) {
  final value = double.tryParse(raw.trim());
  if (raw.trim().isEmpty) return l10n.errorTemperatureRequired;
  // NaN so sánh với số nào cũng ra false → phải loại riêng (double.tryParse("NaN") không trả null).
  if (value == null || value.isNaN || value < -30 || value > 99.9) return l10n.errorTemperatureRange;
  return null;
}

String? validateConfirmedQty(String raw, AppLocalizations l10n) {
  if (raw.trim().isEmpty) return l10n.errorConfirmedQtyRequired;
  final value = int.tryParse(raw.trim());
  if (value == null || value < 0) return l10n.errorNonNegativeInteger;
  return null;
}
