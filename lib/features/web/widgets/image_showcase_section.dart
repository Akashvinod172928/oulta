import 'package:flutter/material.dart';

class ImageShowcaseSection extends StatefulWidget {
  const ImageShowcaseSection({super.key});

  @override
  State<ImageShowcaseSection> createState() => _ImageShowcaseSectionState();
}

class _ImageShowcaseSectionState extends State<ImageShowcaseSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Auto-trigger animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 768;

    return Container(
      width: screenWidth,
      height: screenHeight,
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Color(0xFF0A0A0A), Colors.black],
              ),
            ),
          ),

          // Main image — centered and animated
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Label above image
                  Text(
                    'THE VISION',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: isMobile ? 11 : 14,
                      letterSpacing: 6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // The showcase image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(isMobile ? 12 : 20),
                    child: Image.asset(
                      'assets/rebuilding india.png',
                      width: isMobile ? screenWidth * 0.88 : screenWidth * 0.72,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback: show the "Untitled design (1).png" instead
                        return Image.asset(
                          'assets/Untitled design (1).png',
                          width: isMobile
                              ? screenWidth * 0.88
                              : screenWidth * 0.72,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error2, stackTrace2) {
                            // Final fallback: show the Oulta logo
                            return Image.asset(
                              'assets/social_icons/Black White Simple Modern Neon Griddy Bold Technology Pixel Electronics Store Logo.png',
                              width: isMobile ? 200 : 320,
                              fit: BoxFit.contain,
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Caption below image
                  Text(
                    'REBUILDING INDIA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 22 : 36,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Serif',
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Through goodness, empathy and impact.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: isMobile ? 13 : 17,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Subtle top fade
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.black.withOpacity(0.0)],
                ),
              ),
            ),
          ),

          // Subtle bottom fade
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black, Colors.black.withOpacity(0.0)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
