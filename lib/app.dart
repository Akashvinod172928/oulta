import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:oulta/common/theme/theme.dart';
import 'common/routes/routename.dart';
import 'common/routes/routes.dart';

class MyApp extends StatelessWidget {
  final bool hasSeenWelcome;

  const MyApp({super.key, required this.hasSeenWelcome});

  @override
  Widget build(BuildContext context) {
    // Initial decision based on whether the user has seen the welcome screen
    String initialRoute = hasSeenWelcome ? RouteName.home : RouteName.welcome;

    // On Web, if it's a desktop-sized screen or not a mobile device, we skip the welcome screen
    // and go straight to RouteName.home (which uses ResponsiveRouter to show OultaWebHome).
    if (kIsWeb) {
      // We can't easily check width here without a LayoutBuilder/MediaQuery,
      // but we can check if the platform is mobile.
      bool isMobilePlatform =
          defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS;

      if (!isMobilePlatform) {
        initialRoute = RouteName.home;
      }
    }

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Oulta',
      theme: oultaTheme,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
    );
  }
}
