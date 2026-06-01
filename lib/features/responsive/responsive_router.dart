import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

import '../home/view.dart';
import '../web/view.dart';

class ResponsiveRouter extends StatelessWidget {
  const ResponsiveRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If it's a mobile device (Android/iOS) or the screen is narrow, show mobile layout
        bool isMobilePlatform =
            Theme.of(context).platform == TargetPlatform.iOS ||
            Theme.of(context).platform == TargetPlatform.android;

        if (constraints.maxWidth > 800 && !isMobilePlatform) {
          // Desktop layout
          return const OultaWebHome();
        } else {
          // Mobile and Tablet layout
          return UpgradeAlert(
            showIgnore: false,
            showLater: false,
            child: const HomeScreen(),
          );
        }
      },
    );
  }
}
