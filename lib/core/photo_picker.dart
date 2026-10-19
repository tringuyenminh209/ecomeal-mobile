import 'dart:typed_data';

import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// Ảnh chụp / chọn để tải lên Storage: bằng lái (SCR-D05, bucket driver_licenses) và ảnh món (SCR-S02, batch_photos).
class PickedPhoto {
  const PickedPhoto({required this.bytes, required this.extension});
  final Uint8List bytes;
  final String extension;
}

typedef PhotoPicker = Future<PickedPhoto?> Function(ImageSource source);

// Chọn ảnh thất bại vì đâu (audit S04). image_picker báo bị từ chối quyền bằng PlatformException mã camera_access_denied /
// photo_access_denied (iOS và Android); lỗi khác (đọc file, bộ nhớ…) = không đọc được ảnh. Huỷ chọn không phải lỗi (trả null).
enum PhotoPickProblem { cameraDenied, libraryDenied, failed }

PhotoPickProblem photoPickProblemOf(Object error) => switch (error) {
  PlatformException(code: 'camera_access_denied') => PhotoPickProblem.cameraDenied,
  PlatformException(code: 'photo_access_denied') => PhotoPickProblem.libraryDenied,
  _ => PhotoPickProblem.failed,
};

// 長辺1600px・品質80で十分読める（両バケットの上限5MBに収まる）
const _maxImageSide = 1600.0;
const _imageQuality = 80;

// テストでは差し替える（実機のカメラ／写真ライブラリを使わない）
final photoPickerProvider = Provider<PhotoPicker>((ref) {
  final picker = ImagePicker();
  return (source) async {
    final file = await picker.pickImage(source: source, maxWidth: _maxImageSide, maxHeight: _maxImageSide, imageQuality: _imageQuality);
    if (file == null) return null;
    final name = file.name;
    final dot = name.lastIndexOf('.');
    return PickedPhoto(bytes: await file.readAsBytes(), extension: dot < 0 ? 'jpg' : name.substring(dot + 1).toLowerCase());
  };
});
