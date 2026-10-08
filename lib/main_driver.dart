import 'app.dart';
import 'core/app_flavor.dart';

// App tài xế「EcoMeal Driver」(ADR-007): `flutter run --flavor driver -t lib/main_driver.dart`.
Future<void> main() => runEcoMealApp(AppFlavor.driver);
