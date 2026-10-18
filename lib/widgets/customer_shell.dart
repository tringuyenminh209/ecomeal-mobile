import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/line_menu_link.dart';
import '../features/home/customer_home_page.dart';
import '../features/notifications/notification_inbox.dart';
import '../features/orders/active_order_page.dart';
import '../features/orders/order_gateway.dart';
import '../features/orders/order_history_page.dart';
import '../l10n/l10n.dart';
import 'fade_on_change.dart';
import 'pill_tab_bar.dart';
import '../features/profile/my_page.dart';

// Thứ tự tab: ホーム / 予約 / マイページ (Figma, 05_画面遷移図 SCR-M03/M06/M07).
abstract final class CustomerTab {
  static const home = 0;
  static const orders = 1;
  static const myPage = 2;
}

// Tab đang mở nằm trong provider (không phải state cục bộ của shell): SCR-M05 đặt hàng xong cần nhảy sang
// tab 予約 trong khi nó đang nằm ở route khác phía trên shell. autoDispose: đăng xuất → shell bị gỡ →
// tài khoản đăng nhập sau luôn bắt đầu ở ホーム, không kế thừa tab của người trước.
final customerTabProvider = StateProvider.autoDispose<int>((ref) => CustomerTab.home);

// Thông báo của app khách đều về đơn đã đặt (hoàn tiền, xe tới, trả lời báo cáo, lô mới): đang mở app → tải lại đơn;
// chạm thông báo → mở tab 予約 (PushRegistrar).
void refreshOrdersAfterPush(BuildContext context, WidgetRef ref) {
  ref.invalidate(myOrdersProvider);
  ref.invalidate(inboxUnreadProvider); // thông báo mới cũng vào お知らせ (SCR-M20) → chấm ở chuông
}

void openOrdersFromPush(BuildContext context, WidgetRef ref) {
  ref.invalidate(myOrdersProvider);
  ref.read(customerTabProvider.notifier).state = CustomerTab.orders;
}

// Mobile/Bottom Navigation của Figma (88:245) = PillTabBar (viên thuốc trượt, Figma 「動きの提案（Liquid 風）」 M00).
// Nội dung đổi tab hiện dần (FadeOnChange).
// Shell chỉ hiện khi đã đăng nhập đúng app khách (RoleGate) → đây là nơi mở đích của LINE Rich Menu (LineMenuLinks):
// bấm lúc chưa đăng nhập thì đích chờ tới khi shell xuất hiện; bấm lúc app đang mở thì mở ngay.
class CustomerShell extends ConsumerStatefulWidget {
  const CustomerShell({super.key, this.userId});
  final String? userId;

  @override
  ConsumerState<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends ConsumerState<CustomerShell> {
  late final LineMenuLinks _links;

  @override
  void initState() {
    super.initState();
    _links = ref.read(lineMenuLinksProvider);
    _links.addListener(_openLineMenuTarget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _openLineMenuTarget());
  }

  @override
  void dispose() {
    _links.removeListener(_openLineMenuTarget);
    super.dispose();
  }

  void _goTo(int tab) => ref.read(customerTabProvider.notifier).state = tab;

  // Figma 905:187 — A ホーム（中）/ B 予約タブ / C 受け取りの案内（1件）か予約タブ / D ホーム（低：地図）
  Future<void> _openLineMenuTarget() async {
    if (!mounted) return;
    final target = _links.take();
    if (target == null) return;
    // màn đang push phía trên shell (chi tiết lô, hồ sơ…) đóng lại để thấy đích
    Navigator.of(context).popUntil((route) => route.isFirst);
    switch (target) {
      case LineMenuTarget.browse:
        _goTo(CustomerTab.home);
        ref.read(homeSheetRequestProvider.notifier).state = HomeSheetRequest.standard;
      case LineMenuTarget.stops:
        _goTo(CustomerTab.home);
        ref.read(homeSheetRequestProvider.notifier).state = HomeSheetRequest.map;
      case LineMenuTarget.reservations:
        ref.invalidate(myOrdersProvider);
        _goTo(CustomerTab.orders);
      case LineMenuTarget.pickup:
        await _openPickup();
    }
  }

  // QR chỉ có ở đơn đã giữ chỗ (allocated — giống nút 受け取りの案内 ở SCR-M06). Đúng 1 đơn → mở thẳng SCR-M18;
  // 0 đơn hoặc nhiều đơn → tab 予約 (trạng thái trống / danh sách để chọn). Đơn luôn tải mới theo phiên hiện tại.
  Future<void> _openPickup() async {
    ref.invalidate(myOrdersProvider);
    _goTo(CustomerTab.orders);
    final List<OrderSummary> orders;
    try {
      orders = await ref.read(orderGatewayProvider).fetchMyOrders();
    } catch (_) {
      return; // tab 予約 tự hiện lỗi + nút thử lại
    }
    if (!mounted) return;
    final ready = orders.where((o) => o.status == 'allocated').toList();
    if (ready.length != 1) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ActiveOrderPage(order: ready.single)));
  }

  @override
  Widget build(BuildContext context) {
    final userId = widget.userId;
    final index = ref.watch(customerTabProvider);
    void goTo(int tab) => _goTo(tab);
    final l10n = context.l10n;

    return Scaffold(
      // IndexedStack giữ cả 3 trang sống: quay lại tab thì bản đồ, bộ lọc, vị trí cuộn còn nguyên.
      // Nút ở trạng thái Empty của SCR-M03/M06 chuyển tab qua callback — trang con không tự biết shell.
      body: FadeOnChange(
        value: index,
        child: IndexedStack(
          index: index,
          children: [
            CustomerHomePage(
              userId: userId,
              onOpenMyPage: () => goTo(CustomerTab.myPage),
              onOpenOrders: () {
                ref.invalidate(myOrdersProvider);
                goTo(CustomerTab.orders);
              },
            ),
            OrderHistoryPage(onBrowse: () => goTo(CustomerTab.home)),
            // SCR-M07 (Chương 18) — có cả nút ログアウト.
            const MyPage(),
          ],
        ),
      ),
      bottomNavigationBar: PillTabBar(
        index: index,
        onSelect: (tab) {
          // Trạng thái đơn đổi ở server (tài xế xác nhận số lượng, giao hàng…) — mỗi lần mở tab 予約 tải lại.
          if (tab == CustomerTab.orders) ref.invalidate(myOrdersProvider);
          goTo(tab);
        },
        tabs: [
          (const Key('navHome'), Icons.home_outlined, Icons.home, l10n.homeTab),
          (const Key('navOrders'), Icons.receipt_long_outlined, Icons.receipt_long, l10n.reservationsTab),
          (const Key('navProfile'), Icons.person_outline, Icons.person, l10n.myPageTab),
        ],
      ),
    );
  }
}
