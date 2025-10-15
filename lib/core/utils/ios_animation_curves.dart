import 'package:flutter/widgets.dart';

/// iOS-native animation curves for 60fps performance
class IOSAnimationCurves {
  IOSAnimationCurves._();

  /// Standard iOS ease-in-out curve (similar to CAMediaTimingFunction)
  static const Curve easeInOut = Cubic(0.25, 0.1, 0.25, 1.0);

  /// iOS ease-in curve
  static const Curve easeIn = Cubic(0.42, 0.0, 1.0, 1.0);

  /// iOS ease-out curve
  static const Curve easeOut = Cubic(0.0, 0.0, 0.58, 1.0);

  /// iOS spring animation curve (similar to UIView spring animations)
  static const Curve spring = Cubic(0.175, 0.885, 0.32, 1.275);

  /// iOS bounce curve for scroll physics
  static const Curve bounce = Cubic(0.68, -0.55, 0.265, 1.55);

  /// iOS navigation transition curve
  static const Curve navigationTransition = Cubic(0.4, 0.0, 0.2, 1.0);

  /// iOS modal presentation curve
  static const Curve modalPresentation = Cubic(0.25, 0.46, 0.45, 0.94);

  /// iOS list scroll curve for smooth scrolling
  static const Curve listScroll = Cubic(0.25, 0.1, 0.25, 1.0);
}

/// iOS-specific animation durations matching system animations
class IOSAnimationDurations {
  IOSAnimationDurations._();

  /// Standard iOS animation duration (300ms)
  static const Duration standard = Duration(milliseconds: 300);

  /// Quick iOS animation duration (200ms)
  static const Duration quick = Duration(milliseconds: 200);

  /// Slow iOS animation duration (500ms)
  static const Duration slow = Duration(milliseconds: 500);

  /// Navigation transition duration
  static const Duration navigationTransition = Duration(milliseconds: 350);

  /// Modal presentation duration
  static const Duration modalPresentation = Duration(milliseconds: 400);

  /// Spring animation duration
  static const Duration spring = Duration(milliseconds: 600);

  /// Bounce animation duration
  static const Duration bounce = Duration(milliseconds: 800);
}

/// Utility class for creating iOS-native animations
class IOSAnimationUtils {
  IOSAnimationUtils._();

  /// Create a standard iOS fade animation
  static Animation<double> createFadeAnimation(
    AnimationController controller, {
    Curve curve = IOSAnimationCurves.easeInOut,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create a standard iOS slide animation
  static Animation<Offset> createSlideAnimation(
    AnimationController controller, {
    Offset begin = const Offset(1.0, 0.0),
    Offset end = Offset.zero,
    Curve curve = IOSAnimationCurves.navigationTransition,
  }) {
    return Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create a standard iOS scale animation
  static Animation<double> createScaleAnimation(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = IOSAnimationCurves.spring,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create an iOS spring animation controller
  static AnimationController createSpringController(
    TickerProvider vsync, {
    Duration duration = IOSAnimationDurations.spring,
  }) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
    );
  }

  /// Create an iOS navigation animation controller
  static AnimationController createNavigationController(
    TickerProvider vsync, {
    Duration duration = IOSAnimationDurations.navigationTransition,
  }) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
    );
  }
}

/// Custom iOS-style scroll physics for 60fps performance
class IOSScrollPhysics extends BouncingScrollPhysics {
  const IOSScrollPhysics({super.parent});

  @override
  IOSScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return IOSScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 0.5,
        stiffness: 100.0,
        damping: 0.8,
      );

  @override
  double get minFlingVelocity => 50.0;

  @override
  double get maxFlingVelocity => 8000.0;

  @override
  Tolerance get tolerance => const Tolerance(
        velocity: 1.0,
        distance: 1.0,
      );
}

/// High-performance scroll physics for fast scrolling
class IOSHighPerformanceScrollPhysics extends IOSScrollPhysics {
  const IOSHighPerformanceScrollPhysics({super.parent});

  @override
  IOSHighPerformanceScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return IOSHighPerformanceScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 0.3, // Lighter for faster response
        stiffness: 120.0, // Stiffer for quicker settling
        damping: 0.9, // Higher damping for stability
      );

  @override
  double get minFlingVelocity => 100.0; // Higher threshold

  @override
  double get maxFlingVelocity => 12000.0; // Higher max velocity
}
