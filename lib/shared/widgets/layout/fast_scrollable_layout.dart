/// **FastScrollableLayout** - Enhanced scrollable layout optimized for iOS with native behavior.
///
/// **Use Case:**
/// Use this when you need scrollable content with native iOS behavior, proper keyboard
/// handling, and safe area management. Perfect for long-form content, lists, and
/// any scrollable interface that needs to feel native on iOS devices.
///
/// **Key Features:**
/// - Native iOS bounce scrolling with proper physics
/// - Automatic keyboard handling and dismissal
/// - iOS system margins and spacing
/// - Orientation-aware layout adaptation
/// - Enhanced safe area management
/// - Performance optimizations for smooth scrolling
///
/// **Important Parameters:**
/// - `child`: Content widget to be made scrollable
/// - `enableIOSOptimizations`: Use iOS-specific optimizations (default: true)
/// - `autoAdjustForIOSKeyboard`: Auto-handle keyboard appearance (default: true)
/// - `useIOSSystemMargins`: Apply iOS standard margins (default: true)
/// - `scrollDirection`: Scroll direction (vertical/horizontal)
/// - `physics`: Custom scroll physics override
/// - `controller`: Custom scroll controller
///
/// **Usage Example:**
/// ```dart
/// // Basic scrollable content
/// FastScrollableLayout(child: LongContent())
///
/// // iOS-optimized with keyboard handling
/// FastScrollableLayout(
///   child: YourContent(),
///   enableIOSOptimizations: true,
///   autoAdjustForIOSKeyboard: true,
///   useIOSSystemMargins: true,
/// )
/// ```

import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FastScrollableLayout extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool enableKeyboardDismiss;
  final Color? backgroundColor;
  final bool safeArea;
  final ScrollController? controller;
  final bool resizeToAvoidBottomInset;

  /// Whether to use iOS-specific system margins
  final bool useIOSSystemMargins;

  /// Whether to enable iOS-specific behavior optimizations
  final bool enableIOSOptimizations;

  /// Whether to automatically adjust for iOS keyboard
  final bool autoAdjustForIOSKeyboard;

  /// Whether to adapt layout for orientation changes
  final bool adaptToOrientation;

  /// Whether to use iOS native scroll indicators
  final bool useIOSScrollIndicators;

  /// Custom scroll behavior for iOS
  final ScrollBehavior? iosScrollBehavior;

  /// Whether to enable pull-to-refresh on iOS
  final bool enablePullToRefresh;

  /// Callback for pull-to-refresh
  final Future<void> Function()? onRefresh;

  const FastScrollableLayout({
    super.key,
    required this.child,
    this.padding,
    this.physics,
    this.enableKeyboardDismiss = true,
    this.backgroundColor,
    this.safeArea = true,
    this.controller,
    this.resizeToAvoidBottomInset = true,
    this.useIOSSystemMargins = true,
    this.enableIOSOptimizations = true,
    this.autoAdjustForIOSKeyboard = true,
    this.adaptToOrientation = true,
    this.useIOSScrollIndicators = true,
    this.iosScrollBehavior,
    this.enablePullToRefresh = false,
    this.onRefresh,
  });

  @override
  State<FastScrollableLayout> createState() => _FastScrollableLayoutState();
}

class _FastScrollableLayoutState extends State<FastScrollableLayout> {
  late ScrollController _scrollController;
  late Orientation _currentOrientation;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    // Initialize with a default value
    _currentOrientation = Orientation.portrait;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.adaptToOrientation) {
      final newOrientation = MediaQuery.of(context).orientation;
      if (newOrientation != _currentOrientation) {
        _currentOrientation = newOrientation;
        // Trigger haptic feedback on orientation change for iOS
        if (Platform.isIOS) {
          HapticFeedback.selectionClick();
        }
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
    final bool isLandscape = mediaQuery.orientation == Orientation.landscape;

    // Determine effective padding with orientation awareness
    EdgeInsetsGeometry effectivePadding = _calculateEffectivePadding(
      isIOS: isIOS,
      isIPad: isIPad,
      isLandscape: isLandscape,
      mediaQuery: mediaQuery,
    );

    // Determine enhanced scroll physics for iOS
    ScrollPhysics effectivePhysics = _getEffectiveScrollPhysics(isIOS);

    Widget content = _buildScrollableContent(
      isIOS: isIOS,
      effectivePadding: effectivePadding,
      effectivePhysics: effectivePhysics,
    );

    // Apply iOS scroll indicators if enabled
    if (isIOS && widget.useIOSScrollIndicators) {
      content = CupertinoScrollbar(
        controller: _scrollController,
        child: content,
      );
    } else if (!isIOS) {
      content = Scrollbar(
        controller: _scrollController,
        child: content,
      );
    }

    // Apply safe area handling
    if (widget.safeArea) {
      content = SafeArea(
        top: true,
        bottom: !(isIOS &&
            widget
                .autoAdjustForIOSKeyboard), // Let iOS handle bottom with keyboard
        left: true,
        right: true,
        maintainBottomViewPadding: isIOS && widget.autoAdjustForIOSKeyboard,
        child: content,
      );
    }

    Widget body = content;

    // Enhanced keyboard dismissal for iOS
    if (widget.enableKeyboardDismiss) {
      body = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          final FocusNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
            // Add haptic feedback for iOS
            if (isIOS) {
              HapticFeedback.selectionClick();
            }
          }
        },
        child: content,
      );
    }

    return Scaffold(
      backgroundColor:
          widget.backgroundColor ?? _getBackgroundColor(context, isIOS),
      body: body,
      resizeToAvoidBottomInset: widget.autoAdjustForIOSKeyboard
          ? widget.resizeToAvoidBottomInset
          : widget.resizeToAvoidBottomInset,
    );
  }

  /// Enhanced iPad detection
  bool _isIPad(double width, double height, bool isIOS) {
    if (!isIOS) return false;
    final double minDimension = width < height ? width : height;
    final double maxDimension = width > height ? width : height;
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
      double horizontalMargin;

      if (isIPad) {
        horizontalMargin = isLandscape ? 20.0 : 16.0;
      } else {
        horizontalMargin = 20.0; // iPhone standard
      }

      return EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 0);
    }

    return EdgeInsets.zero;
  }

  /// Get effective scroll physics with iOS optimizations
  ScrollPhysics _getEffectiveScrollPhysics(bool isIOS) {
    if (widget.physics != null) {
      return widget.physics!;
    }

    if (isIOS && widget.enableIOSOptimizations) {
      // Enhanced iOS scroll physics with proper bounce behavior
      return const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(
          decelerationRate: ScrollDecelerationRate.normal,
        ),
      );
    } else {
      return const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      );
    }
  }

  /// Build scrollable content with iOS optimizations
  Widget _buildScrollableContent({
    required bool isIOS,
    required EdgeInsetsGeometry effectivePadding,
    required ScrollPhysics effectivePhysics,
  }) {
    Widget scrollView = SingleChildScrollView(
      controller: _scrollController,
      physics: effectivePhysics,
      padding: effectivePadding,
      keyboardDismissBehavior: isIOS && widget.enableIOSOptimizations
          ? ScrollViewKeyboardDismissBehavior.onDrag
          : ScrollViewKeyboardDismissBehavior.manual,
      child: widget.child,
    );

    // Add pull-to-refresh for iOS if enabled
    if (isIOS && widget.enablePullToRefresh && widget.onRefresh != null) {
      scrollView = CustomScrollView(
        controller: _scrollController,
        physics: effectivePhysics,
        keyboardDismissBehavior: widget.enableIOSOptimizations
            ? ScrollViewKeyboardDismissBehavior.onDrag
            : ScrollViewKeyboardDismissBehavior.manual,
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: widget.onRefresh,
          ),
          SliverPadding(
            padding: effectivePadding,
            sliver: SliverToBoxAdapter(
              child: widget.child,
            ),
          ),
        ],
      );
    }

    return scrollView;
  }

  /// Get background color based on platform
  Color _getBackgroundColor(BuildContext context, bool isIOS) {
    if (isIOS) {
      return CupertinoColors.systemGroupedBackground.resolveFrom(context);
    } else {
      return Theme.of(context).scaffoldBackgroundColor;
    }
  }
}
