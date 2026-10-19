import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/jst_date.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import 'store_gateway.dart';

// SCR-S02 登録完了（554:544）. Giờ lấy hàng và tuyến đọc lại từ lô vừa tạo (API-083) — chỉ server mới biết sau khi xếp tuyến.
class StoreRegisterDonePage extends ConsumerWidget {
  const StoreRegisterDonePage({
    super.key,
    required this.restaurantId,
    required this.batchId,
    required this.onViewBatch,
    required this.onHome,
  });
  final String restaurantId;
  final String batchId;
  final VoidCallback onViewBatch;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final eco = context.eco;
    final batch = ref.watch(storeBatchProvider((restaurantId: restaurantId, batchId: batchId))).valueOrNull;
    final planned = batch?.collectionPlannedAt;
    final names = batch?.stops.map((s) => s.name).toList() ?? const <String>[];
    final route = names.isEmpty
        ? null
        : names.length <= 2
        ? names.join('・')
        : l10n.storeDoneRouteMore(names.take(2).join('・'));

    Widget row(String label, String? value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: eco.textSecondary)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value ?? '—',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: eco.primarySoft, shape: BoxShape.circle),
                child: Icon(Icons.check_circle_outline_rounded, size: 40, color: eco.primary),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.storeDoneTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.storeDoneBody,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.6, color: eco.textSecondary),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: eco.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: eco.border),
              ),
              child: Column(
                children: [
                  row(
                    l10n.storeDoneCollection,
                    planned == null
                        ? null
                        : l10n.storeDoneCollectionValue(tokyoTime(planned)),
                  ),
                  row(l10n.storeDoneRoute, route),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('storeDoneViewBatch'),
              onPressed: onViewBatch,
              child: Text(l10n.storeDoneViewBatch),
            ),
            const SizedBox(height: 12),
            OutlinedButton(key: const Key('storeDoneHome'), onPressed: onHome, child: Text(l10n.storeDoneHome)),
          ],
        ),
      ),
    );
  }
}
