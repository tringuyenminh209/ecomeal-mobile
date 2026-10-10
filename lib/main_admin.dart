import 'app.dart';
import 'core/app_flavor.dart';

// App vận hành「EcoMeal Admin」(ADR-015, chỉ phát hành TestFlight): `flutter run --flavor admin -t lib/main_admin.dart`.
Future<void> main() => runEcoMealApp(AppFlavor.admin);
