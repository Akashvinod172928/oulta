import 'package:flutter/material.dart';

class IndiaSection extends StatefulWidget {
  const IndiaSection({super.key});

  @override
  State<IndiaSection> createState() => _IndiaSectionState();
}

class _IndiaSectionState extends State<IndiaSection> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _isVisible = true);
    });
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
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Rebuilding India',
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
                              'India is the foundation for a compassion-driven civilization.',
                              'Empowers students, villages, and businesses through purpose.',
                              'Building a model for an ethical, humanity-first AI future.',
                            ]
                            .map(
                              (point) => Padding(
                                padding: const EdgeInsets.only(bottom: 24.0),
                                child: Text(
                                  point,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
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
      ),
    );
  }
}
