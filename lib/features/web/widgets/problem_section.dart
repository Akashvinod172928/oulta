import 'package:flutter/material.dart';

class ProblemSection extends StatefulWidget {
  const ProblemSection({super.key});

  @override
  State<ProblemSection> createState() => _ProblemSectionState();
}

class _ProblemSectionState extends State<ProblemSection> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 150), () {
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
        color: Colors.white,
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 80 : 120,
          horizontal: isMobile ? 24 : 60,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFF0052D4),
              size: 48,
            ),
            const SizedBox(height: 24),
            Text(
              "The Problem",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Text(
                "In a world where AI and technology are evolving rapidly, human value and impact are often overlooked. We need a way to track, verify, and reward the positive contributions people make to society.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
