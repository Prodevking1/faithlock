/// **FastCenteredView** - Responsive centered layout with automatic iOS device adaptation.
///
/// **Use Case:**
/// Use this when you need content centered on screen with automatic adaptation to different
/// device sizes and orientations. Perfect for forms, content pages, and modal-style layouts
/// that need to look native on both iPhone and iPad.
///
/// **Key Features:**
/// - Automatic iOS device detection (iPhone, iPad, iPad Pro)
/// - Orientation-aware padding and spacing adjustments
/// - iOS standard margins (20pt iPhone, 16pt iPad)
/// - Enhanced safe area handling with multitasking support
/// - Automatic keyboard management with smooth animations
/// - Scrollable content with native bounce physics
///
/// **Important Parameters:**
/// - `child`: Content widget to be centered and made responsive
/// - `maxWidth`: Maximum content width (default: 1200)
/// - `scrollable`: Enable scrolling for overflow content (default: true)
/// - `useIOSSafeArea`: Apply iOS-specific safe area handling (default: true)
/// - `useIOSSystemMargins`: Use iOS standard margins (default: true)
/// - `useIOSBreakpoints`: Adapt for iPhone/iPad breakpoints (default: true)
/// - `adaptToOrientation`: Auto-adapt to orientation changes (default: true)
/// - `handleKeyboard`: Auto-handle keyboard appearance (default: true)
///
/// **Usage Example:**
/// ```dart
/// // Basic centered content
/// FastCenteredView(child: MyForm())
///
/// // iPad-optimized with custom width
/// FastCenteredView(
///   child: ArticleContent(),
///   maxWidth: 692, // iOS reading width
///   adaptToOrientation: true,
/// )
/// ```

import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Configuration for iOS safe area handling
class SafeAreaConfig {
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final EdgeInsets minimum;

  const SafeAreaConfig({
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.minimum = EdgeInsets.zero,
  });

  /// Default iOS safe area configuration
  factory SafeAreaConfig.ios() {
    return const SafeAreaConfig(
      top: true,
      bottom: true,
      left: true,
      right: true,
      minimum: EdgeInsets.zero,
    );
  }

  /// Safe area configuration for modals
  factory SafeAreaConfig.modal() {
    return const SafeAreaConfig(
      top: false, // Modal handles its own top area
      bottom: true,
      left: true,
      right: true,
      minimum: EdgeInsets.zero,
    );
  }
}

class FastCenteredView extends StatefulWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;

  /// Whether to use iOS-specific safe area handling
  final bool useIOSSafeArea;

  /// Whether to respect iOS system margins (20pt iPhone, 16pt iPad)
  final bool useIOSSystemMargins;

  /// Whether to adapt for iPhone and iPad breakpoints
  final bool useIOSBreakpoints;

  /// Whether to automatically adapt to orientation changes
  final bool adaptToOrientation;

  /// Whether to handle keyboard appearance automatically
  final bool handleKeyboard;

  /// Custom safe area configuration for iOS
  final SafeAreaConfig? iosSafeAreaConfig;

  const FastCenteredView({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding,
    this.scrollable = true,
    this.useIOSSafeArea = true,
    this.useIOSSystemMargins = true,
    this.useIOSBreakpoints = true,
    this.adaptToOrientation = true,
    this.handleKeyboard = true,
    this.iosSafeAreaConfig,
  });

  @override
  State<FastCenteredView> createState() => _FastCenteredViewState();
}

class _FastCenteredViewState extends State<FastCenteredView> {
  late Orientation _currentOrientation;

  @override
  void initState() {
    super.initState();
    // Initialize with a default value
    _currentOrientation = Orientation.portrait;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newOrientation = MediaQuery.of(context).orientation;
    if (widget.adaptToOrientation && newOrientation != _currentOrientation) {
      _currentOrientation = newOrientation;
      // Trigger haptic feedback on orientation change for iOS
      if (Platform.isIOS) {
        HapticFeedback.selectionClick();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final ThemeData theme = Theme.of(context);
    final bool isIOS = Platform.isIOS || theme.platform == TargetPlatform.iOS;

    // Calculate iOS-specific values
    final double screenWidth = mediaQuery.size.width;
    final double screenHeight = mediaQuery.size.height;
    final bool isIPad = _isIPad(screenWidth, screenHeight, isIOS);
    final bool isIPhonePlus = screenWidth >= 414 && screenWidth < 768 && isIOS;
    final bool isLandscape = mediaQuery.orientation == Orientation.landscape;

    // Determine effective padding with orientation awareness
    EdgeInsetsGeometry effectivePadding = _calculateEffectivePadding(
      isIOS: isIOS,
      isIPad: isIPad,
      isLandscape: isLandscape,
      mediaQuery: mediaQuery,
    );

    // Determine effective max width with iOS breakpoints
    double? effectiveMaxWidth = _calculateEffectiveMaxWidth(
      isIOS: isIOS,
      isIPad: isIPad,
      isIPhonePlus: isIPhonePlus,
      isLandscape: isLandscape,
      screenWidth: screenWidth,
    );

    Widget content = Container(
      constraints: BoxConstraints(
        maxWidth: effectiveMaxWidth ?? double.infinity,
      ),
      padding: effectivePadding,
      child: widget.child,
    );

    if (widget.scrollable) {
      content = SingleChildScrollView(
        physics: isIOS
            ? const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics())
            : const ClampingScrollPhysics(),
        keyboardDismissBehavior: isIOS && widget.handleKeyboard
            ? ScrollViewKeyboardDismissBehavior.onDrag
            : ScrollViewKeyboardDismissBehavior.manual,
        child: content,
      );
    }

    Widget layout = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: mediaQuery.size.width,
          minHeight: widget.handleKeyboard
              ? mediaQuery.size.height - mediaQuery.viewInsets.bottom
              : mediaQuery.size.height,
        ),
        child: Container(
          color: isIOS
              ? CupertinoColors.systemBackground.resolveFrom(context)
              : theme.scaffoldBackgroundColor,
          child: content,
        ),
      ),
    );

    // Apply enhanced iOS-specific safe area handling
    if (widget.useIOSSafeArea && isIOS) {
      final SafeAreaConfig config =
          widget.iosSafeAreaConfig ?? SafeAreaConfig.ios();
      layout = SafeArea(
        top: config.top,
        bottom: config.bottom &&
            !widget
                .handleKeyboard, // Don't apply bottom safe area if handling keyboard
        left: config.left,
        right: config.right,
        minimum: config.minimum,
        maintainBottomViewPadding: widget.handleKeyboard,
        child: layout,
      );
    } else if (!isIOS) {
      layout = SafeArea(child: layout);
    }

    return layout;
  }

  /// Enhanced iPad detection considering both dimensions and iOS
  bool _isIPad(double width, double height, bool isIOS) {
    if (!isIOS) return false;

    // iPad detection based on screen dimensions
    final double minDimension = width < height ? width : height;
    final double maxDimension = width > height ? width : height;

    // iPad Mini and larger have minimum 768pt width in portrait
    return minDimension >= 768 || maxDimension >= 1024;
  }

  /// Calculate effective padding with iOS standards and orientation awareness
  EdgeInsetsGeometry _calculateEffectivePadding({
    required bool isIOS,
    required bool isIPad,
    required bool isLandscape,
    required MediaQueryData mediaQuery,
  }) {
    if (widget.padding != null) {
      return widget.padding!;
    }

    if (isIOS && widget.useIOSSystemMargins) {
      // iOS standard margins with orientation adaptation
      double horizontalMargin;
      double verticalMargin;

      if (isIPad) {
        horizontalMargin =
            isLandscape ? 20.0 : 16.0; // More margin in landscape
        verticalMargin = 16.0;
      } else {
        horizontalMargin = 20.0; // iPhone standard
        verticalMargin =
            isLandscape ? 8.0 : 16.0; // Less vertical margin in landscape
      }

      // Adjust for safe areas if needed
      final EdgeInsets safeAreaInsets = mediaQuery.padding;
      final double additionalTop = safeAreaInsets.top > 0 ? 0.0 : 8.0;
      final double additionalBottom = safeAreaInsets.bottom > 0 ? 0.0 : 8.0;

      return EdgeInsets.only(
        left: horizontalMargin,
        right: horizontalMargin,
        top: verticalMargin + additionalTop,
        bottom: verticalMargin + additionalBottom,
      );
    }

    return const EdgeInsets.all(16.0);
  }

  /// Calculate effective max width with iOS breakpoints and orientation
  double? _calculateEffectiveMaxWidth({
    required bool isIOS,
    required bool isIPad,
    required bool isIPhonePlus,
    required bool isLandscape,
    required double screenWidth,
  }) {
    if (!widget.useIOSBreakpoints || !isIOS) {
      return widget.maxWidth;
    }

    if (isIPad) {
      if (isLandscape) {
        // iPad landscape: use reading width for better readability
        return widget.maxWidth ?? 692.0;
      } else {
        // iPad portrait: use most of the width
        return widget.maxWidth ?? (screenWidth * 0.9);
      }
    } else if (isIPhonePlus && isLandscape) {
      // iPhone Plus landscape: constrain width for readability
      return widget.maxWidth ?? 600.0;
    }

    // Regular iPhone: use full width
    return null;
  }

  /// Get iOS system margin based on device type
  static double getIOSSystemMargin(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double screenHeight = mediaQuery.size.height;
    final bool isIPad = _isIPadStatic(screenWidth, screenHeight);
    return isIPad ? 16.0 : 20.0;
  }

  /// Check if current device is iPad (static version)
  static bool isIPad(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return _isIPadStatic(mediaQuery.size.width, mediaQuery.size.height);
  }

  /// Static iPad detection helper
  static bool _isIPadStatic(double width, double height) {
    final double minDimension = width < height ? width : height;
    final double maxDimension = width > height ? width : height;
    return minDimension >= 768 || maxDimension >= 1024;
  }
}

/// Backward compatibility alias
typedef CenteredView = FastCenteredView;
