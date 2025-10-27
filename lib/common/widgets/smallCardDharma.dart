import 'package:flutter/material.dart';

class SmallCardDharma extends StatelessWidget {
  final String title;
  final String actionText;
  final Color iconBackgroundColor;

  const SmallCardDharma({
    super.key,
    required this.title,
    required this.actionText,
    required this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: (screenWidth / 2) - 24, // 🔹 half of screen width with margin
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🔹 Top Logo instead of Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              // shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Image.asset(
              "assets/Untitled design (1).png",
              fit: BoxFit.contain,
            ),
          ),

          // 🔹 Title & Value
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                actionText,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class SmallCardDharmaDummy extends StatelessWidget {


  const SmallCardDharmaDummy({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: (screenWidth / 2) - 24, // 🔹 half of screen width with margin
      height: 140,
      padding: const EdgeInsets.all(16),
    );
  }
}
