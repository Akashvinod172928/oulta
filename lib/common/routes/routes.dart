import 'package:get/get.dart';
import 'package:oulta/features/settings/moderator_page.dart';
import 'package:oulta/features/settings/web/child_safety_policy_web_page.dart';
import 'package:oulta/features/settings/web/delete_account_web_page.dart';
import 'package:oulta/features/settings/web/privacy_policy_web_page.dart';
import 'package:oulta/features/presentation/account/view/account_page.dart';
import '../../features/achivements/view.dart';
import '../../features/onboarding/welcome_screen.dart';
import '../../features/responsive/responsive_router.dart';
import '../../features/settings/view.dart';
import 'package:oulta/features/presentation/social/view.dart';
import 'package:oulta/features/search/search_page.dart';
import 'package:oulta/features/presentation/social/view/impact_stand_detail_page.dart';
import 'package:oulta/features/settings/create_victory_screen.dart';
import 'package:oulta/features/settings/create_impact_victory_screen.dart';
import 'routename.dart';

class AppPages {
  static const String INITIAL = RouteName.home;

  static final routes = <GetPage>[
    GetPage(name: RouteName.home, page: () => const ResponsiveRouter()),
    GetPage(name: RouteName.welcome, page: () => const WelcomeScreen()),
    GetPage(name: RouteName.social, page: () => const SocialPage()),
    GetPage(
      name: RouteName.account,
      page: () => const AccountScreen(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: RouteName.settings,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RouteName.achivements,
      page: () => const AchievementsView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RouteName.deleteAccount,
      page: () => const DeleteAccountWebPage(),
    ),
    GetPage(
      name: RouteName.privacyPolicy,
      page: () => const PrivacyPolicyWebPage(),
    ),
    GetPage(
      name: RouteName.childSafetyPolicy,
      page: () => const ChildSafetyPolicyWebPage(),
    ),
    GetPage(
      name: RouteName.moderator,
      page: () => const ModeratorPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RouteName.search,
      page: () => const SearchPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: RouteName.impactStandDetail,
      page: () => const ImpactStandDetailWrapper(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: RouteName.createVictory,
      page: () => const CreateVictoryScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RouteName.createImpactVictory,
      page: () => const CreateImpactVictoryScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
