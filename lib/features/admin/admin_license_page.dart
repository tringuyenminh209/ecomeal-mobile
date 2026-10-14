import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/jst_date.dart';
import '../../core/rpc_error.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/confirm_dialog.dart';
import '../notifications/notification_inbox.dart' show inboxTimeLabel;
import 'admin_gateway.dart';
import 'admin_restaurant_page.dart' show AdminReasonSheet, maxRejectionReasonLength, showAdminReasonSheet;
import '../../widgets/error_banner.dart';
import 'admin_tasks_gateway.dart';

final _licenseImageUrlProvider = FutureProvider.autoDispose.family<String, String>(
  (ref, path) => ref.watch(adminTasksGatewayProvider).licenseImageUrl(path),
);
final _assignedTruckProvider = FutureProvider.autoDispose.family<String?, String>(
  (ref, driverId) => ref.watch(adminTasksGatewayProvider).assignedTruck(driverId),
);

// SCR-A05 免許の確認（565:1304）— API-037 review_driver_license. Ngày hết hạn admin nhập theo ảnh (bắt buộc khi xác nhận,
// không được là ngày đã qua — server: E-DRV-004).
class AdminLicensePage extends ConsumerStatefulWidget {
  // onClose: trong cột chi tiết của iPad — xong thì bỏ chọn thay vì pop
  const AdminLicensePage({super.key, required this.license, this.onClose});
  final AdminLicense license;
  final VoidCallback? onClose;

  @override
  ConsumerState<AdminLicensePage> createState() => _AdminLicensePageState();
}

class _AdminLicensePageState extends ConsumerState<AdminLicensePage> {
  late String? _expiresOn = widget.license.expiresOn;
  bool _busy = false;
  bool _failed = false;
  String? _expiryError;

  Future<void> _pickExpiry() async {
    final today = DateTime.parse(todayInTokyo());
    final picked = await showDatePicker(
      context: context,
      firstDate: today,
      lastDate: DateTime(today.year + 20),
      initialDate: _expiresOn == null ? today : DateTime.parse(_expiresOn!),
    );
    if (picked != null) {
      setState(() {
        _expiresOn = DateFormat('yyyy-MM-dd').format(picked);
        _expiryError = null;
      });
    }
  }

  Future<void> _review({required bool verify, String? reason}) async {
    final l10n = context.l10n;
    if (verify && (_expiresOn == null || _expiresOn!.compareTo(todayInTokyo()) < 0)) {
      setState(() => _expiryError = l10n.adminLicErrExpiry);
      return;
    }
    // 確認済みにするとシフトに入れられるようになる — 名前と有効期限を出して確認する
    if (verify) {
      final ok = await showConfirmDialog(
        context,
        title: l10n.adminLicVerifyConfirmTitle(widget.license.name),
        message: l10n.adminLicVerifyConfirmBody(_expiresOn!.replaceAll('-', '/')),
        cancelLabel: l10n.back,
        confirmLabel: l10n.adminLicVerify,
        confirmKey: const Key('adminLicVerifyConfirm'),
      );
      if (ok != true || !mounted) return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final close = widget.onClose ?? Navigator.of(context).pop;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await ref
          .read(adminTasksGatewayProvider)
          .reviewLicense(
            widget.license.driverId,
            verify: verify,
            expiresOn: verify ? _expiresOn : null,
            reason: reason,
          );
      ref.invalidate(adminLicensesProvider);
      ref.invalidate(adminBadgesProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminLicDone(widget.license.name))));
      close();
    } catch (e) {
      if (rpcErrorCode(e) == 'E-DRV-004') {
        setState(() => _expiryError = l10n.adminLicErrExpiry);
      } else if (mounted) {
        // Giữ ngày hết hạn đã nhập — báo ngay trong trang (Figma 797:4525)
        setState(() => _failed = true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject() async {
    final l10n = context.l10n;
    final reason = await showAdminReasonSheet(
      context,
      AdminReasonSheet(title: l10n.adminLicRejectTitle, note: l10n.adminRestRejectNote, sendLabel: l10n.adminLicReject),
    );
    if (reason != null && reason.length <= maxRejectionReasonLength) await _review(verify: false, reason: reason);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final locale = Localizations.localeOf(context).languageCode;
    final lic = widget.license;
    final path = lic.imagePath;
    final truck = ref.watch(_assignedTruckProvider(lic.driverId)).valueOrNull;
    final image = path == null ? null : ref.watch(_licenseImageUrlProvider(path));

    void zoom(String url) => Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          appBar: AppBar(),
          body: InteractiveViewer(maxScale: 5, child: Center(child: Image.network(url))),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.onClose == null,
        titleSpacing: widget.onClose == null ? 0 : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lic.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            if (lic.submittedAt != null)
              Text(
                l10n.adminLicSubmitted(inboxTimeLabel(lic.submittedAt!, DateTime.now(), l10n, locale)),
                style: TextStyle(fontSize: 12, color: eco.textSecondary),
              ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          AspectRatio(
            aspectRatio: 1.58, // 運転免許証の縦横比
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ColoredBox(
                color: eco.chip,
                child: image == null
                    ? Center(child: Text(l10n.adminLicImageFailed))
                    : image.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, _) => Center(child: Text(l10n.adminLicImageFailed)),
                        data: (url) => Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Center(child: Text(l10n.adminLicImageFailed)),
                            ),
                            Positioned(
                              right: 10,
                              bottom: 10,
                              child: FilledButton.tonalIcon(
                                key: const Key('adminLicZoom'),
                                onPressed: () => zoom(url),
                                icon: const Icon(Icons.zoom_out_map, size: 16),
                                label: Text(l10n.adminLicZoom),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(l10n.adminLicTruck, style: TextStyle(fontSize: 13, color: eco.textSecondary)),
              const Spacer(),
              Text(truck ?? l10n.adminLicNoTruck, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          Text(l10n.adminLicExpiry, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          InkWell(
            key: const Key('adminLicExpiry'),
            onTap: _busy ? null : _pickExpiry,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: InputDecoration(
                errorText: _expiryError,
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
              child: Text(
                _expiresOn == null ? l10n.adminLicExpiryPick : formatDateWithYear(_expiresOn!, locale),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(l10n.adminLicVerifyNote, style: TextStyle(fontSize: 12, color: eco.textSecondary)),
          if (_failed)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ErrorBanner(
                key: const Key('adminLicError'),
                title: l10n.adminIssueErrorTitle,
                message: l10n.adminLicErrorBody,
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: const Key('adminLicReject'),
                  onPressed: _busy ? null : _reject,
                  child: Text(l10n.adminLicReject),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  key: const Key('adminLicVerify'),
                  onPressed: _busy ? null : () => _review(verify: true),
                  child: Text(_failed ? l10n.adminLicRetryVerify : l10n.adminLicVerify),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
