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

  // Ảnh trong thẻ (cạnh ≤ 96): ảnh quán chụp có cạnh dài tới 1600px — giải mã nguyên cỡ để hiện ô 60〜72px làm khung hình
  // bị khựng khi kéo sheet. Giải mã cạnh dài = 2 × 96 × mật độ điểm ảnh (vẫn đủ nét khi BoxFit.cover cắt ảnh 4:3), và mọi
  // thẻ dùng CÙNG 1 cỡ → cùng khoá cache: đổi bố cục 中↔高 (thẻ 72 ↔ 60) không phải giải mã lại. Ảnh lớn giữ ảnh gốc.
  static const thumbMaxSide = 96.0;

  ImageProvider _provider(BuildContext context, String url) {
    final network = NetworkImage(url);
    final w = width;
    final h = height;
    if (w == null || h == null || w > thumbMaxSide || h > thumbMaxSide) return network;
    final side = (2 * thumbMaxSide * MediaQuery.devicePixelRatioOf(context)).round();
    return ResizeImage(network, width: side, height: side, policy: ResizeImagePolicy.fit);
  }

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
          : Image(
              image: _provider(context, url),
              width: width,
              height: height,
              fit: BoxFit.cover,
              semanticLabel: context.l10n.mealPhotoLabel,
              // Đang tải / đang giải mã → khung xương; xong thì ảnh hiện dần (không "bật" ra). Ảnh đã có trong cache
              // (vd kéo sheet 中↔高 dựng lại thẻ) thì hiện ngay, không chạy lại hiệu ứng.
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedSwitcher(
                  duration: Motion.of(context, Motion.small),
                  child: frame == null
                      ? SkeletonPulse(
                          key: const ValueKey('loading'),
                          child: SkeletonBox(height: height ?? 200, width: width, radius: radius),
                        )
                      : KeyedSubtree(key: const ValueKey('photo'), child: child),
                );
              },
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
