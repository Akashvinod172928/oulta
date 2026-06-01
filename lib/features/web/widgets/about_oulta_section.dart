import 'package:flutter/material.dart';

class AboutOultaSection extends StatefulWidget {
  const AboutOultaSection({super.key});

  @override
  State<AboutOultaSection> createState() => _AboutOultaSectionState();
}

class _AboutOultaSectionState extends State<AboutOultaSection> {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCleanSection(context, 'About Oulta', [
                'A global system to help humanity thrive in the age of AI.',
                'Redefines value from wealth to human goodness.',
                'Measures and amplifies positive impact via a transparent network.',
              ]),
              const SizedBox(height: 48),
              _buildCleanSection(context, 'Why the World Needs Oulta', [
                'AI is transforming our world, risking human meaning.',
                'Makes human kindness and empathy our most valuable currency.',
                'Gives every person a way to matter through their contributions.',
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCleanSection(
    BuildContext context,
    String title,
    List<String> points,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 24),
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
                      ).textTheme.bodyLarge?.copyWith(color: Colors.black87),
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
