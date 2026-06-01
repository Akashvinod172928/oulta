import 'package:flutter/material.dart';

class CursorController {
  static final CursorController _instance = CursorController._internal();
  factory CursorController() => _instance;
  CursorController._internal();

  final ValueNotifier<bool> isHovering = ValueNotifier<bool>(false);

  void setHovering(bool val) {
    isHovering.value = val;
  }
}

class CustomCursorWrapper extends StatefulWidget {
  final Widget child;
  const CustomCursorWrapper({super.key, required this.child});

  @override
  State<CustomCursorWrapper> createState() => _CustomCursorWrapperState();
}

class _CustomCursorWrapperState extends State<CustomCursorWrapper> {
  final ValueNotifier<Offset> _mousePos = ValueNotifier<Offset>(Offset.zero);
  final CursorController _controller = CursorController();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) return widget.child;

    return MouseRegion(
      cursor: SystemMouseCursors.none,
      onHover: (event) {
        _mousePos.value = event.localPosition;
      },
      child: Stack(
        children: [
          widget.child,
          ValueListenableBuilder<Offset>(
            valueListenable: _mousePos,
            builder: (context, pos, child) {
              return ValueListenableBuilder<bool>(
                valueListenable: _controller.isHovering,
                builder: (context, hovering, child) {
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 50),
                    curve: Curves.easeOut,
                    left: pos.dx - (hovering ? 30 : 12),
                    top: pos.dy - (hovering ? 30 : 12),
                    child: IgnorePointer(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: hovering ? 60 : 24,
                        height: hovering ? 60 : 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hovering
                              ? Colors.white.withOpacity(0.15)
                              : Colors.white.withOpacity(0.2),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: hovering ? 1.5 : 1,
                          ),
                          boxShadow: hovering
                              ? [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1),
                                    blurRadius: 15,
                                    spreadRadius: 5,
                                  ),
                                ]
                              : [],
                        ),
                        child: hovering
                            ? Center(
                                child: Icon(
                                  Icons.arrow_outward_rounded,
                                  size: 20,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              )
                            : Center(
                                child: Container(
                                  width: 2,
                                  height: 2,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class AnimatedCursorButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const AnimatedCursorButton({super.key, required this.child, this.onTap});

  @override
  State<AnimatedCursorButton> createState() => _AnimatedCursorButtonState();
}

class _AnimatedCursorButtonState extends State<AnimatedCursorButton> {
  final CursorController _controller = CursorController();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.setHovering(true),
      onExit: (_) => _controller.setHovering(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: widget.onTap, child: widget.child),
    );
  }
}
