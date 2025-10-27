
import 'package:flutter/material.dart';
import '../home/view.dart';
import '../web/view.dart';

class ResponsiveRouter extends StatelessWidget {
  const ResponsiveRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1024) { // Desktop layout
          return const OultaWebHome();
        } else { // Mobile and Tablet layout
          return const HomeScreen();
        }
      },
    );
  }
}
