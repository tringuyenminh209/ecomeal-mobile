import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/yen.dart';
import '../../l10n/l10n.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/state_panel.dart';
import '../../widgets/status_badge.dart';
import '../notifications/notification_inbox.dart' show inboxTimeLabel;
import '../orders/order_helpers.dart';
import 'admin_dashboard_page.dart' show AdminTask;
import 'admin_gateway.dart';
import 'admin_inquiry_page.dart';
import 'admin_issue_page.dart';
import 'admin_license_page.dart';
import 'admin_restaurant_page.dart';
import 'admin_tasks_gateway.dart';

// Tab 対応（SCR-A04 一覧 565:1160 — chọn mục 問題報告 / 審査 / 免許 / 問合せ; A03 563:1166; A06 565:1368）
class AdminTasksPage extends ConsumerWidget {
  const AdminTasksPage({super.key, required this.task, required this.onSelect});
  final AdminTask task;
  final ValueChanged<AdminTask> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final eco = context.eco;
    final b = ref.watch(adminBadgesProvider).valueOrNull;
    final segments = [
      (AdminTask.issues, l10n.adminSegIssues(b?.openIssues ?? 0)),
      (AdminTask.restaurants, l10n.adminSegRestaurants(b?.pendingRestaurants ?? 0)),
      (AdminTask.licenses, l10n.adminSegLicenses(b?.pendingLicenses ?? 0)),
      (AdminTask.inquiries, l10n.adminSegInquiries(b?.newInquiries ?? 0)),
    ];
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.adminTasksTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                Text(l10n.adminTasksSubtitle, style: TextStyle(fontSize: 13, color: eco.textSecondary)),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                for (final (t, label) in segments) ...[
                  ChoiceChip(
                    key: Key('adminSeg-${t.name}'),
                    label: Text(label),
                    selected: task == t,
                    onSelected: (_) => onSelect(t),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: switch (task) {
              AdminTask.issues => const _IssuesList(),
              AdminTask.restaurants => const _RestaurantsList(),
              AdminTask.licenses => const _LicensesList(),
              AdminTask.inquiries => const _InquiriesList(),
            },
          ),
        ],
      ),
    );
  }
}

// Phần chung của 4 danh sách: tải / lỗi / trống / kéo để tải lại
class _AsyncList<T> extends ConsumerWidget {
  const _AsyncList({required this.provider, required this.empty, required this.itemBuilder, this.filter});
  final ProviderListenable<AsyncValue<List<T>>> provider;
  final String empty;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final bool Function(T item)? filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final eco = context.eco;
    return ref
        .watch(provider)
        .when(
          loading: () => const SkeletonList(heights: [88, 88, 88]),
          error: (_, _) => Center(
            child: StatePanel.error(
              title: l10n.storeLoadErrorTitle,
              message: l10n.storeLoadErrorBody,
              actionLabel: l10n.storeReload,
              onAction: () {
                ref.invalidate(adminIssuesProvider);
                ref.invalidate(adminRestaurantsProvider);
                ref.invalidate(adminLicensesProvider);
                ref.invalidate(adminInquiriesProvider);
              },
            ),
          ),
          data: (all) {
            final items = filter == null ? all : all.where(filter!).toList();
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(adminBadgesProvider);
                ref.invalidate(adminIssuesProvider);
                ref.invalidate(adminRestaurantsProvider);
                ref.invalidate(adminLicensesProvider);
                ref.invalidate(adminInquiriesProvider);
              },
              child: items.isEmpty
                  ? ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            empty,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: eco.textSecondary),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => itemBuilder(context, items[i]),
                    ),
            );
          },
        );
  }
}

class _Card extends StatelessWidget {
  const _Card({super.key, required this.onTap, required this.children});
  final VoidCallback? onTap; // null: chỉ xem (không có trang chi tiết)
  final List<Widget> children;

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
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: eco.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
              ),
              if (onTap != null) Icon(Icons.chevron_right, color: eco.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

void _push(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

class _IssuesList extends StatelessWidget {
  const _IssuesList();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final locale = Localizations.localeOf(context).languageCode;
    return _AsyncList<AdminIssue>(
      provider: adminIssuesProvider,
      empty: l10n.adminIssuesEmpty,
      itemBuilder: (context, i) {
        final time = inboxTimeLabel(i.createdAt, DateTime.now(), l10n, locale);
        return _Card(
          key: Key('adminIssue-${i.id}'),
          onTap: i.isOpen ? () => _push(context, AdminIssuePage(issue: i)) : null,
          children: [
            Row(
              children: [
                Text(orderDisplayNumber(i.orderId), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                StatusBadge(
                  label: i.isOpen ? l10n.adminIssueOpen : l10n.adminIssueResolved,
                  tone: i.isOpen ? BadgeTone.warning : BadgeTone.neutral,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              issueCategoryLabel(i.category, l10n),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            Text(
              i.isOpen
                  ? l10n.adminIssueLine(i.message, i.stopName ?? '—', formatYen(i.pricePaid))
                  : (i.refundAmount ?? 0) > 0
                  ? l10n.adminIssueRefunded(formatYen(i.refundAmount!))
                  : l10n.adminIssueNoRefund,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: eco.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              i.customerName == null ? time : l10n.adminIssueMeta(time, i.customerName!),
              style: TextStyle(fontSize: 11, color: eco.textSecondary),
            ),
          ],
        );
      },
    );
  }
}

enum _RestaurantFilter { pending, rejected, approved }

class _RestaurantsList extends StatefulWidget {
  const _RestaurantsList();

  @override
  State<_RestaurantsList> createState() => _RestaurantsListState();
}

class _RestaurantsListState extends State<_RestaurantsList> {
  _RestaurantFilter _filter = _RestaurantFilter.pending;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final locale = Localizations.localeOf(context).languageCode;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SegmentedButton<_RestaurantFilter>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: _RestaurantFilter.pending, label: Text(l10n.adminRestPending)),
              ButtonSegment(value: _RestaurantFilter.rejected, label: Text(l10n.adminRestRejected)),
              ButtonSegment(value: _RestaurantFilter.approved, label: Text(l10n.adminRestApproved)),
            ],
            selected: {_filter},
            onSelectionChanged: (s) => setState(() => _filter = s.first),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _AsyncList<AdminRestaurant>(
            provider: adminRestaurantsProvider,
            empty: l10n.adminRestEmpty,
            filter: (r) => switch (_filter) {
              _RestaurantFilter.pending => r.isPending,
              _RestaurantFilter.rejected => r.rejectedAt != null && !r.isApproved,
              _RestaurantFilter.approved => r.isApproved,
            },
            itemBuilder: (context, r) => _Card(
              key: Key('adminRest-${r.id}'),
              onTap: () => _push(context, AdminRestaurantPage(restaurant: r)),
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(r.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                    if (r.isPending) ...[
                      const SizedBox(width: 8),
                      StatusBadge(label: l10n.adminRestPendingBadge, tone: BadgeTone.warning),
                    ],
                  ],
                ),
                Text(r.address, style: TextStyle(fontSize: 12, color: eco.textSecondary)),
                Text(
                  '${l10n.adminRestApplied(inboxTimeLabel(r.createdAt, DateTime.now(), l10n, locale))}・'
                  '${r.plDocPath == null ? l10n.adminRestNoPl : l10n.adminRestHasPl}',
                  style: TextStyle(fontSize: 11, color: eco.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LicensesList extends StatelessWidget {
  const _LicensesList();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final locale = Localizations.localeOf(context).languageCode;
    return _AsyncList<AdminLicense>(
      provider: adminLicensesProvider,
      empty: l10n.adminLicEmpty,
      itemBuilder: (context, lic) => _Card(
        key: Key('adminLic-${lic.driverId}'),
        onTap: () => _push(context, AdminLicensePage(license: lic)),
        children: [
          Text(lic.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          if (lic.submittedAt != null)
            Text(
              l10n.adminLicSubmitted(inboxTimeLabel(lic.submittedAt!, DateTime.now(), l10n, locale)),
              style: TextStyle(fontSize: 12, color: eco.textSecondary),
            ),
        ],
      ),
    );
  }
}

enum _InquiryFilter { fresh, inProgress, closed }

class _InquiriesList extends StatefulWidget {
  const _InquiriesList();

  @override
  State<_InquiriesList> createState() => _InquiriesListState();
}

class _InquiriesListState extends State<_InquiriesList> {
  _InquiryFilter _filter = _InquiryFilter.fresh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final locale = Localizations.localeOf(context).languageCode;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SegmentedButton<_InquiryFilter>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: _InquiryFilter.fresh, label: Text(l10n.adminInqNew)),
              ButtonSegment(value: _InquiryFilter.inProgress, label: Text(l10n.adminInqInProgress)),
              ButtonSegment(value: _InquiryFilter.closed, label: Text(l10n.adminInqDone)),
            ],
            selected: {_filter},
            onSelectionChanged: (s) => setState(() => _filter = s.first),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _AsyncList<AdminInquiry>(
            provider: adminInquiriesProvider,
            empty: l10n.adminInqEmpty,
            filter: (q) => switch (_filter) {
              _InquiryFilter.fresh => q.status == 'new',
              _InquiryFilter.inProgress => q.status == 'in_progress',
              _InquiryFilter.closed => q.status == 'done' || q.status == 'rejected',
            },
            itemBuilder: (context, q) => _Card(
              key: Key('adminInq-${q.id}'),
              onTap: () => _push(context, AdminInquiryPage(inquiry: q)),
              children: [
                Row(
                  children: [
                    Text(
                      inquiryTypeLabel(q.type, l10n),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(label: inquiryStatusLabel(q.status, l10n), tone: inquiryStatusTone(q.status)),
                    const SizedBox(width: 8),
                    Text(
                      inboxTimeLabel(q.createdAt, DateTime.now(), l10n, locale),
                      style: TextStyle(fontSize: 11, color: eco.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  q.companyName == null ? q.name : '${q.companyName}（${q.name}）',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                Text(
                  q.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: eco.textSecondary),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(l10n.adminInqInviteOnWeb, style: TextStyle(fontSize: 11, color: eco.textSecondary)),
        ),
      ],
    );
  }
}
