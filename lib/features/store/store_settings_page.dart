import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/app_version.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/logout_button.dart';
import '../legal/legal_pages.dart';
import '../notifications/push_registration.dart';
import 'store_gateway.dart';
import 'store_inquiry_page.dart';
import 'store_ratings_page.dart';

// SCR-S08 設定（558:614）. Thông tin quán chỉ xem (sửa trên Web / qua お問い合わせ — proposal §3.1).
// Xoá tài khoản: tài khoản quán gắn với hợp đồng / quyết toán nên là「依頼」qua お問い合わせ (App Store 5.1.1(v) — §5.1).
// Điều kiện của quán nằm trong 提携契約 ký riêng (không có điều khoản web cho quán; điều khoản khách không áp dụng) —
// quyết định của chủ dự án 2026-10-11: dòng「提携契約について」mở sheet giải thích + nút お問い合わせ.
class StoreSettingsPage extends ConsumerWidget {
  const StoreSettingsPage({super.key, required this.restaurant, required this.userId});
  final StoreRestaurant restaurant;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final eco = context.eco;
    final email = restaurant.accountEmail;
    final version = ref.watch(appVersionProvider).valueOrNull ?? '';
    final closing = restaurant.closingTime.length >= 5
        ? restaurant.closingTime.substring(0, 5)
        : restaurant.closingTime;
    void push(Widget page) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

    BoxDecoration card() => BoxDecoration(
      color: eco.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: eco.border),
    );
    Widget tile(IconData icon, String label, VoidCallback onTap, {Key? key, Color? color}) => ListTile(
      key: key,
      leading: Icon(icon, color: color ?? eco.textPrimary),
      title: Text(
        label,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color),
      ),
      trailing: Icon(Icons.chevron_right, color: eco.textSecondary),
      onTap: onTap,
    );

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text(l10n.storeSettingsTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: card(),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: eco.primarySoft, shape: BoxShape.circle),
                  child: Icon(Icons.storefront_outlined, color: eco.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(restaurant.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Text(
                        l10n.storeSettingsAddress(restaurant.address, closing),
                        style: TextStyle(fontSize: 12, color: eco.textSecondary),
                      ),
                      if (email.isNotEmpty) Text(email, style: TextStyle(fontSize: 12, color: eco.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(l10n.storeSettingsInfoNote, style: TextStyle(fontSize: 12, color: eco.textSecondary)),
          const SizedBox(height: 16),
          Container(
            decoration: card(),
            child: Column(
              children: [
                const _PushRow(),
                Divider(height: 1, color: eco.border),
                tile(
                  Icons.star_outline_rounded,
                  l10n.storeSettingsRatings,
                  () => push(StoreRatingsPage(restaurantId: restaurant.id)),
                  key: const Key('storeSettingsRatings'),
                ),
                Divider(height: 1, color: eco.border),
                tile(
                  Icons.chat_bubble_outline_rounded,
                  l10n.storeSettingsInquiry,
                  () => push(StoreInquiryPage(userId: userId)),
                  key: const Key('storeSettingsInquiry'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: card(),
            child: Column(
              children: [
                tile(
                  Icons.handshake_outlined,
                  l10n.storeSettingsContract,
                  () => _showContractSheet(context, () => push(StoreInquiryPage(userId: userId))),
                  key: const Key('storeSettingsContract'),
                ),
                Divider(height: 1, color: eco.border),
                tile(
                  Icons.description_outlined,
                  l10n.storeSettingsPrivacy,
                  () => openLegalDocument(context, LegalDocument.privacy),
                ),
                Divider(height: 1, color: eco.border),
                tile(
                  Icons.person_remove_outlined,
                  l10n.storeSettingsDeleteAccount,
                  () => push(StoreInquiryPage(userId: userId, initialMessage: l10n.storeAccountDeletionMessage)),
                  key: const Key('storeSettingsDeleteAccount'),
                  color: eco.error,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const LogoutButton(danger: false),
          const SizedBox(height: 12),
          if (version.isNotEmpty)
            Text(
              l10n.storeSettingsVersion(version),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: eco.textSecondary),
            ),
        ],
      ),
    );
  }
}

void _showContractSheet(BuildContext context, VoidCallback openInquiry) {
  final l10n = context.l10n;
  final eco = context.eco;
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheet) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.storeSettingsContract, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(l10n.storeContractBody, style: TextStyle(fontSize: 14, height: 1.6, color: eco.textSecondary)),
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('storeContractInquiry'),
              onPressed: () {
                Navigator.of(sheet).pop();
                openInquiry();
              },
              child: Text(l10n.storeContractInquiry),
            ),
          ],
        ),
      ),
    ),
  );
}

// 「アプリの通知」: bật = xin quyền + lưu token (cùng logic SCR-M07: enablePush). Tắt hẳn quyền phải làm ở Cài đặt của máy.
class _PushRow extends ConsumerStatefulWidget {
  const _PushRow();

  @override
  ConsumerState<_PushRow> createState() => _PushRowState();
}

class _PushRowState extends ConsumerState<_PushRow> {
  bool _working = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final status = ref.watch(pushStatusProvider).valueOrNull;
    if (status == null || status == PushStatus.unavailable) return const SizedBox.shrink();
    return SwitchListTile(
      key: const Key('storeSettingsPush'),
      secondary: Icon(Icons.notifications_none_rounded, color: eco.textPrimary),
      title: Text(l10n.storeSettingsPush, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      subtitle: status == PushStatus.denied
          ? Text(l10n.storeSettingsPushDenied, style: TextStyle(fontSize: 12, color: eco.textSecondary))
          : null,
      value: status == PushStatus.on,
      onChanged: _working
          ? null
          : (_) async {
              if (status == PushStatus.off) {
                setState(() => _working = true);
                try {
                  await enablePush(ref);
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorPushEnable)));
                  }
                } finally {
                  if (mounted) setState(() => _working = false);
                }
                return;
              }
              // Bị từ chối / muốn tắt: chỉ đổi được ở Cài đặt của máy. Quay lại app thì đọc lại quyền.
              await Geolocator.openAppSettings();
              ref.invalidate(pushStatusProvider);
            },
    );
  }
}
