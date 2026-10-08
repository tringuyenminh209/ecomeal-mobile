import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/l10n.dart';

// Official Account nhận/gửi thông báo "xe sắp tới" (Chương 09, @939hqcxi) — giá trị công khai trong env.json.
// Thiếu thì app ẩn các nút mở LINE thay vì mở 1 link hỏng.
const lineOfficialAccountId = String.fromEnvironment('LINE_OFFICIAL_ACCOUNT_ID');

// line.me/R/ti/p/@id: có app LINE thì mở trang OA (kết bạn nếu chưa, rồi vào trò chuyện), không có thì mở web.
// Đây cũng là đường để người lỡ bỏ qua bước 友だち追加 lúc liên kết kết bạn lại — LINE chỉ push cho bạn bè.
Uri? lineOfficialAccountUri(String accountId) {
  final id = accountId.trim();
  if (id.isEmpty) return null;
  return Uri.https('line.me', '/R/ti/p/${id.startsWith('@') ? id : '@$id'}');
}

// null = chưa cấu hình. Test thay bằng hàm giả (không mở trình duyệt thật).
final openLineOfficialAccountProvider = Provider<Future<bool> Function()?>((ref) {
  final uri = lineOfficialAccountUri(lineOfficialAccountId);
  if (uri == null) return null;
  return () => launchUrl(uri, mode: LaunchMode.externalApplication);
});

// Dùng chung cho SCR-M07 và trạng thái Empty của SCR-M03. Mở thất bại (không có trình duyệt, lỗi hệ thống) → toast.
Future<void> openLineOfficialAccount(BuildContext context, WidgetRef ref) async {
  final open = ref.read(openLineOfficialAccountProvider);
  final messenger = ScaffoldMessenger.of(context);
  final failed = context.l10n.errorOpenLine;
  var opened = false;
  try {
    opened = open != null && await open();
  } catch (_) {}
  if (!opened) messenger.showSnackBar(SnackBar(content: Text(failed)));
}
