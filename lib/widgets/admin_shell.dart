import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/wide_layout.dart';
import '../features/admin/admin_dashboard_page.dart';
import '../features/admin/admin_gateway.dart';
import '../features/admin/admin_operations_page.dart';
import '../features/admin/admin_settings_page.dart';
import '../features/admin/admin_tasks_page.dart';
import '../features/notifications/notification_inbox.dart';
import '../features/notifications/push_registration.dart';
import '../l10n/l10n.dart';
import 'adaptive_nav_shell.dart';

// Thứ tự tab của app vận hành: ホーム / 運行 / 対応 / 設定 (Figma "Admin/Tab bar" 550:223).
abstract final class AdminTab {
  static const home = 0;
  static const operations = 1;
  static const tasks = 2;
  static const settings = 3;
}

final adminTabProvider = StateProvider.autoDispose<int>((ref) => AdminTab.home);
// Mục đang mở trong tab 対応 (thẻ việc ở ダッシュボード chọn sẵn)
final adminTaskProvider = StateProvider.autoDispose<AdminTask>((ref) => AdminTask.issues);

// Mở tab 対応 ở đúng nhóm (thẻ việc ở ダッシュボード, お知らせ, thông báo của điện thoại): đọc lại danh sách để thấy việc vừa
// tới; iPad bỏ chọn việc cũ (có thể thuộc nhóm khác) → cột phải chờ chọn.
void openAdminTask(WidgetRef ref, AdminTask task) {
  refreshAdminTasks(ref);
  ref.read(adminSelectionProvider.notifier).state = null;
  ref.read(adminTaskProvider.notifier).state = task;
  ref.read(adminTabProvider.notifier).state = AdminTab.tasks;
}

// Shell + thông báo app (token đăng ký với p_app = 'admin' — server chỉ nhận khi đã aal2). Thông báo của admin là việc cần
// xử lý: đang mở app → tải lại số đếm; chạm → tab 対応 đúng nhóm (adminTaskFor).
class AdminApp extends StatelessWidget {
  const AdminApp({super.key, required this.userId, required this.email});
  final String userId;
  final String email;

  @override
  Widget build(BuildContext context) {
    return PushRegistrar(
      onMessage: (context, ref) {
        ref.invalidate(adminBadgesProvider);
        ref.invalidate(inboxUnreadProvider(userId));
      },
      onOpened: (context, ref, push) {
        final navigator = Navigator.of(context)..popUntil((route) => route.isFirst);
        final task = adminTaskFor(push.type);
        if (task != null) return openAdminTask(ref, task);
        // loại app chưa biết (server mới hơn app) → mở お知らせ như trước
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => NotificationInboxPage(userId: userId, onOpen: adminInboxOpener((t) => openAdminTask(ref, t))),
          ),
        );
      },
      child: AdminShell(userId: userId, email: email),
    );
  }
}

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.userId, required this.email});
  final String userId;
  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(adminTabProvider);
    final task = ref.watch(adminTaskProvider);
    final l10n = context.l10n;
    void goTo(int tab) => ref.read(adminTabProvider.notifier).state = tab;

    void select(int tab) {
      if (tab == AdminTab.home) {
        ref.invalidate(adminBadgesProvider);
        ref.invalidate(adminTonightProvider);
        ref.invalidate(inboxUnreadProvider(userId));
      }
      goTo(tab);
    }

    final wide = isWideLayout(context);
    final dashboard = AdminDashboardPage(
      userId: userId,
      onOpenTask: (task) => openAdminTask(ref, task),
    );
    final pages = IndexedStack(
      index: index,
      children: [
        // iPad ngang (Figma 791:3126): bên phải ダッシュボード là 運行モニタ — cùng dữ liệu với tab 運行 (adminRoutesProvider)
        if (wide)
          Row(
            children: [
              Expanded(child: dashboard),
              VerticalDivider(width: 1, color: context.eco.border),
              const SizedBox(width: adminMonitorPaneWidth, child: AdminOperationsPage(pollRoutes: false)),
            ],
          )
        else
          dashboard,
        const AdminOperationsPage(),
        AdminTasksPage(task: task, onSelect: (t) => ref.read(adminTaskProvider.notifier).state = t),
        AdminSettingsPage(userId: userId, email: email),
      ],
    );
    final tabs = <NavTab>[
      (const Key('adminNavHome'), Icons.grid_view_outlined, Icons.grid_view_rounded, l10n.adminTabHome),
      (const Key('adminNavOperations'), Icons.map_outlined, Icons.map, l10n.adminTabOperations),
      (const Key('adminNavTasks'), Icons.inbox_outlined, Icons.inbox, l10n.adminTabTasks),
      (const Key('adminNavSettings'), Icons.tune, Icons.tune, l10n.adminTabSettings),
    ];

    return AdaptiveNavShell(index: index, onSelect: select, tabs: tabs, body: pages);
  }
}
