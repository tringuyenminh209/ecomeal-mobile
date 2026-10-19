import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' show Geolocator;
import 'package:image_picker/image_picker.dart' show ImageSource;
import '../../core/photo_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/labeled_field.dart';
import 'profile_avatar.dart';
import '../auth/auth_gateway.dart' show isLineOnlyEmail;
import 'profile_gateway.dart';
import 'profile_validation.dart';

// SCR-M08 プロフィール編集 — 06_画面設計 §SCR-M08, khớp frame Figma 91:804 (thường) / 91:850 (Error) /
// 91:896 (Loading) / 91:942 (変更破棄確認). Không có Bottom Navigation (06: tránh rời màn hình khi đang sửa).
// Ảnh đại diện (UC-35, 2026-10-09): 419:970 未設定 / 419:1026 設定済み / 419:1084 アップロード中 / 419:1146 エラー /
// 419:1202 選択シート. Đổi ảnh có hiệu lực ngay, độc lập với nút 保存する (không làm form "dirty").
class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key, required this.initial});
  final UserProfile initial;

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _kanaController;
  bool _saving = false;
  late String? _avatarPath = widget.initial.avatarPath;
  bool _uploadingPhoto = false;
  bool _photoError = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initial.name)..addListener(_onChanged);
    _kanaController = TextEditingController(text: widget.initial.nameKana ?? '')..addListener(_onChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _kanaController.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  // "Có thay đổi" so sánh SAU khi trim — gõ thêm rồi xoá khoảng trắng ở cuối không tính là thay đổi.
  bool get _isDirty =>
      _nameController.text.trim() != widget.initial.name || _kanaController.text.trim() != (widget.initial.nameKana ?? '');

  String? get _nameError => validateDisplayName(_nameController.text, context.l10n);
  String? get _kanaError => validateNameKana(_kanaController.text, context.l10n);

  // 06 §SCR-M08: chưa đổi gì → "保存する" disabled; vi phạm validate → không gửi.
  bool get _canSave => !_saving && _isDirty && _nameError == null && _kanaError == null;

  Future<void> _save() async {
    setState(() => _saving = true);
    final kana = _kanaController.text.trim();
    try {
      await ref.read(profileGatewayProvider).updateProfile(
            name: _nameController.text.trim(),
            nameKana: kana.isEmpty ? null : kana, // ô trống → NULL (cột nullable), không lưu chuỗi rỗng
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.profileSaved)));
      Navigator.of(context).pop(true);
    } catch (_) {
      // Giữ nguyên nội dung đã nhập (06 §SCR-M08 Error Message 通信).
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.errorSaveFailed)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Ảnh đại diện ───────────────────────────────────────────────────────────
  Future<void> _openPhotoSheet() async {
    final l10n = context.l10n;
    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.profilePhotoSheetTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ListTile(
              key: const Key('photoTakeOption'),
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.profilePhotoTake),
              onTap: () => Navigator.of(sheetContext).pop(_PhotoAction.camera),
            ),
            ListTile(
              key: const Key('photoLibraryOption'),
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.profilePhotoLibrary),
              onTap: () => Navigator.of(sheetContext).pop(_PhotoAction.library),
            ),
            if (_avatarPath != null)
              ListTile(
                key: const Key('photoDeleteOption'),
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: Text(l10n.profilePhotoDelete, style: const TextStyle(color: AppColors.error)),
                onTap: () => Navigator.of(sheetContext).pop(_PhotoAction.delete),
              ),
            ListTile(
              key: const Key('photoCancelOption'),
              title: Text(l10n.cancelButton, textAlign: TextAlign.center),
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
    switch (action) {
      case _PhotoAction.camera:
        await _pickAndUpload(ImageSource.camera);
      case _PhotoAction.library:
        await _pickAndUpload(ImageSource.gallery);
      case _PhotoAction.delete:
        await _deletePhoto();
      case null:
        break;
    }
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    final Uint8List? picked;
    try {
      picked = await ref.read(avatarImagePickerProvider)(source);
    } catch (err) {
      // Bị từ chối quyền camera / ảnh → chỉ đường sang Cài đặt của OS; lỗi đọc ảnh khác → báo 「写真を読み込めませんでした」
      // (trước đây im lặng — photoPickProblemOf dùng chung với app quán, audit S04)
      if (photoPickProblemOf(err) == PhotoPickProblem.failed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${context.l10n.photoReadFailed}\n${context.l10n.photoReadFailedBody}')),
          );
        }
      } else {
        await _showAccessDenied();
      }
      return;
    }
    if (picked == null || !mounted) return; // huỷ chọn
    setState(() {
      _uploadingPhoto = true;
      _photoError = false;
    });
    final jpeg = await ref.read(avatarJpegPreparerProvider)(picked);
    if (!mounted) return;
    if (jpeg == null) {
      setState(() => _uploadingPhoto = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.errorProfilePhotoInvalid)));
      return;
    }
    try {
      final path = await ref.read(profileGatewayProvider).uploadAvatar(jpeg, previousPath: _avatarPath);
      if (!mounted) return;
      setState(() => _avatarPath = path);
      ref.invalidate(myProfileProvider); // SCR-M07 phía dưới hiện ảnh mới khi quay lại
    } catch (_) {
      if (mounted) setState(() => _photoError = true); // 419:1146: giữ ảnh cũ, câu lỗi đỏ dưới avatar
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _deletePhoto() async {
    final path = _avatarPath;
    if (path == null) return;
    setState(() {
      _uploadingPhoto = true;
      _photoError = false;
    });
    try {
      await ref.read(profileGatewayProvider).removeAvatar(path);
      if (!mounted) return;
      setState(() => _avatarPath = null);
      ref.invalidate(myProfileProvider);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.profilePhotoDeleted)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.errorSaveFailed)));
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _showAccessDenied() async {
    if (!mounted) return;
    final open = await showConfirmDialog(
      context,
      title: context.l10n.photoAccessDeniedTitle,
      message: context.l10n.photoAccessDeniedBody,
      cancelLabel: context.l10n.cancelButton,
      confirmLabel: context.l10n.openSettings,
      confirmKey: const Key('openSettingsButton'),
    );
    if (open == true) await Geolocator.openAppSettings();
  }

  Future<bool> _confirmDiscard() async {
    final discard = await showConfirmDialog(
      context,
      title: context.l10n.discardDialogTitle,
      message: context.l10n.discardDialogBody,
      cancelLabel: context.l10n.keepEditing,
      cancelKey: const Key('keepEditingButton'),
      confirmLabel: context.l10n.discard,
      confirmKey: const Key('discardButton'),
      destructive: true,
      centered: true,
    );
    return discard == true;
  }

  @override
  Widget build(BuildContext context) {
    // PopScope chặn MỌI kiểu quay lại (nút ← trên AppBar, nút back Android, vuốt iOS) khi có thay đổi
    // chưa lưu — không chỉ riêng nút trên AppBar.
    return PopScope(
      canPop: !_isDirty || _saving,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _confirmDiscard()) navigator.pop(false);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.profileEditTitle), centerTitle: true),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          children: [
            _PhotoSection(
              name: widget.initial.name,
              avatarPath: _avatarPath,
              uploading: _uploadingPhoto,
              hasError: _photoError,
              onTap: _uploadingPhoto ? null : _openPhotoSheet,
            ),
            const SizedBox(height: 24),
            LabeledField(
              label: context.l10n.displayNameLabel,
              badge: context.l10n.requiredBadge,
              isRequired: true,
              child: TextField(
                key: const Key('nameField'),
                controller: _nameController,
                decoration: InputDecoration(hintText: context.l10n.displayNameHint, errorText: _nameError),
              ),
            ),
            const SizedBox(height: 20),
            LabeledField(
              label: context.l10n.nameKanaLabel,
              badge: context.l10n.optionalBadge,
              child: TextField(
                key: const Key('kanaField'),
                controller: _kanaController,
                decoration: InputDecoration(hintText: context.l10n.nameKanaHint, errorText: _kanaError),
              ),
            ),
            const SizedBox(height: 20),
            LabeledField(
              label: context.l10n.emailLabel,
              // Figma: ô khoá nền xám nhạt + icon ổ khoá, chữ vẫn màu chính (đọc được, chỉ không sửa được).
              child: TextFormField(
                // 0057: tài khoản LINE có email nội bộ — hiện「LINEでログイン中」thay cho địa chỉ đó
                initialValue: isLineOnlyEmail(widget.initial.email) ? context.l10n.signedInWithLine : widget.initial.email,
                enabled: false,
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  fillColor: AppColors.chip,
                  helperText: context.l10n.emailNotEditable,
                  suffixIcon: const Icon(Icons.lock_outline, size: 16, color: AppColors.textSecondary),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.chip,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.credentialsChangeOutOfScope,
                      style: const TextStyle(fontSize: 11, height: 1.55, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // "Sticky action" của Figma: nền trắng, viền trên, nút 保存する full chiều ngang (mờ khi chưa đổi gì).
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            minimum: const EdgeInsets.all(16),
            child: FilledButton(
              key: const Key('saveProfileButton'),
              onPressed: _canSave ? _save : null,
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surface),
                    )
                  : Text(context.l10n.saveButton),
            ),
          ),
        ),
      ),
    );
  }
}

enum _PhotoAction { camera, library, delete }

// Khối ảnh trên cùng của SCR-M08: avatar 96 + huy hiệu máy ảnh, nút chữ, dòng gợi ý (hoặc câu lỗi đỏ).
class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.name,
    required this.avatarPath,
    required this.uploading,
    required this.hasError,
    required this.onTap,
  });
  final String name;
  final String? avatarPath;
  final bool uploading;
  final bool hasError;
  final VoidCallback? onTap;

  static const _size = 96.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        GestureDetector(
          key: const Key('profilePhotoAvatar'),
          onTap: onTap,
          child: SizedBox(
            width: _size,
            height: _size,
            child: Stack(
              children: [
                ProfileAvatar(name: name, avatarPath: avatarPath, size: _size),
                if (uploading)
                  Container(
                    width: _size,
                    height: _size,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: Color(0x80000000), shape: BoxShape.circle),
                    child: const CircularProgressIndicator(color: AppColors.surface),
                  ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: const Icon(Icons.photo_camera, size: 15, color: AppColors.surface),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          key: const Key('profilePhotoButton'),
          onPressed: onTap,
          child: Text(
            uploading
                ? l10n.profilePhotoUploading
                : avatarPath == null
                    ? l10n.profilePhotoSet
                    : l10n.profilePhotoChange,
          ),
        ),
        Text(
          hasError ? l10n.errorProfilePhotoUpload : l10n.profilePhotoHint,
          key: const Key('profilePhotoNote'),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, height: 1.5, color: hasError ? AppColors.error : AppColors.textSecondary),
        ),
      ],
    );
  }
}
