import 'app.dart';
import 'core/app_flavor.dart';

// App nhà hàng「EcoMeal Store」(ADR-015): `flutter run --flavor store -t lib/main_store.dart`.
Future<void> main() => runEcoMealApp(AppFlavor.store);
