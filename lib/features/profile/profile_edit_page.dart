import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/labeled_field.dart';
import 'profile_gateway.dart';
import 'profile_validation.dart';

// SCR-M08 プロフィール編集 — 06_画面設計 §SCR-M08, khớp frame Figma 91:804 (thường) / 91:850 (Error) /
// 91:896 (Loading) / 91:942 (変更破棄確認). Không có Bottom Navigation (06: tránh rời màn hình khi đang sửa).
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
                initialValue: widget.initial.email,
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
