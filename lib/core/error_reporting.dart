import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// Theo dõi lỗi bằng Sentry (ADR-010, 0051 #9). Có SENTRY_DSN trong env.json thì gửi lỗi chưa bắt + crash; không có thì chạy
// như cũ. Không gửi thông tin cá nhân: sendDefaultPii=false (không IP / tên / email), không đính kèm ảnh chụp màn hình.
const _sentryDsn = String.fromEnvironment('SENTRY_DSN');
const _environment = String.fromEnvironment('APP_ENV', defaultValue: 'development');

Future<void> runWithErrorReporting(Widget app, {required String appName}) async {
  if (_sentryDsn.isEmpty || kIsWeb) {
    runApp(app);
    return;
  }
  await SentryFlutter.init(
    (options) {
      options.dsn = _sentryDsn;
      options.environment = _environment;
      options.sendDefaultPii = false;
      options.attachScreenshot = false;
      options.tracesSampleRate = 0.1; // 10% thao tác để đo độ trễ — đủ cho quy mô thử nghiệm
      options.dist = appName; // phân biệt app khách / app tài xế (ADR-007) trong cùng 1 project Sentry
    },
    appRunner: () => runApp(app),
  );
}
