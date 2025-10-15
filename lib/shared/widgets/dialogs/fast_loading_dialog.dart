/// **FastLoadingDialog** - Cross-platform loading dialog with platform-appropriate indicators.
///
/// **Use Case:** 
/// Display loading states during async operations like API calls, file uploads, or data processing.
/// Provides visual feedback to users that the app is working on their request and prevents 
/// interaction during loading states.
///
/// **Key Features:**
/// - Platform-adaptive loading indicators (CupertinoActivityIndicator on iOS, CircularProgressIndicator on Android)
/// - Built-in internationalization support with GetX translations
/// - Custom indicator support for branded loading animations
/// - Non-dismissible by default to prevent interruption
/// - Static helper methods for easy show/hide operations
/// - Automatic GetX dialog management
///
/// **Important Parameters:**
/// - `message`: Loading message to display (defaults to translated "loading")
/// - `customIndicator`: Custom loading widget (replaces platform default)
///
/// **Usage Examples:**
/// ```dart
/// // Show basic loading dialog
/// FastLoadingDialog.show();
///
/// // With custom message
/// FastLoadingDialog.show(message: 'Uploading photo...');
///
/// // With custom indicator
/// FastLoadingDialog.show(
///   message: 'Processing...',
///   customIndicator: SpinKitFadingCircle(color: Colors.blue, size: 30)
/// );
///
/// // Hide loading dialog
/// FastLoadingDialog.hide();
///
/// // Complete async operation example
/// try {
///   FastLoadingDialog.show(message: 'Saving changes...');
///   await saveData();
///   FastLoadingDialog.hide();
///   // Show success feedback
/// } catch (e) {
///   FastLoadingDialog.hide();
///   // Show error dialog
/// }
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FastLoadingDialog extends StatelessWidget {
  final String? message;
  final Widget? customIndicator;

  const FastLoadingDialog({
    super.key,
    this.message,
    this.customIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS
        ? _buildCupertinoDialog()
        : _buildMaterialDialog();
  }

  Widget _buildCupertinoDialog() {
    return CupertinoAlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          customIndicator ?? const CupertinoActivityIndicator(),
          const SizedBox(height: 16),
          Text(message ?? 'loading'.tr),
        ],
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
          Text(message ?? 'loading'.tr),
        ],
      ),
    );
  }

  static void show({String? message, Widget? customIndicator}) {
    Get.dialog(
      FastLoadingDialog(message: message ?? 'loading'.tr, customIndicator: customIndicator),
      barrierDismissible: false,
    );
  }

  static void hide() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}
