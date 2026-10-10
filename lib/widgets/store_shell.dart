import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../features/notifications/notification_inbox.dart';
import '../features/notifications/push_registration.dart';
import '../features/store/store_batch_detail_page.dart';
import '../features/store/store_gateway.dart';
import '../features/store/store_home_page.dart';
import '../features/store/store_register_done_page.dart';
import '../features/store/store_register_page.dart';
import '../features/store/store_settings_page.dart';
import '../features/store/store_layout.dart';
import '../features/store/store_settlement_page.dart';
import '../l10n/l10n.dart';
import 'ecomeal_logo.dart';

// Thứ tự tab của app nhà hàng: ホーム / 登録 / 精算 / 設定 (Figma "Store/Tab bar" 550:118).
abstract final class StoreTab {
  static const home = 0;
  static const register = 1;
  static const settlement = 2;
  static const settings = 3;
}

// Trong provider (như customerTabProvider): CTA「今日の余剰を登録」ở ホーム chuyển sang tab 登録. autoDispose: đăng xuất →
// tài khoản sau bắt đầu ở ホーム.
final storeTabProvider = StateProvider.autoDispose<int>((ref) => StoreTab.home);

// Shell + thông báo app (0059: token đăng ký với p_app = 'store'). Thông báo của quán là về lô / quyết toán / đánh giá:
// đang mở app → tải lại ホーム và chấm chưa đọc; chạm thông báo → mở お知らせ (SCR-S07).
class StoreApp extends StatelessWidget {
  const StoreApp({super.key, required this.restaurant, required this.userId});
  final StoreRestaurant restaurant;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return PushRegistrar(
      onMessage: (context, ref) {
        ref.invalidate(storeTodayBatchesProvider(restaurant.id));
        ref.invalidate(inboxUnreadProvider(userId));
      },
      onOpened: (context, ref) =>
          Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => NotificationInboxPage(userId: userId))),
      child: StoreShell(restaurant: restaurant, userId: userId),
    );
  }
}

class StoreShell extends ConsumerWidget {
  const StoreShell({super.key, required this.restaurant, required this.userId});
  final StoreRestaurant restaurant;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(storeTabProvider);
    void goTo(int tab) => ref.read(storeTabProvider.notifier).state = tab;
    final l10n = context.l10n;
    final id = restaurant.id;

    // Đăng ký xong (SCR-S02 → 登録完了): ホーム phải thấy lô mới ngay, không đợi lần tải sau
    void onRegistered(String batchId) {
      ref.invalidate(storeTodayBatchesProvider(id));
      final navigator = Navigator.of(context);
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => StoreRegisterDonePage(
            restaurantId: id,
            batchId: batchId,
            onViewBatch: () {
              goTo(StoreTab.home); // quay lại từ ロット詳細 → ホーム (không phải form trống)
              navigator.pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => StoreBatchDetailPage(restaurantId: id, batchId: batchId),
                ),
              );
            },
            onHome: () {
              navigator.pop();
              goTo(StoreTab.home);
            },
          ),
        ),
      );
    }

    // Số đơn / tiền đổi ở server — mỗi lần mở lại tab thì tải lại
    void select(int tab) {
      if (tab == StoreTab.home) {
        ref.invalidate(storeTodayBatchesProvider(id));
        ref.invalidate(storeMonthRevenueProvider(id));
        ref.invalidate(inboxUnreadProvider(userId));
      }
      if (tab == StoreTab.settlement) ref.invalidate(storeSettlementsProvider(id));
      goTo(tab);
    }

    final tabs = [
      (const Key('storeNavHome'), Icons.home_outlined, Icons.home, l10n.storeTabHome),
      (const Key('storeNavRegister'), Icons.add_circle_outline, Icons.add_circle, l10n.storeTabRegister),
      (
        const Key('storeNavSettlement'),
        Icons.account_balance_wallet_outlined,
        Icons.account_balance_wallet,
        l10n.storeTabSettlement,
      ),
      (const Key('storeNavSettings'), Icons.tune, Icons.tune, l10n.storeTabSettings),
    ];
    final pages = IndexedStack(
      index: index,
      children: [
        StoreHomePage(restaurant: restaurant, userId: userId, onRegister: () => goTo(StoreTab.register)),
        StoreRegisterPage(restaurant: restaurant, onRegistered: onRegistered),
        StoreSettlementPage(restaurant: restaurant),
        StoreSettingsPage(restaurant: restaurant, userId: userId),
      ],
    );

    // iPad ngang (Figma "Store/Side rail" 559:677): thanh dọc bên trái thay cho tab dưới
    if (isStoreWide(context)) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              right: false,
              child: NavigationRail(
                selectedIndex: index,
                onDestinationSelected: select,
                labelType: NavigationRailLabelType.all,
                leading: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: EcoMealLogo(height: 26)),
                destinations: [
                  for (final (key, icon, selectedIcon, label) in tabs)
                    NavigationRailDestination(
                      icon: Icon(icon, key: key),
                      selectedIcon: Icon(selectedIcon),
                      label: Text(label),
                    ),
                ],
              ),
            ),
            const VerticalDivider(width: 1, color: AppColors.border),
            Expanded(child: pages),
          ],
        ),
      );
    }
    return Scaffold(
      body: pages,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: select,
          destinations: [
            for (final (key, icon, selectedIcon, label) in tabs)
              NavigationDestination(key: key, icon: Icon(icon), selectedIcon: Icon(selectedIcon), label: label),
          ],
        ),
      ),
    );
  }
}
