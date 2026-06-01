import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:oulta/common/routes/routename.dart';
import 'custom_cursor.dart';

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isVisible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 768;

    return AnimatedOpacity(
      duration: const Duration(seconds: 1),
      opacity: _isVisible ? 1.0 : 0.0,
      child: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          color: Colors.black,
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFF1A1A1A), Colors.black],
          ),
        ),
        child: Stack(
          children: [
            // Logo at top-left
            Positioned(
              top: isMobile ? 40 : 60,
              left: isMobile ? 24 : 60,
              child: AnimatedCursorButton(
                onTap: () => Get.toNamed(RouteName.home),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/app_icon/Untitled design.svg',
                      height: isMobile ? 40 : 50,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'OULTA',
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: isMobile ? 18 : 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Content centered
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "BE AN\nIMPACTIST",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 56 : 110,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Serif',
                        letterSpacing: 4,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 64),
                    const SizedBox(height: 64),
                  ],
                ),
              ),
            ),

            // Bottom Links & Copyright
            Positioned(
              bottom: isMobile ? 40 : 60,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: isMobile ? 24 : 48,
                    runSpacing: 16,
                    children: [
                      _FooterLink(
                        title: "PRIVACY POLICY",
                        onTap: () => Get.toNamed(RouteName.privacyPolicy),
                      ),
                      _FooterLink(
                        title: "CHILD SAFETY",
                        onTap: () => Get.toNamed(RouteName.childSafetyPolicy),
                      ),
                      _FooterLink(
                        title: "DELETE ACCOUNT",
                        onTap: () => Get.toNamed(RouteName.deleteAccount),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Text(
                    "© 2025 OULTA SOCIAL IMPACT PVT LTD.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.15),
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _FooterLink({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedCursorButton(
      onTap: onTap,
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 11,
          letterSpacing: 2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
