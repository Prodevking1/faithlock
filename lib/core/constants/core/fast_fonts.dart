/// **FastFonts** - Typography system with Alan Sans integration and cross-platform font management.
///
/// **Use Case:**
/// Centralized font family management with support for custom fonts, fallbacks,
/// and platform-specific typography. Perfect for maintaining consistent text
/// styling across the app with support for system fonts and custom branding.
///
/// **Key Features:**
/// - Alan Sans integration with all weights (Light to Black)
/// - Platform-aware font fallbacks (San Francisco on iOS, Roboto on Android)
/// - Weight-specific font constants for type safety
/// - System font support for accessibility and performance
/// - Generated font constants via flutter_gen integration
///
/// **Usage Example:**
/// ```dart
/// // Primary brand font (Alan Sans)
/// Text('Welcome', style: TextStyle(fontFamily: FastFonts.primary))
///
/// // With specific weight
/// Text('Bold Title', style: TextStyle(
///   fontFamily: FastFonts.primary,
///   fontWeight: FastFonts.bold,
/// ))
///
/// // System font for body text
/// Text('Body text', style: TextStyle(fontFamily: FastFonts.system))
///
/// // Platform-specific defaults
/// Text('Platform text', style: TextStyle(fontFamily: FastFonts.platform))
/// ```

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../gen/fonts.gen.dart';

class FastFonts {
  FastFonts._();

  // Primary brand font (Alan Sans)
  static const String primary = FontFamily.alanSans;

  // System fonts for better performance and accessibility
  static const String system = '.AppleSystemUIFont'; // iOS will use SF Pro, Android will use Roboto

  // Platform-specific font recommendations
  static String get platform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return '.AppleSystemUIFont'; // San Francisco
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return 'Roboto';
      case TargetPlatform.windows:
        return 'Segoe UI';
      case TargetPlatform.linux:
        return 'Ubuntu';
    }
  }

  // Font weights for Alan Sans
  static const FontWeight light = FontWeight.w300;      // AlanSans-Light
  static const FontWeight regular = FontWeight.w400;    // AlanSans-Regular
  static const FontWeight medium = FontWeight.w500;     // AlanSans-Medium
  static const FontWeight semiBold = FontWeight.w600;   // AlanSans-SemiBold
  static const FontWeight bold = FontWeight.w700;       // AlanSans-Bold
  static const FontWeight extraBold = FontWeight.w800;  // AlanSans-ExtraBold
  static const FontWeight black = FontWeight.w900;      // AlanSans-Black

  // Common font weight aliases
  static const FontWeight thin = FontWeight.w100;       // System fallback
  static const FontWeight extraLight = FontWeight.w200; // System fallback

  // Font family with fallbacks for maximum compatibility
  static const List<String> primaryWithFallback = [
    FontFamily.alanSans,
    '.AppleSystemUIFont', // iOS fallback
    'Roboto',             // Android fallback
    'Segoe UI',           // Windows fallback
    'Ubuntu',             // Linux fallback
    'sans-serif',         // Web fallback
  ];

  // System font family with platform optimization
  static List<String> get systemWithFallback {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ['.AppleSystemUIFont', 'Helvetica Neue', 'Helvetica', 'sans-serif'];
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return ['Roboto', 'sans-serif'];
      case TargetPlatform.windows:
        return ['Segoe UI', 'Tahoma', 'sans-serif'];
      case TargetPlatform.linux:
        return ['Ubuntu', 'Liberation Sans', 'sans-serif'];
    }
  }

  // Text style builders with Alan Sans
  static TextStyle primaryStyle({
    FontWeight? weight,
    double? size,
    Color? color,
    double? height,
    double? letterSpacing,
  }) => TextStyle(
    fontFamily: FontFamily.alanSans,
    fontWeight: weight ?? regular,
    fontSize: size,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );

  static TextStyle systemStyle({
    FontWeight? weight,
    double? size,
    Color? color,
    double? height,
    double? letterSpacing,
  }) => TextStyle(
    fontFamily: platform,
    fontWeight: weight ?? FontWeight.normal,
    fontSize: size,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}
