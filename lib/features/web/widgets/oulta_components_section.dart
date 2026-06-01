import 'package:flutter/material.dart';

class OultaComponentsSection extends StatelessWidget {
  const OultaComponentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      width: screenWidth,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 60,
        vertical: isMobile ? 80 : 120,
      ),
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildFeatureGroup(context, 'OULTA Vision Components (OVC)', [
            'Human dignity as data: Good acts become proof of worth.',
            'Ethical AI collaboration: AI for efficiency, humans for empathy.',
            'Collective Dharma economy: A value system that rewards contribution.',
          ]),
          const SizedBox(height: 80),
          _buildFeatureGroup(context, 'OULTA Impact Chain (OIC)', [
            'Transparent chain that tracks and verifies positive impact.',
            'Ensures every contribution is visible and traceable.',
            'Links every Dharma point to real-world results.',
          ]),
          const SizedBox(height: 80),
          _buildFeatureGroup(context, 'OULTA Social Matrix (OSM)', [
            'A living ecosystem where people and organizations create value.',
            'Powered by people who act and brands that have impact.',
            'Turns scattered good deeds into a unified human movement.',
          ]),
        ],
      ),
    );
  }

  Widget _buildFeatureGroup(
    BuildContext context,
    String title,
    List<String> points,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.displaySmall?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 32),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: points
                .map(
                  (point) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      point,
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
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
