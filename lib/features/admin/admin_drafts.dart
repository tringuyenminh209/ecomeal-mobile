import 'package:flutter_riverpod/flutter_riverpod.dart';

// Nháp ở các màn xử lý việc của vận hành (audit A02, ghi chú Figma 972:22609): đang viết dở việc A mà mở việc B (iPad: chạm
// danh sách bên trái; iPhone: Back) hoặc xoay iPad đổi 1 cột / 2 cột → màn chi tiết của A bị bỏ khỏi cây widget và mất chữ.
// Giữ nháp theo từng việc ở đây (sống cả phiên, không autoDispose); lưu xong thì xoá; đóng app thì mất.
// Khoá: '<loại>:<id>' (vd 'inquiry:q-1'). Không ai watch → đổi map không cần báo dựng lại.
final adminDraftsProvider = Provider<Map<String, Object>>((ref) => {});

typedef InquiryDraft = ({String status, String note});
typedef IssueDraft = ({String amount, String answer});
typedef LicenseDraft = ({String? expiresOn});
