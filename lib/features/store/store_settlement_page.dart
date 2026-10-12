import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/jst_date.dart';
import '../../core/theme/app_theme.dart';
import '../../core/web_admin.dart';
import '../../core/yen.dart';
import '../../l10n/l10n.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/state_panel.dart';
import '../../widgets/status_badge.dart';
import 'store_gateway.dart';
import 'store_register_logic.dart';
import 'store_layout.dart';

String _md(DateTime t, String locale) => DateFormat.MMMd(locale).format(DateTime.parse(dateInTokyo(t)));
String _ym(String periodMonth, String locale) => DateFormat.yMMM(locale).format(DateTime.parse(periodMonth));

// Mở trang in của Web (SCR-W18 /settlements/:id). Test thay bằng hàm giả.
final openSettlementOnWebProvider = Provider<Future<bool> Function(String settlementId)>((ref) {
  return (id) => launchUrl(Uri.parse('$webAdminUrl/settlements/$id'), mode: LaunchMode.externalApplication);
});

// SCR-S04 精算（556:355）: tháng này (chưa chốt) + danh sách phiếu đã chốt
// iPad ngang: phiếu đang mở ở cột phải (null = phiếu mới nhất)
final selectedSettlementProvider = StateProvider.autoDispose.family<String?, String>((ref, restaurantId) => null);

class StoreSettlementPage extends ConsumerWidget {
  const StoreSettlementPage({super.key, required this.restaurant});
  final StoreRestaurant restaurant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final eco = context.eco;
    final locale = Localizations.localeOf(context).languageCode;
    final id = restaurant.id;
    final revenue = ref.watch(storeMonthRevenueProvider(id)).valueOrNull;
    final settlements = ref.watch(storeSettlementsProvider(id));
    final month = DateFormat.MMM(locale).format(DateTime.parse(todayInTokyo()));
    final wide = isStoreWide(context);
    final list = settlements.valueOrNull ?? const <StoreSettlement>[];
    final selectedId = ref.watch(selectedSettlementProvider(id));
    final selected = list.isEmpty ? null : list.firstWhere((s) => s.id == selectedId, orElse: () => list.first);

    final listPane = SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(storeMonthRevenueProvider(id));
          await ref.refresh(storeSettlementsProvider(id).future).catchError((_) => <StoreSettlement>[]);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text(l10n.storeSettlementTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            Text(l10n.storeSettlementSubtitle, style: TextStyle(fontSize: 13, color: eco.textSecondary)),
            const SizedBox(height: 16),
            Container(
              key: const Key('storeSettlementCurrent'),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: eco.primary, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n.storeSettlementCurrent(month),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                        child: Text(
                          l10n.storeSettlementCutoff,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: eco.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.storeSettlementEstimate(revenue == null ? '—' : formatYen(revenue.payout)),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  if (revenue != null)
                    Text(
                      l10n.storeSettlementCurrentSub(
                        formatYen(revenue.revenue),
                        revenue.orders,
                        formatSharePct(revenue.sharePct),
                      ),
                      style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(l10n.storeSettlementStatements, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            settlements.when(
              loading: () => const SkeletonPulse(child: SkeletonBox(height: 180, radius: 16)),
              error: (_, _) => StatePanel.error(
                title: l10n.storeLoadErrorTitle,
                message: l10n.storeLoadErrorBody,
                actionLabel: l10n.storeReload,
                onAction: () => ref.invalidate(storeSettlementsProvider(id)),
              ),
              data: (list) => list.isEmpty
                  ? StatePanel(
                      icon: Icons.receipt_long_outlined,
                      title: l10n.storeSettlementEmptyTitle,
                      message: l10n.storeSettlementEmptyBody,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: eco.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: eco.border),
                      ),
                      child: Column(
                        children: [
                          for (final (i, s) in list.indexed) ...[
                            if (i > 0) Divider(height: 1, color: eco.border),
                            ListTile(
                              key: Key('settlement-${s.id}'),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              title: Row(
                                children: [
                                  Text(
                                    _ym(s.periodMonth, locale),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(width: 8),
                                  StatusBadge(
                                    label: s.paidAt == null ? l10n.storeSettlementConfirmed : l10n.storeSettlementPaid,
                                    tone: s.paidAt == null ? BadgeTone.soft : BadgeTone.neutral,
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                s.paidAt == null
                                    ? l10n.storeSettlementRowConfirmed(_md(s.confirmedAt, locale), s.orders)
                                    : l10n.storeSettlementRowPaid(_md(s.paidAt!, locale), s.orders),
                                style: TextStyle(fontSize: 12, color: eco.textSecondary),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    formatYen(s.payout),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                  Icon(Icons.chevron_right, color: eco.textSecondary),
                                ],
                              ),
                              selected: wide && s.id == selected?.id,
                              onTap: () => wide
                                  ? ref.read(selectedSettlementProvider(id).notifier).state = s.id
                                  : Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            StoreSettlementNoticePage(restaurant: restaurant, settlement: s),
                                      ),
                                    ),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: eco.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.storeSettlementNote,
                    style: TextStyle(fontSize: 12, height: 1.6, color: eco.textSecondary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (!wide) return listPane;
    // iPad ngang (Figma 559:1275): danh sách bên trái, phiếu đang chọn bên phải
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: listPane),
        Expanded(
          child: SafeArea(
            child: selected == null
                ? const SizedBox.shrink()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(4, 16, 20, 24),
                    children: [StoreSettlementNoticeView(restaurant: restaurant, settlement: selected)],
                  ),
          ),
        ),
      ],
    );
  }
}

// SCR-S04 支払通知書（556:450）. Dòng giống phiếu in của Web (SCR-W18). Không có「還元率」của kỳ: tỷ lệ tính theo từng đơn.
class StoreSettlementNoticeView extends ConsumerWidget {
  const StoreSettlementNoticeView({super.key, required this.restaurant, required this.settlement});
  final StoreRestaurant restaurant;
  final StoreSettlement settlement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final eco = context.eco;
    final locale = Localizations.localeOf(context).languageCode;
    final s = settlement;
    final ymd = DateFormat.yMMMd(locale);
    String day(DateTime t) => ymd.format(DateTime.parse(dateInTokyo(t)));

    Widget row(String label, String value, {bool emphasis = false, Key? key}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: eco.textSecondary)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              key: key,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: emphasis ? 22 : 14,
                fontWeight: FontWeight.w700,
                color: emphasis ? eco.primary : eco.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: eco.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: eco.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.storeNoticeTitle,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ),
                  StatusBadge(
                    label: s.paidAt == null ? l10n.storeSettlementConfirmed : l10n.storeSettlementPaid,
                    tone: s.paidAt == null ? BadgeTone.soft : BadgeTone.neutral,
                  ),
                ],
              ),
              Text(
                l10n.storeNoticeFor(_ym(s.periodMonth, locale)),
                style: TextStyle(fontSize: 12, color: eco.textSecondary),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.storeNoticeAddressee(restaurant.name),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Text(
                l10n.storeNoticeIssued(day(s.confirmedAt)),
                style: TextStyle(fontSize: 12, color: eco.textSecondary),
              ),
              Divider(height: 24, color: eco.border),
              row(l10n.storeNoticeOrders, l10n.storeNoticeOrdersValue(s.orders)),
              row(l10n.storeNoticeSales, formatYen(s.sales)),
              Divider(height: 8, color: eco.border),
              row(l10n.storeNoticePayout, formatYen(s.payout), emphasis: true, key: const Key('noticePayout')),
              row(l10n.storeNoticeConfirmedAt, day(s.confirmedAt)),
              row(
                l10n.storeNoticePaidAt,
                s.paidAt == null ? l10n.storeNoticeUnpaid : day(s.paidAt!),
                key: const Key('noticePaidAt'),
              ),
              row(l10n.storeNoticeNumber, s.number),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(l10n.storeNoticeFootnote, style: TextStyle(fontSize: 12, height: 1.6, color: eco.textSecondary)),
        const SizedBox(height: 20),
        // Figma vẽ「印刷」「PDFで共有」. Tạo PDF tiếng Nhật trên máy cần thêm plugin + font CJK → dùng trang in của Web (cùng nội dung).
        FilledButton.icon(
          key: const Key('noticePrintOnWeb'),
          icon: const Icon(Icons.print_outlined),
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            final failed = l10n.errorOpenWebAdmin;
            var opened = false;
            try {
              opened = await ref.read(openSettlementOnWebProvider)(s.id);
            } catch (_) {}
            if (!opened) messenger.showSnackBar(SnackBar(content: Text(failed)));
          },
          label: Text(l10n.storeNoticePrintOnWeb),
        ),
      ],
    );
  }
}

// Điện thoại / iPad dọc: phiếu là 1 trang riêng
class StoreSettlementNoticePage extends StatelessWidget {
  const StoreSettlementNoticePage({super.key, required this.restaurant, required this.settlement});
  final StoreRestaurant restaurant;
  final StoreSettlement settlement;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final locale = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.storeNoticeTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            Text(_ym(settlement.periodMonth, locale), style: TextStyle(fontSize: 12, color: eco.textSecondary)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [StoreSettlementNoticeView(restaurant: restaurant, settlement: settlement)],
      ),
    );
  }
}
