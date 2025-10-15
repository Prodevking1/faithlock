import 'package:flutter/widgets.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import '../posthog_service.dart';

/// Module for automatic screen tracking and navigation analytics
class ScreenTrackingModule {
  final PostHogService _postHogService;
  bool _isInitialized = false;
  bool _autoTrackingEnabled = true;
  String? _currentScreen;
  DateTime? _screenStartTime;
  final Map<String, int> _screenVisitCounts = {};

  ScreenTrackingModule(this._postHogService);

  /// Initialize the screen tracking module
  Future<void> init({bool autoTrackingEnabled = true}) async {
    try {
      _autoTrackingEnabled = autoTrackingEnabled;
      _isInitialized = true;
      debugPrint('ScreenTrackingModule: Initialized successfully (auto-tracking: $_autoTrackingEnabled)');
    } catch (e) {
      debugPrint('ScreenTrackingModule: Failed to initialize - $e');
      rethrow;
    }
  }

  /// Shutdown the module
  Future<void> shutdown() async {
    try {
      if (_currentScreen != null) {
        await _trackScreenEnd(_currentScreen!);
      }
      _isInitialized = false;
      debugPrint('ScreenTrackingModule: Shutdown successfully');
    } catch (e) {
      debugPrint('ScreenTrackingModule: Failed to shutdown - $e');
    }
  }

  /// Manually track a screen view
  Future<void> trackScreen({
    required String screenName,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint('ScreenTrackingModule: Cannot track screen - module not initialized');
      return;
    }

    try {
      // End tracking for previous screen
      if (_currentScreen != null && _currentScreen != screenName) {
        await _trackScreenEnd(_currentScreen!);
      }

      // Start tracking new screen
      _currentScreen = screenName;
      _screenStartTime = DateTime.now();
      _screenVisitCounts[screenName] = (_screenVisitCounts[screenName] ?? 0) + 1;

      await Posthog().screen(
        screenName: screenName,
        properties: {
          'screen_name': screenName,
          'visit_count': _screenVisitCounts[screenName] ?? 0,
          'timestamp': _screenStartTime!.toIso8601String(),
          ...?properties,
        },
      );

      debugPrint('ScreenTrackingModule: Screen tracked - $screenName');
    } catch (e) {
      debugPrint('ScreenTrackingModule: Failed to track screen - $e');
    }
  }

  /// Track screen transition
  Future<void> trackScreenTransition({
    required String fromScreen,
    required String toScreen,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint('ScreenTrackingModule: Cannot track transition - module not initialized');
      return;
    }

    try {
      await Posthog().capture(
        eventName: 'screen_transition',
        properties: {
          'from_screen': fromScreen,
          'to_screen': toScreen,
          'timestamp': DateTime.now().toIso8601String(),
          ...?properties,
        },
      );

      debugPrint('ScreenTrackingModule: Screen transition tracked - $fromScreen -> $toScreen');
    } catch (e) {
      debugPrint('ScreenTrackingModule: Failed to track screen transition - $e');
    }
  }

  /// Track time spent on screen
  Future<void> trackScreenDuration({
    required String screenName,
    required Duration duration,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint('ScreenTrackingModule: Cannot track duration - module not initialized');
      return;
    }

    try {
      await Posthog().capture(
        eventName: 'screen_duration',
        properties: {
          'screen_name': screenName,
          'duration_seconds': duration.inSeconds,
          'duration_minutes': duration.inMinutes,
          'timestamp': DateTime.now().toIso8601String(),
          ...?properties,
        },
      );

      debugPrint('ScreenTrackingModule: Screen duration tracked - $screenName (${duration.inSeconds}s)');
    } catch (e) {
      debugPrint('ScreenTrackingModule: Failed to track screen duration - $e');
    }
  }

  /// Track screen interaction
  Future<void> trackScreenInteraction({
    required String screenName,
    required String interactionType,
    String? elementId,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint('ScreenTrackingModule: Cannot track interaction - module not initialized');
      return;
    }

    try {
      await Posthog().capture(
        eventName: 'screen_interaction',
        properties: {
          'screen_name': screenName,
          'interaction_type': interactionType,
          if (elementId != null) 'element_id': elementId,
          'timestamp': DateTime.now().toIso8601String(),
          ...?properties,
        },
      );

      debugPrint('ScreenTrackingModule: Screen interaction tracked - $screenName ($interactionType)');
    } catch (e) {
      debugPrint('ScreenTrackingModule: Failed to track screen interaction - $e');
    }
  }

  /// Get current screen name
  String? get currentScreen => _currentScreen;

  /// Get screen visit counts
  Map<String, int> get screenVisitCounts => Map.unmodifiable(_screenVisitCounts);

  /// Enable/disable auto tracking
  void setAutoTrackingEnabled(bool enabled) {
    _autoTrackingEnabled = enabled;
    debugPrint('ScreenTrackingModule: Auto tracking ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Check if auto tracking is enabled
  bool get isAutoTrackingEnabled => _autoTrackingEnabled;

  /// Reset the module
  Future<void> reset() async {
    try {
      if (_currentScreen != null) {
        await _trackScreenEnd(_currentScreen!);
      }
      _currentScreen = null;
      _screenStartTime = null;
      _screenVisitCounts.clear();
      debugPrint('ScreenTrackingModule: Reset successfully');
    } catch (e) {
      debugPrint('ScreenTrackingModule: Failed to reset - $e');
    }
  }

  /// Private method to track screen end
  Future<void> _trackScreenEnd(String screenName) async {
    if (_screenStartTime != null) {
      final duration = DateTime.now().difference(_screenStartTime!);
      await trackScreenDuration(screenName: screenName, duration: duration);
    }
  }

  /// Route observer for automatic screen tracking
  RouteObserver<PageRoute> get routeObserver => _ScreenTrackingRouteObserver(this);
}

/// Route observer for automatic screen tracking
class _ScreenTrackingRouteObserver extends RouteObserver<PageRoute> {
  final ScreenTrackingModule _module;

  _ScreenTrackingRouteObserver(this._module);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute && _module._autoTrackingEnabled) {
      final screenName = route.settings.name ?? route.runtimeType.toString();
      _module.trackScreen(screenName: screenName);

      if (previousRoute is PageRoute) {
        final previousScreen = previousRoute.settings.name ?? previousRoute.runtimeType.toString();
        _module.trackScreenTransition(
          fromScreen: previousScreen,
          toScreen: screenName,
        );
      }
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && _module._autoTrackingEnabled) {
      final screenName = previousRoute.settings.name ?? previousRoute.runtimeType.toString();
      _module.trackScreen(screenName: screenName);

      if (route is PageRoute) {
        final fromScreen = route.settings.name ?? route.runtimeType.toString();
        _module.trackScreenTransition(
          fromScreen: fromScreen,
          toScreen: screenName,
        );
      }
    }
  }
}
