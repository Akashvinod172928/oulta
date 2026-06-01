import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:oulta/common/routes/routename.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onLeadingIconPressed;
  final VoidCallback? onTrailingIconPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool hasActionButton;
  final bool hasLeadingButton;
  final bool isDarkTheme;
  final List<Widget>? extraActions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onLeadingIconPressed,
    this.onTrailingIconPressed,
    this.trailingIcon,
    this.leadingIcon,
    this.hasActionButton = true,
    this.hasLeadingButton = true,
    this.isDarkTheme = false,
    this.extraActions,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkTheme ? Colors.transparent : Colors.white;
    final fgColor = isDarkTheme ? Colors.white : Colors.black;
    final btnBgColor = isDarkTheme ? const Color(0xFF1E1E1E) : const Color(0xFFF0F0F2);

    return Material(
      color: bgColor,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDarkTheme ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Container(
            height: preferredSize.height,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Leading (default: back button)
                hasLeadingButton ?
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: btnBgColor,
                  ),
                  child: IconButton(
                    icon: Icon(
                      leadingIcon ?? Icons.arrow_back,
                      size: 28,
                      color: fgColor,
                    ),
                    onPressed: onLeadingIconPressed ?? () => Get.back(),
                  ),
                )
                    : const SizedBox(width: 44), // keep spacing

                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: fgColor,
                  ),
                ),

                // Trailing actions and main trailing button
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (extraActions != null) ...[
                      ...extraActions!,
                      const SizedBox(width: 8),
                    ],
                    hasActionButton
                        ? Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: btnBgColor,
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                trailingIcon ?? Icons.settings,
                                size: 22,
                                color: fgColor,
                              ),
                              onPressed: onTrailingIconPressed ?? () => Get.toNamed(RouteName.settings),
                            ),
                          )
                        : const SizedBox(width: 44), // keep spacing
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(76);
}
