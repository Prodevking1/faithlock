import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// iOS device size categories
enum IOSDeviceSize {
  compact, // iPhone SE, iPhone 12 mini
  regular, // iPhone 12, iPhone 13, iPhone 14
  large, // iPhone 12 Pro Max, iPhone 13 Pro Max, iPhone 14 Plus
  iPad, // All iPad sizes
}

/// Platform detection utilities with iOS-specific checks
class IOSPlatformDetector {
  IOSPlatformDetector._();

  // MARK: - Basic Platform Detection

  /// Returns true if running on iOS platform
  static bool get isIOS {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  /// Returns true if running on any Apple platform (iOS or macOS)
  static bool get isApplePlatform {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isMacOS;
  }

  /// Returns true if running on web
  static bool get isWeb => kIsWeb;

  /// Returns true if running on Android
  static bool get isAndroid {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  // MARK: - iOS Device Detection

  /// Returns true if running on iPad
  /// Uses screen size heuristics since there's no direct API
  static bool isIPad(BuildContext context) {
    if (!isIOS) return false;

    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final devicePixelRatio = mediaQuery.devicePixelRatio;

    // Calculate physical screen size in inches
    final physicalWidth = size.width * devicePixelRatio;
    final physicalHeight = size.height * devicePixelRatio;
    final diagonalPixels = math
        .sqrt(physicalWidth * physicalWidth + physicalHeight * physicalHeight);

    // iPad typically has diagonal >= 9 inches (around 2048 pixels)
    // This is a heuristic and may need adjustment for new devices
    return diagonalPixels >= 2000;
  }

  /// Returns true if running on iPhone
  static bool isIPhone(BuildContext context) {
    return isIOS && !isIPad(context);
  }

  /// Returns true if device has a notch or Dynamic Island
  /// Detected by checking top safe area padding
  static bool hasNotch(BuildContext context) {
    if (!isIOS) return false;
    return MediaQuery.of(context).viewPadding.top > 20;
  }

  /// Returns true if device has home indicator (iPhone X and later)
  /// Detected by checking bottom safe area padding
  static bool hasHomeIndicator(BuildContext context) {
    if (!isIOS) return false;
    return MediaQuery.of(context).viewPadding.bottom > 0;
  }

  // MARK: - Screen Size Categories

  /// Returns the iOS device size category
  static IOSDeviceSize getDeviceSize(BuildContext context) {
    if (!isIOS) return IOSDeviceSize.regular;

    if (isIPad(context)) return IOSDeviceSize.iPad;

    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;

    if (shortestSide <= 375) return IOSDeviceSize.compact;
    if (shortestSide <= 390) return IOSDeviceSize.regular;
    return IOSDeviceSize.large;
  }

  // MARK: - Orientation Detection

  /// Returns true if device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Returns true if device is in portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  // MARK: - Accessibility Detection

  /// Returns true if user has enabled reduce motion
  static bool isReduceMotionEnabled(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Returns true if user has enabled high contrast
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Returns true if user has enabled bold text
  static bool isBoldTextEnabled(BuildContext context) {
    return MediaQuery.of(context).boldText;
  }

  /// Returns the current text scale factor
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0);
  }

  // MARK: - Safe Area Helpers

  /// Returns the safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).viewPadding;
  }

  /// Returns the top safe area padding
  static double getTopSafeArea(BuildContext context) {
    return MediaQuery.of(context).viewPadding.top;
  }

  /// Returns the bottom safe area padding
  static double getBottomSafeArea(BuildContext context) {
    return MediaQuery.of(context).viewPadding.bottom;
  }

  // MARK: - Adaptive Helpers

  /// Returns appropriate margin based on device type
  static double getHorizontalMargin(BuildContext context) {
    if (!isIOS) return 16.0;
    return isIPad(context) ? 16.0 : 20.0;
  }

  /// Returns appropriate list item height based on device
  static double getListItemHeight({
    bool hasSubtitle = false,
    bool isCompact = false,
  }) {
    if (hasSubtitle) return 60.0;
    if (isCompact) return 44.0;
    return 44.0;
  }

  /// Returns appropriate navigation bar height
  static double getNavigationBarHeight(BuildContext context) {
    return 44.0 + getTopSafeArea(context);
  }

  /// Returns appropriate tab bar height
  static double getTabBarHeight(BuildContext context) {
    return 49.0 + getBottomSafeArea(context);
  }

  // MARK: - Widget Builders

  /// Builds a widget based on platform
  static Widget buildAdaptive({
    required Widget iosWidget,
    required Widget androidWidget,
    Widget? webWidget,
  }) {
    if (kIsWeb) return webWidget ?? androidWidget;
    if (isIOS) return iosWidget;
    return androidWidget;
  }

  /// Builds a widget based on iOS device type
  static Widget buildIOSAdaptive(
    BuildContext context, {
    required Widget iPhoneWidget,
    required Widget iPadWidget,
    Widget? fallbackWidget,
  }) {
    if (!isIOS) return fallbackWidget ?? iPhoneWidget;
    return isIPad(context) ? iPadWidget : iPhoneWidget;
  }

  /// Builds a widget based on device size
  static Widget buildSizeAdaptive(
    BuildContext context, {
    Widget? compactWidget,
    Widget? regularWidget,
    Widget? largeWidget,
    Widget? iPadWidget,
    required Widget fallbackWidget,
  }) {
    if (!isIOS) return fallbackWidget;

    final deviceSize = getDeviceSize(context);

    switch (deviceSize) {
      case IOSDeviceSize.compact:
        return compactWidget ?? regularWidget ?? fallbackWidget;
      case IOSDeviceSize.regular:
        return regularWidget ?? fallbackWidget;
      case IOSDeviceSize.large:
        return largeWidget ?? regularWidget ?? fallbackWidget;
      case IOSDeviceSize.iPad:
        return iPadWidget ?? largeWidget ?? regularWidget ?? fallbackWidget;
    }
  }

  // MARK: - Debug Helpers

  /// Returns device information for debugging
  static Map<String, dynamic> getDeviceInfo(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return {
      'platform': isIOS ? 'iOS' : (isAndroid ? 'Android' : 'Other'),
      'isIPad': isIPad(context),
      'isIPhone': isIPhone(context),
      'hasNotch': hasNotch(context),
      'hasHomeIndicator': hasHomeIndicator(context),
      'deviceSize': getDeviceSize(context).toString(),
      'orientation': mediaQuery.orientation.toString(),
      'screenSize': '${mediaQuery.size.width}x${mediaQuery.size.height}',
      'devicePixelRatio': mediaQuery.devicePixelRatio,
      'textScaleFactor': getTextScaleFactor(context),
      'safeAreaTop': getTopSafeArea(context),
      'safeAreaBottom': getBottomSafeArea(context),
      'reduceMotion': isReduceMotionEnabled(context),
      'highContrast': isHighContrastEnabled(context),
      'boldText': isBoldTextEnabled(context),
    };
  }
}
