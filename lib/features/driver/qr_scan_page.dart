import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' show Geolocator;
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/haptics.dart';
import '../../l10n/l10n.dart';

// Kết quả đặc biệt của màn quét: tài xế chọn 「コードを手動で入力」 vì camera không dùng được (không phải ID đơn).
const qrManualEntry = '\u0000manual-entry';

// Camera không dùng được (bị từ chối quyền, app khác đang dùng…): cách sửa + mã 4 ký tự thay QR (audit D05).
class CameraUnavailablePanel extends StatelessWidget {
  const CameraUnavailablePanel({super.key, required this.onManualEntry});
  final VoidCallback onManualEntry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.cameraUnavailableTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.cameraUnavailableBody,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 20),
              FilledButton(
                key: const Key('cameraOpenSettings'),
                onPressed: Geolocator.openAppSettings, // trang Cài đặt của app (quyền camera nằm ở đó)
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: Text(l10n.openSettings),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                key: const Key('cameraManualEntry'),
                onPressed: onManualEntry,
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), foregroundColor: Colors.white),
                child: Text(l10n.enterCodeManually),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Màn camera quét QR của khách (SCR-M06 mã hoá nguyên văn orders.id, Chương 17). Trả về chuỗi đọc được.
// Tài xế quét ở điểm bán buổi tối: khung ngắm + câu hướng dẫn cho biết đặt mã ở đâu, nút đèn pin cho chỗ tối,
// rung khi đọc được để không phải nhìn màn hình xác nhận.
class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final _controller = MobileScannerController();
  bool _done = false; // onDetect bắn liên tục nhiều khung hình — chỉ pop 1 lần

  static const _windowSize = 260.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final value = capture.barcodes.isEmpty ? null : capture.barcodes.first.rawValue;
    if (_done || value == null) return;
    _done = true;
    Haptics.success();
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.scanPickupQr),
        actions: [
          // Đèn pin: chỉ hiện khi máy có đèn (TorchState.unavailable → ẩn)
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              if (state.torchState == TorchState.unavailable) return const SizedBox.shrink();
              final isOn = state.torchState == TorchState.on;
              return IconButton(
                tooltip: isOn ? l10n.torchOff : l10n.torchOn,
                isSelected: isOn,
                icon: const Icon(Icons.flashlight_off_outlined),
                selectedIcon: const Icon(Icons.flashlight_on),
                onPressed: _controller.toggleTorch,
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final window = Rect.fromCenter(
            center: constraints.biggest.center(Offset.zero),
            width: _windowSize,
            height: _windowSize,
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: _controller,
                scanWindow: window,
                onDetect: _onDetect,
                // Audit D05 (Figma 963:2136): camera bị từ chối / đang bận → nói cách sửa + lối nhập mã tay
                errorBuilder: (context, _) =>
                    CameraUnavailablePanel(onManualEntry: () => Navigator.of(context).pop(qrManualEntry)),
              ),
              // Phủ tối ngoài khung + 4 góc khung + câu hướng dẫn: chỉ khi camera chạy
              ValueListenableBuilder<MobileScannerState>(
                valueListenable: _controller,
                builder: (context, state, _) => state.error != null
                    ? const SizedBox.shrink()
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          IgnorePointer(child: CustomPaint(painter: _ScanWindowPainter(window))),
                          Positioned(
                            left: 24,
                            right: 24,
                            top: window.bottom + 24,
                            child: Text(
                              l10n.scanPickupQrHint,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ScanWindowPainter extends CustomPainter {
  _ScanWindowPainter(this.window);
  final Rect window;

  @override
  void paint(Canvas canvas, Size size) {
    final frame = RRect.fromRectAndRadius(window, const Radius.circular(16));
    final dim = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(frame);
    canvas.drawPath(dim, Paint()..color = Colors.black.withValues(alpha: 0.55));

    const arm = 28.0;
    final corner = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final l = window.left, t = window.top, r = window.right, b = window.bottom;
    for (final path in [
      Path()..moveTo(l, t + arm)..lineTo(l, t + 8)..quadraticBezierTo(l, t, l + 8, t)..lineTo(l + arm, t),
      Path()..moveTo(r - arm, t)..lineTo(r - 8, t)..quadraticBezierTo(r, t, r, t + 8)..lineTo(r, t + arm),
      Path()..moveTo(r, b - arm)..lineTo(r, b - 8)..quadraticBezierTo(r, b, r - 8, b)..lineTo(r - arm, b),
      Path()..moveTo(l + arm, b)..lineTo(l + 8, b)..quadraticBezierTo(l, b, l, b - 8)..lineTo(l, b - arm),
    ]) {
      canvas.drawPath(path, corner);
    }
  }

  @override
  bool shouldRepaint(_ScanWindowPainter old) => old.window != window;
}

// Bọc sau 1 provider: camera là plugin native, không chạy trong flutter test → test override hàm này.
typedef QrScanLauncher = Future<String?> Function(BuildContext context);

final qrScanLauncherProvider = Provider<QrScanLauncher>((ref) {
  return (context) => Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => const QrScanPage()));
});
