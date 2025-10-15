/// **FastDestructiveButton** - Specialized button for destructive actions with red styling.
///
/// **Use Case:** 
/// For dangerous or irreversible actions like delete, remove, cancel subscriptions, 
/// or logout. Provides clear visual indication that the action is destructive with 
/// consistent red styling across platforms.
///
/// **Key Features:**
/// - Platform-adaptive destructive styling (red background)
/// - Built-in loading state with activity indicator
/// - Disabled state with proper visual feedback
/// - Icon support for better context
/// - Haptic feedback for tactile confirmation
///
/// **Important Parameters:**
/// - `text`: Button text (defaults to "Delete" if not provided)
/// - `onTap`: Callback when button is pressed (required for enabled state)
/// - `isLoading`: Shows loading spinner, disables interaction
/// - `isDisabled`: Disables button with grayed-out appearance
/// - `icon`: Optional icon to clarify the destructive action
/// - `width/height`: Custom button dimensions
///
/// **Usage Examples:**
/// ```dart
/// // Basic delete button
/// FastDestructiveButton(text: 'Delete Account', onTap: () => deleteAccount())
///
/// // With confirmation loading state
/// FastDestructiveButton(
///   text: 'Remove Item', 
///   isLoading: isDeleting,
///   onTap: () => removeItem()
/// )
///
/// // With warning icon
/// FastDestructiveButton(
///   text: 'Clear All Data',
///   icon: Icon(Icons.warning, color: Colors.white),
///   onTap: () => clearData()
/// )
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FastDestructiveButton extends StatelessWidget {
  final Widget? child;
  final String? text;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;

  /// Whether to add haptic feedback on tap (default: true)
  final bool hapticFeedback;

  const FastDestructiveButton({
    super.key,
    this.child,
    this.text,
    this.onTap,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.hapticFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonContent = isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CupertinoActivityIndicator(color: CupertinoColors.white),
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
                    text ?? "Delete",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.w600,
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
        color: isDisabled
            ? CupertinoColors.inactiveGray
            : CupertinoColors.destructiveRed,
        disabledColor: CupertinoColors.inactiveGray,
        padding: padding ?? EdgeInsets.zero,
        borderRadius: borderRadius ?? BorderRadius.circular(10),
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          child: buttonContent,
        ),
        minimumSize: Size(height ?? 48, height ?? 55),
      );
    } else {
      return Material(
        elevation: 0,
        borderRadius: borderRadius ?? BorderRadius.circular(10),
        color: isDisabled ? Colors.grey.shade300 : Colors.red,
        child: InkWell(
          onTap: (isDisabled || isLoading) ? null : _handleTap,
          borderRadius: borderRadius ?? BorderRadius.circular(10),
          child: Container(
            width: width,
            height: height,
            constraints: const BoxConstraints(minHeight: 48),
            padding: padding ??
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Center(child: buttonContent),
          ),
        ),
      );
    }
  }
}
