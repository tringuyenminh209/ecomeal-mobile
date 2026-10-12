import 'package:flutter/widgets.dart';

// Token chuyển động của cả app (Figma 00 Foundations "Motion tokens"; docs/proposals/2026-10-12_mobile-animation-guide.md).
// Mọi animation lấy thời lượng / curve ở đây, không ghi số rải rác. Người dùng bật "giảm chuyển động"
// (iOS: 視差効果を減らす / Android: アニメーションを削除) → [of] trả 0: đổi trạng thái ngay, không trượt / phóng.
abstract final class Motion {
  // Phản hồi chạm (nút lún, ☆ nảy)
  static const tap = Duration(milliseconds: 120);
  // Thay đổi nhỏ (chip, ☆ bật/tắt, số đổi)
  static const small = Duration(milliseconds: 200);
  // Chuyển màn có phần tử chung (thẻ → chi tiết)
  static const page = Duration(milliseconds: 320);
  // Xe tải trên bản đồ trượt tới vị trí mới
  static const marker = Duration(milliseconds: 1200);
  // Khoảnh khắc ăn mừng (thanh toán xong, nhận hàng xong) — chỉ 2 chỗ này
  static const celebrate = Duration(milliseconds: 700);

  static const enter = Curves.easeOutCubic;
  static const exit = Curves.easeInCubic;
  static const move = Curves.easeInOutCubic;
  // Nảy nhẹ khi xuất hiện (vòng tròn ✓, ☆)
  static const pop = Curves.easeOutBack;

  static bool reduced(BuildContext context) => MediaQuery.disableAnimationsOf(context);

  static Duration of(BuildContext context, Duration duration) => reduced(context) ? Duration.zero : duration;
}
