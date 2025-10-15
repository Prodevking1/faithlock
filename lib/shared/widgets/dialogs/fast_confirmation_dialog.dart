/// **FastConfirmationDialog** - Simple yes/no confirmation dialog with platform-native styling.
///
/// **Use Case:** 
/// Quick confirmation dialogs for common yes/no decisions like "Delete item?", "Save changes?", 
/// "Exit without saving?". Provides a simplified API compared to FastAlertDialog for the most 
/// common dialog pattern with just two actions (cancel and confirm).
///
/// **Key Features:**
/// - Platform-adaptive styling (CupertinoAlertDialog on iOS, AlertDialog on Android)
/// - Built-in internationalization support with GetX translations
/// - Destructive action styling for dangerous confirmations
/// - Static helper method returns boolean result
/// - Built-in haptic feedback on iOS
/// - Proper action positioning according to platform conventions
///
/// **Important Parameters:**
/// - `title`: Dialog title text (required)
/// - `message`: Confirmation message text (required)
/// - `onConfirm`: Callback for confirm action (required)
/// - `onCancel`: Callback for cancel action (required)
/// - `confirmText`: Custom confirm button text (defaults to translated "confirm")
/// - `cancelText`: Custom cancel button text (defaults to translated "cancel")
/// - `isDestructiveConfirm`: Style confirm button as destructive (red on iOS)
/// - `useIOSBlur`: Enable iOS blur effects
///
/// **Usage Examples:**
/// ```dart
/// // Simple confirmation
/// bool result = await FastConfirmationDialog.show(
///   title: 'Delete Item',
///   message: 'This action cannot be undone.',
///   isDestructiveConfirm: true
/// );
/// if (result) deleteItem();
///
/// // Save confirmation with custom text
/// bool shouldSave = await FastConfirmationDialog.show(
///   title: 'Unsaved Changes',
///   message: 'Do you want to save your changes?',
///   confirmText: 'Save',
///   cancelText: 'Discard'
/// );
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FastConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  
  /// Whether the confirm action is destructive (shown in red on iOS)
  final bool isDestructiveConfirm;
  
  /// Whether to use iOS blur effect
  final bool useIOSBlur;

  const FastConfirmationDialog({
    required this.title,
    required this.message,
    required this.onConfirm,
    required this.onCancel,
    super.key,
    this.confirmText,
    this.cancelText,
    this.titleStyle,
    this.messageStyle,
    this.isDestructiveConfirm = false,
    this.useIOSBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS
        ? _buildCupertinoDialog()
        : _buildMaterialDialog();
  }

  Widget _buildCupertinoDialog() {
    return CupertinoAlertDialog(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
      actions: <Widget>[
        // Cancel button (left position, regular style)
        CupertinoDialogAction(
          onPressed: () {
            HapticFeedback.lightImpact();
            onCancel();
          },
          child: Text(
            cancelText ?? 'cancel'.tr,
            style: const TextStyle(
              color: CupertinoColors.activeBlue,
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        // Confirm button (right position, destructive if specified)
        CupertinoDialogAction(
          isDestructiveAction: isDestructiveConfirm,
          isDefaultAction: !isDestructiveConfirm,
          onPressed: () {
            HapticFeedback.lightImpact();
            onConfirm();
          },
          child: Text(
            confirmText ?? 'confirm'.tr,
            style: TextStyle(
              color: isDestructiveConfirm 
                ? CupertinoColors.destructiveRed 
                : CupertinoColors.activeBlue,
              fontSize: 17,
              fontWeight: isDestructiveConfirm 
                ? FontWeight.w400 
                : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialDialog() {
    return AlertDialog(
      title: Text(title, style: titleStyle),
      content: Text(message, style: messageStyle),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          onPressed: onCancel,
          child: Text((cancelText ?? 'cancel'.tr).toUpperCase()),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
          ),
          onPressed: onConfirm,
          child: Text((confirmText ?? 'confirm'.tr).toUpperCase()),
        ),
      ],
    );
  }

  static Future<bool> show({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    bool isDestructiveConfirm = false,
    bool useIOSBlur = true,
    bool barrierDismissible = false,
  }) async {
    return await Get.dialog<bool>(
          FastConfirmationDialog(
            title: title,
            message: message,
            confirmText: confirmText ?? 'confirm'.tr,
            cancelText: cancelText ?? 'cancel'.tr,
            titleStyle: titleStyle,
            messageStyle: messageStyle,
            isDestructiveConfirm: isDestructiveConfirm,
            useIOSBlur: useIOSBlur,
            onConfirm: () => Get.back(result: true),
            onCancel: () => Get.back(result: false),
          ),
          barrierDismissible: barrierDismissible,
        ) ??
        false;
  }
}
