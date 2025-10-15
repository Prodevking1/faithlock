import 'package:faithlock/core/utils/ios_haptic_feedback.dart';
import 'package:faithlock/core/utils/ios_platform_detector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// iOS system behavior integration following Apple's guidelines
class IOSSystemBehavior {
  IOSSystemBehavior._();

  // MARK: - Dark Mode Support

  /// Returns true if system is in dark mode
  static bool isDarkMode(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  /// Returns appropriate brightness for current system theme
  static Brightness getSystemBrightness(BuildContext context) {
    return MediaQuery.of(context).platformBrightness;
  }

  /// Builds widget that adapts to dark/light mode
  static Widget buildThemeAdaptive(
    BuildContext context, {
    required Widget lightWidget,
    required Widget darkWidget,
  }) {
    return isDarkMode(context) ? darkWidget : lightWidget;
  }

  /// Returns color that adapts to current theme
  static Color adaptiveColor(
    BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    return isDarkMode(context) ? darkColor : lightColor;
  }

  // MARK: - Reduce Motion Support

  /// Returns true if user has enabled reduce motion
  static bool isReduceMotionEnabled(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Returns appropriate animation duration based on reduce motion setting
  static Duration getAnimationDuration(
    BuildContext context, {
    Duration normalDuration = const Duration(milliseconds: 300),
    Duration reducedDuration = const Duration(milliseconds: 100),
  }) {
    return isReduceMotionEnabled(context) ? reducedDuration : normalDuration;
  }

  /// Builds animation that respects reduce motion setting
  static Widget buildAccessibleAnimation(
    BuildContext context, {
    required Widget child,
    required Animation<double> animation,
    Widget Function(BuildContext, Widget?, Animation<double>)? builder,
  }) {
    if (isReduceMotionEnabled(context)) {
      return child;
    }

    return builder != null
        ? builder(context, child, animation)
        : FadeTransition(opacity: animation, child: child);
  }

  // MARK: - High Contrast Support

  /// Returns true if user has enabled high contrast
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Returns color with enhanced contrast if needed
  static Color getContrastAdjustedColor(
    BuildContext context, {
    required Color normalColor,
    required Color highContrastColor,
  }) {
    return isHighContrastEnabled(context) ? highContrastColor : normalColor;
  }

  // MARK: - Bold Text Support

  /// Returns true if user has enabled bold text
  static bool isBoldTextEnabled(BuildContext context) {
    return MediaQuery.of(context).boldText;
  }

  /// Returns text style with appropriate weight based on bold text setting
  static TextStyle getBoldAdjustedTextStyle(
    BuildContext context, {
    required TextStyle normalStyle,
    FontWeight? boldWeight,
  }) {
    if (!isBoldTextEnabled(context)) return normalStyle;

    return normalStyle.copyWith(
      fontWeight: boldWeight ?? FontWeight.w600,
    );
  }

  // MARK: - Dynamic Type Support

  /// Returns current text scale factor
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0);
  }

  /// Returns true if accessibility text sizes are enabled
  static bool isAccessibilityTextSizeEnabled(BuildContext context) {
    return getTextScaleFactor(context) > 1.35;
  }

  /// Scales text style for current accessibility settings
  static TextStyle getAccessibilityScaledTextStyle(
    BuildContext context,
    TextStyle baseStyle,
  ) {
    final scaleFactor = getTextScaleFactor(context);
    return baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 17.0) * scaleFactor,
    );
  }

  // MARK: - Keyboard Avoidance

  /// Automatically adjusts view for keyboard with iOS animations
  static Widget buildKeyboardAvoidingView({
    required Widget child,
    bool resizeToAvoidBottomInset = true,
  }) {
    if (!IOSPlatformDetector.isIOS) {
      return child;
    }

    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      child: child,
    );
  }

  /// Returns keyboard height if visible
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  /// Returns true if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return getKeyboardHeight(context) > 0;
  }

  // MARK: - Background/Foreground State Management

  /// Handles app lifecycle state changes
  static void handleAppLifecycleState(
    AppLifecycleState state, {
    VoidCallback? onResumed,
    VoidCallback? onPaused,
    VoidCallback? onInactive,
    VoidCallback? onDetached,
  }) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResumed?.call();
        break;
      case AppLifecycleState.paused:
        onPaused?.call();
        break;
      case AppLifecycleState.inactive:
        onInactive?.call();
        break;
      case AppLifecycleState.detached:
        onDetached?.call();
        break;
      case AppLifecycleState.hidden:
        // Handle hidden state if needed
        break;
    }
  }

  // MARK: - Multitasking iPad Support

  /// Returns true if app is in split view mode (iPad)
  static bool isInSplitView(BuildContext context) {
    if (!IOSPlatformDetector.isIPad(context)) return false;

    final size = MediaQuery.of(context).size;
    // Heuristic: if width is significantly less than typical iPad width
    return size.width < 700;
  }

  /// Returns appropriate layout based on multitasking state
  static Widget buildMultitaskingAdaptiveLayout(
    BuildContext context, {
    required Widget fullScreenLayout,
    required Widget compactLayout,
  }) {
    return isInSplitView(context) ? compactLayout : fullScreenLayout;
  }

  /// Returns appropriate margins for multitasking
  static EdgeInsets getMultitaskingAwareMargins(BuildContext context) {
    if (isInSplitView(context)) {
      return const EdgeInsets.symmetric(horizontal: 12.0);
    }
    return IOSPlatformDetector.isIPad(context)
        ? const EdgeInsets.symmetric(horizontal: 16.0)
        : const EdgeInsets.symmetric(horizontal: 20.0);
  }

  // MARK: - System Preferences Integration

  /// System preferences that affect UI behavior
  static Map<String, dynamic> getSystemPreferences(BuildContext context) {
    return {
      'isDarkMode': isDarkMode(context),
      'isReduceMotionEnabled': isReduceMotionEnabled(context),
      'isHighContrastEnabled': isHighContrastEnabled(context),
      'isBoldTextEnabled': isBoldTextEnabled(context),
      'textScaleFactor': getTextScaleFactor(context),
      'isAccessibilityTextSizeEnabled': isAccessibilityTextSizeEnabled(context),
      'isKeyboardVisible': isKeyboardVisible(context),
      'isInSplitView': isInSplitView(context),
    };
  }

  // MARK: - Adaptive UI Helpers

  /// Builds UI that adapts to all system preferences
  static Widget buildFullyAdaptiveUI(
    BuildContext context, {
    required Widget Function(BuildContext, Map<String, dynamic>) builder,
  }) {
    final preferences = getSystemPreferences(context);
    return builder(context, preferences);
  }

  /// Returns appropriate animation curve for iOS
  static Curve getIOSAnimationCurve({
    bool isReduceMotion = false,
  }) {
    if (isReduceMotion) return Curves.linear;
    return Curves.easeInOut;
  }

  /// Returns iOS-appropriate page transition
  static PageRouteBuilder<T> buildIOSPageRoute<T>({
    required Widget page,
    required BuildContext context,
    RouteSettings? settings,
  }) {
    final reduceMotion = isReduceMotionEnabled(context);

    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: getAnimationDuration(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (reduceMotion) {
          return child;
        }

        return CupertinoPageTransition(
          primaryRouteAnimation: animation,
          secondaryRouteAnimation: secondaryAnimation,
          child: child,
          linearTransition: false,
        );
      },
    );
  }

  // MARK: - Status Bar Management

  /// Sets status bar style based on current theme
  static void setStatusBarStyle(BuildContext context) {
    if (!IOSPlatformDetector.isIOS) return;

    final isDark = isDarkMode(context);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  // MARK: - Haptic Feedback Integration

  /// Triggers appropriate haptic feedback based on interaction type
  static Future<void> triggerContextualHapticFeedback(
    IOSHapticFeedbackType type,
  ) async {
    switch (type) {
      case IOSHapticFeedbackType.light:
        await IOSHapticFeedback.lightImpact();
        break;
      case IOSHapticFeedbackType.medium:
        await IOSHapticFeedback.mediumImpact();
        break;
      case IOSHapticFeedbackType.heavy:
        await IOSHapticFeedback.heavyImpact();
        break;
      case IOSHapticFeedbackType.selection:
        await IOSHapticFeedback.selectionClick();
        break;
      case IOSHapticFeedbackType.success:
        await IOSHapticFeedback.notificationSuccess();
        break;
      case IOSHapticFeedbackType.warning:
        await IOSHapticFeedback.notificationWarning();
        break;
      case IOSHapticFeedbackType.error:
        await IOSHapticFeedback.notificationError();
        break;
    }
  }
}

/// Types of haptic feedback for different contexts
enum IOSHapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
  success,
  warning,
  error,
}

/// Mixin for widgets that need iOS system behavior integration
mixin IOSSystemBehaviorMixin<T extends StatefulWidget> on State<T> {
  late AppLifecycleState _lifecycleState;

  @override
  void initState() {
    super.initState();
    _lifecycleState = AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(_AppLifecycleObserver(
      onStateChanged: _handleAppLifecycleStateChanged,
    ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_AppLifecycleObserver(
      onStateChanged: _handleAppLifecycleStateChanged,
    ));
    super.dispose();
  }

  void _handleAppLifecycleStateChanged(AppLifecycleState state) {
    setState(() {
      _lifecycleState = state;
    });
    onAppLifecycleStateChanged(state);
  }

  /// Override this method to handle app lifecycle changes
  void onAppLifecycleStateChanged(AppLifecycleState state) {}

  /// Current app lifecycle state
  AppLifecycleState get lifecycleState => _lifecycleState;

  /// Convenience method to check if app is active
  bool get isAppActive => _lifecycleState == AppLifecycleState.resumed;
}

/// Private app lifecycle observer
class _AppLifecycleObserver extends WidgetsBindingObserver {
  final Function(AppLifecycleState) onStateChanged;

  _AppLifecycleObserver({required this.onStateChanged});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    onStateChanged(state);
  }
}
