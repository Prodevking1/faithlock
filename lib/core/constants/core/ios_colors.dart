import 'package:flutter/cupertino.dart';

/// iOS system colors following Apple's Human Interface Guidelines
class IOSColors {
  IOSColors._();

  // MARK: - System Colors

  /// iOS system blue - primary action color
  static const Color systemBlue = CupertinoColors.systemBlue;

  /// iOS system green - success states
  static const Color systemGreen = CupertinoColors.systemGreen;

  /// iOS system indigo
  static const Color systemIndigo = CupertinoColors.systemIndigo;

  /// iOS system orange - warning states
  static const Color systemOrange = CupertinoColors.systemOrange;

  /// iOS system pink
  static const Color systemPink = CupertinoColors.systemPink;

  /// iOS system purple
  static const Color systemPurple = CupertinoColors.systemPurple;

  /// iOS system red - destructive actions and errors
  static const Color systemRed = CupertinoColors.systemRed;

  /// iOS system teal
  static const Color systemTeal = CupertinoColors.systemTeal;

  /// iOS system yellow
  static const Color systemYellow = CupertinoColors.systemYellow;

  // MARK: - System Gray Colors

  /// iOS system gray
  static const Color systemGray = CupertinoColors.systemGrey;

  /// iOS system gray 2
  static const Color systemGray2 = CupertinoColors.systemGrey2;

  /// iOS system gray 3
  static const Color systemGray3 = CupertinoColors.systemGrey3;

  /// iOS system gray 4
  static const Color systemGray4 = CupertinoColors.systemGrey4;

  /// iOS system gray 5
  static const Color systemGray5 = CupertinoColors.systemGrey5;

  /// iOS system gray 6
  static const Color systemGray6 = CupertinoColors.systemGrey6;

  // MARK: - Label Colors (Semantic)

  /// Primary label color - adapts to light/dark mode
  static const Color label = CupertinoColors.label;

  /// Secondary label color - adapts to light/dark mode
  static const Color secondaryLabel = CupertinoColors.secondaryLabel;

  /// Tertiary label color - adapts to light/dark mode
  static const Color tertiaryLabel = CupertinoColors.tertiaryLabel;

  /// Quaternary label color - adapts to light/dark mode
  static const Color quaternaryLabel = CupertinoColors.quaternaryLabel;

  // MARK: - Fill Colors

  /// System fill color - adapts to light/dark mode
  static const Color systemFill = CupertinoColors.systemFill;

  /// Secondary system fill color - adapts to light/dark mode
  static const Color secondarySystemFill = CupertinoColors.secondarySystemFill;

  /// Tertiary system fill color - adapts to light/dark mode
  static const Color tertiarySystemFill = CupertinoColors.tertiarySystemFill;

  /// Quaternary system fill color - adapts to light/dark mode
  static const Color quaternarySystemFill =
      CupertinoColors.quaternarySystemFill;

  // MARK: - Background Colors

  /// System background color - adapts to light/dark mode
  static const Color systemBackground = CupertinoColors.systemBackground;

  /// Secondary system background color - adapts to light/dark mode
  static const Color secondarySystemBackground =
      CupertinoColors.secondarySystemBackground;

  /// Tertiary system background color - adapts to light/dark mode
  static const Color tertiarySystemBackground =
      CupertinoColors.tertiarySystemBackground;

  // MARK: - Grouped Background Colors

  /// System grouped background color - adapts to light/dark mode
  static const Color systemGroupedBackground =
      CupertinoColors.systemGroupedBackground;

  /// Secondary system grouped background color - adapts to light/dark mode
  static const Color secondarySystemGroupedBackground =
      CupertinoColors.secondarySystemGroupedBackground;

  /// Tertiary system grouped background color - adapts to light/dark mode
  static const Color tertiarySystemGroupedBackground =
      CupertinoColors.tertiarySystemGroupedBackground;

  // MARK: - Separator Colors

  /// Separator color - adapts to light/dark mode
  static const Color separator = CupertinoColors.separator;

  /// Opaque separator color - adapts to light/dark mode
  static const Color opaqueSeparator = CupertinoColors.opaqueSeparator;

  // MARK: - Link Color

  /// Link color - adapts to light/dark mode
  static const Color link = CupertinoColors.link;

  // MARK: - Interactive State Colors

  /// Active blue color for interactive elements
  static const Color activeBlue = CupertinoColors.activeBlue;

  /// Active green color for interactive elements
  static const Color activeGreen = CupertinoColors.activeGreen;

  /// Active orange color for interactive elements
  static const Color activeOrange = CupertinoColors.activeOrange;

  /// Destructive red color for destructive actions
  static const Color destructiveRed = CupertinoColors.destructiveRed;

  /// Inactive gray color for disabled elements
  static const Color inactiveGray = CupertinoColors.inactiveGray;

  // MARK: - Accessibility Colors

  /// High contrast version of system blue
  static const Color accessibilityBlue = Color(0xFF0040DD);

  /// High contrast version of system red
  static const Color accessibilityRed = Color(0xFFD70015);

  /// High contrast version of system green
  static const Color accessibilityGreen = Color(0xFF008400);

  // MARK: - Helper Methods

  /// Returns the appropriate color based on brightness
  static Color adaptiveColor({
    required Color lightColor,
    required Color darkColor,
    required Brightness brightness,
  }) {
    return brightness == Brightness.light ? lightColor : darkColor;
  }

  /// Returns iOS system color with proper adaptation
  static CupertinoDynamicColor dynamicColor({
    required Color light,
    required Color dark,
    Color? highContrastLight,
    Color? highContrastDark,
  }) {
    return CupertinoDynamicColor.withBrightness(
      color: light,
      darkColor: dark,
    );
  }
}
