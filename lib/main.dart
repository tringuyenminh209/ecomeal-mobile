import 'app.dart';
import 'core/app_flavor.dart';

// App khách「EcoMeal」(ADR-007). Đây cũng là target mặc định của `flutter run` / `flutter build`.
// Android: `--flavor customer` (bản tài xế: `--flavor driver -t lib/main_driver.dart`).
Future<void> main() => runEcoMealApp(AppFlavor.customer);
