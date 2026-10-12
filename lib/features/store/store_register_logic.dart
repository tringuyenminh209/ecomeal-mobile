import '../../core/jst_date.dart';
import '../../core/rpc_error.dart';
import '../../l10n/l10n.dart';
import 'store_gateway.dart';

// Tỉ lệ phần của quán (revenue_share_pct, numeric): 25.00 → "25", 22.5 → "22.5" (S01, S06 và bước xác nhận S02)
String formatSharePct(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

// Phần của quán ước tính (tối đa): bán hết với giá hiện tại × tỉ lệ — cùng cách tính với Web W03 (CreateSurplusBatchPage)
int estimatedStoreShare({required int qty, required int price, required double sharePct}) => (qty * price * sharePct / 100).floor();

// allergen_types không có cột thứ tự (bài học 第49回) → thứ tự cố định theo seed 0002 và Figma SCR-S02.
// 8 品目 đầu là 特定原材料 (表示義務), 20 品目 sau là 表示推奨.
const allergenCodeOrder = [
  'egg',
  'milk',
  'wheat',
  'buckwheat',
  'peanut',
  'shrimp',
  'crab',
  'walnut',
  'almond',
  'abalone',
  'squid',
  'salmon_roe',
  'orange',
  'cashew',
  'kiwi',
  'beef',
  'sesame',
  'salmon',
  'mackerel',
  'soybean',
  'chicken',
  'banana',
  'pork',
  'matsutake',
  'peach',
  'mountain_yam',
  'apple',
  'gelatin',
];
const mandatoryAllergenCount = 8;

// 12 品目 hiện sẵn trên form (Figma SCR-S02 554:260, đúng thứ tự Figma): 8 特定原材料 + 大豆・鶏肉・豚肉・ごま
const commonAllergenCodes = [
  'egg',
  'milk',
  'wheat',
  'shrimp',
  'crab',
  'buckwheat',
  'peanut',
  'walnut',
  'soybean',
  'chicken',
  'pork',
  'sesame',
];

List<AllergenType> sortAllergens(List<AllergenType> types) {
  int rank(AllergenType t) {
    final i = allergenCodeOrder.indexOf(t.code);
    return i < 0 ? allergenCodeOrder.length : i; // mã lạ (thêm sau này) xếp cuối, không làm hỏng màn
  }

  return [...types]..sort((a, b) => rank(a).compareTo(rank(b)));
}

// Tên trên chip: bỏ phần chú thích trong ngoặc（落花生（ピーナッツ）→ 落花生）— sheet 28 品目 hiện tên đầy đủ
String allergenChipLabel(String name) => name.split('（').first;

// Hạn bán = ngày JST (hôm nay / ngày mai) + giờ:phút JST → thời điểm UTC
DateTime sellByAtJst({required DateTime now, required bool tomorrow, required int hour, required int minute}) {
  final today = toTokyo(now);
  return DateTime.utc(
    today.year,
    today.month,
    today.day + (tomorrow ? 1 : 0),
    hour,
    minute,
  ).subtract(const Duration(hours: 9));
}

// Giờ mặc định của 販売期限: giờ đóng cửa của quán (restaurants.closing_time 'HH:mm:ss'), không đọc được thì 21:00
({int hour, int minute}) defaultSellByTime(String closingTime) {
  final parts = closingTime.split(':');
  final h = parts.isNotEmpty ? int.tryParse(parts[0]) : null;
  final m = parts.length > 1 ? int.tryParse(parts[1]) : null;
  if (h == null || m == null || h > 23 || m > 59) return (hour: 21, minute: 0);
  return (hour: h, minute: m);
}

// Câu báo lỗi theo mã của create_surplus_batch (10_API設計 §3, API-004) — cùng bảng với Web (create-batch-error.ts)
String registerBatchErrorMessage(Object error, AppLocalizations l10n) {
  if (error is BatchPhotoUploadException) return l10n.storeErrPhotoUpload;
  return switch (rpcErrorCode(error)) {
    'E-REST-008' => l10n.storeErrSellByPast,
    'E-REST-011' => l10n.storeErrNotApproved,
    'E-REST-015' => l10n.storeErrPhotoInvalid,
    'E-REST-018' => l10n.storeErrAllergenRequired,
    'E-ROUTE-001' => l10n.storeErrNoTruck,
    'E-ROUTE-002' => l10n.storeErrNoStops,
    'E-ROUTE-003' => l10n.storeErrNoStopsLeft,
    'E-ROUTE-004' => l10n.storeErrTruckDeparted,
    _ => l10n.storeErrRegisterFailed,
  };
}
