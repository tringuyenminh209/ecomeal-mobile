import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_brightness/screen_brightness.dart';

// Độ sáng màn hình khi hiện QR nhận hàng (SCR-M18): tài xế quét nhanh hơn ngoài trời tối, kể cả khi khách để máy tối.
// Chỉ đổi độ sáng của app (không đổi cài đặt máy); rời khối QR thì trả lại như cũ. Lỗi (web, máy không hỗ trợ) → bỏ qua:
// độ sáng không được làm hỏng màn nhận hàng. Test thay bằng bản giả (plugin cần platform channel).
abstract class ScreenBrightnessControl {
  Future<void> raise();
  Future<void> restore();
}

class PluginScreenBrightness implements ScreenBrightnessControl {
  const PluginScreenBrightness();

  @override
  Future<void> raise() async {
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(1.0);
    } catch (_) {}
  }

  @override
  Future<void> restore() async {
    try {
      await ScreenBrightness.instance.resetApplicationScreenBrightness();
    } catch (_) {}
  }
}

final screenBrightnessProvider = Provider<ScreenBrightnessControl>((ref) => const PluginScreenBrightness());

// Bọc khối QR: hiện ra → sáng tối đa; biến mất (đã nhận xong, rời màn) → trả lại độ sáng cũ.
class MaxBrightness extends ConsumerStatefulWidget {
  const MaxBrightness({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<MaxBrightness> createState() => _MaxBrightnessState();
}

class _MaxBrightnessState extends ConsumerState<MaxBrightness> {
  // Giữ lại ở initState: không dùng ref trong dispose
  late final ScreenBrightnessControl _control = ref.read(screenBrightnessProvider);

  @override
  void initState() {
    super.initState();
    _control.raise();
  }

  @override
  void dispose() {
    _control.restore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
