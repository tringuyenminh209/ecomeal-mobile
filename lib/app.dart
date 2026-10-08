import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app_flavor.dart';
import 'core/supabase_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/locale_controller.dart';
import 'features/auth/role_gate.dart';
import 'l10n/l10n.dart';

// Khởi động chung cho cả 2 app (ADR-007). Khác nhau chỉ ở [flavor].
Future<void> runEcoMealApp(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  // LINE Login chỉ dùng ở app khách (SCR-M07). Chưa có channel ID thì app vẫn chạy — chỉ nút 「LINEと連携する」 báo lỗi.
  const lineChannelId = String.fromEnvironment('LINE_CHANNEL_ID');
  // flutter_line_sdk chỉ có bản Android/iOS — trên web (chạy thử bằng Chrome) gọi setup sẽ crash lúc khởi động.
  if (flavor == AppFlavor.customer && lineChannelId.isNotEmpty && !kIsWeb) {
    await LineSDK.instance.setup(lineChannelId);
  }
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appFlavorProvider.overrideWithValue(flavor),
      ],
      child: const EcoMealApp(),
    ),
  );
}

class EcoMealApp extends ConsumerWidget {
  const EcoMealApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    // App tài xế làm việc ban đêm trong cabin → toàn bộ app (kể cả màn đăng nhập SCR-D00 và các màn push lên) dùng bộ
    // màu tối (EcoPalette.night). App khách giữ bộ màu sáng của Figma.
    final isDriverApp = ref.watch(appFlavorProvider) == AppFlavor.driver;
    return MaterialApp(
      onGenerateTitle: (context) => isDriverApp ? context.l10n.driverAppTitle : context.l10n.appTitle,
      locale: locale,
      // gen-l10n sinh sẵn 2 danh sách này từ lib/l10n/app_*.arb — thêm ngôn ngữ mới chỉ cần thêm 1 file ARB.
      // localizationsDelegates còn nạp bản dịch của chính Material (nút OK/キャンセル của dialog, DatePicker...).
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Toàn bộ màu/chữ/nút/ô nhập theo Figma "00 Foundations" + "01 Components" — xem core/theme/app_theme.dart.
      theme: buildAppTheme(dark: isDriverApp),
      home: const RoleGate(),
    );
  }
}
