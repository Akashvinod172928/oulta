
import 'package:flutter/material.dart';
class SmallCard extends StatelessWidget {
  final IconData accentIcon;
  final String title;
  final String actionText;
  final Color iconBackgroundColor;

  const SmallCard({
    super.key,
    required this.accentIcon,
    required this.title,
    required this.actionText,
    required this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 145,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(shape: BoxShape.circle, color: iconBackgroundColor),
            child: Icon(accentIcon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 6),
          Text(actionText, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
