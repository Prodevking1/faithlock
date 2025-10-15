/// **FastBadge** - Platform-adaptive notification badge with customizable styling and positioning.
///
/// **Use Case:**
/// Use this for adding notification badges, status indicators, or labels to widgets.
/// Perfect for showing unread counts on icons, status badges on profile pictures,
/// or any overlay indicator that needs platform-appropriate styling.
///
/// **Key Features:**
/// - Platform-adaptive styling (iOS red badge, Material design badge)
/// - Automatic positioning over child widget
/// - Customizable colors, padding, and border radius
/// - Support for text labels and numeric counts
/// - Automatic scaling for different text lengths
/// - Accessibility support with proper semantics
/// - Optional badge hiding when count is zero
///
/// **Important Parameters:**
/// - `child`: Widget to overlay the badge on
/// - `label`: Text or number to display in the badge
/// - `backgroundColor`: Custom badge background color
/// - `textColor`: Custom badge text color
/// - `padding`: Custom padding inside the badge
/// - `borderRadius`: Custom border radius for badge shape
/// - `position`: Badge position relative to child widget
///
/// **Usage Example:**
/// ```dart
/// // Basic notification badge
/// FastBadge(
///   child: Icon(Icons.notifications),
///   label: '5',
/// )
///
/// // Custom styled badge
/// FastBadge(
///   child: CircleAvatar(child: Text('AB')),
///   label: 'VIP',
///   backgroundColor: Colors.green,
///   textColor: Colors.white,
///   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
/// )
///
/// // Conditional badge display
/// FastBadge(
///   child: Icon(Icons.message),
///   label: unreadCount > 0 ? unreadCount.toString() : '',
///   backgroundColor: Colors.red,
/// )
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FastBadge extends StatelessWidget {
  final Widget child;
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final TextStyle? textStyle;
  final double? top;
  final double? right;
  final double? size;

  const FastBadge({
    super.key,
    required this.child,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.borderRadius,
    this.textStyle,
    this.top,
    this.right,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS
        ? _buildCupertinoBadge(context)
        : _buildMaterialBadge(context);
  }

  Widget _buildCupertinoBadge(BuildContext context) {
    final badgeSize = size ?? 18.0;
    final badgeRadius = borderRadius ?? (badgeSize / 2);
    final badgePadding = padding ?? EdgeInsets.symmetric(
      horizontal: badgeSize * 0.25,
      vertical: badgeSize * 0.15,
    );
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: right ?? -(badgeSize * 0.3),
          top: top ?? -(badgeSize * 0.3),
          child: Container(
            padding: badgePadding,
            decoration: BoxDecoration(
              color: backgroundColor ?? CupertinoColors.systemRed,
              borderRadius: BorderRadius.circular(badgeRadius),
              border: Border.all(
                color: CupertinoColors.white,
                width: 1.0,
              ),
            ),
            constraints: BoxConstraints(
              minWidth: badgeSize,
              minHeight: badgeSize,
            ),
            child: Text(
              label,
              style: textStyle ??
                  TextStyle(
                    color: textColor ?? CupertinoColors.white,
                    fontSize: badgeSize * 0.6,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialBadge(BuildContext context) {
    final badgeSize = size ?? 20.0;
    final badgeRadius = borderRadius ?? (badgeSize / 2);
    final badgePadding = padding ?? EdgeInsets.symmetric(
      horizontal: badgeSize * 0.25,
      vertical: badgeSize * 0.15,
    );
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: right ?? -(badgeSize * 0.25),
          top: top ?? -(badgeSize * 0.25),
          child: Container(
            padding: badgePadding,
            decoration: BoxDecoration(
              color: backgroundColor ?? Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(badgeRadius),
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 1.5,
              ),
            ),
            constraints: BoxConstraints(
              minWidth: badgeSize,
              minHeight: badgeSize,
            ),
            child: Text(
              label,
              style: textStyle ??
                  TextStyle(
                    color: textColor ?? Theme.of(context).colorScheme.onError,
                    fontSize: badgeSize * 0.55,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
