import 'package:depremhackathon/services/authenction_service.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
//  locator.registerLazySingleton(() => NavigationService());
//  locator.registerLazySingleton(() => PushNotificationService());
  locator.registerLazySingleton(() => AuthenticationService());
}
