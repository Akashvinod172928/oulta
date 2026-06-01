import 'package:flutter/material.dart';

class VisualStoryStyle {
  static const Color accentColor = Color(0xFF0052D4);
  static const double lineWidth = 1.5;
  static const double nodeSize = 40.0;

  static Widget verticalLine({required Color color, double height = 100}) {
    return Container(
      width: lineWidth,
      height: height,
      color: color.withOpacity(0.3),
    );
  }

  static Widget storyNode({
    required String step,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      width: nodeSize,
      height: nodeSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.5), width: lineWidth),
        color: Colors.transparent,
      ),
      child: Center(
        child: Text(
          step,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class AnimatedStorySection extends StatefulWidget {
  final Widget child;
  final String step;
  final bool isLast;
  final bool isFirst;
  final Color themeColor;
  final Color contentColor;

  const AnimatedStorySection({
    super.key,
    required this.child,
    required this.step,
    this.isLast = false,
    this.isFirst = false,
    required this.themeColor,
    required this.contentColor,
  });

  @override
  State<AnimatedStorySection> createState() => _AnimatedStorySectionState();
}

class _AnimatedStorySectionState extends State<AnimatedStorySection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(bool visible) {
    if (visible && !_hasAnimated) {
      _controller.forward();
      _hasAnimated = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('story-section-${widget.step}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2) {
          _onVisibilityChanged(true);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: widget.themeColor,
        child: Stack(
          children: [
            // Centered Vertical Line
            Center(
              child: Column(
                children: [
                  if (!widget.isFirst)
                    VisualStoryStyle.verticalLine(
                      color: widget.contentColor,
                      height: 60,
                    ),
                  VisualStoryStyle.storyNode(
                    step: widget.step,
                    color: widget.contentColor,
                    textColor: widget.contentColor,
                  ),
                  if (!widget.isLast)
                    Expanded(
                      child: VisualStoryStyle.verticalLine(
                        color: widget.contentColor,
                      ),
                    ),
                ],
              ),
            ),

            // Content
            FadeTransition(
              opacity: _opacityAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple Visibility Detector Mock if package not available
class VisibilityDetector extends StatelessWidget {
  final Key key;
  final Widget child;
  final void Function(VisibilityInfo) onVisibilityChanged;

  const VisibilityDetector({
    required this.key,
    required this.child,
    required this.onVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    // In a real app we'd use visibility_detector package
    // For now we trigger immediately or use a post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onVisibilityChanged(VisibilityInfo(visibleFraction: 1.0));
    });
    return child;
  }
}

class VisibilityInfo {
  final double visibleFraction;
  VisibilityInfo({required this.visibleFraction});
}
