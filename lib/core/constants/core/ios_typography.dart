import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Content size categories for accessibility
enum ContentSizeCategory {
  extraSmall,
  small,
  medium,
  large,
  extraLarge,
  extraExtraLarge,
  extraExtraExtraLarge,
  accessibilityMedium,
  accessibilityLarge,
  accessibilityExtraLarge,
  accessibilityExtraExtraLarge,
  accessibilityExtraExtraExtraLarge,
}

/// iOS typography system following Apple's Human Interface Guidelines
class IOSTypography {
  IOSTypography._();

  // MARK: - iOS Text Styles (System Font)

  /// Large Title - 34pt, Bold
  /// Used for maintitles in navigation
  static const TextStyle largeTitle = TextStyle(
    fontSize: 34.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.37,
    height: 1.12,
  );

  /// Title 1 - 28pt, Regular
  /// Used for primary headings
  static const TextStyle title1 = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.36,
    height: 1.14,
  );

  /// Title 2 - 22pt, Regular
  /// Used for secondary headings
  static const TextStyle title2 = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.35,
    height: 1.18,
  );

  /// Title 3 - 20pt, Regular
  /// Used for tertiary headings
  static const TextStyle title3 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.38,
    height: 1.20,
  );

  /// Headline - 17pt, Semibold
  /// Used for section headers and important text
  static const TextStyle headline = TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    height: 1.29,
  );

  /// Body - 17pt, Regular
  /// Used for main body text and list titles
  static const TextStyle body = TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    height: 1.29,
  );

  /// Callout - 16pt, Regular
  /// Used for secondary body text
  static const TextStyle callout = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.32,
    height: 1.31,
  );

  /// Subheadline - 15pt, Regular
  /// Used for list subtitles and secondary information
  static const TextStyle subheadline = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    height: 1.33,
  );

  /// Footnote - 13pt, Regular
  /// Used for footnotes and small text
  static const TextStyle footnote = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
    height: 1.38,
  );

  /// Caption 1 - 12pt, Regular
  /// Used for captions and very small text
  static const TextStyle caption1 = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.33,
  );

  /// Caption 2 - 11pt, Regular
  /// Used for the smallest text elements
  static const TextStyle caption2 = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.07,
    height: 1.36,
  );

  // MARK: - Button Text Styles

  /// Button text - 17pt, Semibold
  /// Used for primary button text
  static const TextStyle buttonText = TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    height: 1.29,
  );

  /// Small button text - 15pt, Semibold
  /// Used for smaller buttons
  static const TextStyle smallButtonText = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.24,
    height: 1.33,
  );

  /// Large button text - 20pt, Semibold
  /// Used for prominent buttons
  static const TextStyle largeButtonText = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.38,
    height: 1.20,
  );

  // MARK: - Navigation Text Styles

  /// Navigation title - 17pt, Semibold
  /// Used for navigation bar titles
  static const TextStyle navigationTitle = TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    height: 1.29,
  );

  /// Navigation large title - 34pt, Bold
  /// Used for large navigation titles
  static const TextStyle navigationLargeTitle = largeTitle;

  /// Tab bar text - 10pt, Medium
  /// Used for tab bar item labels
  static const TextStyle tabBarText = TextStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.12,
    height: 1.20,
  );

  // MARK: - List Text Styles

  /// List title - 17pt, Regular
  /// Used for main list item text
  static const TextStyle listTitle = body;

  /// List subtitle - 15pt, Regular
  /// Used for list item subtitles
  static const TextStyle listSubtitle = subheadline;

  /// List section header - 13pt, Regular, Uppercase
  /// Used for list section headers
  static const TextStyle listSectionHeader = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
    height: 1.38,
  );

  /// List section footer - 13pt, Regular
  /// Used for list section footers
  static const TextStyle listSectionFooter = footnote;

  // MARK: - Form Text Styles

  /// Input text - 17pt, Regular
  /// Used for text input content
  static const TextStyle inputText = body;

  /// Input placeholder - 17pt, Regular
  /// Used for text input placeholders
  static const TextStyle inputPlaceholder = body;

  /// Input label - 13pt, Regular
  /// Used for input field labels
  static const TextStyle inputLabel = footnote;

  /// Input error - 13pt, Regular
  /// Used for input validation errors
  static const TextStyle inputError = footnote;

  // MARK: - Dynamic Type Support

  /// Scaling factors for Dynamic Type
  static const Map<ContentSizeCategory, double> _scalingFactors = {
    ContentSizeCategory.extraSmall: 0.82,
    ContentSizeCategory.small: 0.88,
    ContentSizeCategory.medium: 0.95,
    ContentSizeCategory.large: 1.0,
    ContentSizeCategory.extraLarge: 1.12,
    ContentSizeCategory.extraExtraLarge: 1.23,
    ContentSizeCategory.extraExtraExtraLarge: 1.35,
    ContentSizeCategory.accessibilityMedium: 1.60,
    ContentSizeCategory.accessibilityLarge: 1.90,
    ContentSizeCategory.accessibilityExtraLarge: 2.35,
    ContentSizeCategory.accessibilityExtraExtraLarge: 2.76,
    ContentSizeCategory.accessibilityExtraExtraExtraLarge: 3.12,
  };

  // MARK: - Helper Methods

  /// Scales a text style for Dynamic Type
  static TextStyle scaleForAccessibility(
    TextStyle style,
    ContentSizeCategory category,
  ) {
    final scaleFactor = _scalingFactors[category] ?? 1.0;
    return style.copyWith(
      fontSize: (style.fontSize ?? 17.0) * scaleFactor,
    );
  }

  /// Returns the appropriate text style with color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Returns text style with system font
  static TextStyle withSystemFont(TextStyle style) {
    return style.copyWith(
      fontFamily: '.SF Pro Text', // iOS system font
    );
  }

  /// Creates a text style with iOS-appropriate properties
  static TextStyle createIOSTextStyle({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    double? letterSpacing,
    double? height,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
      fontFamily: '.SF Pro Text',
    );
  }

  /// Gets the current content size category from MediaQuery
  static ContentSizeCategory getContentSizeCategory(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaler.scale(1.0);

    if (textScaleFactor <= 0.82) return ContentSizeCategory.extraSmall;
    if (textScaleFactor <= 0.88) return ContentSizeCategory.small;
    if (textScaleFactor <= 0.95) return ContentSizeCategory.medium;
    if (textScaleFactor <= 1.0) return ContentSizeCategory.large;
    if (textScaleFactor <= 1.12) return ContentSizeCategory.extraLarge;
    if (textScaleFactor <= 1.23) return ContentSizeCategory.extraExtraLarge;
    if (textScaleFactor <= 1.35)
      return ContentSizeCategory.extraExtraExtraLarge;
    if (textScaleFactor <= 1.60) return ContentSizeCategory.accessibilityMedium;
    if (textScaleFactor <= 1.90) return ContentSizeCategory.accessibilityLarge;
    if (textScaleFactor <= 2.35)
      return ContentSizeCategory.accessibilityExtraLarge;
    if (textScaleFactor <= 2.76)
      return ContentSizeCategory.accessibilityExtraExtraLarge;

    return ContentSizeCategory.accessibilityExtraExtraExtraLarge;
  }

  /// Applies Dynamic Type scaling to a text style
  static TextStyle applyDynamicType(TextStyle style, BuildContext context) {
    final category = getContentSizeCategory(context);
    return scaleForAccessibility(style, category);
  }
}
