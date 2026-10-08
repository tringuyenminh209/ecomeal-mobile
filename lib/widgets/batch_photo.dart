import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import 'skeleton.dart';

// Ảnh món của フードバッグ (migration 0038): quán chụp lúc đăng ký (SCR-W03, tuỳ chọn). Không có ảnh, hoặc tải lỗi
// (mất mạng, file bị xoá) → ảnh minh hoạ chung như trước đây — không bao giờ để khung trống / icon vỡ.
// Ảnh thật có nhãn cho trình đọc màn hình; ảnh minh hoạ thì không (chỉ trang trí).
class BatchPhoto extends StatelessWidget {
  const BatchPhoto({super.key, required this.photoUrl, this.width, this.height, this.radius = 16});

  static const fallbackAsset = 'assets/images/mystery-bag-preview.png';

  final String? photoUrl;
  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    final fallback = Image.asset(fallbackAsset, width: width, height: height, fit: BoxFit.cover, excludeFromSemantics: true);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url == null
          ? fallback
          : Image.network(
              url,
              width: width,
              height: height,
              fit: BoxFit.cover,
              semanticLabel: context.l10n.mealPhotoLabel,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : SkeletonPulse(child: SkeletonBox(height: height ?? 200, width: width, radius: radius)),
              errorBuilder: (_, __, ___) => fallback,
            ),
    );
  }
}
