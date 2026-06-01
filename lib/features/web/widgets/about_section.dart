import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 60 : 80,
          horizontal: isMobile ? 20 : 24
      ),
      constraints: const BoxConstraints(maxWidth: 900),
      child: Column(
        children: [
          const Text(
            "What is Oulta?",
            style: TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Oulta is the world's first Universal Basic Impact network — a new kind of social media where every post, project, and idea contributes to real change. "
                "It's a black-and-white space — transparent, simple, and built for collaboration. Oulta transforms social networking into a tool for national rebuilding.",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black54,
                fontSize: isMobile ? 15 : 16,
                height: 1.6
            ),
          ),
        ],
      ),
    );
  }
}
