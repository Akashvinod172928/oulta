import 'package:get/get.dart';
import '../../features/account/view.dart';
import '../../features/responsive/responsive_router.dart'; // Import the new responsive router
import '../../features/settings/view.dart';
import 'routename.dart';

class AppPages {
  // Set the initial route to our new responsive router
  static const String INITIAL = RouteName.home;

  static final routes = <GetPage>[
    GetPage(
      name: RouteName.home,
      page: () => const ResponsiveRouter(), // Use ResponsiveRouter
    ),
    GetPage(
      name: RouteName.account,
      page: () => const AccountScreen(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: RouteName.settings,
      page: () =>  SettingsScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
