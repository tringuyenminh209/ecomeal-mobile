import 'package:flutter/widgets.dart';

// Chạm ra ngoài ô nhập thì bàn phím hạ xuống (2026-10-12, chủ dự án báo ở cả 4 app). Trên điện thoại Flutter KHÔNG tự
// bỏ focus khi chạm ra ngoài (onTapOutside mặc định chỉ làm việc đó với chuột/desktop), nên bọc 1 lần ở gốc app.
// Nút, ô nhập khác, danh sách... vẫn nhận chạm trước (cây con thắng trong gesture arena) — chỉ chạm vào chỗ trống mới tới đây.
class TapOutsideToUnfocus extends StatelessWidget {
  const TapOutsideToUnfocus({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    );
  }
}
