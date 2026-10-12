import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app_flavor.dart';
import 'core/error_reporting.dart';
import 'core/push_notifications.dart';
import 'core/stripe_payments.dart';
import 'core/supabase_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/locale_controller.dart';
import 'features/auth/role_gate.dart';
import 'l10n/l10n.dart';

// Khởi động chung cho cả 2 app (ADR-007). Khác nhau chỉ ở [flavor].
Future<void> runEcoMealApp(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  // Phải trước initSupabase (Supabase đọc phiên từ Keychain lúc khởi động)
  await clearSessionFromPreviousInstall(prefs);
  await initSupabase();
  // LINE Login chỉ dùng ở app khách (SCR-M07). Chưa có channel ID thì app vẫn chạy — chỉ nút 「LINEと連携する」 báo lỗi.
  const lineChannelId = String.fromEnvironment('LINE_CHANNEL_ID');
  // flutter_line_sdk chỉ có bản Android/iOS — trên web (chạy thử bằng Chrome) gọi setup sẽ crash lúc khởi động.
  if (flavor == AppFlavor.customer && lineChannelId.isNotEmpty && !kIsWeb) {
    await LineSDK.instance.setup(lineChannelId);
  }
  // Stripe chỉ dùng ở app khách (SCR-M05/M09). Không có khoá → thanh toán giả (0043).
  if (flavor == AppFlavor.customer) await initStripe();
  // Thông báo app (0048, 0059): app khách, nhà hàng, vận hành. Mỗi app 1 Firebase app ID; thiếu cấu hình thì bỏ qua
  if (flavor != AppFlavor.driver) await initPush(flavor);
  await runWithErrorReporting(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appFlavorProvider.overrideWithValue(flavor),
      ],
      child: const EcoMealApp(),
    ),
    appName: flavor.name,
  );
}

class EcoMealApp extends ConsumerWidget {
  const EcoMealApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    // App tài xế (ban đêm trong cabin) và app vận hành (đêm vận hành) → toàn bộ app (kể cả màn đăng nhập và các màn push
    // lên) dùng bộ màu tối (EcoPalette.night). App khách và app nhà hàng giữ bộ màu sáng của Figma.
    final flavor = ref.watch(appFlavorProvider);
    return MaterialApp(
      onGenerateTitle: (context) => switch (flavor) {
        AppFlavor.customer => context.l10n.appTitle,
        AppFlavor.driver => context.l10n.driverAppTitle,
        AppFlavor.store => context.l10n.storeAppTitle,
        AppFlavor.admin => context.l10n.adminAppTitle,
      },
      locale: locale,
      // gen-l10n sinh sẵn 2 danh sách này từ lib/l10n/app_*.arb — thêm ngôn ngữ mới chỉ cần thêm 1 file ARB.
      // localizationsDelegates còn nạp bản dịch của chính Material (nút OK/キャンセル của dialog, DatePicker...).
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Toàn bộ màu/chữ/nút/ô nhập theo Figma "00 Foundations" + "01 Components" — xem core/theme/app_theme.dart.
      theme: buildAppTheme(dark: flavor.usesNightTheme),
      home: const RoleGate(),
    );
  }
}
