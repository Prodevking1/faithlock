/// ⭕ FastCircularLoader: Customizable circular progress indicator
///
/// A simple wrapper around CircularProgressIndicator with customizable
/// size, color, and stroke width. Always centered within its container.
/// Perfect for loading states and progress indication.
///
/// 📋 Use Cases:
/// - Loading states in buttons or cards
/// - Inline progress indicators
/// - Small loading spinners
/// - Custom-sized progress indicators
/// - Async operation feedback
///
/// 🔧 Key Parameters:
/// - `size`: Width and height (default: 24.0)
/// - `color`: Indicator color (default: FastColors.primary)
/// - `strokeWidth`: Line thickness (default: 1.5)

import 'package:faithlock/core/constants/core/fast_colors.dart';
import 'package:flutter/material.dart';

class FastCircularLoader extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const FastCircularLoader({
    super.key,
    this.size = 24.0,
    this.color = FastColors.primary,
    this.strokeWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}
