import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/admin/admin_dashboard_page.dart';
import '../features/admin/admin_gateway.dart';
import '../features/admin/admin_operations_page.dart';
import '../features/admin/admin_settings_page.dart';
import '../features/admin/admin_tasks_page.dart';
import '../features/notifications/notification_inbox.dart';
import '../features/notifications/push_registration.dart';
import '../l10n/l10n.dart';

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

// Shell + thông báo app (token đăng ký với p_app = 'admin' — server chỉ nhận khi đã aal2). Thông báo của admin là việc cần
// xử lý: đang mở app → tải lại số đếm; chạm → mở お知らせ.
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
      onOpened: (context, ref) =>
          Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => NotificationInboxPage(userId: userId))),
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

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: [
          AdminDashboardPage(
            userId: userId,
            onOpenTask: (task) {
              ref.read(adminTaskProvider.notifier).state = task;
              goTo(AdminTab.tasks);
            },
          ),
          const AdminOperationsPage(),
          AdminTasksPage(task: task, onSelect: (t) => ref.read(adminTaskProvider.notifier).state = t),
          AdminSettingsPage(userId: userId, email: email),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: select,
        destinations: [
          NavigationDestination(
            key: const Key('adminNavHome'),
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: const Icon(Icons.grid_view_rounded),
            label: l10n.adminTabHome,
          ),
          NavigationDestination(
            key: const Key('adminNavOperations'),
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: l10n.adminTabOperations,
          ),
          NavigationDestination(
            key: const Key('adminNavTasks'),
            icon: const Icon(Icons.inbox_outlined),
            selectedIcon: const Icon(Icons.inbox),
            label: l10n.adminTabTasks,
          ),
          NavigationDestination(
            key: const Key('adminNavSettings'),
            icon: const Icon(Icons.tune),
            selectedIcon: const Icon(Icons.tune),
            label: l10n.adminTabSettings,
          ),
        ],
      ),
    );
  }
}
