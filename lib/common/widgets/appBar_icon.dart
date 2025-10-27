import 'package:flutter/material.dart';

/// Small reusable circular icon used in the appbar (matches your screenshot)
class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;
  final String? tooltip;

  const CircularIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.size = 56,
    this.iconSize = 28,
    this.backgroundColor = const Color(0xFFF0F0F2), // light grey
    this.iconColor = Colors.black,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: onPressed,
          splashFactory: InkRipple.splashFactory,
          child: Center(
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor,
              semanticLabel: tooltip,
            ),
          ),
        ),
      ),
      // outer decoration:
      // container can't have Material ripple, so keep the background decoration outside
      // We'll wrap this SizedBox in another Container where used.
    );
  }
}