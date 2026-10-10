import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/web_admin.dart';
import '../../l10n/l10n.dart';
import '../../widgets/account_notice_screen.dart';

// Mở Web Admin bằng trình duyệt ngoài. Test thay bằng hàm giả.
final openWebAdminProvider = Provider<Future<bool> Function()>((ref) {
  return () => launchUrl(Uri.parse(webAdminUrl), mode: LaunchMode.externalApplication);
});

// Mở Web Admin; không mở được (không có trình duyệt…) thì báo bằng SnackBar
Future<void> openWebAdminOrReport(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final failed = context.l10n.errorOpenWebAdmin;
  var opened = false;
  try {
    opened = await ref.read(openWebAdminProvider)();
  } catch (_) {}
  if (!opened) messenger.showSnackBar(SnackBar(content: Text(failed)));
}

// 「Web管理画面を開く」(SCR-M02 対象外アカウント, SCR-S00 却下・未登録).
class OpenWebAdminButton extends ConsumerWidget {
  const OpenWebAdminButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton(
      key: const Key('openWebAdminButton'),
      onPressed: () => openWebAdminOrReport(context, ref),
      child: Text(context.l10n.openWebAdmin),
    );
  }
}

// Tài khoản 飲食店担当者・運営 đăng nhập app (05 §5: app chỉ cho khách/tài xế) — Figma "SCR-M02 対象外アカウント"
// (244:1414). Không tự đăng xuất: người dùng cần đọc vì sao rồi chọn mở Web Admin hoặc ログアウト.
class WebAdminOnlyScreen extends StatelessWidget {
  const WebAdminOnlyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AccountNoticeScreen(
      title: l10n.webOnlyAccountTitle,
      body: l10n.webOnlyAccountBody,
      primaryAction: const OpenWebAdminButton(),
      footer: Text(
        Uri.parse(webAdminUrl).host,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, color: context.eco.textSecondary),
      ),
    );
  }
}
