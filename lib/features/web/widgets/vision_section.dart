import 'package:flutter/material.dart';

class VisionSection extends StatefulWidget {
  const VisionSection({super.key});

  @override
  State<VisionSection> createState() => _VisionSectionState();
}

class _VisionSectionState extends State<VisionSection> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 768;

    return Container(
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
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Our Vision',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children:
                      [
                            'Impact replaces income as the measure of value.',
                            'Universal Basic Impact (UBI) rewards contribution.',
                            'Verified acts of good celebrated globally.',
                            'Civilization based on shared purpose.',
                          ]
                          .map(
                            (point) => Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: Text(
                                point,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w400,
                                    ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
