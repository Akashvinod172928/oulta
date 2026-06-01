import 'package:flutter/material.dart';

class UbiAndIndiaSection extends StatefulWidget {
  const UbiAndIndiaSection({super.key});

  @override
  State<UbiAndIndiaSection> createState() => _UbiAndIndiaSectionState();
}

class _UbiAndIndiaSectionState extends State<UbiAndIndiaSection> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
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
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 60,
                vertical: isMobile ? 40 : 80,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCleanPoint(context, 'Universal Basic Impact (UBI)', [
                    'A new social framework that rewards positive human acts.',
                    'Values impact over labor, turning kindness into Dharma points.',
                    'Ensures no good deed goes unnoticed.',
                  ]),
                  const SizedBox(height: 80),
                  _buildCleanPoint(context, 'Rebuilding India', [
                    'India is the foundation for a compassion-driven civilization.',
                    'Empowers students, villages, and businesses through purpose.',
                    'Building a model for an ethical, humanity-first AI future.',
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCleanPoint(
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
          ),
        ),
        const SizedBox(height: 32),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
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
