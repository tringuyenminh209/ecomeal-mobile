import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../auth/auth_controller.dart';
import '../notifications/push_registration.dart';
import 'terms_gateway.dart';

// SCR-M10 利用規約 / SCR-M11 プライバシーポリシー (06_画面設計 §SCR-M10/M11, Figma section 420:989 —
// 全文 420:990 / 420:1041, 同意が必要 420:1136). Nội dung đi qua ARB; bản tiếng Nhật là bản chính.

enum LegalDocument { terms, privacy }

typedef _Section = (String title, String body);

List<_Section> _sectionsOf(LegalDocument doc, AppLocalizations l10n) => switch (doc) {
      LegalDocument.terms => [
          (l10n.termsArticle1Title, l10n.termsArticle1Body),
          (l10n.termsArticle2Title, l10n.termsArticle2Body),
          (l10n.termsArticle3Title, l10n.termsArticle3Body),
          (l10n.termsArticle4Title, l10n.termsArticle4Body),
          (l10n.termsArticle5Title, l10n.termsArticle5Body),
          (l10n.termsArticle6Title, l10n.termsArticle6Body),
          (l10n.termsArticle7Title, l10n.termsArticle7Body),
          (l10n.termsArticle8Title, l10n.termsArticle8Body),
          (l10n.termsArticle9Title, l10n.termsArticle9Body),
          (l10n.termsArticle10Title, l10n.termsArticle10Body),
        ],
      LegalDocument.privacy => [
          (l10n.privacySection1Title, l10n.privacySection1Body),
          (l10n.privacySection2Title, l10n.privacySection2Body),
          (l10n.privacySection3Title, l10n.privacySection3Body),
          (l10n.privacySection4Title, l10n.privacySection4Body),
          (l10n.privacySection5Title, l10n.privacySection5Body),
        ],
    };

String legalTitleOf(LegalDocument doc, AppLocalizations l10n) =>
    doc == LegalDocument.terms ? l10n.legalTermsTitle : l10n.legalPrivacyTitle;

// Mở trang bằng Navigator.push — gọi từ SCR-M07「アプリについて」 và link ở ô đồng ý SCR-M02.
Future<void> openLegalDocument(BuildContext context, LegalDocument doc) {
  return Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => LegalDocumentPage(document: doc)));
}

// Mở trang của site công khai bằng trình duyệt ngoài. Test thay bằng hàm giả (không mở trình duyệt thật).
final openExternalUrlProvider = Provider<Future<bool> Function(String url)>((ref) {
  return (url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
});

class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({super.key, required this.document});
  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    // Không có Bottom Navigation (06 §SCR-M10): trang đọc, quay lại bằng ←.
    return Scaffold(
      appBar: AppBar(title: Text(legalTitleOf(document, context.l10n)), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [_LegalBody(document: document)],
      ),
    );
  }
}

class _LegalBody extends ConsumerWidget {
  const _LegalBody({required this.document, this.showEnactedOn = true});
  final LegalDocument document;
  final bool showEnactedOn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showEnactedOn) ...[
          Text(l10n.legalEnactedOn, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
        ],
        // Khung vàng nhạt: văn bản demo của đồ án (cùng màu khung lưu ý SCR-M05/M06).
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.amberSoft,
            border: Border.all(color: AppColors.amber),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(l10n.legalDemoNotice, style: const TextStyle(fontSize: 12, height: 1.55, color: AppColors.amberInk)),
        ),
        for (final (title, body) in _sectionsOf(document, l10n)) ...[
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(fontSize: 13, height: 1.7)),
        ],
        const SizedBox(height: 24),
        InkWell(
          key: const Key('legalContactCard'),
          borderRadius: BorderRadius.circular(12),
          onTap: () => ref.read(openExternalUrlProvider)(contactPageUrl),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.mail_outline, size: 20, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.legalContactTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(
                        Uri.parse(contactPageUrl).host + Uri.parse(contactPageUrl).path,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.open_in_new, size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// SCR-M10 同意が必要 (Figma 420:1136): RoleGate hiện màn này thay cho CustomerShell khi users.terms_version khác
// currentTermsVersion. Không có nút ←, và chặn cả thao tác quay lại của hệ điều hành (PopScope canPop: false).
class TermsConsentPage extends ConsumerStatefulWidget {
  const TermsConsentPage({super.key, required this.userId});
  final String userId;

  @override
  ConsumerState<TermsConsentPage> createState() => _TermsConsentPageState();
}

class _TermsConsentPageState extends ConsumerState<TermsConsentPage> {
  bool _submitting = false;

  Future<void> _accept() async {
    setState(() => _submitting = true);
    try {
      await ref.read(termsGatewayProvider).acceptTerms(currentTermsVersion);
      // RoleGate đọc lại → bản đã đồng ý khớp → vào CustomerShell.
      ref.invalidate(acceptedTermsVersionProvider(widget.userId));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.errorTermsAcceptFailed)));
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              Text(l10n.termsUpdatedTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(l10n.termsUpdatedBody, style: const TextStyle(fontSize: 13, height: 1.65, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  key: const Key('consentPrivacyLink'),
                  onPressed: () => openLegalDocument(context, LegalDocument.privacy),
                  child: Text(l10n.legalPrivacyTitle),
                ),
              ),
              const SizedBox(height: 8),
              const _LegalBody(document: LegalDocument.terms, showEnactedOn: false),
            ],
          ),
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            minimum: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton(
                  key: const Key('acceptTermsButton'),
                  onPressed: _submitting ? null : _accept,
                  child: _submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surface),
                        )
                      : Text(l10n.termsAgreeAndContinue),
                ),
                const SizedBox(height: 8),
                TextButton(
                  key: const Key('declineTermsButton'),
                  onPressed: _submitting
                      ? null
                      : () async {
                          await unregisterPush(ref);
                          await ref.read(authControllerProvider.notifier).signOut();
                        },
                  child: Text(l10n.termsDeclineAndLogout),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
