import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/line_menu_link.dart';
import '../../l10n/l10n.dart';
import 'auth_controller.dart';

// Biên phiên đăng nhập chung cho cả 4 app (docs/proposals/2026-10-14_mobile-session-payment-bug.md):
//  A. Phiên kết thúc (bấm đăng xuất / server từ chối) → đóng MỌI trang đang mở (hồ sơ, dialog…) về trang gốc. RoleGate là
//     `home` của MaterialApp nên tự đổi sang màn đăng nhập, nhưng trang đã push phía trên thì không tự đóng — tài xế bấm
//     đăng xuất ở SCR-D05 mà vẫn đứng ở SCR-D05.
//  B. App mở / quay lại màn hình → hỏi server phiên còn hiệu lực không (AuthController.verifySession). Server từ chối →
//     đăng xuất trên máy và báo 「ログインし直してください」 (sessionExpired). Mất mạng thì không làm gì.
// Đặt trong MaterialApp.builder (phía trên Navigator) nên dùng navigatorKey / scaffoldMessengerKey của MaterialApp.
class SessionGuard extends ConsumerStatefulWidget {
  const SessionGuard({super.key, required this.navigatorKey, required this.messengerKey, required this.child});

  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final Widget child;

  @override
  ConsumerState<SessionGuard> createState() => _SessionGuardState();
}

class _SessionGuardState extends ConsumerState<SessionGuard> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // phiên khôi phục từ máy lúc mở app (cold start) cũng phải được server xác nhận
    WidgetsBinding.instance.addPostFrameCallback((_) => _verify());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _verify();
  }

  void _verify() {
    if (!mounted) return;
    ref.read(authControllerProvider.notifier).verifySession();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AppAuthState>(authControllerProvider, (prev, next) {
      if (prev?.session == null || next.session != null) return;
      widget.navigatorKey.currentState?.popUntil((route) => route.isFirst);
      // Đích LINE Rich Menu chưa mở (bấm lúc chưa đăng nhập xong) không chuyển sang tài khoản đăng nhập sau
      ref.read(lineMenuLinksProvider).clear();
      if (next.sessionExpired) {
        final messenger = widget.messengerKey.currentState;
        final l10nContext = widget.navigatorKey.currentContext;
        if (messenger != null && l10nContext != null) {
          messenger.showSnackBar(SnackBar(content: Text(l10nContext.l10n.errorSessionExpired)));
        }
      }
    });
    return widget.child;
  }
}
