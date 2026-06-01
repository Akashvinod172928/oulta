import 'package:flutter/material.dart';
import 'custom_cursor.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 768;

    return Container(
      width: screenWidth,
      height: screenHeight,
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: const AssetImage(
            'assets/app_icon/futuristic-moon-background.jpg',
          ),
          fit: BoxFit.cover,
          // colorFilter: ColorFilter.mode(
          //   Colors.black.withOpacity(0.3),
          //   BlendMode.darken,
          // ),
        ),
      ),
      child: Stack(
        children: [
          // Vertical Side Text - Left
          if (!isMobile)
            Positioned(
              left: 20,
              top: 0,
              bottom: 0,
              child: RotatedBox(
                quarterTurns: 3,
                child: Center(
                  child: Text(
                    "NOT  -  EVERYONE  -  WILL  -  GET  -  THIS",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      letterSpacing: 6,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),

          // Vertical Side Text - Right
          if (!isMobile)
            Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              child: RotatedBox(
                quarterTurns: 1,
                child: Center(
                  child: Text(
                    "AND  -  THATS  -  EXPECTED",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      letterSpacing: 6,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),

          // Center Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedCursorButton(
                  child: Image.asset(
                    'assets/social_icons/Black White Simple Modern Neon Griddy Bold Technology Pixel Electronics Store Logo.png',
                    height: isMobile ? 120 : 180,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 0),
                Text(
                  "OULTA",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 32 : 56,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "POWERED BY IMPACTISM",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: isMobile ? 10 : 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 10),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(seconds: 2),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        Text(
                          "WE ARE",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: isMobile ? 12 : 16,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "REBUILDING INDIA",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 28 : 56,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Serif',
                            letterSpacing: 2,
                            height: 1.1,
                          ),
                        ),

                        Text(
                          "How is this possible?\nLet’s explore.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: isMobile ? 12 : 16,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Content Indicator
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 2),
              builder: (context, value, child) =>
                  Opacity(opacity: value, child: child),
              child: Column(
                children: [
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
