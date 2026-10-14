import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/wide_layout.dart';
import '../../l10n/l10n.dart';
import 'store_register_logic.dart';

typedef SellByTime = ({int hour, int minute});

// Giờ hay dùng (Figma 871:4434 "Quick presets") — giờ đóng cửa phổ biến của quán đối tác
const sellByTimePresets = <SellByTime>[
  (hour: 20, minute: 0),
  (hour: 20, minute: 30),
  (hour: 21, minute: 0),
  (hour: 21, minute: 30),
];

// SCR-S02 「販売の終了時刻」(Figma section 26, 871:4434): iPhone = sheet từ dưới lên, iPad = hộp 460 ở giữa.
// Nhập giờ / phút bằng bàn phím số (tự do từng phút) hoặc chọn giờ hay dùng. Ngày (本日/翌日) lấy từ form.
// Trả null khi キャンセル hoặc chạm ra ngoài — giờ cũ trên form giữ nguyên.
Future<SellByTime?> showSellByTimePicker(BuildContext context, {required SellByTime initial, required bool tomorrow}) {
  const barrier = Color(0x59141F17);
  final panel = _SellByTimePanel(initial: initial, tomorrow: tomorrow);
  if (isWideLayout(context)) {
    return showDialog<SellByTime>(
      context: context,
      barrierColor: barrier,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 460), child: panel),
      ),
    );
  }
  return showModalBottomSheet<SellByTime>(
    context: context,
    isScrollControlled: true,
    barrierColor: barrier,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    // Bàn phím số mở lên thì đẩy sheet lên theo
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(top: false, child: panel),
    ),
  );
}

class _SellByTimePanel extends StatefulWidget {
  const _SellByTimePanel({required this.initial, required this.tomorrow});
  final SellByTime initial;
  final bool tomorrow;

  @override
  State<_SellByTimePanel> createState() => _SellByTimePanelState();
}

class _SellByTimePanelState extends State<_SellByTimePanel> {
  late final _hour = TextEditingController(text: _two(widget.initial.hour));
  late final _minute = TextEditingController(text: _two(widget.initial.minute));
  final _hourFocus = FocusNode();
  final _minuteFocus = FocusNode();
  String? _error;

  static String _two(int v) => v.toString().padLeft(2, '0');

  @override
  void initState() {
    super.initState();
    // Viền xanh theo ô đang nhập (Figma: ô 分 đang chọn)
    _hourFocus.addListener(_rebuild);
    _minuteFocus.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _hour.dispose();
    _minute.dispose();
    _hourFocus.dispose();
    _minuteFocus.dispose();
    super.dispose();
  }

  // null = ô trống hoặc ngoài 00–23 / 00–59
  SellByTime? get _value {
    final h = int.tryParse(_hour.text);
    final m = int.tryParse(_minute.text);
    if (h == null || m == null || h > 23 || m > 59) return null;
    return (hour: h, minute: m);
  }

  void _pickPreset(SellByTime t) {
    FocusScope.of(context).unfocus();
    setState(() {
      _hour.text = _two(t.hour);
      _minute.text = _two(t.minute);
      _error = null;
    });
  }

  void _confirm() {
    final l10n = context.l10n;
    final t = _value;
    if (t == null) {
      setState(() => _error = l10n.storeTimeInvalid);
      return;
    }
    final at = sellByAtJst(now: DateTime.now(), tomorrow: widget.tomorrow, hour: t.hour, minute: t.minute);
    if (!at.isAfter(DateTime.now())) {
      setState(() => _error = l10n.storeErrSellByPast);
      return;
    }
    Navigator.of(context).pop(t);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const secondary = TextStyle(fontSize: 12, height: 1.5, color: AppColors.textSecondary);
    final current = _value;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.storeTimeTitle,
            style: const TextStyle(
              fontSize: 20,
              height: 1.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(l10n.storeTimeHint, style: secondary),
          const SizedBox(height: 20),
          Text(l10n.storeTimeDayNote, style: secondary.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _NumberField(
                  key: const Key('sellByHour'),
                  label: l10n.storeTimeHour,
                  controller: _hour,
                  focusNode: _hourFocus,
                  autofocus: true,
                  onChanged: (v) {
                    setState(() => _error = null);
                    // Đủ 2 số giờ → sang ô phút
                    if (v.length == 2) _minuteFocus.requestFocus();
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 12, 20),
                child: Text(
                  ':',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                ),
              ),
              Expanded(
                child: _NumberField(
                  key: const Key('sellByMinute'),
                  label: l10n.storeTimeMinute,
                  controller: _minute,
                  focusNode: _minuteFocus,
                  onChanged: (_) => setState(() => _error = null),
                  onSubmitted: _confirm,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_error != null)
            Text(
              _error!,
              style: secondary.copyWith(color: AppColors.error, fontWeight: FontWeight.w700),
            )
          else
            Text(l10n.storeTime24h, style: secondary),
          const SizedBox(height: 20),
          Text(l10n.storeTimePresets, style: secondary.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final (i, t) in sellByTimePresets.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _PresetButton(
                    label: '${_two(t.hour)}:${_two(t.minute)}',
                    selected: current == t,
                    onTap: () => _pickPreset(t),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 52,
                child: OutlinedButton(
                  key: const Key('sellByCancel'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.storeCancel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: FilledButton(
                    key: const Key('sellByConfirm'),
                    onPressed: _confirm,
                    child: Text(l10n.storeTimeConfirm),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    super.key,
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final focused = focusNode.hasFocus;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: focused ? AppColors.primary : AppColors.border, width: focused ? 2 : 1),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            height: 1.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          textInputAction: onSubmitted == null ? TextInputAction.next : TextInputAction.done,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
          // Chạm vào ô → chọn hết, gõ đè luôn (không phải xoá trước)
          onTap: () => controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length),
          onChanged: onChanged,
          onSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
          style: TextStyle(
            fontSize: 40,
            height: 1.5,
            fontWeight: FontWeight.w700,
            color: focused ? AppColors.primary : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            counterText: '',
            enabledBorder: border,
            focusedBorder: border,
          ),
        ),
      ],
    );
  }
}

class _PresetButton extends StatelessWidget {
  const _PresetButton({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: Key('sellByPreset_$label'),
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.surface : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
