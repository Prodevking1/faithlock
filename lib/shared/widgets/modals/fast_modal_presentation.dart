/// **FastModalPresentation** - iOS-style modal presentation with Apple HIG-compliant styles and animations.
///
/// **Use Case:**
/// Use this for presenting modal screens with native iOS styling and behavior patterns.
/// Perfect for forms, detail views, settings screens, or any full-screen content that
/// needs to be presented modally with proper iOS presentation styles and gestures.
///
/// **Key Features:**
/// - Multiple iOS presentation styles (pageSheet, fullScreenCover, formSheet)
/// - Native iOS animations and transitions with proper timing curves
/// - Pull-to-dismiss gesture support with haptic feedback
/// - Blur background effects following iOS design language
/// - Automatic safe area handling for all device types
/// - Keyboard avoidance and proper content sizing
/// - Accessibility support with proper navigation semantics
///
/// **Important Parameters:**
/// - `context`: BuildContext for modal presentation (required)
/// - `child`: Content widget to display in the modal (required)
/// - `style`: Presentation style (pageSheet, fullScreenCover, formSheet)
/// - `isDismissible`: Whether modal can be dismissed by gesture (default: true)
/// - `enableDrag`: Whether pull-to-dismiss is enabled (default: true)
/// - `backgroundColor`: Custom background color
/// - `barrierColor`: Custom barrier/backdrop color
/// - `animationDuration`: Custom animation duration
///
/// **Usage Example:**
/// ```dart
/// // Page sheet modal (default iOS style)
/// FastModalPresentation.show(
///   context: context,
///   child: MyModalContent(),
///   style: FastModalPresentationStyle.pageSheet,
/// );
///
/// // Full-screen modal
/// FastModalPresentation.show(
///   context: context,
///   child: FullScreenForm(),
///   style: FastModalPresentationStyle.fullScreenCover,
///   isDismissible: false,
/// );
///
/// // Form sheet with custom styling
/// FastModalPresentation.show(
///   context: context,
///   child: SettingsForm(),
///   style: FastModalPresentationStyle.formSheet,
///   enableDrag: true,
///   backgroundColor: Colors.white,
/// );
/// ```

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
enum FastModalPresentationStyle {
  /// Page sheet with rounded corners and visible background
  pageSheet,

  /// Form sheet centered with margins (iPad)
  formSheet,

  /// Full screen modal
  fullScreen,

  /// Over full screen with transparent background
  overFullScreen,
}

/// A modal presentation widget that follows iOS design patterns
class FastModalPresentation extends StatelessWidget {
  /// The content to display in the modal
  final Widget child;

  /// Modal presentation style
  final FastModalPresentationStyle style;

  /// Whether to show a drag indicator (page sheet only)
  final bool showDragIndicator;

  /// Whether to use blur effect on background
  final bool useBlurEffect;

  /// Background color (when not using blur)
  final Color? backgroundColor;

  /// Corner radius for page sheet and form sheet
  final double? cornerRadius;

  /// Called when modal should be dismissed
  final VoidCallback? onDismiss;

  /// Whether modal can be dismissed by swipe/tap outside
  final bool barrierDismissible;

  const FastModalPresentation({
    super.key,
    required this.child,
    this.style = FastModalPresentationStyle.pageSheet,
    this.showDragIndicator = true,
    this.useBlurEffect = true,
    this.backgroundColor,
    this.cornerRadius,
    this.onDismiss,
    this.barrierDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (!isIOS) {
      return _buildMaterialModal(context);
    }

    switch (style) {
      case FastModalPresentationStyle.pageSheet:
        return _buildPageSheet(context);
      case FastModalPresentationStyle.formSheet:
        return _buildFormSheet(context);
      case FastModalPresentationStyle.fullScreen:
        return _buildFullScreen(context);
      case FastModalPresentationStyle.overFullScreen:
        return _buildOverFullScreen(context);
    }
  }

  Widget _buildPageSheet(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final effectiveCornerRadius = cornerRadius ?? 16.0;

    // Add haptic feedback for presentation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HapticFeedback.lightImpact();
    });

    return GestureDetector(
      onTap: barrierDismissible
          ? () {
              HapticFeedback.lightImpact();
              onDismiss?.call();
            }
          : null,
      child: Container(
        color: Colors.black.withValues(alpha: 0.4), // iOS page sheet background
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // Prevent dismissal when tapping modal content
            onPanUpdate: barrierDismissible
                ? (details) {
                    // Handle swipe-to-dismiss gesture
                    if (details.delta.dy > 5) {
                      HapticFeedback.lightImpact();
                      onDismiss?.call();
                    }
                  }
                : null,
            child: Container(
              width: double.infinity,
              height: isLandscape
                  ? mediaQuery.size.height * 0.9
                  : mediaQuery.size.height * 0.85,
              margin: EdgeInsets.only(
                top: mediaQuery.padding.top +
                    (isLandscape ? 8 : 16), // Leave visible background
              ),
              child: useBlurEffect
                  ? ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(effectiveCornerRadius),
                        topRight: Radius.circular(effectiveCornerRadius),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: (backgroundColor ??
                                    CupertinoColors.systemBackground
                                        .resolveFrom(context))
                                .withValues(alpha: 0.85),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(effectiveCornerRadius),
                              topRight: Radius.circular(effectiveCornerRadius),
                            ),
                            border: Border.all(
                              color: CupertinoColors.separator
                                  .resolveFrom(context)
                                  .withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                          ),
                          child: _buildModalContent(),
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: backgroundColor ??
                            CupertinoColors.systemBackground
                                .resolveFrom(context),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(effectiveCornerRadius),
                          topRight: Radius.circular(effectiveCornerRadius),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(effectiveCornerRadius),
                          topRight: Radius.circular(effectiveCornerRadius),
                        ),
                        child: _buildModalContent(),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalContent() {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          if (showDragIndicator) _buildDragIndicator(),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildFormSheet(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width >= 768;
    final effectiveCornerRadius = cornerRadius ?? 12.0;

    // Add haptic feedback for presentation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HapticFeedback.lightImpact();
    });

    return GestureDetector(
      onTap: barrierDismissible
          ? () {
              HapticFeedback.lightImpact();
              onDismiss?.call();
            }
          : null,
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: isTablet ? 540 : mediaQuery.size.width * 0.9,
              height: isTablet ? 620 : mediaQuery.size.height * 0.7,
              child: useBlurEffect
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.circular(effectiveCornerRadius),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: (backgroundColor ??
                                    CupertinoColors.systemBackground
                                        .resolveFrom(context))
                                .withValues(alpha: 0.85),
                            borderRadius:
                                BorderRadius.circular(effectiveCornerRadius),
                            border: Border.all(
                              color: CupertinoColors.separator
                                  .resolveFrom(context)
                                  .withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                          ),
                          child: SafeArea(child: child),
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: backgroundColor ??
                            CupertinoColors.systemBackground
                                .resolveFrom(context),
                        borderRadius:
                            BorderRadius.circular(effectiveCornerRadius),
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(effectiveCornerRadius),
                        child: SafeArea(child: child),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullScreen(BuildContext context) {
    // Add haptic feedback for presentation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HapticFeedback.lightImpact();
    });

    return Container(
      color: backgroundColor ??
          CupertinoColors.systemBackground.resolveFrom(context),
      child: SafeArea(child: child),
    );
  }

  Widget _buildOverFullScreen(BuildContext context) {
    return GestureDetector(
      onTap: barrierDismissible ? onDismiss : null,
      child: Container(
        color: Colors.transparent,
        child: child,
      ),
    );
  }

  Widget _buildMaterialModal(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: style == FastModalPresentationStyle.pageSheet
            ? BorderRadius.only(
                topLeft: Radius.circular(cornerRadius ?? 16),
                topRight: Radius.circular(cornerRadius ?? 16),
              )
            : BorderRadius.circular(cornerRadius ?? 12),
      ),
      child: Column(
        children: [
          if (showDragIndicator &&
              style == FastModalPresentationStyle.pageSheet)
            _buildDragIndicator(),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildDragIndicator() {
    return Builder(
      builder: (context) => Container(
        width: 36,
        height: 5,
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey3.resolveFrom(context),
          borderRadius: BorderRadius.circular(2.5),
        ),
      ),
    );
  }

  /// Show a modal with iOS-native presentation
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    FastModalPresentationStyle style = FastModalPresentationStyle.pageSheet,
    bool showDragIndicator = true,
    bool useBlurEffect = true,
    Color? backgroundColor,
    double? cornerRadius,
    bool barrierDismissible = true,
    bool useRootNavigator = false,
  }) {
    return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
      _FastModalRoute<T>(
        child: child,
        style: style,
        showDragIndicator: showDragIndicator,
        useBlurEffect: useBlurEffect,
        backgroundColor: backgroundColor,
        cornerRadius: cornerRadius,
        dismissible: barrierDismissible,
      ),
    );
  }
}

class _FastModalRoute<T> extends PageRoute<T> {
  final Widget child;
  final FastModalPresentationStyle style;
  final bool showDragIndicator;
  final bool useBlurEffect;
  final Color? backgroundColor;
  final double? cornerRadius;
  final bool dismissible;

  _FastModalRoute({
    required this.child,
    required this.style,
    required this.showDragIndicator,
    required this.useBlurEffect,
    this.backgroundColor,
    this.cornerRadius,
    required this.dismissible,
  });

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => dismissible;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 350);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return FastModalPresentation(
      style: style,
      showDragIndicator: showDragIndicator,
      useBlurEffect: useBlurEffect,
      backgroundColor: backgroundColor,
      cornerRadius: cornerRadius,
      barrierDismissible: dismissible,
      onDismiss: () => Navigator.of(context).pop(),
      child: child,
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (!isIOS) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      );
    }

    switch (style) {
      case FastModalPresentationStyle.pageSheet:
      case FastModalPresentationStyle.formSheet:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      case FastModalPresentationStyle.fullScreen:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      case FastModalPresentationStyle.overFullScreen:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
    }
  }
}
