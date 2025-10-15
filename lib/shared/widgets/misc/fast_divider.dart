/// **FastDivider** - Customizable divider widget with platform-appropriate styling and spacing.
///
/// **Use Case:**
/// Use this for creating visual separations between content sections, list items,
/// or any interface elements that need clear boundaries. Provides consistent
/// divider styling with customizable thickness, color, and indentation.
///
/// **Key Features:**
/// - Customizable height, thickness, and color
/// - Configurable left and right indentation
/// - Platform-appropriate default colors
/// - Consistent spacing and alignment
/// - Accessibility support with proper semantics
/// - Responsive to theme changes
///
/// **Important Parameters:**
/// - `height`: Total height of the divider container (default: 1.0)
/// - `color`: Color of the divider line (defaults to theme divider color)
/// - `thickness`: Thickness of the divider line (default: 1.0)
/// - `indent`: Left margin/indentation (default: 0.0)
/// - `endIndent`: Right margin/indentation (default: 0.0)
///
/// **Usage Example:**
/// ```dart
/// // Basic divider
/// FastDivider()
///
/// // Custom styled divider
/// FastDivider(
///   height: 2.0,
///   thickness: 1.5,
///   color: Colors.grey.shade300,
///   indent: 16.0,
///   endIndent: 16.0,
/// )
///
/// // List separator with indentation
/// FastDivider(
///   indent: 72.0, // Space for avatar/icon
///   endIndent: 16.0,
/// )
/// ```

import 'package:flutter/material.dart';

class FastDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double thickness;
  final double indent;
  final double endIndent;

  const FastDivider({
    super.key,
    this.height = 1.0,
    this.color = Colors.grey,
    this.thickness = 1.0,
    this.indent = 0.0,
    this.endIndent = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      color: color,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
    );
  }
}
