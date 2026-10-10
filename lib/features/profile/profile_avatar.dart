import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import 'profile_gateway.dart';
import 'profile_validation.dart';

// UC-35 / API-049 ảnh đại diện: chọn ảnh → cắt vuông ở giữa → 512×512 JPEG → tải lên bucket avatars.

const avatarSide = 512;
const _avatarJpegQuality = 85;
const maxAvatarSourceBytes = 10 * 1024 * 1024; // 06 §SCR-M08: 「JPEG・PNG（10MBまで）」
// Thu nhỏ ngay lúc chọn (image_picker) để không phải giải mã ảnh 12MP trong Dart; 1024 vẫn dư cho 512 sau khi cắt.
const _pickMaxSide = 1024.0;

// Kết quả chọn ảnh: bytes gốc (đã thu nhỏ bởi image_picker). null = người dùng huỷ.
typedef AvatarImagePicker = Future<Uint8List?> Function(ImageSource source);

// Test thay bằng hàm giả (không mở camera / thư viện ảnh thật).
final avatarImagePickerProvider = Provider<AvatarImagePicker>((ref) {
  final picker = ImagePicker();
  return (source) async {
    final file = await picker.pickImage(
      source: source,
      maxWidth: _pickMaxSide,
      maxHeight: _pickMaxSide,
      preferredCameraDevice: CameraDevice.front,
    );
    return file?.readAsBytes();
  };
});

// Giải mã + cắt + mã hoá chạy trong isolate riêng (compute) để UI không giật. null = không phải ảnh đọc được hoặc quá 10MB.
Future<Uint8List?> prepareAvatarJpeg(Uint8List source) {
  if (source.length > maxAvatarSourceBytes) return Future.value(null);
  return compute(squareAvatarJpeg, source);
}

// Widget test thay bằng hàm đồng bộ (isolate của compute không chạy trong FakeAsync của testWidgets).
final avatarJpegPreparerProvider = Provider<Future<Uint8List?> Function(Uint8List)>((ref) => prepareAvatarJpeg);

// Hàm thuần (top-level để chạy được trong compute; test gọi trực tiếp).
Uint8List? squareAvatarJpeg(Uint8List source) {
  final decoded = img.decodeImage(source);
  if (decoded == null) return null;
  // Ảnh chụp bằng điện thoại thường lưu hướng xoay trong EXIF — xoay thật trước khi cắt, không thì ảnh dọc bị nằm ngang.
  final oriented = img.bakeOrientation(decoded);
  final side = oriented.width < oriented.height ? oriented.width : oriented.height;
  final square = img.copyCrop(
    oriented,
    x: (oriented.width - side) ~/ 2,
    y: (oriented.height - side) ~/ 2,
    width: side,
    height: side,
  );
  final resized = img.copyResize(square, width: avatarSide, height: avatarSide, interpolation: img.Interpolation.average);
  return Uint8List.fromList(img.encodeJpg(resized, quality: _avatarJpegQuality));
}

// Avatar tròn dùng chung cho SCR-M07 (48) và SCR-M08 (96). Không có ảnh, đang lấy URL, hoặc tải ảnh lỗi → chữ cái đầu
// của tên trên nền xanh nhạt (giống trước khi có tính năng ảnh).
class ProfileAvatar extends ConsumerWidget {
  const ProfileAvatar({super.key, required this.name, required this.avatarPath, required this.size});
  final String name;
  final String? avatarPath;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initial = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
      child: Text(
        avatarInitialOf(name),
        style: TextStyle(fontSize: size * 0.36, fontWeight: FontWeight.w700, color: AppColors.primary),
      ),
    );
    final path = avatarPath;
    if (path == null) return initial;
    final url = ref.watch(avatarUrlProvider(path)).valueOrNull;
    if (url == null) return initial;
    return ClipOval(
      child: Image.network(
        url,
        key: const Key('profileAvatarImage'),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => initial,
      ),
    );
  }
}
