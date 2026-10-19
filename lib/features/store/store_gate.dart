import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/jst_date.dart';
import '../../core/theme/app_theme.dart';
import '../../core/web_admin.dart';
import '../../l10n/l10n.dart';
import '../../widgets/account_notice_screen.dart';
import '../../widgets/logout_button.dart';
import '../../widgets/state_panel.dart';
import '../../widgets/store_shell.dart';
import '../auth/web_admin_only_screen.dart';
import 'store_gateway.dart';

// App nhà hàng sau khi đăng nhập: quán đã duyệt → StoreShell; đang chờ duyệt / bị từ chối → SCR-S00 (552:72 / 552:107);
// chưa gửi đăng ký → báo đăng ký trên Web (đăng ký cần upload PDF bảo hiểm PL, giữ trên Web — proposal §3.1).
// Đây chỉ là hướng dẫn: RPC của quán chưa duyệt vẫn bị chặn ở server (E-REST-011, is_restaurant_approved).
class StoreGate extends ConsumerWidget {
  const StoreGate({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ref
        .watch(myRestaurantProvider(userId))
        .when(
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (_, _) => Scaffold(
            body: SafeArea(
              child: Center(
                child: StatePanel.error(
                  title: l10n.storeLoadErrorTitle,
                  message: l10n.storeLoadErrorBody,
                  actionLabel: l10n.storeReload,
                  onAction: () => ref.invalidate(myRestaurantProvider(userId)),
                ),
              ),
            ),
          ),
          data: (restaurant) {
            if (restaurant == null) {
              return AccountNoticeScreen(
                title: l10n.storeNotRegisteredTitle,
                body: l10n.storeNotRegisteredBody,
                primaryAction: const OpenWebAdminButton(),
              );
            }
            if (restaurant.isApproved) return StoreApp(restaurant: restaurant, userId: userId);
            return StoreReviewStatusPage(
              restaurant: restaurant,
              onCheck: () => ref.invalidate(myRestaurantProvider(userId)),
            );
          },
        );
  }
}

// SCR-S00 審査中（552:72）／却下（552:107）. Kết quả duyệt chỉ đọc 1 lần khi vào app → nút 「審査の結果を確認する」
// (953:5928) và tự đọc lại khi quay về app từ nền: quán nhận mail "đã duyệt" mở app là vào được (audit S02 2026-10-19).
class StoreReviewStatusPage extends StatefulWidget {
  const StoreReviewStatusPage({super.key, required this.restaurant, required this.onCheck});
  final StoreRestaurant restaurant;
  final VoidCallback onCheck;

  @override
  State<StoreReviewStatusPage> createState() => _StoreReviewStatusPageState();
}

class _StoreReviewStatusPageState extends State<StoreReviewStatusPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) widget.onCheck();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;
    final l10n = context.l10n;
    final eco = context.eco;
    final locale = Localizations.localeOf(context).languageCode;
    final rejected = restaurant.isRejected;
    final appliedOn = formatDateWithYear(dateInTokyo(restaurant.appliedAt), locale);

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: eco.textSecondary)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(color: rejected ? eco.errorSoft : eco.primarySoft, shape: BoxShape.circle),
                  child: Icon(
                    rejected ? Icons.info_outline_rounded : Icons.schedule_rounded,
                    size: 36,
                    color: rejected ? eco.error : eco.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                rejected ? l10n.storeReviewRejectedTitle : l10n.storeReviewPendingTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                rejected ? l10n.storeReviewRejectedBody : l10n.storeReviewPendingBody,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 1.65, color: eco.textSecondary),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: eco.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: eco.border),
                ),
                child: rejected
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            l10n.storeRejectionReasonLabel,
                            style: TextStyle(fontSize: 13, color: eco.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          Text(restaurant.rejectionReason ?? '', style: const TextStyle(fontSize: 14, height: 1.6)),
                          const SizedBox(height: 6),
                        ],
                      )
                    : Column(
                        children: [
                          row(l10n.storeFieldName, restaurant.name),
                          row(l10n.storeFieldAppliedAt, appliedOn),
                          row(l10n.storeFieldApplicant, restaurant.applicantName),
                        ],
                      ),
              ),
              const SizedBox(height: 20),
              if (rejected) ...[const OpenWebAdminButton(), const SizedBox(height: 12)],
              if (!rejected) ...[
                FilledButton(
                  key: const Key('storeReviewCheck'),
                  onPressed: widget.onCheck,
                  child: Text(l10n.storeReviewCheckButton),
                ),
                const SizedBox(height: 12),
              ],
              const LogoutButton(danger: false),
              if (rejected) ...[
                const SizedBox(height: 16),
                Text(
                  Uri.parse(webAdminUrl).host,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: eco.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
