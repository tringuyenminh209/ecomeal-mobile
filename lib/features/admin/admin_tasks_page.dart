import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/motion.dart';
import '../../core/rpc_error.dart';
import '../../core/theme/app_theme.dart';
import '../../core/wide_layout.dart';
import '../../core/yen.dart';
import '../../l10n/l10n.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/state_panel.dart';
import '../../widgets/status_badge.dart';
import '../notifications/notification_inbox.dart' show inboxTimeLabel;
import '../orders/order_helpers.dart';
import '../driver/driver_report.dart' show driverReportCategoryLabel, driverReportDelayLabel;
import 'admin_dashboard_page.dart' show AdminTask;
import 'admin_gateway.dart';
import 'admin_inquiry_page.dart';
import 'admin_issue_page.dart';
import 'admin_license_page.dart';
import 'admin_restaurant_page.dart';
import 'admin_tasks_gateway.dart';

// iPad ngang (Figma section 22「対応（一覧と詳細）」): mục đang mở ở cột phải. key = '<task>:<id>' — danh sách tải lại
// tạo object mới nên so bằng key; đổi mục (問題報告 / 審査 …) thì cột phải trở về「…を選んでください」.
typedef AdminSelection = ({String key, Object item});
final adminSelectionProvider = StateProvider.autoDispose<AdminSelection?>((ref) => null);

const _listPaneWidth = 420.0;
const _riseDistance = 16.0;

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
      (AdminTask.driverReports, l10n.adminSegDriverReports(b?.openDriverReports ?? 0)),
      (AdminTask.restaurants, l10n.adminSegRestaurants(b?.pendingRestaurants ?? 0)),
      (AdminTask.licenses, l10n.adminSegLicenses(b?.pendingLicenses ?? 0)),
      (AdminTask.inquiries, l10n.adminSegInquiries(b?.newInquiries ?? 0)),
    ];
    final list = SafeArea(
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
              AdminTask.driverReports => const _DriverReportsList(),
              AdminTask.restaurants => const _RestaurantsList(),
              AdminTask.licenses => const _LicensesList(),
              AdminTask.inquiries => const _InquiriesList(),
            },
          ),
        ],
      ),
    );
    if (!isWideLayout(context)) return list;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: _listPaneWidth, child: list),
        VerticalDivider(width: 1, color: eco.border),
        Expanded(child: _DetailPane(task: task)),
      ],
    );
  }
}

// Cột phải trên iPad: chi tiết của mục đang chọn (chính các trang chi tiết của iPhone, đóng bằng onClose thay vì pop)
class _DetailPane extends ConsumerWidget {
  const _DetailPane({required this.task});
  final AdminTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final eco = context.eco;
    final sel = ref.watch(adminSelectionProvider);
    void close() => ref.read(adminSelectionProvider.notifier).state = null;
    final current = sel != null && sel.key.startsWith('${task.name}:') ? sel : null;
    // Chọn mục khác → chi tiết mới hiện dần và nhích lên 16px (Figma 「動きの提案」 25, Motion.page)
    return AnimatedSwitcher(
      duration: Motion.of(context, Motion.page),
      switchInCurve: Motion.enter,
      switchOutCurve: Motion.exit,
      transitionBuilder: _riseIn,
      child: current == null ? _placeholder(l10n, eco) : _page(current, close),
    );
  }

  static Widget _riseIn(Widget child, Animation<double> animation) => FadeTransition(
    opacity: animation,
    child: AnimatedBuilder(
      animation: animation,
      builder: (_, c) => Transform.translate(offset: Offset(0, _riseDistance * (1 - animation.value)), child: c),
      child: child,
    ),
  );

  Widget _placeholder(AppLocalizations l10n, EcoPalette eco) {
    final title = switch (task) {
      AdminTask.issues => l10n.adminPickIssue,
      AdminTask.restaurants => l10n.adminPickRestaurant,
      AdminTask.licenses => l10n.adminPickLicense,
      AdminTask.inquiries => l10n.adminPickInquiry,
      AdminTask.driverReports => l10n.adminPickDriverReport,
    };
    return Center(
      key: ValueKey('pick:${task.name}'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              l10n.adminPickBody,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: eco.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _page(AdminSelection current, VoidCallback close) {
    final key = ValueKey(current.key);
    return switch (current.item) {
      final AdminIssue i => AdminIssuePage(key: key, issue: i, onClose: close),
      final AdminRestaurant r => AdminRestaurantPage(key: key, restaurant: r, onClose: close),
      final AdminLicense lic => AdminLicensePage(key: key, license: lic, onClose: close),
      final AdminInquiry q => AdminInquiryPage(key: key, inquiry: q, onClose: close),
      _ => const SizedBox.shrink(),
    };
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
                ref.invalidate(adminDriverReportsProvider);
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
                ref.invalidate(adminDriverReportsProvider);
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

class _Card extends ConsumerWidget {
  const _Card({super.key, required this.onTap, required this.children, this.selectKey});
  final VoidCallback? onTap; // null: chỉ xem (không có trang chi tiết)
  final List<Widget> children;
  final String? selectKey; // iPad: dòng đang mở ở cột phải được tô

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eco = context.eco;
    final selected = selectKey != null && ref.watch(adminSelectionProvider)?.key == selectKey && isWideLayout(context);
    return Material(
      color: selected ? eco.primarySoft : eco.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? eco.primary : eco.border, width: selected ? 1.5 : 1),
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

// Mở chi tiết: iPad ngang → hiện ở cột phải; điện thoại → push như trước
void _open(BuildContext context, String key, Object item, Widget Function() page) {
  if (isWideLayout(context)) {
    ProviderScope.containerOf(context).read(adminSelectionProvider.notifier).state = (key: key, item: item);
    return;
  }
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page()));
}

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
          selectKey: '${AdminTask.issues.name}:${i.id}',
          onTap: i.isOpen
              ? () => _open(context, '${AdminTask.issues.name}:${i.id}', i, () => AdminIssuePage(issue: i))
              : null,
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

// 運行の連絡（SCR-D06 → 0067）: 未対応を先に。タップ → 対応内容を書いて対応済み（お客様への連絡は運営が別に行う）
class _DriverReportsList extends ConsumerWidget {
  const _DriverReportsList();

  Future<void> _resolve(BuildContext context, WidgetRef ref, AdminDriverReport r) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final resolution = await showAdminReasonSheet(
      context,
      AdminReasonSheet(
        title: l10n.adminDriverReportResolveTitle,
        note: l10n.adminDriverReportResolveNote,
        sendLabel: l10n.adminDriverReportResolveSend,
      ),
    );
    if (resolution == null || resolution.length > maxRejectionReasonLength) return;
    try {
      await ref.read(adminTasksGatewayProvider).resolveDriverReport(r.id, resolution: resolution);
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminDriverReportDone)));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            rpcErrorCode(e) == 'E-REPORT-409' ? l10n.adminDriverReportAlready : l10n.adminDriverReportError,
          ),
        ),
      );
    }
    ref.invalidate(adminDriverReportsProvider);
    ref.invalidate(adminBadgesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final eco = context.eco;
    final locale = Localizations.localeOf(context).languageCode;
    return _AsyncList<AdminDriverReport>(
      provider: adminDriverReportsProvider,
      empty: l10n.adminDriverReportsEmpty,
      itemBuilder: (context, r) {
        final time = inboxTimeLabel(r.createdAt, DateTime.now(), l10n, locale);
        final category = driverReportCategoryLabel(r.category, l10n);
        final delay = r.delayMinutes;
        final detail = r.isOpen ? r.message : r.resolution;
        return _Card(
          key: Key('adminDriverReport-${r.id}'),
          onTap: r.isOpen ? () => _resolve(context, ref, r) : null,
          children: [
            Row(
              children: [
                Text(r.plateNumber, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                StatusBadge(
                  label: r.isOpen ? l10n.adminIssueOpen : l10n.adminIssueResolved,
                  tone: r.isOpen ? BadgeTone.warning : BadgeTone.neutral,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              delay == null ? category : '$category・${driverReportDelayLabel(delay, l10n)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            if (detail != null)
              Text(
                detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: eco.textSecondary),
              ),
            const SizedBox(height: 2),
            Text(
              l10n.adminDriverReportMeta(time, r.driverName ?? '—', r.nextStopName ?? l10n.adminDriverReportNoStop),
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
              selectKey: '${AdminTask.restaurants.name}:${r.id}',
              onTap: () =>
                  _open(context, '${AdminTask.restaurants.name}:${r.id}', r, () => AdminRestaurantPage(restaurant: r)),
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
        selectKey: '${AdminTask.licenses.name}:${lic.driverId}',
        onTap: () =>
            _open(context, '${AdminTask.licenses.name}:${lic.driverId}', lic, () => AdminLicensePage(license: lic)),
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
              selectKey: '${AdminTask.inquiries.name}:${q.id}',
              onTap: () => _open(context, '${AdminTask.inquiries.name}:${q.id}', q, () => AdminInquiryPage(inquiry: q)),
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
