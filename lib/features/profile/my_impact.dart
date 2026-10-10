import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/supabase_client.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';

// UC-43「あなたが救った食品」(0055, API-071, ADR-011, Figma「M07」メイン 470:1400 / 0件 465:1397).
// Số kg và CO₂ là ƯỚC TÍNH do server tính bằng hệ số (app không tự nhân) — hệ số trả kèm để ghi chú đúng con số đang dùng.
class MyImpact {
  const MyImpact({
    required this.bags,
    required this.foodKg,
    required this.co2Kg,
    required this.foodKgPerBag,
    required this.co2KgPerFoodKg,
  });
  final int bags;
  final double foodKg;
  final double co2Kg;
  final double foodKgPerBag;
  final double co2KgPerFoodKg;

  factory MyImpact.fromJson(Map<String, dynamic> json) => MyImpact(
        bags: (json['bags'] as num).toInt(),
        foodKg: (json['food_kg'] as num).toDouble(),
        co2Kg: (json['co2_kg'] as num).toDouble(),
        foodKgPerBag: (json['food_kg_per_bag'] as num).toDouble(),
        co2KgPerFoodKg: (json['co2_kg_per_food_kg'] as num).toDouble(),
      );
}

// Test thay bằng hàm giả.
final myImpactLoaderProvider = Provider<Future<MyImpact> Function()>((ref) {
  final client = SupabaseClientHolder.instance;
  return () async => MyImpact.fromJson(Map<String, dynamic>.from(await client.rpc('get_my_impact') as Map));
});

final myImpactProvider = FutureProvider.autoDispose<MyImpact>((ref) => ref.watch(myImpactLoaderProvider)());

String _kg(double v) => v.toStringAsFixed(1);

// Thẻ phụ của SCR-M07: đang tải / lỗi thì không hiện (không chặn các mục khác của マイページ).
class MyImpactCard extends ConsumerWidget {
  const MyImpactCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final impact = ref.watch(myImpactProvider).valueOrNull;
    if (impact == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Container(
      key: const Key('myImpactCard'),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco_outlined, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(l10n.impactTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          if (impact.bags == 0)
            Text(l10n.impactEmpty, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))
          else ...[
            Row(
              children: [
                Expanded(child: _Figure(value: l10n.impactBagsValue(impact.bags), label: l10n.impactBagsLabel)),
                Expanded(child: _Figure(value: l10n.impactApproxKg(_kg(impact.foodKg)), label: l10n.impactFoodLabel)),
                Expanded(
                  child: _Figure(value: l10n.impactApproxKg(_kg(impact.co2Kg)), label: l10n.impactCo2Label, highlight: true),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.impactNote(_kg(impact.foodKgPerBag), impact.co2KgPerFoodKg.toStringAsFixed(2)),
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.value, required this.label, this.highlight = false});
  final String value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: highlight ? AppColors.primary : AppColors.textPrimary),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}
