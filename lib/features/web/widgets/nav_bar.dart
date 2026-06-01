import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oulta/common/routes/routename.dart';
import 'custom_cursor.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedCursorButton(
            onTap: () => Get.toNamed(RouteName.home),
            child: Row(
              children: [
                Image.asset(
                  'assets/app_icon/appicon.png',
                  width: 32,
                  height: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  "OULTA",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          AnimatedCursorButton(
            onTap: () {
              Scaffold.of(context).openEndDrawer();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.menu_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  final String title;
  const _NavButton({required this.title});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: AnimatedCursorButton(
        onTap: () {
          switch (widget.title) {
            case "Home":
              Get.toNamed(RouteName.home);
              break;
            case "About":
              break;
          }
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: _isHovered ? Colors.white : Colors.transparent,
                  width: 2.0,
                ),
              ),
            ),
            child: Text(
              widget.title.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
