import 'package:flutter/services.dart';

// Rung phản hồi cho các thao tác có kết quả thật (giao hàng, quét QR, đặt / huỷ đơn). Tài xế thao tác một tay, mắt nhìn
// khách và túi hàng — rung cho biết thành công / thất bại mà không phải đọc SnackBar. Chỉ dùng ở các điểm này, không
// rung mỗi lần chạm (hệ thống đã có rung khi chạm nút nếu người dùng bật).
abstract final class Haptics {
  // Thao tác hoàn tất (đã giao, đã đặt, đã huỷ, đọc được QR).
  static Future<void> success() => HapticFeedback.mediumImpact();

  // Thao tác bị từ chối (QR không thuộc điểm này, lỗi API) — mạnh hơn để phân biệt với thành công.
  static Future<void> error() => HapticFeedback.heavyImpact();

  // Chọn 1 mục trong nhóm (chọn lô hàng, đổi tab trạng thái).
  static Future<void> selection() => HapticFeedback.selectionClick();
}
