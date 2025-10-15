/// **FastResponsiveLayout** - iOS-aware responsive layout following Apple Human Interface Guidelines.
///
/// **Use Case:**
/// Use this for creating responsive layouts that automatically adapt to different screen sizes
/// with proper iOS breakpoints and spacing. Perfect for universal apps that need to work
/// seamlessly across iPhone, iPad, and iPad Pro with proper multitasking support.
///
/// **Key Features:**
/// - iOS-specific breakpoints (iPhone, iPad, iPad Pro)
/// - Automatic orientation change adaptation
/// - iOS standard margins and spacing
/// - Adaptive typography and spacing
/// - Enhanced iPad multitasking support
/// - Performance optimizations for different screen sizes
///
/// **Important Parameters:**
/// - `child`: Widget to display responsively
/// - `useIOSBreakpoints`: Use iOS-specific breakpoints (default: true)
/// - `adaptiveTypography`: Auto-scale typography for different screens
/// - `adaptToOrientation`: Auto-adapt to orientation changes
/// - `enableMultitaskingSupport`: Enable iPad multitasking detection
/// - `customBreakpoints`: Override default responsive breakpoints
///
/// **Usage Example:**
/// ```dart
/// // Basic responsive layout
/// FastResponsiveLayout(child: MyContent())
///
/// // Custom responsive behavior
/// FastResponsiveLayout(
///   child: YourContent(),
///   useIOSBreakpoints: true,
///   adaptiveTypography: true,
///   adaptToOrientation: true,
/// )
/// ```

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class FastResponsiveLayout extends StatefulWidget {
  /// The widget to display responsively
  final Widget child;

  /// Custom breakpoints for responsive behavior
  final FastResponsiveBreakpoints? breakpoints;

  /// Whether to use iOS-specific responsive behavior
  final bool useIOSBreakpoints;

  /// Whether to adapt typography based on screen size
  final bool adaptiveTypography;

  /// Whether to adapt spacing based on screen size
  final bool adaptiveSpacing;

  /// Maximum width for content on larger screens
  final double? maxContentWidth;

  /// Whether to automatically adapt to orientation changes
  final bool adaptToOrientation;

  /// Whether to support iPad multitasking layouts
  final bool supportIPadMultitasking;

  /// Custom padding for different device types
  final EdgeInsetsGeometry? customPadding;

  /// Whether to use iOS standard margins
  final bool useIOSStandardMargins;

  const FastResponsiveLayout({
    super.key,
    required this.child,
    this.breakpoints,
    this.useIOSBreakpoints = true,
    this.adaptiveTypography = true,
    this.adaptiveSpacing = true,
    this.maxContentWidth,
    this.adaptToOrientation = true,
    this.supportIPadMultitasking = true,
    this.customPadding,
    this.useIOSStandardMargins = true,
  });

  @override
  State<FastResponsiveLayout> createState() => _FastResponsiveLayoutState();
}

class _FastResponsiveLayoutState extends State<FastResponsiveLayout> {
  late Orientation _currentOrientation;
  late Size _currentSize;

  @override
  void initState() {
    super.initState();
    // Initialize with default values
    _currentOrientation = Orientation.portrait;
    _currentSize = const Size(375, 812); // Default iPhone size
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.adaptToOrientation) {
      final mediaQuery = MediaQuery.of(context);
      final newOrientation = mediaQuery.orientation;
      final newSize = mediaQuery.size;

      if (newOrientation != _currentOrientation || newSize != _currentSize) {
        _currentOrientation = newOrientation;
        _currentSize = newSize;

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

    final FastResponsiveBreakpoints effectiveBreakpoints = widget.breakpoints ??
        (widget.useIOSBreakpoints && isIOS
            ? FastResponsiveBreakpoints.ios()
            : FastResponsiveBreakpoints.material());

    final FastDeviceType deviceType =
        effectiveBreakpoints.getDeviceType(mediaQuery);
    final FastScreenSize screenSize =
        effectiveBreakpoints.getScreenSize(mediaQuery);
    final FastIOSDeviceType iosDeviceType =
        _getIOSDeviceType(mediaQuery, isIOS);

    return FastResponsiveScope(
      deviceType: deviceType,
      screenSize: screenSize,
      breakpoints: effectiveBreakpoints,
      adaptiveTypography: widget.adaptiveTypography,
      adaptiveSpacing: widget.adaptiveSpacing,
      iosDeviceType: iosDeviceType,
      isLandscape: mediaQuery.orientation == Orientation.landscape,
      child: _buildAdaptiveContent(
          context, deviceType, screenSize, iosDeviceType, mediaQuery),
    );
  }

  /// Determine iOS-specific device type
  FastIOSDeviceType _getIOSDeviceType(MediaQueryData mediaQuery, bool isIOS) {
    if (!isIOS) return FastIOSDeviceType.other;

    final double width = mediaQuery.size.width;
    final double height = mediaQuery.size.height;
    final double minDimension = width < height ? width : height;
    final double maxDimension = width > height ? width : height;

    // iPad Pro 12.9" detection
    if (maxDimension >= 1366 && minDimension >= 1024) {
      return FastIOSDeviceType.iPadPro12;
    }

    // iPad Pro 11" / iPad Air detection
    if (maxDimension >= 1194 && minDimension >= 834) {
      return FastIOSDeviceType.iPadPro11;
    }

    // Regular iPad detection
    if (minDimension >= 768) {
      return FastIOSDeviceType.iPad;
    }

    // iPhone Plus/Max detection
    if (maxDimension >= 926 || (maxDimension >= 736 && minDimension >= 414)) {
      return FastIOSDeviceType.iPhoneMax;
    }

    // iPhone Pro detection
    if (maxDimension >= 844 && minDimension >= 390) {
      return FastIOSDeviceType.iPhonePro;
    }

    // Regular iPhone
    if (maxDimension >= 667) {
      return FastIOSDeviceType.iPhone;
    }

    // iPhone SE/Mini
    return FastIOSDeviceType.iPhoneMini;
  }

  Widget _buildAdaptiveContent(
    BuildContext context,
    FastDeviceType deviceType,
    FastScreenSize screenSize,
    FastIOSDeviceType iosDeviceType,
    MediaQueryData mediaQuery,
  ) {
    Widget content = widget.child;

    // Calculate adaptive padding
    EdgeInsetsGeometry effectivePadding = _calculateAdaptivePadding(
      deviceType: deviceType,
      iosDeviceType: iosDeviceType,
      mediaQuery: mediaQuery,
    );

    // Apply max width constraint for larger screens with iOS considerations
    double? effectiveMaxWidth = _calculateEffectiveMaxWidth(
      deviceType: deviceType,
      iosDeviceType: iosDeviceType,
      mediaQuery: mediaQuery,
    );

    if (effectiveMaxWidth != null || effectivePadding != EdgeInsets.zero) {
      content = Container(
        constraints: effectiveMaxWidth != null
            ? BoxConstraints(maxWidth: effectiveMaxWidth)
            : null,
        padding: widget.customPadding ?? effectivePadding,
        child: content,
      );

      // Center content for larger screens
      if (deviceType != FastDeviceType.phone) {
        content = Center(child: content);
      }
    }

    return content;
  }

  /// Calculate adaptive padding based on device type and iOS standards
  EdgeInsetsGeometry _calculateAdaptivePadding({
    required FastDeviceType deviceType,
    required FastIOSDeviceType iosDeviceType,
    required MediaQueryData mediaQuery,
  }) {
    if (!widget.useIOSStandardMargins) {
      return EdgeInsets.zero;
    }

    final bool isLandscape = mediaQuery.orientation == Orientation.landscape;

    switch (iosDeviceType) {
      case FastIOSDeviceType.iPadPro12:
        return EdgeInsets.symmetric(
          horizontal: isLandscape ? 24.0 : 20.0,
          vertical: 16.0,
        );
      case FastIOSDeviceType.iPadPro11:
      case FastIOSDeviceType.iPad:
        return EdgeInsets.symmetric(
          horizontal: isLandscape ? 20.0 : 16.0,
          vertical: 16.0,
        );
      case FastIOSDeviceType.iPhoneMax:
      case FastIOSDeviceType.iPhonePro:
        return EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: isLandscape ? 8.0 : 16.0,
        );
      case FastIOSDeviceType.iPhone:
      case FastIOSDeviceType.iPhoneMini:
        return EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: isLandscape ? 8.0 : 16.0,
        );
      case FastIOSDeviceType.other:
        // Non-iOS fallback
        return const EdgeInsets.all(16.0);
    }
  }

  /// Calculate effective max width based on device and orientation
  double? _calculateEffectiveMaxWidth({
    required FastDeviceType deviceType,
    required FastIOSDeviceType iosDeviceType,
    required MediaQueryData mediaQuery,
  }) {
    if (widget.maxContentWidth != null) {
      return widget.maxContentWidth;
    }

    final bool isLandscape = mediaQuery.orientation == Orientation.landscape;
    final double screenWidth = mediaQuery.size.width;

    switch (iosDeviceType) {
      case FastIOSDeviceType.iPadPro12:
        if (isLandscape) {
          return widget.supportIPadMultitasking ? 800.0 : 900.0;
        } else {
          return 692.0; // iOS reading width
        }
      case FastIOSDeviceType.iPadPro11:
      case FastIOSDeviceType.iPad:
        if (isLandscape) {
          return 692.0; // Reading width in landscape
        } else {
          return screenWidth * 0.9; // Use most of the width in portrait
        }
      case FastIOSDeviceType.iPhoneMax:
      case FastIOSDeviceType.iPhonePro:
        if (isLandscape) {
          return 600.0; // Constrain for readability in landscape
        }
        return null; // Use full width in portrait
      case FastIOSDeviceType.iPhone:
      case FastIOSDeviceType.iPhoneMini:
        return null; // Always use full width
      case FastIOSDeviceType.other:
        return deviceType == FastDeviceType.phone ? null : 800.0;
    }
  }
}

/// Device types for responsive layout
enum FastDeviceType {
  phone,
  tablet,
  desktop,
}

/// Screen size categories
enum FastScreenSize {
  compact,
  regular,
  large,
}

/// iOS-specific device types for enhanced responsive behavior
enum FastIOSDeviceType {
  iPhoneMini, // iPhone SE, iPhone 12/13 mini
  iPhone, // iPhone 12/13/14 regular
  iPhonePro, // iPhone 12/13/14 Pro
  iPhoneMax, // iPhone 12/13/14 Pro Max, Plus models
  iPad, // iPad, iPad Mini
  iPadPro11, // iPad Pro 11", iPad Air
  iPadPro12, // iPad Pro 12.9"
  other, // Non-iOS devices
}

/// Responsive breakpoints for different platforms
class FastResponsiveBreakpoints {
  /// Phone breakpoint (width < phoneBreakpoint)
  final double phoneBreakpoint;

  /// Tablet breakpoint (phoneBreakpoint <= width < tabletBreakpoint)
  final double tabletBreakpoint;

  /// Desktop breakpoint (width >= tabletBreakpoint)
  final double desktopBreakpoint;

  /// Compact height breakpoint
  final double compactHeightBreakpoint;

  /// Regular height breakpoint
  final double regularHeightBreakpoint;

  const FastResponsiveBreakpoints({
    this.phoneBreakpoint = 600,
    this.tabletBreakpoint = 900,
    this.desktopBreakpoint = 1200,
    this.compactHeightBreakpoint = 600,
    this.regularHeightBreakpoint = 900,
  });

  /// iOS breakpoints following Apple Human Interface Guidelines
  factory FastResponsiveBreakpoints.ios() {
    return const FastResponsiveBreakpoints(
      phoneBreakpoint: 428, // iPhone 14 Pro Max width
      tabletBreakpoint: 768, // iPad Mini/Air width
      desktopBreakpoint: 1024, // iPad Pro width
      compactHeightBreakpoint: 568, // iPhone SE height
      regularHeightBreakpoint: 812, // iPhone standard height
    );
  }

  /// Material Design breakpoints
  factory FastResponsiveBreakpoints.material() {
    return const FastResponsiveBreakpoints(
      phoneBreakpoint: 600,
      tabletBreakpoint: 900,
      desktopBreakpoint: 1200,
      compactHeightBreakpoint: 600,
      regularHeightBreakpoint: 900,
    );
  }

  /// Get device type based on screen width
  FastDeviceType getDeviceType(MediaQueryData mediaQuery) {
    final double width = mediaQuery.size.width;

    if (width < phoneBreakpoint) {
      return FastDeviceType.phone;
    } else if (width < tabletBreakpoint) {
      return FastDeviceType.tablet;
    } else {
      return FastDeviceType.desktop;
    }
  }

  /// Get screen size category based on height
  FastScreenSize getScreenSize(MediaQueryData mediaQuery) {
    final double height = mediaQuery.size.height;

    if (height < compactHeightBreakpoint) {
      return FastScreenSize.compact;
    } else if (height < regularHeightBreakpoint) {
      return FastScreenSize.regular;
    } else {
      return FastScreenSize.large;
    }
  }
}

/// Enhanced inherited widget to provide responsive context
class FastResponsiveScope extends InheritedWidget {
  final FastDeviceType deviceType;
  final FastScreenSize screenSize;
  final FastResponsiveBreakpoints breakpoints;
  final bool adaptiveTypography;
  final bool adaptiveSpacing;
  final FastIOSDeviceType iosDeviceType;
  final bool isLandscape;

  const FastResponsiveScope({
    super.key,
    required this.deviceType,
    required this.screenSize,
    required this.breakpoints,
    required this.adaptiveTypography,
    required this.adaptiveSpacing,
    required this.iosDeviceType,
    required this.isLandscape,
    required super.child,
  });

  static FastResponsiveScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FastResponsiveScope>();
  }

  @override
  bool updateShouldNotify(FastResponsiveScope oldWidget) {
    return deviceType != oldWidget.deviceType ||
        screenSize != oldWidget.screenSize ||
        adaptiveTypography != oldWidget.adaptiveTypography ||
        adaptiveSpacing != oldWidget.adaptiveSpacing ||
        iosDeviceType != oldWidget.iosDeviceType ||
        isLandscape != oldWidget.isLandscape;
  }
}

/// Extension methods for convenient responsive access
extension FastResponsiveContext on BuildContext {
  /// Get responsive scope information
  FastResponsiveScope? get responsive => FastResponsiveScope.of(this);

  /// Check if current device is a phone
  bool get isPhone {
    final scope = responsive;
    return scope != null ? scope.deviceType == FastDeviceType.phone : false;
  }

  /// Check if current device is a tablet
  bool get isTablet {
    final scope = responsive;
    return scope != null ? scope.deviceType == FastDeviceType.tablet : false;
  }

  /// Check if current device is desktop
  bool get isDesktop {
    final scope = responsive;
    return scope != null ? scope.deviceType == FastDeviceType.desktop : false;
  }

  /// Check if screen has compact height
  bool get isCompactHeight {
    final scope = responsive;
    return scope != null ? scope.screenSize == FastScreenSize.compact : false;
  }

  /// Check if screen has regular height
  bool get isRegularHeight {
    final scope = responsive;
    return scope != null ? scope.screenSize == FastScreenSize.regular : false;
  }

  /// Check if screen has large height
  bool get isLargeHeight {
    final scope = responsive;
    return scope != null ? scope.screenSize == FastScreenSize.large : false;
  }

  /// Check if device is in landscape orientation
  bool get isLandscape {
    final scope = responsive;
    return scope?.isLandscape ??
        MediaQuery.of(this).orientation == Orientation.landscape;
  }

  /// Get iOS device type
  FastIOSDeviceType get iosDeviceType {
    final scope = responsive;
    return scope?.iosDeviceType ?? FastIOSDeviceType.other;
  }

  /// Check if current device is an iPad
  bool get isIPad {
    final iosType = iosDeviceType;
    return iosType == FastIOSDeviceType.iPad ||
        iosType == FastIOSDeviceType.iPadPro11 ||
        iosType == FastIOSDeviceType.iPadPro12;
  }

  /// Check if current device is an iPhone
  bool get isIPhone {
    final iosType = iosDeviceType;
    return iosType == FastIOSDeviceType.iPhone ||
        iosType == FastIOSDeviceType.iPhonePro ||
        iosType == FastIOSDeviceType.iPhoneMax ||
        iosType == FastIOSDeviceType.iPhoneMini;
  }

  /// Get adaptive padding based on device type
  EdgeInsetsGeometry get adaptivePadding {
    if (isIPhone) {
      return EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: isLandscape ? 8.0 : 16.0,
      );
    } else if (isIPad) {
      return EdgeInsets.symmetric(
        horizontal: isLandscape ? 20.0 : 16.0,
        vertical: 16.0,
      );
    } else {
      return const EdgeInsets.all(16.0);
    }
  }

  /// Get adaptive spacing based on device type
  double get adaptiveSpacing {
    if (isIPhone) {
      return 16.0;
    } else if (isIPad) {
      return 20.0;
    } else {
      return 24.0;
    }
  }

  /// Get iOS system margin based on device
  double get iosSystemMargin {
    if (isIPad) {
      return isLandscape ? 20.0 : 16.0;
    } else {
      return 20.0; // iPhone standard
    }
  }

  /// Get responsive column count for grids
  int get responsiveColumns {
    if (isPhone) {
      return 1;
    } else if (isTablet) {
      return isLandscape ? 3 : 2;
    } else {
      return isLandscape ? 4 : 3;
    }
  }

  /// Get responsive maximum width for content
  double? get responsiveMaxWidth {
    if (isPhone) {
      return null; // Use full width
    } else if (isTablet) {
      return isLandscape ? 692.0 : null;
    } else {
      return 800.0;
    }
  }
}

/// Responsive builder widget for conditional UI
class FastResponsiveBuilder extends StatelessWidget {
  /// Widget to show on phones
  final Widget? phone;

  /// Widget to show on tablets
  final Widget? tablet;

  /// Widget to show on desktop
  final Widget? desktop;

  /// Widget to show in landscape orientation
  final Widget? landscape;

  /// Widget to show in portrait orientation
  final Widget? portrait;

  /// Default widget if no specific device widget is provided
  final Widget? defaultWidget;

  const FastResponsiveBuilder({
    super.key,
    this.phone,
    this.tablet,
    this.desktop,
    this.landscape,
    this.portrait,
    this.defaultWidget,
  }) : assert(
          phone != null ||
              tablet != null ||
              desktop != null ||
              landscape != null ||
              portrait != null ||
              defaultWidget != null,
          'At least one widget must be provided',
        );

  @override
  Widget build(BuildContext context) {
    // Check orientation first if orientation-specific widgets are provided
    if (context.isLandscape && landscape != null) {
      return landscape!;
    } else if (!context.isLandscape && portrait != null) {
      return portrait!;
    }

    // Then check device type
    if (context.isPhone && phone != null) {
      return phone!;
    } else if (context.isTablet && tablet != null) {
      return tablet!;
    } else if (context.isDesktop && desktop != null) {
      return desktop!;
    } else {
      return defaultWidget ??
          phone ??
          tablet ??
          desktop ??
          landscape ??
          portrait ??
          const SizedBox.shrink();
    }
  }
}
