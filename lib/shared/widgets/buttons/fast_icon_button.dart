/// **FastIconButton** - Cross-platform icon button for actions and navigation.
///
/// **Use Case:**
/// For icon-based actions like navigation (back, close), utility actions (share, favorite),
/// or toolbar buttons. Provides consistent icon button behavior across iOS and Android
/// with appropriate platform styling.
///
/// **Key Features:**
/// - Platform-adaptive styling (CupertinoButton on iOS, IconButton on Android)
/// - Customizable icon, color, and size
/// - Disabled state with visual feedback
/// - Built-in haptic feedback on tap
/// - Optimized splash radius for better UX
///
/// **Important Parameters:**
/// - `icon`: Icon widget to display (required)
/// - `onTap`: Callback when button is pressed
/// - `color`: Icon color (uses theme default if not provided)
/// - `size`: Icon size (defaults to 24.0 on Android)
/// - `padding`: Button padding (platform defaults applied)
/// - `isDisabled`: Disables button and shows disabled styling
///
/// **Usage Examples:**
/// ```dart
/// // Basic back button
/// FastIconButton(icon: Icon(Icons.arrow_back), onTap: () => Navigator.pop(context))
///
/// // Favorite button with state
/// FastIconButton(
///   icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
///   color: isFavorite ? Colors.red : null,
///   onTap: () => toggleFavorite()
/// )
///
/// // Disabled state
/// FastIconButton(
///   icon: Icon(Icons.share),
///   isDisabled: !canShare,
///   onTap: () => shareContent()
/// )
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/export.dart';

class FastIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onTap;
  final Color? color;
  final double? size;
  final EdgeInsetsGeometry? padding;
  final bool isDisabled;
  final bool enableBackground;

  const FastIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.color,
    this.size,
    this.padding,
    this.isDisabled = false,
    this.enableBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isDisabled
        ? FastColors.disabled(context)
        : (color ?? Theme.of(context).iconTheme.color);

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      // iOS-style button
      return _backgroundWrapper(CupertinoButton(
          onPressed: isDisabled
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onTap?.call();
                },
          padding: padding ?? EdgeInsets.zero,
          child: icon));
    } else {
      return _backgroundWrapper(IconButton(
        icon: icon,
        onPressed: isDisabled
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap?.call();
              },
        color: effectiveColor,
        iconSize: size ?? 22.0,
        padding: padding ?? const EdgeInsets.all(8.0),
        splashRadius: 22.0,
      ));
    }
  }

  Widget _backgroundWrapper(
    Widget child,
  ) {
    return Container(
      width: 34,
      height: 34,
      decoration: enableBackground
          ? BoxDecoration(shape: BoxShape.circle, color: Colors.grey)
          : null,
      child: child,
    );
  }
}
