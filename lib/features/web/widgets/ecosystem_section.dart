import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'custom_cursor.dart';

class EcosystemSection extends StatefulWidget {
  const EcosystemSection({super.key});

  @override
  State<EcosystemSection> createState() => _EcosystemSectionState();
}

class _EcosystemSectionState extends State<EcosystemSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _isVisible = true);
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

    return AnimatedOpacity(
      duration: const Duration(seconds: 1),
      opacity: _isVisible ? 1.0 : 0.0,
      child: Container(
        width: screenWidth,
        height: screenHeight,
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 20,
              horizontal: isMobile ? 24 : 60,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Section Title
                Text(
                  "THE ECOSYSTEM",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    letterSpacing: 4,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20),

                // Circular Diagram
                SizedBox(
                  height: isMobile ? 350 : 500,
                  width: isMobile ? 350 : 800,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rotating Circle & Nodes
                      RotationTransition(
                        turns: _controller,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // The Main Circle
                            Container(
                              width: isMobile ? 220 : 350,
                              height: isMobile ? 220 : 350,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                            ),
                            // Nodes Around the Circle
                            ..._buildNodes(isMobile),
                          ],
                        ),
                      ),

                      // Central Text (Static)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "IMPACTISM",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 24 : 42,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Serif',
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 1,
                            width: 60,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Bottom CTA
                AnimatedCursorButton(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Text(
                      "LEARN MORE ABOUT UBI",
                      style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 3,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNodes(bool isMobile) {
    final double radius = isMobile ? 110 : 175;

    final List<String> labels = [
      "INDIVIDUAL USERS",
      "NGO PARTNERS",
      "CORPORATE ENTITIES",
      "DHARMA ALGORITHM",
      "GLOBAL ECOSYSTEM",
      "TRANSPARENT IMPACT",
      "HUMANITY FIRST AI",
      "COLLECTIVE PROGRESS",
    ];

    return List.generate(labels.length, (index) {
      final double angleDeg = (index * 360 / labels.length) - 90;
      final double angleRad = angleDeg * (math.pi / 180);

      return _EcosystemNode(
        label: labels[index],
        angle: angleRad,
        radius: radius,
        isMobile: isMobile,
      );
    });
  }
}

class _EcosystemNode extends StatelessWidget {
  final String label;
  final double angle;
  final double radius;
  final bool isMobile;

  const _EcosystemNode({
    required this.label,
    required this.angle,
    required this.radius,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final double x = radius * math.cos(angle);
    final double y = radius * math.sin(angle);
    final bool isLeft = x < -10;

    return Transform.translate(
      offset: Offset(x, y),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
          Positioned(
            left: isLeft ? null : 20,
            right: isLeft ? 20 : null,
            child: Container(
              width: isMobile ? 100 : 180,
              alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                label.toUpperCase(),
                textAlign: isLeft ? TextAlign.right : TextAlign.left,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isMobile ? 9 : 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
