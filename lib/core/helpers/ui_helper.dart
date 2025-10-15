// File: lib/core/helpers/ui_helper.dart

// This UIHelper class provides a set of static methods to display various UI elements
// such as snackbars, alert dialogs, confirmation dialogs, bottom sheets, and action sheets.
// It aims to provide a consistent look and feel across both iOS and Android platforms
// while respecting the native design guidelines of each.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

class UIHelper {
  static void showSnackBar({
    required String message,
    Color backgroundColor = Colors.blue,
    Color textColor = Colors.white,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final BuildContext context = Get.context!;
      if (context.mounted) {
        final SnackBar snackBar = SnackBar(
          content: Row(
            children: <Widget>[
              if (icon != null) Icon(icon, color: textColor),
              if (icon != null) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: textColor),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: duration,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  static void showErrorSnackBar(String message) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error_outline,
    );
  }

  static void showSuccessSnackBar(String message) {
    showSnackBar(
      message: message,
      icon: Icons.check_circle_outline,
    );
  }

  static void showInfoSnackBar(String message) {
    showSnackBar(
      message: message,
      icon: Icons.info_outline,
    );
  }

  static Future<void> showAlertDialog({
    required String title,
    required String message,
    String confirmText = 'OK',
  }) async {
    final BuildContext context = Get.context!;
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child: Text(confirmText),
            ),
          ],
        ),
      );
    } else {
      return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(confirmText.toUpperCase()),
            ),
          ],
        ),
      );
    }
  }

  static Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final BuildContext context = Get.context!;
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return await showCupertinoDialog<bool>(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(cancelText),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(confirmText),
                ),
              ],
            ),
          ) ??
          false;
    } else {
      return await showDialog<bool>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(cancelText.toUpperCase()),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(confirmText.toUpperCase()),
                ),
              ],
            ),
          ) ??
          false;
    }
  }

  static Future<void> showBottomSheet({
    required List<Widget> children,
    String? title,
  }) async {
    final BuildContext context = Get.context!;
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: title != null ? Text(title) : null,
          actions: children,
          cancelButton: CupertinoActionSheetAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
    } else {
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ...children,
                TextButton(
                  child: const Text('CANCEL'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  static Future<void> showActionSheet({
    required List<Widget> actions,
    String? title,
  }) async {
    final BuildContext context = Get.context!;
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: title != null ? Text(title) : null,
          actions: actions,
          cancelButton: CupertinoActionSheetAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
    } else {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: title != null ? Text(title) : null,
            content: SingleChildScrollView(
              child: ListBody(
                children: actions,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }

  static Future<T?> showFlexibleActionSheet<T>({
    required BuildContext context,
    required String title,
    required List<ActionSheetItem<T>> items,
    VoidCallback? onCancel,
  }) async {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return await showCupertinoModalPopup<T>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: Text(title),
          actions: items
              .map((ActionSheetItem<T> item) => CupertinoActionSheetAction(
                    child: item.child,
                    onPressed: () => Navigator.of(context).pop(item.value),
                  ))
              .toList(),
          cancelButton: CupertinoActionSheetAction(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
              onCancel?.call();
            },
          ),
        ),
      );
    } else {
      return await showDialog<T>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: items
                    .map((ActionSheetItem<T> item) => ListTile(
                          title: item.child,
                          onTap: () => Navigator.of(context).pop(item.value),
                        ))
                    .toList(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                  onCancel?.call();
                },
              ),
            ],
          );
        },
      );
    }
  }

  static Future<String?> showInputDialog({
    required String title,
    required String hintText,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
  }) async {
    final BuildContext context = Get.context!;
    final TextEditingController controller = TextEditingController();

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return await showCupertinoDialog<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(title),
          content: Column(
            children: <Widget>[
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: controller,
                placeholder: hintText,
              ),
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(cancelText),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: Text(confirmText),
            ),
          ],
        ),
      );
    } else {
      return await showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hintText),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(cancelText.toUpperCase()),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: Text(confirmText.toUpperCase()),
            ),
          ],
        ),
      );
    }
  }

  // static Future showFastBottomSheet({
  //   required BuildContext context,
  //   required Widget child,
  // }) async {
  //   if (Theme.of(context).platform == TargetPlatform.iOS) {
  //     return await CupertinoScaffold.showCupertinoModalBottomSheet(
  //       previousRouteAnimationCurve: Curves.easeInOut,
  //       context: context,
  //       expand: true,
  //       builder: (context) => Padding(padding: EdgeInsets.zero, child: child),
  //     );
  //   } else {
  //     return showModalBottomSheet(
  //       context: context,
  //       builder: (context) => child,
  //     );
  //   }
  // }
}

class ActionSheetItem<T> {
  final Widget child;
  final T value;

  ActionSheetItem({required this.child, required this.value});
}
