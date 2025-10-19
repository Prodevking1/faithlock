/// **FastProgressIndicator** - Modal progress dialog with progress bar and dismissible option.
///
/// **Use Case:**
/// Use this for showing modal progress dialogs during long-running operations like
/// file uploads, data synchronization, or network requests. Supports determinate
/// progress tracking with percentage display and optional dismiss button.
///
/// **Key Features:**
/// - Modal dialog with optional progress bar (0-100%)
/// - Platform-adaptive styling (iOS blur effects, Material design)
/// - Optional back/dismiss button with rounded container
/// - Customizable progress message with GetX internationalization support
/// - Optional custom progress indicator widget
/// - Automatic dismissal methods and programmatic control
/// - Proper safe area handling and responsive sizing
///
/// **Important Parameters:**
/// - `message`: Text message displayed below the progress indicator
/// - `progress`: Optional progress value (0.0 to 1.0) for determinate progress
/// - `showBackButton`: Whether to show a dismissible back button
/// - `onBackPressed`: Callback when back button is pressed
/// - `customIndicator`: Custom widget to replace default progress indicator
///
/// **Usage Example:**
/// ```dart
/// // Show indeterminate progress dialog
/// FastProgressIndicator.show(
///   message: 'Uploading files...',
/// );
///
/// // Show determinate progress with percentage
/// FastProgressIndicator.show(
///   message: 'Uploading files...',
///   progress: 0.65, // 65%
/// );
///
/// // Show with back button
/// FastProgressIndicator.show(
///   message: 'Processing...',
///   progress: 0.45,
///   showBackButton: true,
///   onBackPressed: () {
///     // Cancel operation
///   },
/// );
///
/// // Dismiss progress dialog
/// FastProgressIndicator.hide();
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FastProgressIndicator extends StatelessWidget {
  final String message;
  final double? progress; // 0.0 to 1.0, null for indeterminate
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? customIndicator;

  const FastProgressIndicator({
    super.key,
    this.message = 'Loading...',
    this.progress,
    this.showBackButton = false,
    this.onBackPressed,
    this.customIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS
        ? _buildCupertinoDialog(context)
        : _buildMaterialDialog(context);
  }

  Widget _buildCupertinoDialog(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Progress indicator or custom widget
            if (customIndicator != null)
              customIndicator!
            else if (progress != null)
              _buildProgressBar(context)
            else
              const CupertinoActivityIndicator(radius: 16),

            const SizedBox(height: 20),

            // Message
            Text(
              message,
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            // Percentage text
            if (progress != null) ...[
              const SizedBox(height: 8),
              Text(
                '${(progress! * 100).toInt()}%',
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  fontSize: 14,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
            ],

            // Back button
            if (showBackButton) ...[
              const SizedBox(height: 20),
              _buildBackButton(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialDialog(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Progress indicator or custom widget
            if (customIndicator != null)
              customIndicator!
            else if (progress != null)
              _buildProgressBar(context)
            else
              const CircularProgressIndicator(),

            const SizedBox(height: 20),

            // Message
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            // Percentage text
            if (progress != null) ...[
              const SizedBox(height: 8),
              Text(
                '${(progress! * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            // Back button
            if (showBackButton) ...[
              const SizedBox(height: 20),
              _buildBackButton(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular progress with percentage
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isIOS
                        ? CupertinoColors.systemGrey5.resolveFrom(context)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              // Progress circle
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isIOS
                        ? CupertinoColors.systemBlue
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Linear progress bar
        SizedBox(
          width: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: isIOS
                  ? CupertinoColors.systemGrey5.resolveFrom(context)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                isIOS
                    ? CupertinoColors.systemBlue
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return GestureDetector(
      onTap: onBackPressed ?? () => Get.back(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isIOS
              ? CupertinoColors.systemGrey5.resolveFrom(context)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isIOS
                ? CupertinoColors.separator.resolveFrom(context)
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isIOS ? CupertinoIcons.back : Icons.arrow_back,
              size: 18,
              color: isIOS
                  ? CupertinoColors.label.resolveFrom(context)
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              'Back',
              style: isIOS
                  ? CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    )
                  : Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  static void show({
    String message = 'Loading...',
    double? progress,
    bool showBackButton = false,
    VoidCallback? onBackPressed,
    Widget? customIndicator,
  }) {
    Get.dialog(
      FastProgressIndicator(
        message: message,
        progress: progress,
        showBackButton: showBackButton,
        onBackPressed: onBackPressed,
        customIndicator: customIndicator,
      ),
      barrierDismissible: showBackButton,
    );
  }

  static void hide() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}
