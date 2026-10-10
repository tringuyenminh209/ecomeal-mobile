import 'package:intl/intl.dart';

// Asia/Tokyo là UTC+9 cố định quanh năm (không có giờ mùa hè) — cộng thẳng 9 giờ vào UTC là
// chính xác, không cần package timezone. Dùng lại cho mọi nơi cần biết "ngày hôm nay/ngày mai
// theo giờ Nhật" (13_詳細設計書.md §5.2 dùng chính điều kiện created_at AT TIME ZONE 'Asia/Tokyo').
String _formatDate(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

// Đổi 1 thời điểm sang "giờ treo tường" Tokyo. Kết quả là DateTime UTC mang số giờ JST — chỉ dùng để
// định dạng/so ngày, không dùng để so sánh thời điểm với DateTime khác.
DateTime toTokyo(DateTime t) => t.toUtc().add(const Duration(hours: 9));

// Ngày (YYYY-MM-DD) theo giờ Tokyo của 1 thời điểm bất kỳ (vd ngày nộp đơn — SCR-S00).
String dateInTokyo(DateTime t) => _formatDate(toTokyo(t));

String todayInTokyo() => dateInTokyo(DateTime.now());

String tomorrowInTokyo() {
  return _formatDate(toTokyo(DateTime.now()).add(const Duration(days: 1)));
}

// Figma vẽ khung giờ nhận hàng dạng "20:10–20:30", nhưng app chỉ có planned_time (1 mốc) — khung +20 phút
// là quy ước hiển thị của dự án, KHÔNG phải dữ liệu DB (box-why SCR-M05, Chương 17). SCR-M04 (Chương 16)
// và SCR-M05 (Chương 17) gọi CÙNG hàm này để 2 màn luôn hiện cùng 1 khung giờ cho cùng 1 điểm dừng.
const pickupWindowLength = Duration(minutes: 20);

String pickupWindowLabel(DateTime plannedTime) {
  final format = DateFormat('HH:mm');
  final start = toTokyo(plannedTime);
  return '${format.format(start)}–${format.format(start.add(pickupWindowLength))}';
}

int remainingMinutes(DateTime expiresAt, DateTime now) =>
    ((expiresAt.difference(now).inSeconds + 59) ~/ 60).clamp(0, 99999);

// YYYY-MM-DD に日数を足す（SCR-D05「今後のシフト」の期間）。UTC で計算して端末のタイムゾーンに依存しない。
String addDaysToDate(String date, int days) =>
    _formatDate(DateTime.parse('${date}T00:00:00Z').add(Duration(days: days)));

// 運営日（YYYY-MM-DD）の表示: ja「10月6日(火)」/ en「Tue, Oct 6」
String formatServiceDate(String date, String locale) => DateFormat.MMMEd(locale).format(DateTime.parse(date));

// 年まで必要な日付（運転免許の有効期限）: ja「2029年3月31日」/ en「Mar 31, 2029」
String formatDateWithYear(String date, String locale) => DateFormat.yMMMd(locale).format(DateTime.parse(date));
