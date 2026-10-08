import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/logout_button.dart';
import '../../widgets/state_panel.dart';
import '../../widgets/status_badge.dart';
import '../profile/profile_gateway.dart';
import '../profile/profile_validation.dart';
import 'driver_account_cards.dart';
import 'driver_gateway.dart';
import '../../widgets/skeleton.dart';

// SCR-D05 プロフィール・設定（ドライバー）— 06_画面設計 §SCR-D05, khớp frame Figma 49:105 / ログアウト確認
// 54:3132: avatar xanh đặc + tên + nhãn ドライバー, khung 担当トラック, vùng đăng xuất dính đáy (nút đỏ).
// Tên/email dùng lại myProfileProvider (Chương 18), xe lấy từ tonightRouteProvider.
// レビュー第74回: 運転免許証（提出・状態）と今後のシフト（14日分）のカードを追加（Figma 277:712 / 277:773）.
class DriverProfilePage extends ConsumerWidget {
  const DriverProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    final truck = ref.watch(tonightRouteProvider).valueOrNull?.truck;
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.driverProfileTitle),
            Text(l10n.driverAccountSubtitle, style: textTheme.bodySmall),
          ],
        ),
      ),
      body: profileAsync.when(
        loading: () => const SkeletonList(heights: [64, 96, 120, 120], padding: EdgeInsets.fromLTRB(20, 8, 20, 20)),
        error: (_, __) => Center(
          child: StatePanel.error(
            title: l10n.errorLoadTitle,
            message: l10n.errorLoadBody,
            actionLabel: l10n.retry,
            onAction: () => ref.invalidate(myProfileProvider),
          ),
        ),
        data: (profile) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: context.eco.primary, shape: BoxShape.circle),
                  child: Text(
                    avatarInitialOf(profile.name),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.eco.surface),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(child: Text(profile.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
                          const SizedBox(width: 8),
                          StatusBadge(label: l10n.driverRoleChip, tone: BadgeTone.soft),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(profile.email, style: TextStyle(fontSize: 12, color: context.eco.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(l10n.assignedTruck, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.eco.surface,
                border: Border.all(color: context.eco.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_shipping, size: 40, color: context.eco.primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          truck?.plateNumber ?? l10n.unassigned,
                          key: const Key('driverPlateNumber'),
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(l10n.plateNumberLabel, style: TextStyle(fontSize: 12, color: context.eco.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const DriverLicenseCard(),
            const SizedBox(height: 12),
            const UpcomingShiftsCard(),
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: context.eco.surface,
          border: Border(top: BorderSide(color: context.eco.border)),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.logoutDialogBody, textAlign: TextAlign.center, style: textTheme.bodySmall),
              const SizedBox(height: 8),
              const LogoutButton(filled: true),
            ],
          ),
        ),
      ),
    );
  }
}
