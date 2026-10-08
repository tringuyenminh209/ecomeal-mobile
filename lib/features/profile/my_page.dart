import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/line_login_bridge.dart';
import '../../core/line_official_account.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/logout_button.dart';
import '../../widgets/state_panel.dart';
import '../auth/locale_controller.dart';
import '../payment/card_widgets.dart';
import '../payment/payment_gateway.dart';
import '../payment/payment_methods_page.dart';
import 'profile_edit_page.dart';
import 'profile_gateway.dart';
import 'profile_validation.dart';
import '../../widgets/skeleton.dart';

// SCR-M07 プロフィール・設定 — 06_画面設計 §SCR-M07, khớp frame Figma 16:16656 (thường) / 54:2843
// (LINE連携済み) / 54:2915 (Loading) / 54:2983 (Error) / 125:243 (取得エラー) / 54:3054 (ログアウト確認).
class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const _MyPageSkeleton(),
          error: (_, __) => Center(
            child: StatePanel.error(
              title: l10n.errorLoadTitle,
              message: l10n.errorLoadBody,
              actionLabel: l10n.retry,
              onAction: () => ref.invalidate(myProfileProvider),
            ),
          ),
          data: (profile) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Text(l10n.myPageTab, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _ProfileSummary(profile: profile),
              const SizedBox(height: 16),
              // Figma 16:16656: nhãn song ngữ cố định 「言語 / Language」 phía trên rãnh chọn ngôn ngữ.
              Text(l10n.languageLabel, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 8),
              const _LanguageSwitch(),
              const SizedBox(height: 16),
              const _PaymentMethodRow(),
              const SizedBox(height: 16),
              const _LineLinkSection(),
              const SizedBox(height: 16),
              // "Logout section" của Figma: đường kẻ Border phía trên, cách 16.
              const Divider(),
              const SizedBox(height: 16),
              const LogoutButton(),
            ],
          ),
        ),
      ),
    );
  }
}

// "Profile summary": khung viền bo 12, avatar tròn 48 nền xanh nhạt, tên + email, bút chì ở bên phải.
class _ProfileSummary extends ConsumerWidget {
  const _ProfileSummary({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 4, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
            child: Text(
              avatarInitialOf(profile.name),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(profile.email, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(
            key: const Key('editProfileButton'),
            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
            onPressed: () async {
              // 06 §SCR-M07: lưu thành công ở SCR-M08 → quay lại đây và lấy lại tên mới.
              final saved = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => ProfileEditPage(initial: profile)),
              );
              if (saved == true) ref.invalidate(myProfileProvider);
            },
          ),
        ],
      ),
    );
  }
}

// 「支払い方法」(Figma 16:16656, 0043): dòng phụ = thẻ mặc định「Visa •••• 3456 ・ デフォルト」→ SCR-M09 (quản lý).
// Lỗi tải thẻ không chặn cả trang: chỉ bỏ dòng phụ, chạm vào vẫn mở SCR-M09 (ở đó có nút 再試行).
class _PaymentMethodRow extends ConsumerWidget {
  const _PaymentMethodRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final methods = ref.watch(myPaymentMethodsProvider).valueOrNull;
    final defaultCard = methods == null || methods.isEmpty ? null : methods.firstWhere((m) => m.isDefault, orElse: () => methods.first);
    final subtitle = methods == null
        ? null
        : defaultCard == null
            ? l10n.paymentMethodRowNone
            : l10n.paymentMethodRowDefault(cardLabel(defaultCard.brand, defaultCard.last4));
    return InkWell(
      key: const Key('paymentMethodRow'),
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentMethodsPage())),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.credit_card, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.paymentMethodSection, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// UC-02 + API-023: đổi ngôn ngữ sau khi đã đăng nhập — lưu lên users.preferred_language (server) RỒI
// mới đổi locale ở máy. Ngược thứ tự thì lỗi mạng sẽ để UI một đằng, server một nẻo.
// "Language switch" của Figma: rãnh xám bo 10, ô đang chọn nền trắng bo 8 chữ đậm.
class _LanguageSwitch extends ConsumerStatefulWidget {
  const _LanguageSwitch();

  @override
  ConsumerState<_LanguageSwitch> createState() => _LanguageSwitchState();
}

class _LanguageSwitchState extends ConsumerState<_LanguageSwitch> {
  bool _saving = false;

  Future<void> _change(String code) async {
    setState(() => _saving = true);
    try {
      await ref.read(profileGatewayProvider).updatePreferredLanguage(code);
      await ref.read(localeControllerProvider.notifier).setLocale(Locale(code));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.errorLanguageSave)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(localeControllerProvider).languageCode;
    // tên ngôn ngữ viết bằng chính ngôn ngữ đó (endonym) — không dịch, giống SCR-M01
    const options = [('ja', '日本語'), ('en', 'English')];
    return Container(
      key: const Key('languageToggle'),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.chip, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          for (final (code, label) in options)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _saving || code == current ? null : () => _change(code),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: code == current ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: code == current ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// UC-24 / API-018b. Các trạng thái của Figma: nút "LINEと連携する" → Loading (spinner trong nút) →
// thành công (khung LINE連携済み) hoặc Error (banner đỏ + "もう一度試す").
class _LineLinkSection extends ConsumerStatefulWidget {
  const _LineLinkSection();

  @override
  ConsumerState<_LineLinkSection> createState() => _LineLinkSectionState();
}

class _LineLinkSectionState extends ConsumerState<_LineLinkSection> {
  bool _linking = false;
  bool _hasError = false;

  Future<void> _link() async {
    setState(() {
      _linking = true;
      _hasError = false;
    });
    try {
      // Chỉ gửi ID token lên server — KHÔNG tự giải mã lấy line_user_id ở client (UC-24, レビュー第4回P2).
      final idToken = await ref.read(lineLoginBridgeProvider).obtainIdToken();
      await ref.read(profileGatewayProvider).linkLineAccount(idToken);
      ref.invalidate(lineLinkedProvider);
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _linking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final linkedAsync = ref.watch(lineLinkedProvider);
    final hint = Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        l10n.lineLinkHint,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
      ),
    );

    // レビュー第30回: 3 trạng thái của query phải hiện riêng. Bản cũ dùng "valueOrNull ?? false" → query lỗi
    // bị hiểu thành "chưa liên kết" và người ĐÃ liên kết vẫn thấy nút "LINEと連携する". Chỉ hiện nút khi
    // query thành công VÀ trả false.
    return linkedAsync.when(
      loading: () => const Center(
        key: Key('lineStatusLoading'),
        child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()),
      ),
      // Figma 125:243 (取得エラー): banner + nút 再試行 full chiều ngang, không có dòng gợi ý LIFF.
      error: (_, __) => Column(
        key: const Key('lineStatusError'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ErrorBanner(message: l10n.errorLineStatusLoad),
          const SizedBox(height: 12),
          OutlinedButton(
            key: const Key('retryLineStatusButton'),
            onPressed: () => ref.invalidate(lineLinkedProvider),
            child: Text(l10n.retry),
          ),
        ],
      ),
      data: (isLinked) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isLinked) ...[
            _linkedCard(l10n),
            // Figma 54:2843 (レビュー第66回): mở trò chuyện với Official Account — xem lại thông báo, và kết bạn lại
            // nếu lúc liên kết đã bỏ qua bước 友だち追加 (không kết bạn thì không nhận được push).
            if (ref.watch(openLineOfficialAccountProvider) != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                key: const Key('lineOpenChatButton'),
                onPressed: () => openLineOfficialAccount(context, ref),
                child: Text(l10n.lineOpenChat),
              ),
            ],
          ] else ...[
            // Figma 54:2983: banner lỗi nằm NGAY TRÊN nút, nút đổi chữ thành "もう一度試す".
            if (_hasError) ...[
              ErrorBanner(message: l10n.errorLineLinkFailed),
              const SizedBox(height: 12),
            ],
            OutlinedButton(
              key: const Key('lineLinkButton'),
              onPressed: _linking ? null : _link,
              child: _linking
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_hasError ? l10n.tryAgain : l10n.lineLinkButton),
            ),
          ],
          if (!_hasError) hint,
        ],
      ),
    );
  }

  // "LINE連携済み" của Figma 54:2843: khung viền bo 12, vòng tròn xanh nhạt có dấu check.
  Widget _linkedCard(AppLocalizations l10n) {
    return Container(
      key: const Key('lineLinkedCard'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_outline, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.lineLinked, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Text(l10n.lineLinkedBody, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Loading của hồ sơ: giữ khung (tiêu đề, khung hồ sơ, rãnh ngôn ngữ, nút) bằng khối xám.
class _MyPageSkeleton extends StatelessWidget {
  const _MyPageSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget block(double height, {double? width, double radius = 12}) =>
        SkeletonBox(height: height, width: width, radius: radius);
    return SkeletonPulse(
      child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Align(alignment: Alignment.centerLeft, child: block(26, width: 120, radius: 8)),
        const SizedBox(height: 16),
        block(82),
        const SizedBox(height: 16),
        block(42, radius: 10),
        const SizedBox(height: 16),
        block(48, radius: 999),
      ],
      ),
    );
  }
}
