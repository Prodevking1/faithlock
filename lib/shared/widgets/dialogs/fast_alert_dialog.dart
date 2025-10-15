import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// **FastDialogAction** - Action button configuration for alert dialogs.
///
/// **Use Case:**
/// Defines the behavior and appearance of action buttons in FastAlertDialog.
/// Supports different action types (default, cancel, destructive) with platform-appropriate styling.

class FastDialogAction {
  /// The text displayed on the action button
  final String text;

  /// The callback when the action is pressed
  final VoidCallback? onPressed;

  /// Whether this action is destructive (shown in red on iOS)
  final bool isDestructive;

  /// Whether this action is the default action (emphasized on iOS)
  final bool isDefault;

  /// Whether this action is a cancel action (shown on the left on iOS)
  final bool isCancel;

  const FastDialogAction({
    required this.text,
    this.onPressed,
    this.isDestructive = false,
    this.isDefault = false,
    this.isCancel = false,
  });
}

/// **FastAlertDialog** - Cross-platform alert dialog with native styling and behavior.
///
/// **Use Case:** 
/// Display important messages, confirmations, or simple choices to users. Perfect for 
/// alerts, confirmations, error messages, or any modal interaction that requires user 
/// acknowledgment or decision. Automatically follows platform design conventions.
///
/// **Key Features:**
/// - Platform-adaptive styling (CupertinoAlertDialog on iOS, AlertDialog on Android)
/// - Flexible action system with support for different action types
/// - Proper action ordering according to platform conventions
/// - Support for both text messages and custom content
/// - Built-in haptic feedback on iOS
/// - Static helper method for easy showing
/// - Scrollable content support for longer messages
///
/// **Important Parameters:**
/// - `title`: Dialog title text (required)
/// - `message`: Main message text (use this OR content)
/// - `content`: Custom widget content (use this OR message)
/// - `actions`: List of FastDialogAction buttons (required)
/// - `scrollable`: Allow content scrolling for long messages
/// - `useIOSBlur`: Enable iOS blur effects
///
/// **Usage Examples:**
/// ```dart
/// // Simple confirmation dialog
/// FastAlertDialog.show(
///   context: context,
///   title: 'Delete Item',
///   message: 'Are you sure you want to delete this item?',
///   actions: [
///     FastDialogAction(text: 'Cancel', isCancel: true, onPressed: () => Navigator.pop(context)),
///     FastDialogAction(text: 'Delete', isDestructive: true, onPressed: () => deleteItem())
///   ]
/// )
///
/// // Info dialog with custom content
/// FastAlertDialog(
///   title: 'App Update',
///   content: Column(children: [
///     Text('Version 2.0 is available'),
///     Text('• New features', style: TextStyle(fontSize: 12)),
///     Text('• Bug fixes', style: TextStyle(fontSize: 12))
///   ]),
///   actions: [
///     FastDialogAction(text: 'Later', onPressed: () => Navigator.pop(context)),
///     FastDialogAction(text: 'Update', isDefault: true, onPressed: () => updateApp())
///   ]
/// )
/// ```

class FastAlertDialog extends StatelessWidget {
  /// The title of the dialog
  final String title;

  /// The message content of the dialog
  final String? message;

  /// Custom content widget (alternative to message)
  final Widget? content;

  /// List of actions to display in the dialog
  final List<FastDialogAction> actions;

  /// Whether the dialog content should be scrollable
  final bool scrollable;

  /// iOS-specific blur effect (only used on iOS)
  final bool useIOSBlur;

  const FastAlertDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    required this.actions,
    this.scrollable = false,
    this.useIOSBlur = true,
  }) : assert(
          message != null || content != null,
          'Either message or content must be provided',
        );

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return isIOS ? _buildIOSDialog(context) : _buildMaterialDialog(context);
  }

  Widget _buildIOSDialog(BuildContext context) {
    // Sort actions according to iOS conventions
    final sortedActions = _sortActionsForIOS();

    return CupertinoAlertDialog(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: content ??
          (message != null
              ? Text(
                  message!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                )
              : null),
      // scrollable: scrollable, // Not supported in CupertinoAlertDialog
      actions: sortedActions.map((action) => _buildIOSAction(action)).toList(),
    );
  }

  Widget _buildMaterialDialog(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: content ?? (message != null ? Text(message!) : null),
      scrollable: scrollable,
      actions: actions
          .map((action) => _buildMaterialAction(action, context))
          .toList(),
    );
  }

  /// Sort actions according to iOS conventions:
  /// - Cancel actions on the left
  /// - Destructive actions on the left (after cancel)
  /// - Default/confirm actions on the right
  List<FastDialogAction> _sortActionsForIOS() {
    final List<FastDialogAction> sortedActions = [];

    // Add cancel actions first
    sortedActions.addAll(actions.where((action) => action.isCancel));

    // Add destructive actions (non-cancel)
    sortedActions.addAll(
        actions.where((action) => action.isDestructive && !action.isCancel));

    // Add regular actions
    sortedActions.addAll(actions.where((action) =>
        !action.isDestructive && !action.isCancel && !action.isDefault));

    // Add default actions last
    sortedActions.addAll(actions.where((action) => action.isDefault));

    return sortedActions;
  }

  Widget _buildIOSAction(FastDialogAction action) {
    Color? textColor;
    FontWeight fontWeight = FontWeight.w400;

    if (action.isDestructive) {
      textColor = CupertinoColors.destructiveRed;
    } else if (action.isDefault) {
      textColor = CupertinoColors.activeBlue;
      fontWeight = FontWeight.w600;
    } else if (action.isCancel) {
      textColor = CupertinoColors.activeBlue;
    }

    return CupertinoDialogAction(
      onPressed: () {
        if (action.onPressed != null) {
          // Add haptic feedback for iOS
          HapticFeedback.lightImpact();
          action.onPressed!();
        }
      },
      isDefaultAction: action.isDefault,
      isDestructiveAction: action.isDestructive,
      textStyle: TextStyle(
        color: textColor,
        fontWeight: fontWeight,
        fontSize: 17,
      ),
      child: Text(action.text),
    );
  }

  Widget _buildMaterialAction(FastDialogAction action, BuildContext context) {
    Color? textColor;

    if (action.isDestructive) {
      textColor = Theme.of(context).colorScheme.error;
    } else if (action.isDefault) {
      textColor = Theme.of(context).colorScheme.primary;
    }

    return TextButton(
      onPressed: action.onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor,
      ),
      child: Text(action.text),
    );
  }

  /// Helper method to show the alert dialog
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    required List<FastDialogAction> actions,
    bool scrollable = false,
    bool useIOSBlur = true,
    bool barrierDismissible = false,
  }) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      return showCupertinoDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) => FastAlertDialog(
          title: title,
          message: message,
          content: content,
          actions: actions,
          scrollable: scrollable,
          useIOSBlur: useIOSBlur,
        ),
      );
    } else {
      return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) => FastAlertDialog(
          title: title,
          message: message,
          content: content,
          actions: actions,
          scrollable: scrollable,
        ),
      );
    }
  }
}
