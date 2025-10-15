import 'package:flutter/material.dart';

/// Animated feather cursor that appears inline during typing animations
class FeatherCursor extends StatefulWidget {
  final bool visible;

  const FeatherCursor({
    super.key,
    this.visible = true,
  });

  @override
  State<FeatherCursor> createState() => _FeatherCursorState();
}

class _FeatherCursorState extends State<FeatherCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: const Text(
            '🪶',
            style: TextStyle(fontSize: 28),
          ),
        );
      },
    );
  }
}
