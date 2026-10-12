import 'package:flutter/material.dart';
import '../core/motion.dart';
import '../l10n/l10n.dart';
import 'skeleton.dart';

// Tag Hero cho ảnh món: thẻ ở SCR-M03 → ảnh đầu trang SCR-M04 (Figma "M03 → M04 / Hero"). [scope] phân biệt 2 danh sách
// cùng hiện thẻ của 1 lô (danh sách gần đây / các điểm dừng của xe đang chọn) — 2 Hero trùng tag trong 1 màn là lỗi.
String batchPhotoHeroTag({required String batchId, required String routeStopId, required String scope}) =>
    'batch-photo:$scope:$batchId:$routeStopId';

// Ảnh món của フードバッグ (migration 0038): quán chụp lúc đăng ký (SCR-W03, tuỳ chọn). Không có ảnh, hoặc tải lỗi
// (mất mạng, file bị xoá) → ảnh minh hoạ chung như trước đây — không bao giờ để khung trống / icon vỡ.
// Ảnh thật có nhãn cho trình đọc màn hình; ảnh minh hoạ thì không (chỉ trang trí).
class BatchPhoto extends StatelessWidget {
  const BatchPhoto({super.key, required this.photoUrl, this.width, this.height, this.radius = 16, this.heroTag});

  static const fallbackAsset = 'assets/images/mystery-bag-preview.png';

  final String? photoUrl;
  final double? width;
  final double? height;
  final double radius;
  // Có tag → ảnh "bay" giữa thẻ và màn chi tiết khi chuyển màn (tắt khi "giảm chuyển động")
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    final fallback = Image.asset(
      fallbackAsset,
      width: width,
      height: height,
      fit: BoxFit.cover,
      excludeFromSemantics: true,
    );
    final photo = ClipRRect(
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
                  : SkeletonPulse(
                      child: SkeletonBox(height: height ?? 200, width: width, radius: radius),
                    ),
              errorBuilder: (_, __, ___) => fallback,
            ),
    );
    final tag = heroTag;
    if (tag == null) return photo;
    return HeroMode(
      enabled: !Motion.reduced(context),
      child: Hero(tag: tag, child: photo),
    );
  }
}
