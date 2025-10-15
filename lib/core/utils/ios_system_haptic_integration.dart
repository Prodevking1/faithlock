import 'package:faithlock/core/utils/ios_haptic_feedback.dart';
import 'package:faithlock/core/utils/ios_system_behavior.dart';
import 'package:flutter/material.dart';

/// Integration layer between haptic feedback and system behavior
class IOSSystemHapticIntegration {
  IOSSystemHapticIntegration._();

  /// Enhanced feedback that respects system preferences
  static Future<void> systemAwareFeedback(
    BuildContext context,
    Future<void> Function() feedbackFunction,
  ) async {
    // Respect reduce motion setting - some users prefer no haptic feedback
    if (IOSSystemBehavior.isReduceMotionEnabled(context)) {
      return;
    }

    await feedbackFunction();
  }

  /// Context-aware button feedback
  static Future<void> contextAwareButtonTap(BuildContext context) async {
    await systemAwareFeedback(context, IOSHapticFeedback.lightImpact);
  }

  /// Context-aware destructive action feedback
  static Future<void> contextAwareDestructiveAction(
      BuildContext context) async {
    await systemAwareFeedback(context, () async {
      await IOSHapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await IOSHapticFeedback.heavyImpact();
    });
  }

  /// Context-aware success feedback
  static Future<void> contextAwareSuccess(BuildContext context) async {
    await systemAwareFeedback(context, IOSHapticFeedback.successPattern);
  }

  /// Context-aware error feedback
  static Future<void> contextAwareError(BuildContext context) async {
    await systemAwareFeedback(context, IOSHapticFeedback.errorPattern);
  }
}
