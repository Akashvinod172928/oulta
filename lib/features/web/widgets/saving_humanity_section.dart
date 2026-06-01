import 'package:flutter/material.dart';

class SavingHumanitySection extends StatefulWidget {
  const SavingHumanitySection({super.key});

  @override
  State<SavingHumanitySection> createState() => _SavingHumanitySectionState();
}

class _SavingHumanitySectionState extends State<SavingHumanitySection> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
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
        color: Colors.black,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 60,
          vertical: isMobile ? 80 : 120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Saving Humanity",
              textAlign: TextAlign.center,
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
                          'AI should remind us of our uniqueness, not replace it.',
                          'Create an economy of purpose that machines cannot replicate.',
                          'A world where machines produce and humans care.',
                        ]
                        .map(
                          (point) => Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Text(
                              point,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Colors.white70,
                                    height: 1.5,
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
    );
  }
}
