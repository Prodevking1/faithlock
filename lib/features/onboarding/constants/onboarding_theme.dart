import 'package:flutter/material.dart';

/// iOS-style Design System for FaithLock Onboarding
/// Clean, modern, professional - inspired by Apple's design language
class OnboardingTheme {
  // ==================== COLOR SYSTEM ====================
  // iOS Semantic Colors

  /// Pure black background (iOS dark mode)
  static const Color backgroundColor = Color(0xFF000000);

  /// Primary gold - more subtle and refined
  static const Color goldColor = Color(0xFFC9A962);

  /// Secondary beige - softer tone
  static const Color beigeColor = Color(0xFFE8DCC4);

  /// iOS label colors
  static const Color labelPrimary = Color(0xFFFFFFFF);
  static const Color labelSecondary = Color(0x99FFFFFF); // 60% white
  static const Color labelTertiary = Color(0x4DFFFFFF); // 30% white

  /// iOS system colors
  static const Color systemBlue = Color(0xFF007AFF);
  static const Color systemOrange = Color(0xFFFF9500);
  static const Color systemRed = Color(0xFFFF453A);
  static const Color systemGreen = Color(0xFF32D74B);

  /// Card/Container backgrounds
  static const Color cardBackground = Color(0x0DFFFFFF); // 5% white
  static const Color cardBorder = Color(0x1AFFFFFF); // 10% white

  // Legacy color aliases for compatibility
  static const Color grayColor = labelSecondary;
  static const Color redAlert = systemRed;
  static const Color blueSpirit = systemBlue;

  // ==================== TYPOGRAPHY ====================
  // iOS San Francisco Font System

  /// SF Pro Display for large text
  static const String fontFamily = 'SF Pro Display';

  /// SF Pro Text for body text
  static const String bodyFontFamily = 'SF Pro Text';

  // iOS Font Sizes (augmented for onboarding impact)
  static const double largeTitleSize = 40.0; // Large Title
  static const double title1Size = 32.0; // Title 1
  static const double title2Size = 26.0; // Title 2
  static const double title3Size = 22.0; // Title 3
  static const double bodySize = 19.0; // Body
  static const double calloutSize = 18.0; // Callout
  static const double subheadSize = 16.0; // Subhead
  static const double footnoteSize = 14.0; // Footnote
  static const double caption1Size = 13.0; // Caption 1

  // iOS Line Heights (tighter, more refined)
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.35;
  static const double lineHeightRelaxed = 1.5;

  // ==================== SPACING ====================
  // iOS Standard Spacing (multiples of 4)

  static const double horizontalPadding = 20.0; // iOS standard
  static const double verticalPadding = 24.0;

  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;

  // ==================== CORNER RADIUS ====================

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;

  // ==================== TEXT STYLES ====================

  /// Large Title - 34pt Bold (for major headings)
  static TextStyle get largeTitle => const TextStyle(
        fontFamily: fontFamily,
        fontSize: largeTitleSize,
        fontWeight: FontWeight.w700, // Bold
        color: labelPrimary,
        height: lineHeightTight,
        letterSpacing: 0.0,
      );

  /// Title 1 - 28pt Bold (for section titles)
  static TextStyle get title1 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: title1Size,
        fontWeight: FontWeight.w700, // Bold
        color: labelPrimary,
        height: lineHeightTight,
        letterSpacing: 0.0,
      );

  /// Title 2 - 22pt Bold (for subsection titles)
  static TextStyle get title2 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: title2Size,
        fontWeight: FontWeight.w700, // Bold
        color: labelPrimary,
        height: lineHeightNormal,
        letterSpacing: 0.0,
      );

  /// Title 3 - 20pt Semibold (for card titles)
  static TextStyle get title3 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: title3Size,
        fontWeight: FontWeight.w600, // Semibold
        color: labelPrimary,
        height: lineHeightNormal,
        letterSpacing: 0.0,
      );

  /// Body - 17pt Regular (main body text)
  static TextStyle get body => const TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: bodySize,
        fontWeight: FontWeight.w400, // Regular
        color: labelPrimary,
        height: lineHeightNormal,
        letterSpacing: 0.0,
      );

  /// Body Emphasized - 17pt Semibold
  static TextStyle get bodyEmphasized => const TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: bodySize,
        fontWeight: FontWeight.w600, // Semibold
        color: labelPrimary,
        height: lineHeightNormal,
        letterSpacing: 0.0,
      );

  /// Callout - 16pt Regular
  static TextStyle get callout => const TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: calloutSize,
        fontWeight: FontWeight.w400, // Regular
        color: labelSecondary,
        height: lineHeightNormal,
        letterSpacing: 0.0,
      );

  /// Subhead - 15pt Regular
  static TextStyle get subhead => const TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: subheadSize,
        fontWeight: FontWeight.w400, // Regular
        color: labelSecondary,
        height: lineHeightNormal,
        letterSpacing: 0.0,
      );

  /// Footnote - 13pt Regular (for small descriptions)
  static TextStyle get footnote => const TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: footnoteSize,
        fontWeight: FontWeight.w400, // Regular
        color: labelTertiary,
        height: lineHeightNormal,
        letterSpacing: 0.0,
      );

  /// Caption - 12pt Regular (for labels)
  static TextStyle get caption => const TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: caption1Size,
        fontWeight: FontWeight.w400, // Regular
        color: labelTertiary,
        height: lineHeightNormal,
        letterSpacing: 0.0,
      );

  // ==================== SPECIAL STYLES ====================

  /// Display Number - 64pt Bold (for big stats)
  static TextStyle get displayNumber => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 64.0,
        fontWeight: FontWeight.w700, // Bold
        color: labelPrimary,
        height: 1.0,
        letterSpacing: -0.5,
      );

  /// Display Unit - 15pt Regular (unit below number)
  static TextStyle get displayUnit => const TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: subheadSize,
        fontWeight: FontWeight.w400, // Regular
        color: labelSecondary,
        height: lineHeightNormal,
        letterSpacing: 0.0,
      );

  // ==================== LEGACY COMPATIBILITY ====================
  // For gradual migration from old theme

  @Deprecated('Use body instead')
  static TextStyle get bodyText => body;

  @Deprecated('Use bodyEmphasized instead')
  static TextStyle get emphasisText => bodyEmphasized;

  @Deprecated('Use title1 instead')
  static TextStyle get headerText => title1;

  @Deprecated('Use footnote instead')
  static TextStyle get referenceText => footnote;

  @Deprecated('Use body with goldColor instead')
  static TextStyle get verseText => body.copyWith(color: goldColor);

  @Deprecated('Use body instead')
  static TextStyle get questionText => body;

  // ==================== COMPONENT STYLES ====================

  /// Card decoration - frosted glass effect
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: cardBackground,
        border: Border.all(color: cardBorder, width: 1.0),
        borderRadius: BorderRadius.circular(radiusLarge),
      );

  /// Button decoration - filled style
  static BoxDecoration filledButtonDecoration(Color color) => BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radiusMedium),
      );

  /// Subtle shadow for cards
  static List<BoxShadow> get cardShadow => [
        const BoxShadow(
          color: Color(0x0A000000), // 4% black
          offset: Offset(0, 2),
          blurRadius: 8,
        ),
      ];
}
