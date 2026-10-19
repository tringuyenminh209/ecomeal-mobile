import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import 'order_gateway.dart';
import 'order_helpers.dart';

// UC-42 受け取り後の評価 (0054, API-069). Figma「M17 受け取り後の評価」: thẻ đơn đã nhận có ô「フードバッグはいかがでしたか？」
// (463:5600) → chạm sao mở bảng đánh giá (463:5820) → gửi xong thẻ hiện「あなたの評価 ★★★★☆」(463:5710).
// Quán chỉ thấy số sao + câu nhận xét, không thấy tên khách.

const ratingCommentMaxLength = 200;

String ratingLabel(int rating, AppLocalizations l10n) => switch (rating) {
      1 => l10n.ratingLabel1,
      2 => l10n.ratingLabel2,
      3 => l10n.ratingLabel3,
      4 => l10n.ratingLabel4,
      _ => l10n.ratingLabel5,
    };

// Câu lỗi khi gửi: hết 7 ngày / đã đánh giá (máy khác) / còn lại
String ratingErrorMessage(Object error, AppLocalizations l10n) {
  final message = error is PostgrestException ? error.message : '';
  if (message.contains('E-RATING-410')) return l10n.ratingErrorExpired;
  if (message.contains('E-RATING-409')) return l10n.ratingErrorAlreadyRated;
  return l10n.ratingErrorFailed;
}

// Vùng bấm tối thiểu của 1 sao (iPhone 44pt, audit C06 / Figma 972:21139)
const _starTapSize = 44.0;

class _Stars extends StatelessWidget {
  const _Stars({required this.value, required this.size, this.onTap, this.spacing = 2});
  final int value;
  final double size;
  final double spacing;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Sao bấm được: mỗi sao nằm giữa ô ≥ 44pt; khoảng cách tính từ mép ô sao cho tâm 2 sao cách nhau ≥ 44
    // (sao 28 + cách 8 → ô 44 sát nhau; sao 40 + cách 10 → giữ đúng 50)
    final box = onTap == null ? size : (size > _starTapSize ? size : _starTapSize);
    final gap = onTap == null ? spacing : ((spacing + size - box) > 0 ? spacing + size - box : 0.0);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Padding(
            padding: EdgeInsets.only(right: i < 5 ? gap : 0),
            child: onTap == null
                ? Icon(i <= value ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: size, color: i <= value ? AppColors.amber : AppColors.textSecondary)
                : Semantics(
                    button: true,
                    selected: i == value,
                    label: l10n.ratingStarSemantics(i),
                    child: InkResponse(
                      key: Key('ratingStar$i'),
                      radius: size * 0.7,
                      onTap: () => onTap!(i),
                      child: SizedBox.square(
                        dimension: box,
                        child: Icon(i <= value ? Icons.star_rounded : Icons.star_outline_rounded,
                            size: size, color: i <= value ? AppColors.amber : AppColors.textSecondary),
                      ),
                    ),
                  ),
          ),
      ],
    );
  }
}

// Ô mời đánh giá trong thẻ đơn (nền vàng nhạt). Chạm sao thứ n → mở bảng với n sao đã chọn.
class RatingPrompt extends StatelessWidget {
  const RatingPrompt({super.key, required this.order, required this.onRated});
  final OrderSummary order;
  final VoidCallback onRated;

  Future<void> _open(BuildContext context, int initial) async {
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => RatingSheet(order: order, initialRating: initial),
    );
    if (sent == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.ratingSent)));
      onRated();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      key: const Key('ratingPrompt'),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(color: AppColors.amberSoft, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.ratingPromptTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          // Ô sao cao 44 (sao 28) đã gồm khoảng cách trên/dưới 8 như trước
          _Stars(value: 0, size: 28, spacing: 8, onTap: (n) => _open(context, n)),
          Text(l10n.ratingPromptHint, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// Đã đánh giá: 「あなたの評価 ★★★★☆ ありがとうございました」
class RatedNote extends StatelessWidget {
  const RatedNote({super.key, required this.rating});
  final int rating;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      key: const Key('ratedNote'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.chip, borderRadius: BorderRadius.circular(10)),
      child: Semantics(
        label: l10n.ratedSemantics(rating),
        excludeSemantics: true,
        child: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(l10n.ratedLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            _Stars(value: rating, size: 16),
            Text(l10n.ratedThanks, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class RatingSheet extends ConsumerStatefulWidget {
  const RatingSheet({super.key, required this.order, required this.initialRating});
  final OrderSummary order;
  final int initialRating;

  @override
  ConsumerState<RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends ConsumerState<RatingSheet> {
  late int _rating = widget.initialRating;
  final _comment = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final comment = _comment.text.trim();
      await ref.read(orderGatewayProvider).rateOrder(
            orderId: widget.order.id,
            rating: _rating,
            comment: comment.isEmpty ? null : comment,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => _error = ratingErrorMessage(e, l10n));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final order = widget.order;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.ratingPromptTitle, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              l10n.ratingSheetOrder(orderDisplayNumber(order.id), orderTimeLabel(order.plannedPickupTime, l10n)),
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            _Stars(value: _rating, size: 40, spacing: 10, onTap: _sending ? null : (n) => setState(() => _rating = n)),
            const SizedBox(height: 8),
            Text(ratingLabel(_rating, l10n),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.amberInk)),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(l10n.ratingCommentLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 6),
            TextField(
              key: const Key('ratingComment'),
              controller: _comment,
              enabled: !_sending,
              maxLines: 3,
              maxLength: ratingCommentMaxLength,
              decoration: InputDecoration(hintText: l10n.ratingCommentHint),
            ),
            Text(l10n.ratingPrivacyNote, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, key: const Key('ratingError'), style: const TextStyle(fontSize: 12, color: AppColors.error)),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('submitRatingButton'),
                onPressed: _sending ? null : _submit,
                child: _sending
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.ratingSubmit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
