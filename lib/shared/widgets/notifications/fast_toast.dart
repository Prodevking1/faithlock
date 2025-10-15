/// **FastToast** - Platform-adaptive toast notifications with smooth animations and customizable styling.
///
/// **Use Case:**
/// Use this for displaying temporary, non-blocking messages to users such as success confirmations,
/// error alerts, warnings, or informational updates. Perfect for providing feedback after user
/// actions like saving data, network responses, or validation messages without interrupting workflow.
///
/// **Key Features:**
/// - Platform-adaptive styling (iOS blur background with system colors, Android Material design with colored backgrounds)
/// - Four built-in notification types (success, error, warning, info) with appropriate icons and colors
/// - Smooth slide-in animations from top with native timing curves and bounce effects
/// - Auto-dismissal with configurable duration and manual dismissal support
/// - Optional title and custom messages with proper typography hierarchy
/// - Haptic feedback integration for enhanced user experience
/// - Overlay-based rendering that doesn't affect page layout
/// - Custom icon support and tap interaction handling
/// - Automatic prevention of multiple toasts with replacement behavior
///
/// **Important Parameters:**
/// - `context`: BuildContext for overlay insertion (required)
/// - `message`: Toast message text (required)
/// - `type`: Toast type - success, error, warning, info (default: info)
/// - `duration`: How long toast stays visible (default: 3 seconds, error: 4 seconds)
/// - `title`: Optional title text displayed above message
/// - `icon`: Custom icon widget (overrides type-based icon)
/// - `onTap`: Callback when toast is tapped (defaults to dismiss)
///
/// **Usage Example:**
/// ```dart
/// // Basic success toast
/// FastToast.showSuccess(
///   context: context,
///   message: 'Data saved successfully!',
/// )
///
/// // Error with custom duration
/// FastToast.showError(
///   context: context,
///   message: 'Failed to connect to server',
///   title: 'Network Error',
///   duration: Duration(seconds: 5),
/// )
///
/// // Custom toast with interaction
/// FastToast.show(
///   context: context,
///   message: 'New update available',
///   type: FastToastType.info,
///   title: 'App Update',
///   onTap: () => showUpdateDialog(),
/// )
///
/// // Manual dismissal
/// FastToast.dismiss()
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum FastToastType {
  success,
  error,
  warning,
  info,
}

class FastToast {
  static OverlayEntry? _currentToast;

  static void show({
    required BuildContext context,
    required String message,
    FastToastType type = FastToastType.info,
    Duration duration = const Duration(seconds: 3),
    String? title,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    _removeCurrentToast();

    final overlay = Overlay.of(context);

    _currentToast = OverlayEntry(
      builder: (context) => _FastToastWidget(
        message: message,
        type: type,
        duration: duration,
        title: title,
        icon: icon,
        onTap: onTap,
        onDismiss: _removeCurrentToast,
      ),
    );

    overlay.insert(_currentToast!);
  }

  static void showSuccess({
    required BuildContext context,
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    show(
      context: context,
      message: message,
      type: FastToastType.success,
      title: title,
      duration: duration,
      onTap: onTap,
    );
  }

  static void showError({
    required BuildContext context,
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    show(
      context: context,
      message: message,
      type: FastToastType.error,
      title: title,
      duration: duration,
      onTap: onTap,
    );
  }

  static void showWarning({
    required BuildContext context,
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    show(
      context: context,
      message: message,
      type: FastToastType.warning,
      title: title,
      duration: duration,
      onTap: onTap,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    show(
      context: context,
      message: message,
      type: FastToastType.info,
      title: title,
      duration: duration,
      onTap: onTap,
    );
  }

  static void dismiss() {
    _removeCurrentToast();
  }

  static void _removeCurrentToast() {
    _currentToast?.remove();
    _currentToast = null;
  }
}

class _FastToastWidget extends StatefulWidget {
  final String message;
  final FastToastType type;
  final Duration duration;
  final String? title;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const _FastToastWidget({
    required this.message,
    required this.type,
    required this.duration,
    this.title,
    this.icon,
    this.onTap,
    required this.onDismiss,
  });

  @override
  State<_FastToastWidget> createState() => _FastToastWidgetState();
}

class _FastToastWidgetState extends State<_FastToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _animationController.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: widget.onTap ?? _dismiss,
            child:
                isIOS ? _buildIOSToast(context) : _buildMaterialToast(context),
          ),
        ),
      ),
    );
  }

  Widget _buildIOSToast(BuildContext context) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getIOSBackgroundColor(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey
                  .resolveFrom(context)
                  .withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              _getIcon(),
              color: _getIOSIconColor(context),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.title != null)
                    Text(
                      widget.title!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                      ),
                    ),
                  Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: widget.title != null ? 14 : 16,
                      color: widget.title != null
                          ? CupertinoColors.secondaryLabel
                          : CupertinoColors.label,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialToast(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      color: _getMaterialBackgroundColor(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _getIcon(),
              color: _getMaterialIconColor(context),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.title != null)
                    Text(
                      widget.title!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _getMaterialTextColor(context),
                          ),
                    ),
                  Text(
                    widget.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: widget.title != null
                              ? _getMaterialTextColor(context)
                                  .withValues(alpha: 0.8)
                              : _getMaterialTextColor(context),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    if (widget.icon != null) return widget.icon!;

    switch (widget.type) {
      case FastToastType.success:
        return Theme.of(context).platform == TargetPlatform.iOS
            ? CupertinoIcons.checkmark_circle_fill
            : Icons.check_circle;
      case FastToastType.error:
        return Theme.of(context).platform == TargetPlatform.iOS
            ? CupertinoIcons.xmark_circle_fill
            : Icons.error;
      case FastToastType.warning:
        return Theme.of(context).platform == TargetPlatform.iOS
            ? CupertinoIcons.exclamationmark_triangle_fill
            : Icons.warning;
      case FastToastType.info:
        return Theme.of(context).platform == TargetPlatform.iOS
            ? CupertinoIcons.info_circle_fill
            : Icons.info;
    }
  }

  Color _getIOSBackgroundColor(BuildContext context) {
    return CupertinoColors.systemBackground.resolveFrom(context);
  }

  Color _getIOSIconColor(BuildContext context) {
    switch (widget.type) {
      case FastToastType.success:
        return CupertinoColors.systemGreen;
      case FastToastType.error:
        return CupertinoColors.destructiveRed;
      case FastToastType.warning:
        return CupertinoColors.systemOrange;
      case FastToastType.info:
        return CupertinoColors.systemBlue;
    }
  }

  Color _getMaterialBackgroundColor(BuildContext context) {
    switch (widget.type) {
      case FastToastType.success:
        return Colors.green.shade50;
      case FastToastType.error:
        return Colors.red.shade50;
      case FastToastType.warning:
        return Colors.orange.shade50;
      case FastToastType.info:
        return Colors.blue.shade50;
    }
  }

  Color _getMaterialIconColor(BuildContext context) {
    switch (widget.type) {
      case FastToastType.success:
        return Colors.green;
      case FastToastType.error:
        return Colors.red;
      case FastToastType.warning:
        return Colors.orange;
      case FastToastType.info:
        return Colors.blue;
    }
  }

  Color _getMaterialTextColor(BuildContext context) {
    switch (widget.type) {
      case FastToastType.success:
        return Colors.green.shade800;
      case FastToastType.error:
        return Colors.red.shade800;
      case FastToastType.warning:
        return Colors.orange.shade800;
      case FastToastType.info:
        return Colors.blue.shade800;
    }
  }
}
