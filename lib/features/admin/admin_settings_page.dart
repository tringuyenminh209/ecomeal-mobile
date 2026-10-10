import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_version.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/logout_button.dart';
import '../../widgets/status_badge.dart';
import '../auth/web_admin_only_screen.dart' show openWebAdminOrReport;
import '../notifications/notification_preferences.dart';
import '../notifications/push_registration.dart';
import 'admin_gateway.dart';

// Thứ tự công tắc theo Figma SCR-A07 (565:1464)
const adminNotificationTypes = ['issue_reported', 'restaurant_applied', 'license_submitted', 'inquiry_received'];

String adminPreferenceLabel(String type, AppLocalizations l10n) => switch (type) {
  'issue_reported' => l10n.adminPrefIssues,
  'restaurant_applied' => l10n.adminPrefRestaurants,
  'license_submitted' => l10n.adminPrefLicenses,
  _ => l10n.adminPrefInquiries,
};

// SCR-A07 設定. Công tắc từng loại lưu ở server (0060) — tắt thì server không gửi, không chỉ ẩn ở app.
class AdminSettingsPage extends ConsumerWidget {
  const AdminSettingsPage({super.key, required this.userId, required this.email});
  final String userId;
  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final eco = context.eco;
    final name = ref.watch(adminNameProvider(userId)).valueOrNull ?? '';
    final version = ref.watch(appVersionProvider).valueOrNull ?? '';
    final prefs = ref.watch(notificationPreferencesProvider(userId));
    final push = ref.watch(pushStatusProvider).valueOrNull;
    BoxDecoration card() => BoxDecoration(
      color: eco.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: eco.border),
    );

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text(l10n.adminSettingsTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: card(),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: eco.primarySoft,
                  child: Icon(Icons.shield_outlined, color: eco.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Text(email, style: TextStyle(fontSize: 12, color: eco.textSecondary)),
                    ],
                  ),
                ),
                StatusBadge(label: l10n.adminMfaOn, tone: BadgeTone.soft),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.adminNotifications, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          // Máy chưa cho phép thông báo: công tắc theo loại không có tác dụng → cho bật ngay tại đây (cùng logic SCR-M07)
          if (push == PushStatus.off || push == PushStatus.denied)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(l10n.adminPushOff, style: TextStyle(fontSize: 12, color: eco.textSecondary)),
                  ),
                  if (push == PushStatus.off)
                    TextButton(
                      key: const Key('adminPushEnable'),
                      onPressed: () => enablePush(ref).catchError((_) => PushStatus.off),
                      child: Text(l10n.adminPushEnable),
                    ),
                ],
              ),
            ),
          Container(
            decoration: card(),
            child: prefs.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => ListTile(
                title: Text(l10n.storeLoadErrorTitle),
                trailing: TextButton(
                  onPressed: () => ref.invalidate(notificationPreferencesProvider(userId)),
                  child: Text(l10n.storeReload),
                ),
              ),
              data: (list) {
                final byType = {for (final p in list) p.type: p};
                final rows = [
                  for (final t in adminNotificationTypes)
                    if (byType[t] != null) byType[t]!,
                ];
                return Column(
                  children: [
                    for (final (i, p) in rows.indexed) ...[
                      if (i > 0) Divider(height: 1, color: eco.border),
                      SwitchListTile(
                        key: Key('adminPref-${p.type}'),
                        title: Text(
                          adminPreferenceLabel(p.type, l10n),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        value: p.isEnabled,
                        onChanged: p.isMandatory
                            ? null
                            : (v) async {
                                final messenger = ScaffoldMessenger.of(context);
                                final failed = l10n.adminPrefSaveFailed;
                                try {
                                  await ref.read(notificationPreferencesGatewayProvider).set(p.type, enabled: v);
                                } catch (_) {
                                  messenger.showSnackBar(SnackBar(content: Text(failed)));
                                }
                                ref.invalidate(notificationPreferencesProvider(userId));
                              },
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: card(),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.verified_user_outlined, color: eco.textPrimary),
                  title: Text(l10n.adminTwoFactor, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  trailing: Text(
                    l10n.adminTwoFactorOn,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: eco.primary),
                  ),
                ),
                Divider(height: 1, color: eco.border),
                ListTile(
                  key: const Key('adminOpenWebAdmin'),
                  leading: Icon(Icons.open_in_new, color: eco.textPrimary),
                  title: Text(
                    l10n.adminOpenWebAdmin,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  trailing: Icon(Icons.chevron_right, color: eco.textSecondary),
                  onTap: () => openWebAdminOrReport(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const LogoutButton(danger: false),
          const SizedBox(height: 12),
          if (version.isNotEmpty)
            Text(
              l10n.adminVersion(version),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: eco.textSecondary),
            ),
        ],
      ),
    );
  }
}
