import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/photo_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/yen.dart';
import '../home/home_gateway.dart';
import '../../l10n/l10n.dart';
import '../../widgets/error_banner.dart';
import 'store_gateway.dart';
import '../../core/wide_layout.dart';
import 'sell_by_time_picker.dart';
import 'store_register_logic.dart';

const _maxQty = 99;

// SCR-S02 余剰を登録（概算）— Figma 554:260 / 確認シート 554:388 / アレルゲン28品目シート 568:1325. Đăng ký xong → [onRegistered].
class StoreRegisterPage extends ConsumerStatefulWidget {
  const StoreRegisterPage({super.key, required this.restaurant, required this.onRegistered});
  final StoreRestaurant restaurant;
  final void Function(String batchId) onRegistered;

  @override
  ConsumerState<StoreRegisterPage> createState() => _StoreRegisterPageState();
}

class _StoreRegisterPageState extends ConsumerState<StoreRegisterPage> {
  final _price = TextEditingController();
  PickedPhoto? _photo;
  int _qty = 1;
  bool _tomorrow = false;
  late ({int hour, int minute}) _time = defaultSellByTime(widget.restaurant.closingTime);
  final Set<String> _allergenIds = {};
  // 「アレルゲンは含まれていません」— không chọn món nào thì phải xác nhận rõ (phân biệt "quên chọn" với "không có", 0068)
  bool _noAllergens = false;
  String? _allergenError;
  final List<BatchIngredient> _ingredients = [];
  bool _submitting = false;
  String? _error;
  String? _priceError;
  String? _sellByError;

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _price.clear();
      _photo = null;
      _qty = 1;
      _tomorrow = false;
      _time = defaultSellByTime(widget.restaurant.closingTime);
      _allergenIds.clear();
      _noAllergens = false;
      _ingredients.clear();
      _error = _priceError = _sellByError = _allergenError = null;
    });
  }

  DateTime get _sellByAt =>
      sellByAtJst(now: DateTime.now(), tomorrow: _tomorrow, hour: _time.hour, minute: _time.minute);
  String get _timeLabel => '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickPhoto() async {
    final l10n = context.l10n;
    final source = await showModalBottomSheet<ImageSource?>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const Key('storePhotoCamera'),
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.storePhotoCamera),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              key: const Key('storePhotoLibrary'),
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.storePhotoLibrary),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            if (_photo != null)
              ListTile(
                key: const Key('storePhotoRemove'),
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.storePhotoRemove),
                onTap: () {
                  setState(() => _photo = null);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await ref.read(photoPickerProvider)(source);
    if (picked != null && mounted) setState(() => _photo = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showSellByTimePicker(context, initial: _time, tomorrow: _tomorrow);
    if (picked != null) {
      setState(() {
        _time = picked;
        _sellByError = null;
      });
    }
  }

  Future<void> _addIngredient() async {
    final added = await showDialog<BatchIngredient>(context: context, builder: (_) => const _IngredientDialog());
    if (added != null) setState(() => _ingredients.add(added));
  }

  bool _validate() {
    final l10n = context.l10n;
    final price = int.tryParse(_price.text);
    setState(() {
      _priceError = price == null || price < minUnitPrice ? l10n.storeErrPrice : null;
      _sellByError = _sellByAt.isAfter(DateTime.now()) ? null : l10n.storeErrSellByPast;
      _allergenError = _allergenIds.isEmpty && !_noAllergens ? l10n.storeErrAllergenRequired : null;
    });
    return _priceError == null && _sellByError == null && _allergenError == null;
  }

  Future<void> _review(List<AllergenType> catalog) async {
    if (!_validate()) return;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ConfirmSheet(
        restaurantId: widget.restaurant.id,
        sellByAt: _sellByAt,
        qty: _qty,
        price: int.parse(_price.text),
        sellBy: context.l10n.storeSellByValue(
          _tomorrow ? context.l10n.storeSellByTomorrow : context.l10n.storeSellByToday,
          _timeLabel,
        ),
        allergens: [
          for (final t in catalog)
            if (_allergenIds.contains(t.id)) _allergenName(t),
        ],
        ingredients: _ingredients,
      ),
    );
    if (confirmed == true) await _submit();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final id = await ref
          .read(storeGatewayProvider)
          .registerBatch(
            StoreBatchDraft(
              restaurantId: widget.restaurant.id,
              estimatedQty: _qty,
              unitPrice: int.parse(_price.text),
              sellByAt: _sellByAt,
              allergenTypeIds: _allergenIds.toList(),
              ingredients: List.of(_ingredients),
              noAllergens: _noAllergens,
              photo: _photo,
            ),
          );
      if (!mounted) return;
      _reset();
      widget.onRegistered(id);
    } catch (e) {
      // Lỗi: giữ nguyên mọi ô đã nhập để sửa / gửi lại
      if (mounted) setState(() => _error = registerBatchErrorMessage(e, l10n));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _toggleAllergen(String id) => setState(() {
    _allergenIds.contains(id) ? _allergenIds.remove(id) : _allergenIds.add(id);
    if (_allergenIds.isNotEmpty) _noAllergens = false;
    _allergenError = null;
  });

  String _allergenName(AllergenType t) => Localizations.localeOf(context).languageCode == 'ja' ? t.nameJa : t.nameEn;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final catalog = ref.watch(allergenTypesProvider);
    final sorted = catalog.valueOrNull == null ? null : sortAllergens(catalog.value!);

    Widget label(String text, {bool required = false}) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          if (required) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(color: eco.errorSoft, borderRadius: BorderRadius.circular(4)),
              child: Text(
                l10n.storeRequired,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: eco.error),
              ),
            ),
          ],
        ],
      ),
    );

    final head = <Widget>[
      Text(l10n.storeRegisterTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      Text(l10n.storeRegisterSubtitle, style: TextStyle(fontSize: 12, color: eco.textSecondary)),
      const SizedBox(height: 16),
      if (_error != null) ...[
        ErrorBanner(key: const Key('storeRegisterError'), message: _error!),
        const SizedBox(height: 16),
      ],
      _PhotoField(photo: _photo, onTap: _pickPhoto),
      const SizedBox(height: 8),
      Text(l10n.storePhotoHint, style: TextStyle(fontSize: 12, color: eco.textSecondary)),
    ];
    final reviewButton = FilledButton(
      key: const Key('storeReviewButton'),
      // Danh mục dị ứng chưa tải được thì KHÔNG cho đăng ký: gửi danh sách rỗng như thể "không có dị ứng" chỉ vì lỗi mạng
      onPressed: _submitting || sorted == null ? null : () => _review(sorted),
      child: _submitting
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : Text(l10n.storeReviewButton),
    );
    final fields = <Widget>[
      label(l10n.storeQtyLabel, required: true),
      _Stepper(value: _qty, onChanged: (v) => setState(() => _qty = v)),
      const SizedBox(height: 20),
      label(l10n.storePriceLabel, required: true),
      TextField(
        key: const Key('storePriceField'),
        controller: _price,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
        decoration: InputDecoration(prefixText: '¥ ', errorText: _priceError),
        onChanged: (_) {
          if (_priceError != null) setState(() => _priceError = null);
        },
      ),
      const SizedBox(height: 6),
      Text(l10n.storePriceHint, style: TextStyle(fontSize: 12, color: eco.textSecondary)),
      const SizedBox(height: 20),
      label(l10n.storeSellByLabel, required: true),
      SegmentedButton<bool>(
        key: const Key('storeSellByDay'),
        showSelectedIcon: false,
        segments: [
          ButtonSegment(value: false, label: Text(l10n.storeSellByToday)),
          ButtonSegment(value: true, label: Text(l10n.storeSellByTomorrow)),
        ],
        selected: {_tomorrow},
        onSelectionChanged: (s) => setState(() {
          _tomorrow = s.first;
          _sellByError = null;
        }),
      ),
      const SizedBox(height: 8),
      InkWell(
        key: const Key('storeSellByTime'),
        borderRadius: BorderRadius.circular(12),
        onTap: _pickTime,
        child: InputDecorator(
          decoration: InputDecoration(errorText: _sellByError),
          child: Row(
            children: [
              Expanded(
                child: Text(_timeLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              Text(
                l10n.storeSellByChange,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: eco.primary),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      label(l10n.storeAllergenLabel),
      if (sorted == null)
        catalog.hasError
            ? ErrorBanner(
                message: l10n.storeAllergenLoadFailed,
                retryLabel: l10n.storeReload,
                onRetry: () => ref.invalidate(allergenTypesProvider),
              )
            : const LinearProgressIndicator()
      else ...[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in [for (final code in commonAllergenCodes) ...sorted.where((t) => t.code == code)])
              _AllergenChip(
                label: allergenChipLabel(_allergenName(t)),
                selected: _allergenIds.contains(t.id),
                onTap: () => _toggleAllergen(t.id),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            key: const Key('storeAllergenShowAll'),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => StatefulBuilder(
                builder: (sheetContext, setSheetState) => _AllergenSheet(
                  types: sorted,
                  nameOf: _allergenName,
                  selected: _allergenIds,
                  // Sửa thẳng lựa chọn của form: đóng sheet bằng bất kỳ cách nào cũng giữ (Figma: 閉じても残ります)
                  onToggle: (id) {
                    _toggleAllergen(id);
                    setSheetState(() {});
                  },
                  onClear: () {
                    setState(_allergenIds.clear);
                    setSheetState(() {});
                  },
                ),
              ),
            ),
            child: Text(l10n.storeAllergenShowAll),
          ),
        ),
        const SizedBox(height: 10),
        _NoAllergensBox(
          checked: _noAllergens,
          hasError: _allergenError != null,
          onChanged: (v) => setState(() {
            _noAllergens = v;
            if (v) _allergenIds.clear(); // 2 lựa chọn loại trừ nhau
            _allergenError = null;
          }),
        ),
        if (_allergenError != null) ...[
          const SizedBox(height: 6),
          Text(
            _allergenError!,
            key: const Key('storeAllergenError'),
            style: TextStyle(fontSize: 12, color: eco.error),
          ),
        ],
      ],
      const SizedBox(height: 6),
      Text(
        _allergenIds.isEmpty
            ? l10n.storeAllergenHint
            : '${l10n.storeAllergenSelected(_allergenIds.length)}　${l10n.storeAllergenHint}',
        style: TextStyle(fontSize: 12, color: eco.textSecondary),
      ),
      const SizedBox(height: 20),
      label(l10n.storeIngredientsLabel),
      for (final (i, ing) in _ingredients.indexed)
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.only(left: 14),
          decoration: BoxDecoration(
            color: eco.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: eco.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(ing.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
              Text(ing.origin, style: TextStyle(fontSize: 13, color: eco.textSecondary)),
              IconButton(
                tooltip: l10n.storeIngredientRemove(ing.name),
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => setState(() => _ingredients.removeAt(i)),
              ),
            ],
          ),
        ),
      TextButton(key: const Key('storeIngredientAdd'), onPressed: _addIngredient, child: Text(l10n.storeIngredientAdd)),
    ];

    // iPad ngang (Figma 559:968): ảnh + nút xác nhận bên trái, các ô nhập bên phải (form rộng, không cuộn qua ảnh)
    if (isWideLayout(context)) {
      return Scaffold(
        body: SafeArea(
          child: AbsorbPointer(
            absorbing: _submitting,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 420,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 12, 24),
                    children: [...head, const SizedBox(height: 20), reviewButton],
                  ),
                ),
                Expanded(
                  child: ListView(
                    key: const Key('storeRegisterForm'),
                    padding: const EdgeInsets.fromLTRB(12, 16, 24, 24),
                    children: fields,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _submitting,
          child: ListView(
            key: const Key('storeRegisterForm'),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [...head, const SizedBox(height: 20), ...fields],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 12), child: reviewButton),
      ),
    );
  }
}

class _PhotoField extends StatelessWidget {
  const _PhotoField({required this.photo, required this.onTap});
  final PickedPhoto? photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    final p = photo;
    return Material(
      color: eco.chip,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: const Key('storePhotoField'),
        onTap: onTap,
        child: SizedBox(
          height: 200,
          width: double.infinity,
          child: p == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_camera_outlined, size: 36, color: eco.primary),
                    const SizedBox(height: 8),
                    Text(
                      l10n.storePhotoTake,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: eco.primary),
                    ),
                  ],
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(p.bytes, fit: BoxFit.cover, semanticLabel: l10n.storePhotoTake),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo_camera_outlined, size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              l10n.storePhotoRetake,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// Nút −/+ to (thao tác trong bếp, tay ướt / đeo găng — proposal §4)
class _Stepper extends StatelessWidget {
  const _Stepper({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    Widget button(IconData icon, String tooltip, Key key, int? next) => IconButton.filledTonal(
      key: key,
      tooltip: tooltip,
      iconSize: 28,
      style: IconButton.styleFrom(
        backgroundColor: eco.primarySoft,
        foregroundColor: eco.primary,
        minimumSize: const Size(52, 52),
      ),
      onPressed: next == null ? null : () => onChanged(next),
      icon: Icon(icon),
    );
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: eco.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: eco.border),
      ),
      child: Row(
        children: [
          button(Icons.remove, l10n.storeQtyDecrease, const Key('storeQtyMinus'), value > 1 ? value - 1 : null),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$value',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: ' ${l10n.storeQtyUnit}',
                    style: TextStyle(fontSize: 14, color: eco.textSecondary),
                  ),
                ],
              ),
              key: const Key('storeQtyValue'),
              textAlign: TextAlign.center,
            ),
          ),
          button(Icons.add, l10n.storeQtyIncrease, const Key('storeQtyPlus'), value < _maxQty ? value + 1 : null),
        ],
      ),
    );
  }
}

class _AllergenChip extends StatelessWidget {
  const _AllergenChip({super.key, required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final eco = context.eco;
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: true,
      checkmarkColor: eco.surface,
      selectedColor: eco.primary,
      labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? eco.surface : eco.textPrimary),
      shape: StadiumBorder(side: BorderSide(color: selected ? eco.primary : eco.border)),
      backgroundColor: eco.surface,
      onSelected: (_) => onTap(),
    );
  }
}

// Sheet 28 品目 (568:1325): 表示義務 8 / 表示推奨 20, theo thứ tự seed
class _AllergenSheet extends StatelessWidget {
  const _AllergenSheet({
    required this.types,
    required this.nameOf,
    required this.selected,
    required this.onToggle,
    required this.onClear,
  });
  final List<AllergenType> types;
  final String Function(AllergenType) nameOf;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eco = context.eco;
    bool isMandatory(AllergenType t) {
      final i = allergenCodeOrder.indexOf(t.code);
      return i >= 0 && i < mandatoryAllergenCount;
    }

    final mandatory = types.where(isMandatory).toList();
    final others = types.where((t) => !mandatory.contains(t)).toList();
    Widget group(String title, List<AllergenType> items) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: eco.textSecondary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in items)
              _AllergenChip(
                key: Key('allergen-${t.code}'),
                label: nameOf(t),
                selected: selected.contains(t.id),
                onTap: () => onToggle(t.id),
              ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.storeAllergenLabel,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  l10n.storeAllergenSelected(selected.length),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: eco.primary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(l10n.storeAllergenSheetNote, style: TextStyle(fontSize: 13, color: eco.textSecondary)),
            const SizedBox(height: 16),
            group(l10n.storeAllergenMandatory, mandatory),
            group(l10n.storeAllergenRecommended, others),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('storeAllergenClear'),
                    onPressed: onClear,
                    child: Text(l10n.storeAllergenClear),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    key: const Key('storeAllergenDone'),
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.storeAllergenDone(selected.length)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientDialog extends StatefulWidget {
  const _IngredientDialog();

  @override
  State<_IngredientDialog> createState() => _IngredientDialogState();
}

class _IngredientDialogState extends State<_IngredientDialog> {
  final _name = TextEditingController();
  final _origin = TextEditingController();
  String? _nameError;

  @override
  void dispose() {
    _name.dispose();
    _origin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.storeIngredientsLabel),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('storeIngredientName'),
            controller: _name,
            autofocus: true,
            maxLength: 50,
            decoration: InputDecoration(labelText: l10n.storeIngredientName, errorText: _nameError),
          ),
          TextField(
            key: const Key('storeIngredientOrigin'),
            controller: _origin,
            maxLength: 50,
            decoration: InputDecoration(
              labelText: l10n.storeIngredientOrigin,
              hintText: l10n.storeIngredientOriginHint,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.storeCancel)),
        FilledButton(
          key: const Key('storeIngredientSave'),
          onPressed: () {
            final name = _name.text.trim();
            if (name.isEmpty) {
              setState(() => _nameError = l10n.storeErrIngredientName);
              return;
            }
            Navigator.pop(context, BatchIngredient(name: name, origin: _origin.text.trim()));
          },
          child: Text(l10n.storeAdd),
        ),
      ],
    );
  }
}

// Sheet xác nhận (554:388)
// Giá khách thấy ngay lúc này cho bước xác nhận S02 — gọi calc_current_price qua HomeGateway (cùng hàm app khách dùng;
// app không tự tính giá, BR-008). Tách thành provider để test thay được.
final storePricePreviewProvider = FutureProvider.autoDispose.family<int, ({int unitPrice, DateTime sellByAt})>(
  (ref, k) async =>
      (await ref.watch(homeGatewayProvider).calcCurrentPrice(unitPrice: k.unitPrice, expiresAt: k.sellByAt)).currentPrice,
);

class _ConfirmSheet extends ConsumerWidget {
  const _ConfirmSheet({
    required this.restaurantId,
    required this.sellByAt,
    required this.qty,
    required this.price,
    required this.sellBy,
    required this.allergens,
    required this.ingredients,
  });
  final String restaurantId;
  final DateTime sellByAt;
  final int qty;
  final int price;
  final String sellBy;
  final List<String> allergens;
  final List<BatchIngredient> ingredients;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final eco = context.eco;
    String ingredientLabel(BatchIngredient i) => i.origin.isEmpty ? i.name : '${i.name}（${i.origin}）';
    final ingredientsText = ingredients.isEmpty
        ? l10n.storeConfirmNone
        : ingredients.length == 1
        ? ingredientLabel(ingredients.first)
        : l10n.storeConfirmIngredientsMore(ingredientLabel(ingredients.first), ingredients.length - 1);
    final rows = [
      (l10n.storeConfirmQty, l10n.storeConfirmQtyValue(qty)),
      (l10n.storePriceLabel, formatYen(price)),
      (l10n.storeSellByLabel, sellBy),
      (l10n.storeConfirmAllergens, allergens.isEmpty ? l10n.storeConfirmNone : allergens.join('・')),
      (l10n.storeConfirmIngredients, ingredientsText),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.storeConfirmTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            for (final (k, v) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(k, style: TextStyle(fontSize: 13, color: eco.textSecondary)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        v,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            _PreviewBlock(restaurantId: restaurantId, qty: qty, price: price, sellByAt: sellByAt),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: eco.primarySoft, borderRadius: BorderRadius.circular(12)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18, color: eco.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l10n.storeConfirmNote, style: const TextStyle(fontSize: 13, height: 1.5))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('storeConfirmSubmit'),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.storeConfirmSubmit),
            ),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.storeConfirmBack)),
          ],
        ),
      ),
    );
  }
}

// Ô xác nhận 「アレルゲンは含まれていません」 (Figma SCR-S02 Checkbox/アレルゲンなし; viền đỏ khi thiếu lựa chọn)
class _NoAllergensBox extends StatelessWidget {
  const _NoAllergensBox({required this.checked, required this.hasError, required this.onChanged});
  final bool checked;
  final bool hasError;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final eco = context.eco;
    return Material(
      color: eco.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: hasError ? eco.error : eco.border, width: hasError ? 1.5 : 1),
      ),
      child: CheckboxListTile(
        key: const Key('storeNoAllergens'),
        value: checked,
        onChanged: (v) => onChanged(v ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: Text(context.l10n.storeNoAllergens, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// Bước xác nhận S02 (2026-10-12, giống cột phải của Web W03): khách sẽ thấy gì, giá lúc này và phần của quán ước tính.
// Lỗi tính giá không chặn việc đăng — chỉ báo không tính được.
class _PreviewBlock extends ConsumerWidget {
  const _PreviewBlock({required this.restaurantId, required this.qty, required this.price, required this.sellByAt});
  final String restaurantId;
  final int qty;
  final int price;
  final DateTime sellByAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final eco = context.eco;
    final preview = ref.watch(storePricePreviewProvider((unitPrice: price, sellByAt: sellByAt)));
    final share = ref.watch(storeMonthRevenueProvider(restaurantId)).valueOrNull?.sharePct;
    final now = preview.valueOrNull;
    return Container(
      key: const Key('storeConfirmPreview'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: eco.surface,
        border: Border.all(color: eco.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.storeConfirmPreviewTitle, style: TextStyle(fontSize: 12, color: eco.textSecondary)),
          const SizedBox(height: 6),
          Text(l10n.partnerStore, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: eco.primary)),
          Text(l10n.mysteryBag, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          if (preview.isLoading)
            const LinearProgressIndicator()
          else if (now == null)
            Text(l10n.storeConfirmPreviewFailed, style: TextStyle(fontSize: 12, color: eco.textSecondary))
          else ...[
            Text(
              l10n.storeConfirmPreviewPrice(formatYen(now)),
              key: const Key('storeConfirmPreviewPrice'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(l10n.storeConfirmPreviewPriceNote, style: TextStyle(fontSize: 12, color: eco.textSecondary)),
            if (share != null) ...[
              const Divider(height: 20),
              Row(
                children: [
                  Expanded(child: Text(l10n.storeConfirmEstimate, style: const TextStyle(fontSize: 13))),
                  Text(
                    l10n.storeConfirmEstimateValue(formatYen(estimatedStoreShare(qty: qty, price: now, sharePct: share))),
                    key: const Key('storeConfirmEstimate'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: eco.primary),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                l10n.storeConfirmEstimateNote(formatSharePct(share)),
                style: TextStyle(fontSize: 12, color: eco.textSecondary),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
