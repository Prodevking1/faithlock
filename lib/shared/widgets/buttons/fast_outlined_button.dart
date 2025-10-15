/// **FastOutlinedButton** - Secondary action button with border styling.
///
/// **Use Case:**
/// For secondary actions that need less visual weight than primary buttons.
/// Perfect for cancel actions, alternative options, or when you need a button
/// that doesn't dominate the interface while still being clearly actionable.
///
/// **Key Features:**
/// - Clean outlined design with customizable border
/// - Loading state with spinner
/// - Disabled state with proper visual feedback
/// - Icon support with text
/// - Built-in haptic feedback
/// - Consistent styling across platforms
///
/// **Important Parameters:**
/// - `text`: Button text (can use with `child` for custom content)
/// - `onTap`: Callback when button is pressed (required for enabled state)
/// - `isLoading`: Shows loading spinner, disables interaction
/// - `isDisabled`: Disables button with grayed-out appearance
/// - `textColor`: Border and text color (defaults to primary theme color)
/// - `icon`: Optional icon widget displayed before text
/// - `width/height`: Custom button dimensions
/// - `borderRadius`: Custom border radius
///
/// **Usage Examples:**
/// ```dart
/// // Basic secondary action
/// FastOutlinedButton(text: 'Cancel', onTap: () => Navigator.pop(context))
///
/// // With custom styling
/// FastOutlinedButton(
///   text: 'Save Draft',
///   textColor: Colors.blue,
///   icon: Icon(Icons.draft),
///   onTap: () => saveDraft()
/// )
///
/// // Loading state
/// FastOutlinedButton(
///   text: 'Processing',
///   isLoading: isProcessing,
///   onTap: () => processAction()
/// )
/// ```

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/export.dart';

class FastOutlinedButton extends StatelessWidget {
  final Widget? child;
  final String? text;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final double? width;

  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool isLoading;
  final bool isDisabled;
  final Color? disabledColor;
  final Color? loadingColor;
  final Widget? icon;
  final double? elevation;

  /// Whether to add haptic feedback on tap (default: true)
  final bool hapticFeedback;

  const FastOutlinedButton({
    super.key,
    this.backgroundColor,
    this.child,
    this.text,
    this.textColor,
    this.onTap,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.isLoading = false,
    this.isDisabled = false,
    this.disabledColor,
    this.loadingColor,
    this.icon,
    this.elevation,
    this.hapticFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color effectiveTextColor = textColor ?? FastColors.primary;

    Widget buttonContent = isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                  loadingColor ?? effectiveTextColor),
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
                    style: theme.textTheme.titleMedium!.copyWith(
                      color: effectiveTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          );

    return GestureDetector(
      onTap: isDisabled || isLoading
          ? null
          : () {
              if (hapticFeedback) {
                HapticFeedback.lightImpact();
              }
              onTap?.call();
            },
      child: Container(
        width: width,
        height: height,
        padding:
            padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        constraints: const BoxConstraints(minHeight: 48),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDisabled
                ? FastColors.disabled(context).withValues(alpha: 0.3)
                : textColor ?? FastColors.primary,
            width: 1,
          ),
          borderRadius: borderRadius ?? BorderRadius.circular(10),
        ),
        child: buttonContent,
      ),
    );
  }
}
