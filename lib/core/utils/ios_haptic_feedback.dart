import 'package:faithlock/core/utils/ios_platform_detector.dart';
import 'package:flutter/services.dart';

/// iOS haptic feedback system following Apple's guidelines
class IOSHapticFeedback {
  IOSHapticFeedback._();

  // MARK: - Impact Feedback

  /// Light impact feedback - for small UI interactions
  /// Use for: button taps, switch toggles, picker selections
  static Future<void> lightImpact() async {
    if (!IOSPlatformDetector.isIOS) return;
    await HapticFeedback.lightImpact();
  }

  /// Medium impact feedback - for moderate UI interactions
  /// Use for: refresh actions, significant state changes
  static Future<void> mediumImpact() async {
    if (!IOSPlatformDetector.isIOS) return;
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact feedback - for major UI interactions
  /// Use for: important confirmations, error states
  static Future<void> heavyImpact() async {
    if (!IOSPlatformDetector.isIOS) return;
    await HapticFeedback.heavyImpact();
  }

  // MARK: - Selection Feedback

  /// Selection feedback - for changing selections
  /// Use for: picker wheels, segmented controls, tab switches
  static Future<void> selectionClick() async {
    if (!IOSPlatformDetector.isIOS) return;
    await HapticFeedback.selectionClick();
  }

  // MARK: - Notification Feedback

  /// Success notification feedback
  /// Use for: successful operations, confirmations
  static Future<void> notificationSuccess() async {
    if (!IOSPlatformDetector.isIOS) return;
    // Flutter doesn't have direct notification feedback, use medium impact
    await HapticFeedback.mediumImpact();
  }

  /// Warning notification feedback
  /// Use for: warnings, non-critical errors
  static Future<void> notificationWarning() async {
    if (!IOSPlatformDetector.isIOS) return;
    // Flutter doesn't have direct notification feedback, use heavy impact
    await HapticFeedback.heavyImpact();
  }

  /// Error notification feedback
  /// Use for: errors, failed operations
  static Future<void> notificationError() async {
    if (!IOSPlatformDetector.isIOS) return;
    // Flutter doesn't have direct notification feedback, use heavy impact twice
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  // MARK: - Context-Specific Feedback

  /// Button tap feedback
  /// Standard feedback for button interactions
  static Future<void> buttonTap() async {
    await lightImpact();
  }

  /// Destructive button tap feedback
  /// Feedback for destructive actions (delete, remove, etc.)
  static Future<void> destructiveButtonTap() async {
    await mediumImpact();
  }

  /// Switch toggle feedback
  /// Feedback for switch state changes
  static Future<void> switchToggle() async {
    await lightImpact();
  }

  /// Slider change feedback
  /// Feedback for slider value changes
  static Future<void> sliderChange() async {
    await selectionClick();
  }

  /// Tab selection feedback
  /// Feedback for tab bar selections
  static Future<void> tabSelection() async {
    await selectionClick();
  }

  /// Segmented control feedback
  /// Feedback for segmented control selections
  static Future<void> segmentedControlSelection() async {
    await selectionClick();
  }

  /// List item selection feedback
  /// Feedback for list item taps
  static Future<void> listItemSelection() async {
    await lightImpact();
  }

  /// Modal presentation feedback
  /// Feedback when presenting modals
  static Future<void> modalPresentation() async {
    await lightImpact();
  }

  /// Modal dismissal feedback
  /// Feedback when dismissing modals
  static Future<void> modalDismissal() async {
    await lightImpact();
  }

  /// Pull to refresh feedback
  /// Feedback when pull-to-refresh is triggered
  static Future<void> pullToRefresh() async {
    await mediumImpact();
  }

  /// Context menu feedback
  /// Feedback when context menu appears
  static Future<void> contextMenu() async {
    await mediumImpact();
  }

  /// Long press feedback
  /// Feedback for long press gestures
  static Future<void> longPress() async {
    await mediumImpact();
  }

  // MARK: - Form Feedback

  /// Text input focus feedback
  /// Feedback when text input gains focus
  static Future<void> textInputFocus() async {
    await lightImpact();
  }

  /// Form validation error feedback
  /// Feedback for form validation errors
  static Future<void> formValidationError() async {
    await notificationError();
  }

  /// Form submission success feedback
  /// Feedback for successful form submissions
  static Future<void> formSubmissionSuccess() async {
    await notificationSuccess();
  }

  // MARK: - Navigation Feedback

  /// Page transition feedback
  /// Feedback for page navigation
  static Future<void> pageTransition() async {
    await lightImpact();
  }

  /// Back navigation feedback
  /// Feedback for back button or swipe back
  static Future<void> backNavigation() async {
    await lightImpact();
  }

  // MARK: - Utility Methods

  /// Conditional feedback based on platform
  /// Only triggers on iOS devices
  static Future<void> conditionalFeedback(
      Future<void> Function() feedbackFunction) async {
    if (IOSPlatformDetector.isIOS) {
      await feedbackFunction();
    }
  }

  /// Delayed feedback
  /// Triggers feedback after a specified delay
  static Future<void> delayedFeedback(
    Future<void> Function() feedbackFunction,
    Duration delay,
  ) async {
    await Future.delayed(delay);
    await feedbackFunction();
  }

  /// Multiple feedback pulses
  /// Triggers multiple feedback pulses with delays
  static Future<void> multipleFeedback(
    Future<void> Function() feedbackFunction,
    int count, {
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    for (int i = 0; i < count; i++) {
      await feedbackFunction();
      if (i < count - 1) {
        await Future.delayed(delay);
      }
    }
  }

  // MARK: - Feedback Patterns

  /// Success pattern - light, pause, medium
  static Future<void> successPattern() async {
    await lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await mediumImpact();
  }

  /// Error pattern - heavy, pause, heavy
  static Future<void> errorPattern() async {
    await heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await heavyImpact();
  }

  /// Warning pattern - medium, pause, light
  static Future<void> warningPattern() async {
    await mediumImpact();
    await Future.delayed(const Duration(milliseconds: 75));
    await lightImpact();
  }

  /// Confirmation pattern - light, light, medium
  static Future<void> confirmationPattern() async {
    await lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await mediumImpact();
  }

  // MARK: - Accessibility Considerations

  /// Checks if haptic feedback should be disabled based on accessibility settings
  static bool shouldDisableFeedback() {
    // In a real implementation, you would check system accessibility settings
    // For now, we'll assume feedback is always enabled
    return false;
  }

  /// Accessible feedback - respects user preferences
  static Future<void> accessibleFeedback(
      Future<void> Function() feedbackFunction) async {
    if (!shouldDisableFeedback()) {
      await feedbackFunction();
    }
  }
}
