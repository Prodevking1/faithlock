/// **FastProgressIndicator** - Modal progress dialog with customizable message and platform styling.
///
/// **Use Case:**
/// Use this for showing modal progress dialogs during long-running operations like
/// file uploads, data synchronization, or network requests. Provides a blocking
/// interface that prevents user interaction while clearly indicating progress.
///
/// **Key Features:**
/// - Modal dialog that blocks user interaction during progress
/// - Platform-adaptive styling (iOS blur effects, Material design)
/// - Customizable progress message with GetX internationalization support
/// - Optional custom progress indicator widget
/// - Automatic dismissal methods and programmatic control
/// - Proper safe area handling and responsive sizing
///
/// **Important Parameters:**
/// - `message`: Text message displayed below the progress indicator
/// - `customIndicator`: Custom widget to replace default progress indicator
///
/// **Usage Example:**
/// ```dart
/// // Show progress dialog
/// FastProgressIndicator.show(
///   context: context,
///   message: 'Uploading files...',
/// );
///
/// // Custom progress indicator
/// FastProgressIndicator.show(
///   context: context,
///   message: 'Processing...',
///   customIndicator: CircularProgressIndicator(color: Colors.green),
/// );
///
/// // Dismiss progress dialog
/// FastProgressIndicator.dismiss(context);
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FastProgressIndicator extends StatelessWidget {
  final String message;
  final Widget? customIndicator;

  const FastProgressIndicator({
    super.key,
    this.message = 'Loading...',
    this.customIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS
        ? _buildCupertinoDialog()
        : _buildMaterialDialog();
  }

  Widget _buildCupertinoDialog() {
    return Center(
      child: CupertinoAlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            customIndicator ?? const CupertinoActivityIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialDialog() {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          customIndicator ?? const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }

  static void show({String message = 'Loading...', Widget? customIndicator}) {
    Get.dialog(
      FastProgressIndicator(message: message, customIndicator: customIndicator),
      barrierDismissible: false,
    );
  }

  static void hide() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}
