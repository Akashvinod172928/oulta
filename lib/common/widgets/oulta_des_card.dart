
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class OultaDescCard extends StatelessWidget {
  final String title;
  final String desc;
  final Color backgroundColor;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  const OultaDescCard({
    super.key,
    required this.title,
    required this.desc,
    this.backgroundColor = Colors.white,
    this.trailingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardHeight = MediaQuery.of(context).size.height * 0.20;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: cardHeight,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Optional trailing icon (like arrow or info)
            if (trailingIcon != null) ...[
              const SizedBox(width: 12),
              Icon(
                trailingIcon,
                color: Colors.grey[600],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
