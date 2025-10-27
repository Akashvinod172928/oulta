import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onLeadingIconPressed;
  final VoidCallback? onTrailingIconPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool hasActionButton; // 🔹 controls trailing action

  const CustomAppBar({
    super.key,
    required this.title,
    this.onLeadingIconPressed,
    this.onTrailingIconPressed,
    this.trailingIcon,
    this.leadingIcon,
    this.hasActionButton = true, // 🔹 default: show trailing
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Leading (default: back button)
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF0F0F2),
            ),
            child: IconButton(
              icon: Icon(
                leadingIcon ?? Icons.arrow_back, // 🔹 default back
                size: 28,
                color: Colors.black,
              ),
              onPressed: onLeadingIconPressed ?? () => Get.back(),
            ),
          ),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),

          // Trailing (only if hasActionButton == true)
          hasActionButton
              ? Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF0F0F2),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                trailingIcon ?? Icons.settings,
                size: 22,
                color: Colors.black,
              ),
              onPressed: onTrailingIconPressed ??
                      () => debugPrint("Settings pressed"),
            ),
          )
              : const SizedBox(width: 44), // keep spacing
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(76);
}
