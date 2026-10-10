import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'supabase_client.dart';

// Đo chuyển đổi (0051, API-064): app chỉ ghi 2 sự kiện — mở chi tiết túi đồ ăn (SCR-M04) và mở màn đặt chỗ (SCR-M05).
// Server tự bỏ qua nếu không phải khách hàng / trùng trong 10 phút. Ghi lỗi (mất mạng…) thì bỏ qua: đo lường không được
// làm hỏng thao tác của khách.
enum AppEvent { batchView, checkoutView }

String _wireName(AppEvent e) => switch (e) {
      AppEvent.batchView => 'batch_view',
      AppEvent.checkoutView => 'checkout_view',
    };

typedef AppEventLogger = Future<void> Function(AppEvent event, String? surplusBatchId);

// Test thay bằng hàm giả (hoặc không cần: lỗi khi tạo client cũng bị nuốt ở logAppEvent).
final appEventLoggerProvider = Provider<AppEventLogger>((ref) {
  final client = SupabaseClientHolder.instance;
  return (event, batchId) async {
    await client.rpc('log_app_event', params: {'p_event': _wireName(event), 'p_surplus_batch_id': batchId});
  };
});

void logAppEvent(WidgetRef ref, AppEvent event, String? surplusBatchId) {
  try {
    ref.read(appEventLoggerProvider)(event, surplusBatchId).catchError((_) {});
  } catch (_) {
    // Chưa khởi tạo Supabase (widget test) hoặc lỗi đồng bộ — bỏ qua
  }
}

// Ghi 1 lần khi màn hình được mở (không ghi lại mỗi lần build).
class LogAppEventOnce extends ConsumerStatefulWidget {
  const LogAppEventOnce({super.key, required this.event, required this.surplusBatchId, required this.child});
  final AppEvent event;
  final String? surplusBatchId;
  final Widget child;

  @override
  ConsumerState<LogAppEventOnce> createState() => _LogAppEventOnceState();
}

class _LogAppEventOnceState extends ConsumerState<LogAppEventOnce> {
  @override
  void initState() {
    super.initState();
    logAppEvent(ref, widget.event, widget.surplusBatchId);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
