import 'package:flutter/material.dart';

class MissionSection extends StatefulWidget {
  const MissionSection({super.key});

  @override
  State<MissionSection> createState() => _MissionSectionState();
}

class _MissionSectionState extends State<MissionSection> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 768;

    return Container(
      width: screenWidth,
      height: screenHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [Colors.white, Color(0xFFF2F2F2)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Our Mission',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children:
                      [
                            'Turn kindness into measurable impact.',
                            'Connect people and brands in a transparent network.',
                            'Replace competition with collaboration.',
                            'Build an economy based on purpose and trust.',
                          ]
                          .map(
                            (point) => Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: Text(
                                point,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: Colors.black87,
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
