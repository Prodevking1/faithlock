/// **FastActivityIndicator** - Platform-adaptive loading indicator with native styling and animations.
///
/// **Use Case:**
/// Use this when you need to show loading states, data fetching, or any ongoing process
/// to users. Provides native iOS CupertinoActivityIndicator styling on iOS and Material
/// CircularProgressIndicator on Android with consistent API across platforms.
///
/// **Key Features:**
/// - Platform-adaptive styling (iOS spinner on iOS, Material on Android)
/// - Customizable size, color, and stroke width
/// - Smooth animations that respect platform conventions
/// - Automatic color adaptation for light/dark themes
/// - Optional animation control for performance optimization
/// - Accessibility support with proper semantics
///
/// **Important Parameters:**
/// - `radius`: Size of the activity indicator (default: 10.0)
/// - `color`: Custom color (defaults to platform accent color)
/// - `strokeWidth`: Line thickness for the indicator (default: 2.0)
/// - `animating`: Whether the indicator should animate (default: true)
///
/// **Usage Example:**
/// ```dart
/// // Basic activity indicator
/// FastActivityIndicator()
///
/// // Custom size and color
/// FastActivityIndicator(
///   radius: 15.0,
///   color: Colors.blue,
///   strokeWidth: 3.0,
/// )
///
/// // Conditional animation
/// FastActivityIndicator(
///   animating: isLoading,
///   radius: 12.0,
/// )
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FastActivityIndicator extends StatelessWidget {
  final double radius;
  final Color? color;
  final double strokeWidth;
  final bool animating;

  const FastActivityIndicator({
    super.key,
    this.radius = 10.0,
    this.color,
    this.strokeWidth = 2.0,
    this.animating = true,
  });

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return Center(
        child: CupertinoActivityIndicator(
          radius: radius,
          color: color ?? CupertinoColors.inactiveGray,
          animating: animating,
        ),
      );
    } else {
      return Center(
        child: SizedBox(
            width: radius * 2,
            height: radius * 2,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Theme.of(context).primaryColor,
              ),
            )),
      );
    }
  }
}

class FastLinearActivityIndicator extends StatelessWidget {
  final double? value;
  final Color? backgroundColor;
  final Color? valueColor;
  final double minHeight;

  const FastLinearActivityIndicator({
    super.key,
    this.value,
    this.backgroundColor,
    this.valueColor,
    this.minHeight = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return Center(
        child: Container(
          height: minHeight,
          decoration: BoxDecoration(
            color: backgroundColor ?? CupertinoColors.systemGrey5,
            borderRadius: BorderRadius.circular(minHeight / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value?.clamp(0.0, 1.0) ?? 0.0,
            child: Container(
              decoration: BoxDecoration(
                color: valueColor ?? CupertinoColors.inactiveGray,
                borderRadius: BorderRadius.circular(minHeight / 2),
              ),
            ),
          ),
        ),
      );
    } else {
      return Center(
          child: LinearProgressIndicator(
        value: value,
        backgroundColor: backgroundColor,
        valueColor: valueColor != null
            ? AlwaysStoppedAnimation<Color>(valueColor!)
            : null,
        minHeight: minHeight,
      ));
    }
  }
}
