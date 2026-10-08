import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/jst_date.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/status_badge.dart';
import 'driver_account_gateway.dart';

// SCR-D05 の追加カード（レビュー第74回、Figma 277:712 差し戻し・シフトなし / 277:773 確認済み・シフトあり）

class PickedLicenseImage {
  const PickedLicenseImage({required this.bytes, required this.extension});
  final Uint8List bytes;
  final String extension;
}

typedef LicenseImagePicker = Future<PickedLicenseImage?> Function(ImageSource source);

// 長辺1600px・品質80で十分読める（バケット上限5MBに収まる）
const _maxImageSide = 1600.0;
const _imageQuality = 80;

// テストでは差し替える（実機のカメラ／写真ライブラリを使わない）
final licenseImagePickerProvider = Provider<LicenseImagePicker>((ref) {
  final picker = ImagePicker();
  return (source) async {
    final file = await picker.pickImage(source: source, maxWidth: _maxImageSide, maxHeight: _maxImageSide, imageQuality: _imageQuality);
    if (file == null) return null;
    final name = file.name;
    final dot = name.lastIndexOf('.');
    return PickedLicenseImage(bytes: await file.readAsBytes(), extension: dot < 0 ? 'jpg' : name.substring(dot + 1));
  };
});

(String, BadgeTone) _licenseBadge(LicenseStatus status, AppLocalizations l10n) => switch (status) {
      LicenseStatus.none => (l10n.licenseStatusNone, BadgeTone.neutral),
      LicenseStatus.submitted => (l10n.licenseStatusSubmitted, BadgeTone.warning),
      LicenseStatus.verified => (l10n.licenseStatusVerified, BadgeTone.soft),
      LicenseStatus.rejected => (l10n.licenseStatusRejected, BadgeTone.error),
    };

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.children, this.badge});
  final String title;
  final Widget? badge;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.eco.surface,
        border: Border.all(color: context.eco.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
              if (badge != null) badge!,
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class DriverLicenseCard extends ConsumerStatefulWidget {
  const DriverLicenseCard({super.key});

  @override
  ConsumerState<DriverLicenseCard> createState() => _DriverLicenseCardState();
}

class _DriverLicenseCardState extends ConsumerState<DriverLicenseCard> {
  bool _uploading = false;

  Future<void> _upload(DriverLicense current) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const Key('licenseSourceCamera'),
              leading: const Icon(Icons.photo_camera),
              title: Text(l10n.licenseSourceCamera),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              key: const Key('licenseSourceGallery'),
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.licenseSourceGallery),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    setState(() => _uploading = true);
    try {
      final picked = await ref.read(licenseImagePickerProvider)(source);
      if (picked == null) return;
      await ref.read(driverAccountGatewayProvider).submitLicense(
            bytes: picked.bytes,
            extension: picked.extension,
            previousPath: current.imagePath,
          );
      ref.invalidate(driverLicenseProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.licenseUploadSuccess)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.licenseUploadError)));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final licenseAsync = ref.watch(driverLicenseProvider);
    return licenseAsync.when(
      loading: () => _Card(title: l10n.driverLicenseTitle, children: const [LinearProgressIndicator()]),
      error: (_, __) => _Card(
        title: l10n.driverLicenseTitle,
        children: [
          Text(l10n.errorLoadBody, style: TextStyle(fontSize: 13, color: context.eco.textSecondary)),
          TextButton(onPressed: () => ref.invalidate(driverLicenseProvider), child: Text(l10n.retry)),
        ],
      ),
      data: (license) {
        final (label, tone) = _licenseBadge(license.status, l10n);
        final locale = Localizations.localeOf(context).toLanguageTag();
        final verified = license.status == LicenseStatus.verified;
        final uploadButton = verified
            ? OutlinedButton(
                key: const Key('licenseUploadButton'),
                onPressed: _uploading ? null : () => _upload(license),
                child: Text(l10n.licenseResubmitButton),
              )
            : FilledButton(
                key: const Key('licenseUploadButton'),
                onPressed: _uploading ? null : () => _upload(license),
                child: Text(l10n.licenseUploadButton),
              );
        return _Card(
          title: l10n.driverLicenseTitle,
          badge: StatusBadge(label: label, tone: tone),
          children: [
            if (license.status == LicenseStatus.none)
              Text(l10n.licenseNoneBody, style: const TextStyle(fontSize: 13, height: 1.6)),
            if (license.status == LicenseStatus.submitted)
              Text(l10n.licenseSubmittedBody, style: const TextStyle(fontSize: 13, height: 1.6)),
            if (verified && license.expiresOn != null)
              Text(l10n.licenseExpiresOn(formatDateWithYear(license.expiresOn!, locale)), style: const TextStyle(fontSize: 13)),
            if (license.status == LicenseStatus.rejected && license.rejectReason != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: context.eco.errorSoft, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.licenseRejectedLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: context.eco.error)),
                    const SizedBox(height: 4),
                    Text(license.rejectReason!, style: const TextStyle(fontSize: 13, height: 1.6)),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            if (_uploading) const Padding(padding: EdgeInsets.only(bottom: 8), child: LinearProgressIndicator()),
            uploadButton,
            const SizedBox(height: 8),
            Text(
              verified ? l10n.licenseResubmitNote : l10n.licensePrivacyNote,
              style: TextStyle(fontSize: 11, color: context.eco.textSecondary, height: 1.6),
            ),
          ],
        );
      },
    );
  }
}

class UpcomingShiftsCard extends ConsumerWidget {
  const UpcomingShiftsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final shiftsAsync = ref.watch(upcomingShiftsProvider);
    return _Card(
      title: l10n.upcomingShiftsTitle(upcomingShiftDays),
      children: shiftsAsync.when(
        loading: () => const [LinearProgressIndicator()],
        error: (_, __) => [
          Text(l10n.shiftsLoadError, style: TextStyle(fontSize: 13, color: context.eco.textSecondary)),
          TextButton(onPressed: () => ref.invalidate(upcomingShiftsProvider), child: Text(l10n.retry)),
        ],
        data: (shifts) => shifts.isEmpty
            ? [Text(l10n.upcomingShiftsEmpty, style: TextStyle(fontSize: 13, color: context.eco.textSecondary, height: 1.6))]
            : [
                for (final s in shifts)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(formatServiceDate(s.serviceDate, locale), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        ),
                        Text(s.plateNumber, style: TextStyle(fontSize: 13, color: context.eco.textSecondary)),
                      ],
                    ),
                  ),
              ],
      ),
    );
  }
}
