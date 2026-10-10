import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/jst_date.dart';
import '../../core/supabase_client.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/state_panel.dart';

// Hộp「お知らせ」(0060, API-078〜079): dùng chung cho app nhà hàng (SCR-S07) và app vận hành. Chỉ đọc qua RPC — server chỉ
// trả thông báo của chính người đăng nhập. Nội dung hiển thị dựng từ `type` bằng ARB (thông báo không chứa số tiền / tên khách);
// riêng 'reservation_received' (0066) lấy số đơn + hạn bán từ `payload`.

class InboxNotification {
  const InboxNotification({
    required this.id,
    required this.type,
    required this.stopName,
    required this.isRead,
    required this.createdAt,
    this.payload,
  });
  final String id;
  final String type;
  final String? stopName;
  final Map<String, dynamic>? payload;
  final bool isRead;
  final DateTime createdAt;
}

class InboxPage {
  const InboxPage({required this.items, required this.unreadCount});
  final List<InboxNotification> items;
  final int unreadCount;
}

abstract class NotificationInboxGateway {
  Future<InboxPage> fetch({int limit = 50});
  Future<void> markAllRead();
}

class SupabaseNotificationInboxGateway implements NotificationInboxGateway {
  SupabaseNotificationInboxGateway(this._client);
  final SupabaseClient _client;

  @override
  Future<InboxPage> fetch({int limit = 50}) async {
    final j = await _client.rpc('get_my_notifications', params: {'p_limit': limit}) as Map<String, dynamic>;
    return InboxPage(
      unreadCount: j['unread_count'] as int,
      items: [
        for (final n in (j['items'] as List).cast<Map<String, dynamic>>())
          InboxNotification(
            id: n['id'] as String,
            type: n['type'] as String,
            stopName: n['stop_name'] as String?,
            payload: n['payload'] as Map<String, dynamic>?,
            isRead: n['read_at'] != null,
            createdAt: DateTime.parse(n['created_at'] as String),
          ),
      ],
    );
  }

  @override
  Future<void> markAllRead() => _client.rpc('mark_notifications_read');
}

final notificationInboxGatewayProvider = Provider<NotificationInboxGateway>(
  (ref) => SupabaseNotificationInboxGateway(SupabaseClientHolder.instance),
);

// Theo userId (bài học 第49回: không lộ dữ liệu của tài khoản trước trên cùng máy)
final inboxProvider = FutureProvider.autoDispose.family<InboxPage, String>(
  (ref, userId) => ref.watch(notificationInboxGatewayProvider).fetch(),
);

// Số chưa đọc cho chuông — tách khỏi danh sách để làm mới chuông mà không vẽ lại trang đang mở
final inboxUnreadProvider = FutureProvider.autoDispose.family<int, String>(
  (ref, userId) async => (await ref.watch(notificationInboxGatewayProvider).fetch(limit: 1)).unreadCount,
);

// 0066: 「販売期限 21:00 のロットに予約が3件入りました。合計8件です。」— payload thiếu / sai kiểu thì câu không có số
String _reservationBody(Map<String, dynamic>? p, AppLocalizations l10n) {
  final count = p?['new_count'];
  final total = p?['total_count'];
  final sellBy = p?['sell_by_at'] is String ? DateTime.tryParse(p!['sell_by_at'] as String) : null;
  if (count is! int || total is! int || sellBy == null) return l10n.noticeReservationReceivedFallback;
  return l10n.noticeReservationReceivedBody(DateFormat('HH:mm').format(toTokyo(sellBy)), count, total);
}

({String title, String body, IconData icon}) inboxContent(
  String type,
  AppLocalizations l10n, {
  Map<String, dynamic>? payload,
}) => switch (type) {
  'reservation_received' => (
    title: l10n.noticeReservationReceivedTitle,
    body: _reservationBody(payload, l10n),
    icon: Icons.shopping_bag_outlined,
  ),
  'restaurant_reviewed' => (
    title: l10n.noticeRestaurantReviewedTitle,
    body: l10n.noticeRestaurantReviewedBody,
    icon: Icons.verified_outlined,
  ),
  'settlement_confirmed' => (
    title: l10n.noticeSettlementConfirmedTitle,
    body: l10n.noticeSettlementConfirmedBody,
    icon: Icons.account_balance_wallet_outlined,
  ),
  'settlement_paid' => (
    title: l10n.noticeSettlementPaidTitle,
    body: l10n.noticeSettlementPaidBody,
    icon: Icons.payments_outlined,
  ),
  'batch_collected' => (
    title: l10n.noticeBatchCollectedTitle,
    body: l10n.noticeBatchCollectedBody,
    icon: Icons.local_shipping_outlined,
  ),
  'batch_photo_removed' => (
    title: l10n.noticeBatchPhotoRemovedTitle,
    body: l10n.noticeBatchPhotoRemovedBody,
    icon: Icons.image_outlined,
  ),
  'rating_received' => (
    title: l10n.noticeRatingReceivedTitle,
    body: l10n.noticeRatingReceivedBody,
    icon: Icons.star_outline_rounded,
  ),
  'issue_reported' => (
    title: l10n.noticeIssueReportedTitle,
    body: l10n.noticeIssueReportedBody,
    icon: Icons.warning_amber_rounded,
  ),
  'restaurant_applied' => (
    title: l10n.noticeRestaurantAppliedTitle,
    body: l10n.noticeRestaurantAppliedBody,
    icon: Icons.storefront_outlined,
  ),
  'license_submitted' => (
    title: l10n.noticeLicenseSubmittedTitle,
    body: l10n.noticeLicenseSubmittedBody,
    icon: Icons.badge_outlined,
  ),
  'inquiry_received' => (
    title: l10n.noticeInquiryReceivedTitle,
    body: l10n.noticeInquiryReceivedBody,
    icon: Icons.chat_bubble_outline_rounded,
  ),
  // Loại mới thêm ở server mà app chưa biết: vẫn hiện, không làm hỏng màn (bài học 第53回)
  _ => (title: l10n.noticeGenericTitle, body: '', icon: Icons.notifications_outlined),
};

// 「たった今」「5分前」(trong 1 giờ) → giờ hôm nay → 「昨日 18:02」→ ngày (JST)
String inboxTimeLabel(DateTime at, DateTime now, AppLocalizations l10n, String locale) {
  final diff = now.difference(at);
  if (diff.inMinutes < 1) return l10n.inboxJustNow;
  if (diff.inMinutes < 60) return l10n.inboxMinutesAgo(diff.inMinutes);
  final day = dateInTokyo(at);
  final time = DateFormat('HH:mm').format(toTokyo(at));
  if (day == dateInTokyo(now)) return time;
  if (day == dateInTokyo(now.subtract(const Duration(days: 1)))) return l10n.inboxYesterday(time);
  return DateFormat.MMMd(locale).format(DateTime.parse(day));
}

// SCR-S07 お知らせ（558:501 / Empty 558:581）. Mở trang = đã xem: đánh dấu đã đọc sau khi hiện (lần này vẫn tô nền mục chưa đọc).
class NotificationInboxPage extends ConsumerStatefulWidget {
  const NotificationInboxPage({super.key, required this.userId});
  final String userId;

  @override
  ConsumerState<NotificationInboxPage> createState() => _NotificationInboxPageState();
}

class _NotificationInboxPageState extends ConsumerState<NotificationInboxPage> {
  bool _marked = false;

  void _markReadOnce(InboxPage page) {
    if (_marked || page.unreadCount == 0) return;
    _marked = true;
    // Đánh dấu là phụ: lỗi mạng thì lần mở sau vẫn còn chưa đọc, không báo lỗi. Xong thì chuông ở ホーム hết chấm.
    ref
        .read(notificationInboxGatewayProvider)
        .markAllRead()
        .then((_) {
          if (mounted) ref.invalidate(inboxUnreadProvider(widget.userId));
        })
        .catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final locale = Localizations.localeOf(context).languageCode;
    final inbox = ref.watch(inboxProvider(widget.userId));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.inboxTitle)),
      body: inbox.when(
        loading: () => const SkeletonList(heights: [72, 72, 72, 72]),
        error: (_, _) => Center(
          child: StatePanel.error(
            title: l10n.storeLoadErrorTitle,
            message: l10n.storeLoadErrorBody,
            actionLabel: l10n.storeReload,
            onAction: () => ref.invalidate(inboxProvider(widget.userId)),
          ),
        ),
        data: (page) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _markReadOnce(page));
          if (page.items.isEmpty) {
            return Center(
              child: StatePanel(
                icon: Icons.notifications_none_rounded,
                title: l10n.inboxEmptyTitle,
                message: l10n.inboxEmptyBody,
              ),
            );
          }
          final now = DateTime.now();
          return RefreshIndicator(
            onRefresh: () => ref.refresh(inboxProvider(widget.userId).future),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: page.items.length,
              separatorBuilder: (_, _) => Divider(height: 1, color: eco.border),
              itemBuilder: (context, i) {
                final n = page.items[i];
                final c = inboxContent(n.type, l10n, payload: n.payload);
                return Container(
                  key: Key('inbox-${n.id}'),
                  color: n.isRead ? null : eco.primarySoft,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(color: eco.surface, shape: BoxShape.circle),
                        child: Icon(c.icon, size: 18, color: eco.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            if (c.body.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(c.body, style: TextStyle(fontSize: 12, height: 1.5, color: eco.textSecondary)),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              inboxTimeLabel(n.createdAt, now, l10n, locale),
                              style: TextStyle(fontSize: 11, color: eco.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Nút chuông có chấm khi còn thông báo chưa đọc (đầu SCR-S01)
class InboxBellButton extends ConsumerWidget {
  const InboxBellButton({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(inboxUnreadProvider(userId)).valueOrNull ?? 0;
    final l10n = context.l10n;
    return IconButton.outlined(
      key: const Key('inboxBell'),
      tooltip: unread > 0 ? '${l10n.inboxOpen}（${l10n.inboxUnread(unread)}）' : l10n.inboxOpen,
      onPressed: () =>
          Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => NotificationInboxPage(userId: userId))),
      icon: Badge(isLabelVisible: unread > 0, smallSize: 9, child: const Icon(Icons.notifications_none_rounded)),
    );
  }
}
