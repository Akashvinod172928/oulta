import 'package:flutter/material.dart';

class TransitionQuestion extends StatefulWidget {
  final String question;
  final Color themeColor;
  final Color textColor;

  const TransitionQuestion({
    super.key,
    required this.question,
    required this.themeColor,
    required this.textColor,
  });

  @override
  State<TransitionQuestion> createState() => _TransitionQuestionState();
}

class _TransitionQuestionState extends State<TransitionQuestion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
      ),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: screenHeight * 0.4, // Compact question height
      decoration: BoxDecoration(
        color: widget.themeColor,
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [
            widget.themeColor == Colors.black
                ? const Color(0xFF121212)
                : Colors.white,
            widget.themeColor,
          ],
        ),
      ),
      child: Column(
        children: [
          // Vertical Line segment
          Container(
            width: 1.5,
            height: 40,
            color: widget.textColor.withOpacity(0.2),
          ),

          Expanded(
            child: FadeTransition(
              opacity: _opacity,
              child: SlideTransition(
                position: _slide,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        widget.question.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: MediaQuery.of(context).size.width < 768
                              ? 20
                              : 36,
                          fontWeight: FontWeight.w900,
                          color: widget.textColor,
                          letterSpacing: 8,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Vertical Line segment
          Container(
            width: 1.5,
            height: 40,
            color: widget.textColor.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}
