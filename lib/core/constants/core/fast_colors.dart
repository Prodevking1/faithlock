import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FastColors {
  FastColors._();

  // Primary colors
  static const Color primary = Color(0xFFF2647C);
  static const Color primaryDark = Color(0xFFCA445D);
  static const Color primaryLight = Color(0xFFF5A5B3);

  // Accent colors
  static const Color accent = Color(0xFF4ECDC4);
  static const Color accentDark = Color(0xFF45B7AE);
  static const Color accentLight = Color(0xFF7FDFD9);

  // Background colors
  static const Color scaffoldBackground = Color(0xFFF8F9FA);
  static const Color scaffoldBackgroundDark = Color(0xFF121212);

  // Neutral colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF424242);

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE57373);
  static const Color warning = Color(0xFFFFB74D);
  static const Color info = Color(0xFF64B5F6);

  // FaithLock Stats Colors (for stat cards)
  static const Color streakOrange = Color(0xFFFF9800);
  static const Color streakOrangeLight = Color(0xFFFFE0B2);
  static const Color versesBlue = Color(0xFF2196F3);
  static const Color versesBlueLight = Color(0xFFBBDEFB);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color successGreenLight = Color(0xFFC8E6C9);
  static const Color timePurple = Color(0xFF9C27B0);
  static const Color timePurpleLight = Color(0xFFE1BEE7);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFAFAFA);
  static const Color textSecondaryDark = Color(0xFFBDBDBD);

  // Interactive states
  static final Color disabledStatic = grey.withValues(alpha: 0.5);
  static const Color hover = Color(0xFFF5758D);
  static const Color hoverDark = Color(0xFFE84E6A);

  // Additional colors for various UI elements
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBackgroundDark = Color(0xFF1E1E1E);
  static const Color divider = Color(0xFFBDBDBD);
  static const Color shadow = Color(0x1F000000);

  // ADAPTIVE COLORS - Auto-adapt to dark/light mode iOS/Android

  /// Primary text color (adaptive dark/light)
  static Color primaryText(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoColors.label.resolveFrom(context);
    }
    return Theme.of(context).colorScheme.onSurface;
  }

  /// Secondary text color (adaptive dark/light)
  static Color secondaryText(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoColors.secondaryLabel.resolveFrom(context);
    }
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  /// Tertiary text color (adaptive dark/light)
  static Color tertiaryText(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoColors.tertiaryLabel.resolveFrom(context);
    }
    return Theme.of(context).colorScheme.outline;
  }

  /// Color for main surface (adaptive dark/light)
  static Color surface(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoColors.systemBackground.resolveFrom(context);
    }
    return Theme.of(context).colorScheme.surface;
  }

  /// Color for secondary surface (adaptive dark/light)
  static Color surfaceVariant(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoColors.secondarySystemBackground.resolveFrom(context);
    }
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }

  /// Color for separator (adaptive dark/light)
  static Color separator(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoColors.separator.resolveFrom(context);
    }
    return Theme.of(context).dividerColor;
  }

  /// Color for border (adaptive dark/light)
  static Color border(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoColors.opaqueSeparator.resolveFrom(context);
    }
    return Theme.of(context).colorScheme.outline;
  }

  /// Color for disabled state (adaptive dark/light)
  static Color disabled(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoColors.quaternaryLabel.resolveFrom(context);
    }
    return Theme.of(context).disabledColor;
  }

  /// Color on primary (text on primary button)
  static Color onPrimary(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoColors.white;
    }
    return Theme.of(context).colorScheme.onPrimary;
  }

  /// White color for cases where context is not available
  static const Color staticWhite = Colors.white;

  /// Overlay for hover/pressed states (adaptive)
  static Color overlay(BuildContext context, {double opacity = 0.1}) {
    return primaryText(context).withValues(alpha: opacity);
  }

  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
