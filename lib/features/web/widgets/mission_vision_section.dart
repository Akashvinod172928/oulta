import 'package:flutter/material.dart';
import 'custom_cursor.dart';

class MissionVisionSection extends StatefulWidget {
  const MissionVisionSection({super.key});

  @override
  State<MissionVisionSection> createState() => _MissionVisionSectionState();
}

class _MissionVisionSectionState extends State<MissionVisionSection> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isVisible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return AnimatedOpacity(
      duration: const Duration(seconds: 1),
      opacity: _isVisible ? 1.0 : 0.0,
      child: Container(
        width: screenWidth,
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 60,
                vertical: isMobile ? 40 : 80,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMissionVisionBlock(
                    context,
                    'Our Mission',
                    [
                      'Turn kindness into measurable impact.',
                      'Connect people and brands in a transparent network.',
                      'Replace competition with collaboration.',
                      'Build an economy based on purpose and trust.',
                    ],
                    isMobile,
                    screenWidth,
                  ),
                  const SizedBox(height: 60),
                  _buildMissionVisionBlock(
                    context,
                    'Our Vision',
                    [
                      'Impact replaces income as the measure of value.',
                      'Universal Basic Impact (UBI) rewards contribution.',
                      'Verified acts of good celebrated globally.',
                      'Civilization based on shared purpose.',
                    ],
                    isMobile,
                    screenWidth,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMissionVisionBlock(
    BuildContext context,
    String title,
    List<String> points,
    bool isMobile,
    double screenWidth,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 40),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: points
                .map(
                  (point) => AnimatedCursorButton(
                    child: Container(
                      width: isMobile ? screenWidth : 350,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        point,
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
