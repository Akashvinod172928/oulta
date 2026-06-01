import 'package:flutter/material.dart';

class ImpactismDefinitionSection extends StatelessWidget {
  const ImpactismDefinitionSection({super.key});

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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "WAIT, WHAT IS THIS?",
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    fontSize: isMobile ? 12 : 16,
                    letterSpacing: 6,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "IMPACTISM",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: isMobile ? 42 : 72,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Serif',
                    letterSpacing: 4,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 64),
                Text(
                  "Impactism is a structured and accountable approach to solving real-world problems by aligning individuals, NGOs, and companies into a measurable system of coordinated action. It transforms intention into documented outcomes, ensuring that impact is visible, verifiable, and scalable — replacing noise and fragmentation with discipline, transparency, and long-term responsibility.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: isMobile ? 18 : 28,
                    fontWeight: FontWeight.w300,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
