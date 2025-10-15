import 'package:flutter/material.dart';

/// iOS spacing constants following Apple's Human Interface Guidelines
class IOSSpacing {
  IOSSpacing._();

  // MARK: - Base Spacing Values (iOS Standard)

  /// Extra small spacing - 4pt
  static const double xs = 4.0;

  /// Small spacing - 8pt
  static const double sm = 8.0;

  /// Medium spacing - 12pt
  static const double md = 12.0;

  /// Large spacing - 16pt (iOS standard margin)
  static const double lg = 16.0;

  /// Extra large spacing - 20pt (iPhone standard margin)
  static const double xl = 20.0;

  /// Extra extra large spacing - 24pt
  static const double xxl = 24.0;

  /// Triple extra large spacing - 32pt (section spacing)
  static const double xxxl = 32.0;

  /// Quadruple extra large spacing - 40pt
  static const double xxxxl = 40.0;

  // MARK: - iOS Specific Spacing

  /// Standard iOS margin for iPhone - 20pt
  static const double iPhoneMargin = 20.0;

  /// Standard iOS margin for iPad - 16pt
  static const double iPadMargin = 16.0;

  /// iOS list item minimum height - 44pt
  static const double listItemMinHeight = 44.0;

  /// iOS list item with subtitle height - 60pt
  static const double listItemWithSubtitleHeight = 60.0;

  /// iOS navigation bar height - 44pt
  static const double navigationBarHeight = 44.0;

  /// iOS large navigation bar height - 96pt
  static const double largeNavigationBarHeight = 96.0;

  /// iOS tab bar height - 49pt
  static const double tabBarHeight = 49.0;

  /// iOS section spacing - 32pt between sections
  static const double sectionSpacing = 32.0;

  /// iOS separator left margin - 54pt (after icon)
  static const double separatorLeftMargin = 54.0;

  /// iOS inset grouped margin - 16pt horizontal
  static const double insetGroupedMargin = 16.0;

  // MARK: - EdgeInsets Presets

  /// No padding
  static const EdgeInsets none = EdgeInsets.zero;

  /// Extra small padding - 4pt all
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);

  /// Small padding - 8pt all
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);

  /// Medium padding - 12pt all
  static const EdgeInsets paddingMD = EdgeInsets.all(md);

  /// Large padding - 16pt all (iOS standard)
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);

  /// Extra large padding - 20pt all (iPhone standard)
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  /// Extra extra large padding - 24pt all
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);

  // MARK: - Horizontal Padding

  /// Extra small horizontal padding - 4pt
  static const EdgeInsets horizontalXS = EdgeInsets.symmetric(horizontal: xs);

  /// Small horizontal padding - 8pt
  static const EdgeInsets horizontalSM = EdgeInsets.symmetric(horizontal: sm);

  /// Medium horizontal padding - 12pt
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);

  /// Large horizontal padding - 16pt (iOS standard)
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);

  /// Extra large horizontal padding - 20pt (iPhone standard)
  static const EdgeInsets horizontalXL = EdgeInsets.symmetric(horizontal: xl);

  /// Extra extra large horizontal padding - 24pt
  static const EdgeInsets horizontalXXL = EdgeInsets.symmetric(horizontal: xxl);

  // MARK: - Vertical Padding

  /// Extra small vertical padding - 4pt
  static const EdgeInsets verticalXS = EdgeInsets.symmetric(vertical: xs);

  /// Small vertical padding - 8pt
  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: sm);

  /// Medium vertical padding - 12pt
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);

  /// Large vertical padding - 16pt (iOS standard)
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);

  /// Extra large vertical padding - 20pt
  static const EdgeInsets verticalXL = EdgeInsets.symmetric(vertical: xl);

  /// Extra extra large vertical padding - 24pt
  static const EdgeInsets verticalXXL = EdgeInsets.symmetric(vertical: xxl);

  // MARK: - iOS Specific EdgeInsets

  /// iPhone standard margins
  static const EdgeInsets iPhoneMargins =
      EdgeInsets.symmetric(horizontal: iPhoneMargin);

  /// iPad standard margins
  static const EdgeInsets iPadMargins =
      EdgeInsets.symmetric(horizontal: iPadMargin);

  /// iOS list item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  /// iOS inset grouped section margins
  static const EdgeInsets insetGroupedMargins =
      EdgeInsets.symmetric(horizontal: insetGroupedMargin);

  /// iOS navigation bar padding
  static const EdgeInsets navigationBarPadding =
      EdgeInsets.symmetric(horizontal: lg);

  // MARK: - SizedBox Gaps

  /// Extra small vertical gap - 4pt
  static const SizedBox gapXS = SizedBox(height: xs);

  /// Small vertical gap - 8pt
  static const SizedBox gapSM = SizedBox(height: sm);

  /// Medium vertical gap - 12pt
  static const SizedBox gapMD = SizedBox(height: md);

  /// Large vertical gap - 16pt
  static const SizedBox gapLG = SizedBox(height: lg);

  /// Extra large vertical gap - 20pt
  static const SizedBox gapXL = SizedBox(height: xl);

  /// Extra extra large vertical gap - 24pt
  static const SizedBox gapXXL = SizedBox(height: xxl);

  /// Triple extra large vertical gap - 32pt (section spacing)
  static const SizedBox gapXXXL = SizedBox(height: xxxl);

  // MARK: - Horizontal Gaps

  /// Extra small horizontal gap - 4pt
  static const SizedBox horizontalGapXS = SizedBox(width: xs);

  /// Small horizontal gap - 8pt
  static const SizedBox horizontalGapSM = SizedBox(width: sm);

  /// Medium horizontal gap - 12pt
  static const SizedBox horizontalGapMD = SizedBox(width: md);

  /// Large horizontal gap - 16pt
  static const SizedBox horizontalGapLG = SizedBox(width: lg);

  /// Extra large horizontal gap - 20pt
  static const SizedBox horizontalGapXL = SizedBox(width: xl);

  /// Extra extra large horizontal gap - 24pt
  static const SizedBox horizontalGapXXL = SizedBox(width: xxl);

  // MARK: - Helper Methods

  /// Returns appropriate margin based on device type
  static EdgeInsets deviceMargins(bool isIPad) {
    return isIPad ? iPadMargins : iPhoneMargins;
  }

  /// Returns appropriate padding for list items
  static EdgeInsets listPadding({bool isGrouped = false}) {
    return isGrouped ? insetGroupedMargins : listItemPadding;
  }

  /// Creates custom EdgeInsets with iOS-appropriate values
  static EdgeInsets custom({
    double? top,
    double? bottom,
    double? left,
    double? right,
    double? horizontal,
    double? vertical,
  }) {
    return EdgeInsets.only(
      top: top ?? vertical ?? 0,
      bottom: bottom ?? vertical ?? 0,
      left: left ?? horizontal ?? 0,
      right: right ?? horizontal ?? 0,
    );
  }
}
