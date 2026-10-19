import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/jst_date.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/state_panel.dart';
import '../../widgets/status_badge.dart';
import '../notifications/notification_inbox.dart';
import '../driver/driver_report.dart' show driverReportCategoryLabel;
import '../orders/order_helpers.dart';
import 'admin_gateway.dart';

// Mục của tab 対応 (SCR-A04 565:1160: 問題報告 / 運行の連絡 (SCR-D06, 0067) / 審査 / 免許 / 問合せ)
enum AdminTask { issues, driverReports, restaurants, licenses, inquiries }

// Thông báo của vận hành → nhóm việc ở tab 対応 (A01 お知らせ 955:4176, audit A06). Mở nhóm chứ không mở 1 việc: thông báo
// gửi cho mọi admin, việc có thể đã được người khác xử lý — nhóm cho thấy đúng những việc còn lại. null = loại app chưa biết.
AdminTask? adminTaskFor(String type) => switch (type) {
  'issue_reported' => AdminTask.issues,
  'driver_reported' => AdminTask.driverReports,
  'restaurant_applied' => AdminTask.restaurants,
  'license_submitted' => AdminTask.licenses,
  'inquiry_received' => AdminTask.inquiries,
  _ => null,
};

// Dòng ở お知らせ: có nhóm thì chạm → [open] nhóm đó; không thì chỉ để đọc
InboxOpener adminInboxOpener(void Function(AdminTask task) open) => (n) {
  final task = adminTaskFor(n.type);
  return task == null ? null : () => open(task);
};

// SCR-A01 ダッシュボード（562:1045 / Loading 562:1197）. [onOpenTask]: thẻ việc → tab 対応 đúng mục.
class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key, required this.userId, required this.onOpenTask});
  final String userId;
  final void Function(AdminTask task) onOpenTask;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final eco = context.eco;
    final locale = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    final badges = ref.watch(adminBadgesProvider);
    final tonight = ref.watch(adminTonightProvider);

    Future<void> refresh() async {
      ref.invalidate(adminTonightProvider);
      ref.invalidate(inboxUnreadProvider(userId));
      // Lỗi đã hiện bằng thẻ lỗi của từng phần — kéo để làm mới thì chỉ cần chờ xong
      await ref.refresh(adminBadgesProvider.future).then((_) {}, onError: (_) {});
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.adminDateTime(
                          formatServiceDate(todayInTokyo(), locale),
                          DateFormat('HH:mm').format(toTokyo(now)),
                        ),
                        style: TextStyle(fontSize: 13, color: eco.textSecondary),
                      ),
                      Text(l10n.adminDashboardTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                InboxBellButton(userId: userId, onOpen: adminInboxOpener(onOpenTask)),
              ],
            ),
            const SizedBox(height: 16),
            tonight.when(
              loading: () => const SkeletonPulse(child: SkeletonBox(height: 120, radius: 16)),
              error: (_, _) => StatePanel.error(
                title: l10n.storeLoadErrorTitle,
                message: l10n.storeLoadErrorBody,
                actionLabel: l10n.storeReload,
                onAction: () => ref.invalidate(adminTonightProvider),
              ),
              data: (t) => _TonightCard(tonight: t),
            ),
            const SizedBox(height: 20),
            Text(l10n.adminNeedsAction, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ...badges.when(
              loading: () => [
                for (var i = 0; i < 5; i++) ...[
                  const SkeletonPulse(child: SkeletonBox(height: 68, radius: 14)),
                  const SizedBox(height: 10),
                ],
              ],
              error: (_, _) => [
                StatePanel.error(
                  title: l10n.storeLoadErrorTitle,
                  message: l10n.storeLoadErrorBody,
                  actionLabel: l10n.storeReload,
                  onAction: () => ref.invalidate(adminBadgesProvider),
                ),
              ],
              data: (b) {
                String time(DateTime t) => inboxTimeLabel(t, now, l10n, locale);
                final issue = b.latestIssue;
                final restaurant = b.latestRestaurant;
                final license = b.latestLicense;
                final report = b.latestDriverReport;
                // Web と同じ区分: パートナー申込 = restaurant、それ以外（ドライバー応募・お問い合わせ）は「その他」
                final partner = b.newInquiryTypes['restaurant'] ?? 0;
                final other = b.newInquiries - partner;
                final cards = [
                  (
                    AdminTask.issues,
                    Icons.warning_amber_rounded,
                    l10n.adminTaskIssues,
                    issue == null
                        ? l10n.adminTaskNone
                        : l10n.adminTaskIssueLatest(
                            orderDisplayNumber(issue.orderId),
                            issueCategoryLabel(issue.category, l10n),
                            time(issue.createdAt),
                          ),
                    b.openIssues,
                  ),
                  (
                    AdminTask.driverReports,
                    Icons.support_agent,
                    l10n.adminTaskDriverReports,
                    report == null
                        ? l10n.adminTaskNone
                        : l10n.adminTaskDriverReportLatest(
                            report.plateNumber,
                            driverReportCategoryLabel(report.category, l10n),
                            time(report.createdAt),
                          ),
                    b.openDriverReports,
                  ),
                  (
                    AdminTask.restaurants,
                    Icons.storefront_outlined,
                    l10n.adminTaskRestaurants,
                    restaurant == null
                        ? l10n.adminTaskNone
                        : l10n.adminTaskLatest(restaurant.name, time(restaurant.createdAt)),
                    b.pendingRestaurants,
                  ),
                  (
                    AdminTask.licenses,
                    Icons.badge_outlined,
                    l10n.adminTaskLicenses,
                    license == null
                        ? l10n.adminTaskNone
                        : license.submittedAt == null
                        ? license.driverName
                        : l10n.adminTaskLicenseLatest(license.driverName, time(license.submittedAt!)),
                    b.pendingLicenses,
                  ),
                  (
                    AdminTask.inquiries,
                    Icons.chat_bubble_outline_rounded,
                    l10n.adminTaskInquiries,
                    b.newInquiries == 0 ? l10n.adminTaskNone : l10n.adminTaskInquiryTypes(partner, other),
                    b.newInquiries,
                  ),
                ];
                return [
                  for (final (task, icon, title, subtitle, count) in cards) ...[
                    _TaskCard(
                      key: Key('adminTask-${task.name}'),
                      icon: icon,
                      title: title,
                      subtitle: subtitle,
                      count: count,
                      onTap: () => onOpenTask(task),
                    ),
                    const SizedBox(height: 10),
                  ],
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TonightCard extends StatelessWidget {
  const _TonightCard({required this.tonight});
  final AdminTonight tonight;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final t = tonight;
    final stats = [
      ('${t.trucksRunning}/${t.trucksTotal}', l10n.adminTrucksRunning),
      ('${t.stopsDone}/${t.stopsTotal}', l10n.adminStopsDone),
      ('${t.reserved}', l10n.adminReserved),
      ('${t.pickedUp}', l10n.adminPickedUp),
    ];
    return Container(
      key: const Key('adminTonight'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: eco.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: eco.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.adminTonight, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              if (t.trucksRunning > 0) StatusBadge(label: l10n.adminRunning, tone: BadgeTone.soft),
            ],
          ),
          const SizedBox(height: 12),
          if (t.trucksTotal == 0)
            Text(l10n.adminNoRouteTonight, style: TextStyle(fontSize: 13, color: eco.textSecondary))
          else ...[
            Row(
              children: [
                for (final (value, label) in stats)
                  Expanded(
                    child: Column(
                      children: [
                        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, color: eco.textSecondary),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: t.stopsTotal == 0 ? 0 : t.stopsDone / t.stopsTotal,
                minHeight: 6,
                backgroundColor: eco.chip,
                color: eco.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final eco = context.eco;
    return Material(
      color: eco.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: eco.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: eco.chip, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 22, color: eco.textPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: eco.textSecondary),
                    ),
                  ],
                ),
              ),
              if (count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: eco.amber, borderRadius: BorderRadius.circular(999)),
                  child: Text(
                    '$count',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: eco.onAmber),
                  ),
                ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: eco.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
