import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../l10n/l10n.dart';

// Chọn ngôn ngữ (Figma 1000:1833 / sheet 1003:1920, 2026-10-20): ở mọi màn chỉ là 1 hàng / 1 nút hiện ngôn ngữ đang dùng,
// bấm vào thì mở bảng chọn từ dưới lên. Thêm ngôn ngữ không làm đổi màn nào — danh sách lấy từ
// AppLocalizations.supportedLocales (có file ARB là có ngôn ngữ), cần thêm tên ở [_endonyms] và [languageNameIn].

// Tên ngôn ngữ viết bằng chính ngôn ngữ đó — không dịch (người đọc nhận ra ngôn ngữ của mình)
const _endonyms = {'ja': '日本語', 'en': 'English'};

// Từ ngần này ngôn ngữ trở lên thì có ô tìm phía trên danh sách
const languageSearchThreshold = 9;

String languageEndonym(String code) => _endonyms[code] ?? code;

// Tên ngôn ngữ bằng ngôn ngữ đang dùng (dòng dưới trong bảng chọn): 日本語 UI → 「英語」, English UI → "Japanese"
String languageNameIn(AppLocalizations l10n, String code) => switch (code) {
  'ja' => l10n.languageNameJa,
  'en' => l10n.languageNameEn,
  _ => code,
};

// Ngôn ngữ chọn sẵn ở SCR-M01 khi chưa từng chọn: ngôn ngữ của máy nếu app có, không thì English
Locale defaultLocaleFor(Locale device, List<Locale> supported) =>
    supported.any((l) => l.languageCode == device.languageCode) ? Locale(device.languageCode) : const Locale('en');

// Ô tìm: khớp tên viết bằng ngôn ngữ đó hoặc tên bằng ngôn ngữ đang dùng, không phân biệt hoa thường
List<String> filterLanguages(List<String> codes, String query, String Function(String code) localName) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return codes;
  return [
    for (final c in codes)
      if (languageEndonym(c).toLowerCase().contains(q) || localName(c).toLowerCase().contains(q) || c.contains(q)) c,
  ];
}

// Mở bảng chọn; trả về mã ngôn ngữ vừa chọn (null: đóng mà không chọn, hoặc chọn lại ngôn ngữ đang dùng)
Future<String?> showLanguageSheet(BuildContext context, {required String current}) async {
  final picked = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: context.eco.surface,
    builder: (_) => _LanguageSheet(current: current),
  );
  return picked == current ? null : picked;
}

class _LanguageSheet extends StatefulWidget {
  const _LanguageSheet({required this.current});
  final String current;

  @override
  State<_LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<_LanguageSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final all = [for (final l in AppLocalizations.supportedLocales) l.languageCode];
    final codes = filterLanguages(all, _query, (c) => languageNameIn(l10n, c));
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.languageLabel, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            if (all.length >= languageSearchThreshold) ...[
              const SizedBox(height: 12),
              TextField(
                key: const Key('languageSearch'),
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.languageSearchHint, isDense: true),
              ),
            ],
            const SizedBox(height: 8),
            // Nhiều ngôn ngữ thì cuộn, tối đa 60% chiều cao màn hình
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.6),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final (i, code) in codes.indexed)
                    _LanguageOptionTile(
                      code: code,
                      localName: languageNameIn(l10n, code),
                      selected: code == widget.current,
                      divider: i < codes.length - 1,
                      onTap: () => Navigator.of(context).pop(code),
                      eco: eco,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.code,
    required this.localName,
    required this.selected,
    required this.divider,
    required this.onTap,
    required this.eco,
  });
  final String code;
  final String localName;
  final bool selected;
  final bool divider;
  final VoidCallback onTap;
  final EcoPalette eco;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        key: Key('languageOption_$code'),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          decoration: BoxDecoration(border: divider ? Border(bottom: BorderSide(color: eco.border)) : null),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageEndonym(code),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: selected ? eco.primary : eco.textPrimary),
                    ),
                    Text(localName, style: TextStyle(fontSize: 12, color: eco.textSecondary)),
                  ],
                ),
              ),
              if (selected) Icon(Icons.check, color: eco.primary),
            ],
          ),
        ),
      ),
    );
  }
}

// Hàng 「🌐 言語 / Language ・ ngôn ngữ đang dùng ›」 — SCR-M07 (inline: false, tên ngôn ngữ ở dòng dưới như các hàng
// khác) và SCR-M01 (inline: true, tên ngôn ngữ ở bên phải)
class LanguageRow extends StatelessWidget {
  const LanguageRow({super.key, required this.current, required this.onTap, this.inline = false});
  final String current;
  final VoidCallback? onTap;
  final bool inline;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final title = Text(l10n.languageLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700));
    final value = Text(languageEndonym(current), style: TextStyle(fontSize: inline ? 14 : 11, color: eco.textSecondary));
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: eco.surface,
          border: Border.all(color: eco.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.language, size: 20, color: eco.primary),
            const SizedBox(width: 12),
            Expanded(
              child: inline
                  ? title
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [title, const SizedBox(height: 3), value]),
            ),
            if (inline) ...[value, const SizedBox(width: 4)],
            Icon(Icons.chevron_right, color: eco.textSecondary),
          ],
        ),
      ),
    );
  }
}

// Nút nhỏ 「🌐 ngôn ngữ đang dùng ⌄」 ở góc màn đăng nhập của app quán / tài xế / vận hành (SCR-D00)
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key, required this.current, required this.onPressed});
  final String current;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final eco = context.eco;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: eco.textPrimary,
        side: BorderSide(color: eco.border),
        shape: const StadiumBorder(),
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.only(left: 12, right: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.language, size: 16),
          const SizedBox(width: 6),
          Text(languageEndonym(current), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const Icon(Icons.expand_more, size: 18),
        ],
      ),
    );
  }
}
