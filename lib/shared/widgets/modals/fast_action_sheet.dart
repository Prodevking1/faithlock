/// **FastActionSheet** - Cross-platform action sheet with iOS CupertinoActionSheet and Material bottom sheet.
///
/// **Use Case:**
/// Use this for presenting users with a list of actions to choose from, typically triggered
/// by buttons or context menus. Perfect for destructive actions, option selection, or
/// any scenario where you need to present multiple choices with platform-native styling.
///
/// **Key Features:**
/// - Platform-adaptive styling (iOS CupertinoActionSheet, Material bottom sheet on Android)
/// - Support for destructive and cancel actions with appropriate styling
/// - Optional title and message for context
/// - Haptic feedback integration for iOS interactions
/// - GetX internationalization support for action labels
/// - Automatic safe area handling and responsive sizing
/// - Smooth animations with platform-appropriate timing
///
/// **Important Parameters:**
/// - `context`: BuildContext for modal presentation (required)
/// - `actions`: List of action buttons to display (required)
/// - `title`: Optional title text displayed at the top
/// - `message`: Optional descriptive message below title
/// - `cancelAction`: Optional cancel button (appears separately on iOS)
/// - `destructiveAction`: Optional destructive action with red styling
///
/// **Usage Example:**
/// ```dart
/// // Basic action sheet
/// FastActionSheet.show(
///   context: context,
///   actions: [
///     FastActionSheetAction(
///       text: 'Share',
///       onPressed: () => shareContent(),
///     ),
///     FastActionSheetAction(
///       text: 'Copy Link',
///       onPressed: () => copyLink(),
///     ),
///   ],
/// );
///
/// // Action sheet with title and destructive action
/// FastActionSheet.show(
///   context: context,
///   title: 'Delete Item',
///   message: 'This action cannot be undone.',
///   actions: [
///     FastActionSheetAction(
///       text: 'Delete',
///       isDestructive: true,
///       onPressed: () => deleteItem(),
///     ),
///   ],
///   cancelAction: FastActionSheetAction(
///     text: 'Cancel',
///     onPressed: () => Navigator.pop(context),
///   ),
/// );
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
class FastActionSheet {
  /// Show an action sheet with the given actions
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    required List<FastActionSheetAction<T>> actions,
    bool showCancelButton = true,
    String? cancelText,
    bool isDismissible = true,
    bool useHapticFeedback = true,
  }) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (useHapticFeedback && isIOS) {
      HapticFeedback.lightImpact();
    }

    if (isIOS) {
      return _showCupertinoActionSheet<T>(
        context: context,
        title: title,
        message: message,
        actions: actions,
        showCancelButton: showCancelButton,
        cancelText: cancelText,
        isDismissible: isDismissible,
      );
    } else {
      return _showMaterialActionSheet<T>(
        context: context,
        title: title,
        message: message,
        actions: actions,
        showCancelButton: showCancelButton,
        cancelText: cancelText,
        isDismissible: isDismissible,
      );
    }
  }

  /// Show iOS-native CupertinoActionSheet
  static Future<T?> _showCupertinoActionSheet<T>({
    required BuildContext context,
    String? title,
    String? message,
    required List<FastActionSheetAction<T>> actions,
    bool showCancelButton = true,
    String? cancelText,
    bool isDismissible = true,
  }) {
    return showCupertinoModalPopup<T>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: title != null ? Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: CupertinoColors.secondaryLabel,
            ),
          ) : null,
          message: message != null ? Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: CupertinoColors.secondaryLabel,
            ),
          ) : null,
          actions: actions.map((action) => CupertinoActionSheetAction(
            onPressed: () {
              HapticFeedback.selectionClick();
              if (action.onTap != null) {
                action.onTap!();
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pop(action.value);
              }
            },
            isDestructiveAction: action.isDestructive,
            isDefaultAction: action.isDefault,
            child: Text(
              action.text,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: action.isDestructive
                  ? CupertinoColors.destructiveRed
                  : CupertinoColors.systemBlue,
              ),
            ),
          )).toList(),
          cancelButton: showCancelButton ? CupertinoActionSheetAction(
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).pop();
            },
            child: Text(
              cancelText ?? 'cancel'.tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.systemBlue,
              ),
            ),
          ) : null,
        );
      },
    );
  }

  /// Show Material-style action sheet
  static Future<T?> _showMaterialActionSheet<T>({
    required BuildContext context,
    String? title,
    String? message,
    required List<FastActionSheetAction<T>> actions,
    bool showCancelButton = true,
    String? cancelText,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle indicator
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              if (title != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              // Message
              if (message != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Actions
              ...actions.map((action) => ListTile(
                title: Text(
                  action.text,
                  style: TextStyle(
                    color: action.isDestructive
                      ? Theme.of(context).colorScheme.error
                      : action.isDefault
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    fontWeight: action.isDefault ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                onTap: () {
                  if (action.onTap != null) {
                    action.onTap!();
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pop(action.value);
                  }
                },
              )),

              // Cancel button
              if (showCancelButton) ...[
                const Divider(height: 1),
                ListTile(
                  title: Text(
                    cancelText ?? 'cancel'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// Show a simple action sheet with predefined actions
  static Future<FastActionSheetResult?> showSimple({
    required BuildContext context,
    String? title,
    String? message,
    bool showCancelButton = true,
    String? cancelText,
    bool isDismissible = true,
    bool useHapticFeedback = true,
  }) {
    return show<FastActionSheetResult>(
      context: context,
      title: title,
      message: message,
      showCancelButton: showCancelButton,
      cancelText: cancelText,
      isDismissible: isDismissible,
      useHapticFeedback: useHapticFeedback,
      actions: [
        FastActionSheetAction<FastActionSheetResult>(
          text: 'ok'.tr,
          value: FastActionSheetResult.ok,
          isDefault: true,
        ),
      ],
    );
  }

  /// Show a confirmation action sheet with Yes/No options
  static Future<FastActionSheetResult?> showConfirmation({
    required BuildContext context,
    String? title,
    String? message,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
    bool isDismissible = true,
    bool useHapticFeedback = true,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return show<FastActionSheetResult>(
      context: context,
      title: title,
      message: message,
      showCancelButton: false, // We'll add our own cancel action
      isDismissible: isDismissible,
      useHapticFeedback: useHapticFeedback,
      actions: [
        FastActionSheetAction<FastActionSheetResult>(
          text: confirmText ?? 'confirm'.tr,
          value: FastActionSheetResult.confirmed,
          onTap: onConfirm,
          isDestructive: isDestructive,
          isDefault: !isDestructive,
        ),
        FastActionSheetAction<FastActionSheetResult>(
          text: cancelText ?? 'cancel'.tr,
          value: FastActionSheetResult.cancelled,
          onTap: onCancel,
          isDefault: false,
        ),
      ],
    );
  }


  /// Show a destructive action sheet (commonly used for delete confirmations)
  static Future<FastActionSheetResult?> showDestructive({
    required BuildContext context,
    String? title,
    String? message,
    String? destructiveText,
    String? cancelText,
    bool isDismissible = true,
    bool useHapticFeedback = true,
    VoidCallback? onDestructive,
    VoidCallback? onCancel,
  }) {
    return show<FastActionSheetResult>(
      context: context,
      title: title,
      message: message,
      showCancelButton: false,
      isDismissible: isDismissible,
      useHapticFeedback: useHapticFeedback,
      actions: [
        FastActionSheetAction<FastActionSheetResult>(
          text: destructiveText ?? 'delete'.tr,
          value: FastActionSheetResult.destructive,
          onTap: onDestructive,
          isDestructive: true,
        ),
        FastActionSheetAction<FastActionSheetResult>(
          text: cancelText ?? 'cancel'.tr,
          value: FastActionSheetResult.cancelled,
          onTap: onCancel,
          isDefault: true,
        ),
      ],
    );
  }

}

/// Represents an action in the action sheet
class FastActionSheetAction<T> {
  /// The text to display for this action
  final String text;

  /// The callback to execute when this action is selected
  final VoidCallback? onTap;

  /// The value to return when this action is selected (for backward compatibility)
  final T? value;

  /// Whether this action is destructive (styled with red color)
  final bool isDestructive;

  /// Whether this action is the default action (styled with bold text)
  final bool isDefault;

  /// Icon to display alongside the text (Material only)
  final IconData? icon;

  const FastActionSheetAction({
    required this.text,
    this.onTap,
    this.value,
    this.isDestructive = false,
    this.isDefault = false,
    this.icon,
  }) : assert(onTap != null || value != null, 'Either onTap callback or value must be provided');
}

/// Predefined results for simple action sheets
enum FastActionSheetResult {
  ok,
  cancelled,
  confirmed,
  destructive,
}

/// Extension for convenient action sheet usage
extension FastActionSheetExtension on BuildContext {
  /// Show a simple action sheet
  Future<FastActionSheetResult?> showActionSheet({
    String? title,
    String? message,
    List<FastActionSheetAction<FastActionSheetResult>>? actions,
    bool showCancelButton = true,
    String? cancelText,
    bool isDismissible = true,
    bool useHapticFeedback = true,
  }) {
    return FastActionSheet.show<FastActionSheetResult>(
      context: this,
      title: title,
      message: message,
      actions: actions ?? [],
      showCancelButton: showCancelButton,
      cancelText: cancelText,
      isDismissible: isDismissible,
      useHapticFeedback: useHapticFeedback,
    );
  }

  /// Show a confirmation action sheet
  Future<bool> showConfirmationActionSheet({
    String? title,
    String? message,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
    bool isDismissible = true,
    bool useHapticFeedback = true,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    final result = await FastActionSheet.showConfirmation(
      context: this,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      isDestructive: isDestructive,
      isDismissible: isDismissible,
      useHapticFeedback: useHapticFeedback,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );

    return result == FastActionSheetResult.confirmed;
  }

  /// Show a destructive action sheet
  Future<bool> showDestructiveActionSheet({
    String? title,
    String? message,
    String? destructiveText,
    String? cancelText,
    bool isDismissible = true,
    bool useHapticFeedback = true,
    VoidCallback? onDestructive,
    VoidCallback? onCancel,
  }) async {
    final result = await FastActionSheet.showDestructive(
      context: this,
      title: title,
      message: message,
      destructiveText: destructiveText,
      cancelText: cancelText,
      isDismissible: isDismissible,
      useHapticFeedback: useHapticFeedback,
      onDestructive: onDestructive,
      onCancel: onCancel,
    );

    return result == FastActionSheetResult.destructive;
  }

}
