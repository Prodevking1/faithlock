/// **FastPlainButton** - Minimal text-only button for subtle actions.
///
/// **Use Case:**
/// For low-priority actions that don't need visual emphasis, like "Skip",
/// "Learn More", or "Forgot Password". Provides a clean text-only appearance
/// that doesn't compete with primary actions while remaining interactive.
///
/// **Key Features:**
/// - Minimal design with text-only appearance
/// - Platform-adaptive styling (CupertinoButton on iOS, TextButton on Android)
/// - Loading state with platform-appropriate spinner
/// - Disabled state with grayed-out text
/// - Icon support for enhanced clarity
/// - Built-in haptic feedback
///
/// **Important Parameters:**
/// - `text`: Button text (can use with `child` for custom content)
/// - `onTap`: Callback when button is pressed
/// - `textColor`: Text color (uses platform primary color if not provided)
/// - `isLoading`: Shows loading spinner, disables interaction
/// - `isDisabled`: Disables button with grayed-out appearance
/// - `icon`: Optional icon widget displayed before text
/// - `width/height`: Custom button dimensions
///
/// **Usage Examples:**
/// ```dart
/// // Basic link-style action
/// FastPlainButton(text: 'Forgot Password?', onTap: () => showForgotPassword())
///
/// // Skip action
/// FastPlainButton(text: 'Skip', onTap: () => skipStep())
///
/// // With icon and custom color
/// FastPlainButton(
///   text: 'Learn More',
///   icon: Icon(Icons.info_outline),
///   textColor: Colors.blue,
///   onTap: () => showInfo()
/// )
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FastPlainButton extends StatelessWidget {
  final Widget? child;
  final String? text;
  final Color? textColor;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;

  /// Whether to add haptic feedback on tap (default: true)
  final bool hapticFeedback;

  const FastPlainButton({
    super.key,
    this.child,
    this.text,
    this.textColor,
    this.onTap,
    this.width,
    this.height,
    this.padding,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.hapticFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color effectiveTextColor = isDisabled
        ? (Theme.of(context).platform == TargetPlatform.iOS
            ? CupertinoColors.inactiveGray
            : Colors.grey)
        : (textColor ??
            (Theme.of(context).platform == TargetPlatform.iOS
                ? CupertinoColors.activeBlue
                : theme.primaryColor));

    Widget buttonContent = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: Theme.of(context).platform == TargetPlatform.iOS
                ? CupertinoActivityIndicator(color: effectiveTextColor)
                : CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(effectiveTextColor),
                  ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                icon!,
                const SizedBox(width: 8),
              ],
              if (child != null)
                child!
              else
                Flexible(
                  child: Text(
                    text ?? "Button",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: effectiveTextColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 17,
                    ),
                  ),
                ),
            ],
          );

    void _handleTap() {
      if (hapticFeedback) {
        HapticFeedback.lightImpact();
      }
      onTap?.call();
    }

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return CupertinoButton(
        onPressed: (isDisabled || isLoading) ? null : _handleTap,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.fromHeight(height ?? 44),
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          child: buttonContent,
        ),
      );
    } else {
      return TextButton(
        onPressed: (isDisabled || isLoading) ? null : _handleTap,
        style: TextButton.styleFrom(
          foregroundColor: effectiveTextColor,
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: Size(width ?? 0, height ?? 44),
        ),
        child: Container(
          width: width,
          alignment: Alignment.center,
          child: buttonContent,
        ),
      );
    }
  }
}
