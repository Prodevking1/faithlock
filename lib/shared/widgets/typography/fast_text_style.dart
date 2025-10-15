/// **FastTextStyle** - Cross-platform text styling system following Material Design and iOS Human Interface Guidelines.
///
/// **Use Case:**
/// Use this as the foundation for all text styling in your app to ensure consistent
/// typography that follows platform-specific guidelines. Automatically applies iOS typography
/// on iOS devices and Material Design typography on Android with proper scaling and colors.
///
/// **Key Features:**
/// - Platform-adaptive typography (iOS HIG + Material Design 3)
/// - Dynamic Type support with accessibility scaling on both platforms
/// - Precise font metrics matching platform specifications
/// - Automatic platform detection with appropriate system fonts
/// - Semantic text styles for common UI components
/// - Material Design 3 type scale integration
/// - iOS Human Interface Guidelines compliance
///
/// **Important Parameters:**
/// - `context`: BuildContext for theme and accessibility information (required)
/// - `color`: Override text color (defaults to iOS system colors)
/// - `enableDynamicType`: Whether to scale text based on accessibility settings
/// - Text styles available: largeTitle, title1-3, headline, body, callout, subheadline, footnote, caption1-2
/// - Semantic styles: navigationTitle, listTitle, button, error, success, etc.
///
/// **Usage Example:**
/// ```dart
/// // Platform-adaptive text styles
/// Text('Large Title', style: FastTextStyle.largeTitle(context))  // iOS: 34pt Bold, Material: 57sp Regular
/// Text('Body Text', style: FastTextStyle.body(context))         // iOS: 17pt Regular, Material: 16sp Regular
/// Text('Small Caption', style: FastTextStyle.caption1(context)) // iOS: 12pt Regular, Material: 12sp Medium
///
/// // Custom colors (respects platform defaults)
/// Text(
///   'Colored Title',
///   style: FastTextStyle.title1(context, color: Colors.blue),
/// )
///
/// // Disable Dynamic Type scaling
/// Text(
///   'Fixed Size Text',
///   style: FastTextStyle.body(context, enableDynamicType: false),
/// )
///
/// // Semantic text styles (platform-adaptive colors)
/// Text('Settings', style: FastTextStyle.navigationTitle(context))   // iOS: CupertinoColors.label, Material: onSurface
/// Text('List Item', style: FastTextStyle.listTitle(context))        // Platform-appropriate colors
/// Text('Subtitle', style: FastTextStyle.listSubtitle(context))      // iOS: secondaryLabel, Material: onSurfaceVariant
/// Text('Error message', style: FastTextStyle.error(context))        // iOS: systemRed, Material: error
/// Text('Success message', style: FastTextStyle.success(context))    // iOS: systemGreen, Material: green
///
/// // Button styling with platform colors
/// Text('Tap Here', style: FastTextStyle.button(context))          // iOS: systemBlue, Material: primary
/// Text('Custom Button', style: FastTextStyle.button(context, color: Colors.red))
/// ```

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/core/fast_fonts.dart';

class FastTextStyle {
  static const Map<String, double> _iosTextSizes = {
    'largeTitle': 34.0,
    'title1': 28.0,
    'title2': 22.0,
    'title3': 20.0,
    'headline': 17.0,
    'body': 17.0,
    'callout': 16.0,
    'subheadline': 15.0,
    'footnote': 13.0,
    'caption1': 12.0,
    'caption2': 11.0,
  };

  static const Map<String, double> _materialTextSizes = {
    'largeTitle': 57.0,
    'title1': 45.0,
    'title2': 36.0,
    'title3': 32.0,
    'headline': 28.0,
    'body': 16.0,
    'callout': 14.0,
    'subheadline': 12.0,
    'footnote': 11.0,
    'caption1': 12.0,
    'caption2': 10.0,
  };

  static const Map<String, FontWeight> _iosTextWeights = {
    'largeTitle': FontWeight.w700,
    'title1': FontWeight.w700,
    'title2': FontWeight.w700,
    'title3': FontWeight.w600,
    'headline': FontWeight.w600,
    'body': FontWeight.w400,
    'callout': FontWeight.w400,
    'subheadline': FontWeight.w400,
    'footnote': FontWeight.w400,
    'caption1': FontWeight.w400,
    'caption2': FontWeight.w400,
  };

  static const Map<String, FontWeight> _materialTextWeights = {
    'largeTitle': FontWeight.w400,
    'title1': FontWeight.w400,
    'title2': FontWeight.w400,
    'title3': FontWeight.w400,
    'headline': FontWeight.w400,
    'body': FontWeight.w400,
    'callout': FontWeight.w400,
    'subheadline': FontWeight.w400,
    'footnote': FontWeight.w500,
    'caption1': FontWeight.w500,
    'caption2': FontWeight.w500,
  };

  static const Map<String, double> _dynamicTypeScales = {
    'xSmall': 0.82,
    'small': 0.88,
    'medium': 1.0,
    'large': 1.12,
    'xLarge': 1.23,
    'xxLarge': 1.35,
    'xxxLarge': 1.40,
  };
  static double _getAccessibilityScale(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double textScaleFactor = mediaQuery.textScaler.scale(1.0);

    if (textScaleFactor <= 0.85) return _dynamicTypeScales['xSmall']!;
    if (textScaleFactor <= 0.9) return _dynamicTypeScales['small']!;
    if (textScaleFactor <= 1.1) return _dynamicTypeScales['medium']!;
    if (textScaleFactor <= 1.2) return _dynamicTypeScales['large']!;
    if (textScaleFactor <= 1.3) return _dynamicTypeScales['xLarge']!;
    if (textScaleFactor <= 1.4) return _dynamicTypeScales['xxLarge']!;
    return _dynamicTypeScales['xxxLarge']!;
  }
  static TextStyle _getPlatformTextStyle(
    BuildContext context,
    String styleKey, {
    Color? color,
    bool enableDynamicType = true,
  }) {
    final bool isIOS =
        Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;

    final double baseSize = isIOS
        ? (_iosTextSizes[styleKey] ?? 17.0)
        : (_materialTextSizes[styleKey] ?? 16.0);

    final FontWeight weight = isIOS
        ? (_iosTextWeights[styleKey] ?? FontWeight.w400)
        : (_materialTextWeights[styleKey] ?? FontWeight. w400);

    final double scale =
        enableDynamicType ? _getAccessibilityScale(context) : 1.0;

    if (isIOS) {
      return TextStyle(
        fontSize: baseSize * scale,
        fontWeight: weight,
        color: color ?? CupertinoColors.label.resolveFrom(context),
        fontFamily: FastFonts.primary,
        letterSpacing: _getIOSLetterSpacing(styleKey),
        height: _getIOSLineHeight(styleKey),
      );
    } else {
      return TextStyle(
        fontSize: baseSize * scale,
        fontWeight: weight,
        color: color ?? Theme.of(context).colorScheme.onSurface,
        fontFamily: FastFonts.primary,
        letterSpacing: _getMaterialLetterSpacing(styleKey),
        height: _getMaterialLineHeight(styleKey),
      );
    }
  }

  static double _getIOSLetterSpacing(String styleKey) {
    switch (styleKey) {
      case 'largeTitle':
        return 0.34;
      case 'title1':
        return 0.35;
      case 'title2':
        return 0.35;
      case 'title3':
        return 0.38;
      case 'headline':
        return -0.41;
      case 'body':
        return -0.41;
      case 'callout':
        return -0.31;
      case 'subheadline':
        return -0.24;
      case 'footnote':
        return -0.08;
      case 'caption1':
        return 0.0;
      case 'caption2':
        return 0.07;
      default:
        return 0.0;
    }
  }

  static double _getIOSLineHeight(String styleKey) {
    switch (styleKey) {
      case 'largeTitle':
        return 1.21;
      case 'title1':
        return 1.29;
      case 'title2':
        return 1.27;
      case 'title3':
        return 1.25;
      case 'headline':
        return 1.29;
      case 'body':
        return 1.29;
      case 'callout':
        return 1.25;
      case 'subheadline':
        return 1.27;
      case 'footnote':
        return 1.23;
      case 'caption1':
        return 1.33;
      case 'caption2':
        return 1.36;
      default:
        return 1.25;
    }
  }

  static double _getMaterialLetterSpacing(String styleKey) {
    switch (styleKey) {
      case 'largeTitle':
        return -0.25;
      case 'title1':
        return 0.0;
      case 'title2':
        return 0.0;
      case 'title3':
        return 0.0;
      case 'headline':
        return 0.0;
      case 'body':
        return 0.5;
      case 'callout':
        return 0.25;
      case 'subheadline':
        return 0.4;
      case 'footnote':
        return 0.5;
      case 'caption1':
        return 0.5;
      case 'caption2':
        return 0.5;
      default:
        return 0.0;
    }
  }

  static double _getMaterialLineHeight(String styleKey) {
    switch (styleKey) {
      case 'largeTitle':
        return 1.12;
      case 'title1':
        return 1.16;
      case 'title2':
        return 1.22;
      case 'title3':
        return 1.25;
      case 'headline':
        return 1.29;
      case 'body':
        return 1.5;
      case 'callout':
        return 1.43;
      case 'subheadline':
        return 1.33;
      case 'footnote':
        return 1.45;
      case 'caption1':
        return 1.33;
      case 'caption2':
        return 1.6;
      default:
        return 1.4;
    }
  }

  static TextStyle largeTitle(BuildContext context,
      {Color? color, bool enableDynamicType = true}) {
    return _getPlatformTextStyle(context, 'largeTitle',
        color: color, enableDynamicType: enableDynamicType);
  }

  static TextStyle title1(BuildContext context,
      {Color? color, bool enableDynamicType = true}) {
    return _getPlatformTextStyle(context, 'title1',
        color: color, enableDynamicType: enableDynamicType);
  }

  static TextStyle title2(BuildContext context,
      {Color? color, bool enableDynamicType = true}) {
    return _getPlatformTextStyle(context, 'title2',
        color: color, enableDynamicType: enableDynamicType);
  }

  static TextStyle title3(BuildContext context,
      {Color? color, bool enableDynamicType = true}) {
    return _getPlatformTextStyle(context, 'title3',
        color: color, enableDynamicType: enableDynamicType);
  }

  static TextStyle headline(BuildContext context,
      {Color? color, bool enableDynamicType = true}) {
    return _getPlatformTextStyle(context, 'headline',
        color: color, enableDynamicType: enableDynamicType);
  }

  static TextStyle body(BuildContext context,
      {Color? color, bool enableDynamicType = true}) {
    return _getPlatformTextStyle(context, 'body',
        color: color, enableDynamicType: enableDynamicType);
  }

  static TextStyle callout(BuildContext context,
      {Color? color, bool enableDynamicType = true}) {
    return _getPlatformTextStyle(context, 'callout',
        color: color, enableDynamicType: enableDynamicType);
  }

  static TextStyle subheadline(BuildContext context,
      {Color? color, bool enableDynamicType = true}) {
    return _getPlatformTextStyle(context, 'subheadline',
        color: color, enableDynamicType: enableDynamicType);
  }

  static TextStyle footnote(BuildContext context,
      {Color? color, bool enableDynamicType = true}) {
    return _getPlatformTextStyle(context, 'footnote',
        color: color, enableDynamicType: enableDynamicType);
  }

  static TextStyle caption1(BuildContext context,
      {Color? color, bool enableDynamicType = true}) {
    return _getPlatformTextStyle(context, 'caption1',
        color: color, enableDynamicType: enableDynamicType);
  }

  static TextStyle caption2(BuildContext context,
      {Color? color, bool enableDynamicType = true}) {
    return _getPlatformTextStyle(context, 'caption2',
        color: color, enableDynamicType: enableDynamicType);
  }

  // Alan Sans specific styles with custom weights
  static TextStyle alanSansLight(BuildContext context,
      {double? fontSize, Color? color, bool enableDynamicType = true}) {
    final double scale = enableDynamicType ? _getAccessibilityScale(context) : 1.0;
    return TextStyle(
      fontFamily: FastFonts.primary,
      fontWeight: FastFonts.light,
      fontSize: (fontSize ?? 17.0) * scale,
      color: color ?? (Platform.isIOS
          ? CupertinoColors.label.resolveFrom(context)
          : Theme.of(context).colorScheme.onSurface),
    );
  }

  static TextStyle alanSansMedium(BuildContext context,
      {double? fontSize, Color? color, bool enableDynamicType = true}) {
    final double scale = enableDynamicType ? _getAccessibilityScale(context) : 1.0;
    return TextStyle(
      fontFamily: FastFonts.primary,
      fontWeight: FastFonts.medium,
      fontSize: (fontSize ?? 17.0) * scale,
      color: color ?? (Platform.isIOS
          ? CupertinoColors.label.resolveFrom(context)
          : Theme.of(context).colorScheme.onSurface),
    );
  }

  static TextStyle alanSansBold(BuildContext context,
      {double? fontSize, Color? color, bool enableDynamicType = true}) {
    final double scale = enableDynamicType ? _getAccessibilityScale(context) : 1.0;
    return TextStyle(
      fontFamily: FastFonts.primary,
      fontWeight: FastFonts.bold,
      fontSize: (fontSize ?? 17.0) * scale,
      color: color ?? (Platform.isIOS
          ? CupertinoColors.label.resolveFrom(context)
          : Theme.of(context).colorScheme.onSurface),
    );
  }

  static TextStyle alanSansBlack(BuildContext context,
      {double? fontSize, Color? color, bool enableDynamicType = true}) {
    final double scale = enableDynamicType ? _getAccessibilityScale(context) : 1.0;
    return TextStyle(
      fontFamily: FastFonts.primary,
      fontWeight: FastFonts.black,
      fontSize: (fontSize ?? 17.0) * scale,
      color: color ?? (Platform.isIOS
          ? CupertinoColors.label.resolveFrom(context)
          : Theme.of(context).colorScheme.onSurface),
    );
  }

  // System font alternatives for fallback
  static TextStyle systemFont(BuildContext context,
      {double? fontSize, FontWeight? weight, Color? color, bool enableDynamicType = true}) {
    final double scale = enableDynamicType ? _getAccessibilityScale(context) : 1.0;
    return TextStyle(
      fontFamily: FastFonts.platform,
      fontWeight: weight ?? FontWeight.normal,
      fontSize: (fontSize ?? 17.0) * scale,
      color: color ?? (Platform.isIOS
          ? CupertinoColors.label.resolveFrom(context)
          : Theme.of(context).colorScheme.onSurface),
    );
  }

  // Semantic Text Styles

  static TextStyle navigationTitle(BuildContext context) {
    final bool isIOS = Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;
    final Color color = isIOS
        ? CupertinoColors.label.resolveFrom(context)
        : Theme.of(context).colorScheme.onSurface;
    return headline(context, color: color);
  }

  static TextStyle navigationLargeTitle(BuildContext context) {
    final bool isIOS = Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;
    final Color color = isIOS
        ? CupertinoColors.label.resolveFrom(context)
        : Theme.of(context).colorScheme.onSurface;
    return largeTitle(context, color: color);
  }

  static TextStyle button(BuildContext context, {Color? color}) {
    final bool isIOS = Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;
    final Color defaultColor = color ?? (isIOS
        ? CupertinoColors.systemBlue.resolveFrom(context)
        : Theme.of(context).colorScheme.primary);
    return headline(context, color: defaultColor);
  }

  static TextStyle listTitle(BuildContext context) {
    final bool isIOS = Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;
    final Color color = isIOS
        ? CupertinoColors.label.resolveFrom(context)
        : Theme.of(context).colorScheme.onSurface;
    return body(context, color: color);
  }

  static TextStyle listSubtitle(BuildContext context) {
    final bool isIOS = Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;
    final Color color = isIOS
        ? CupertinoColors.secondaryLabel.resolveFrom(context)
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return subheadline(context, color: color);
  }

  static TextStyle tabLabel(BuildContext context, {bool isSelected = false}) {
    final bool isIOS = Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;

    Color color;
    if (isIOS) {
      color = isSelected
          ? CupertinoColors.systemBlue.resolveFrom(context)
          : CupertinoColors.inactiveGray.resolveFrom(context);
    } else {
      color = isSelected
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.onSurfaceVariant;
    }

    return caption2(context, color: color);
  }

  static TextStyle textInput(BuildContext context) {
    final bool isIOS = Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;
    final Color color = isIOS
        ? CupertinoColors.label.resolveFrom(context)
        : Theme.of(context).colorScheme.onSurface;
    return body(context, color: color);
  }

  static TextStyle textInputPlaceholder(BuildContext context) {
    final bool isIOS = Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;
    final Color color = isIOS
        ? CupertinoColors.placeholderText.resolveFrom(context)
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return body(context, color: color);
  }

  static TextStyle error(BuildContext context) {
    final bool isIOS = Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;
    final Color color = isIOS
        ? CupertinoColors.systemRed.resolveFrom(context)
        : Theme.of(context).colorScheme.error;
    return footnote(context, color: color);
  }

  static TextStyle success(BuildContext context) {
    final bool isIOS = Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;
    final Color color = isIOS
        ? CupertinoColors.systemGreen.resolveFrom(context)
        : const Color(0xFF4CAF50);
    return footnote(context, color: color);
  }

  static TextStyle secondaryLabel(BuildContext context) {
    final bool isIOS = Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;
    final Color color = isIOS
        ? CupertinoColors.secondaryLabel.resolveFrom(context)
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return subheadline(context, color: color);
  }

  static TextStyle tertiaryLabel(BuildContext context) {
    final bool isIOS = Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;
    final Color color = isIOS
        ? CupertinoColors.tertiaryLabel.resolveFrom(context)
        : Theme.of(context).colorScheme.outline;
    return footnote(context, color: color);
  }
}
