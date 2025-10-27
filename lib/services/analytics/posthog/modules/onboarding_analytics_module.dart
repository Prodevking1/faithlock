import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../posthog_service.dart';

/// Module for tracking onboarding flow analytics
///
/// Tracks:
/// - Step entry/exit events for funnel analysis
/// - User properties for segmentation
/// - Time-to-value metrics
/// - Feature adoption during onboarding
class OnboardingAnalyticsModule {
  final PostHogService _postHogService;
  bool _isInitialized = false;

  // Track onboarding session
  DateTime? _onboardingStartTime;
  DateTime? _currentStepStartTime;
  final Map<int, int> _stepDurations = {}; // step_number -> duration_seconds

  OnboardingAnalyticsModule(this._postHogService);

  /// Initialize the onboarding analytics module
  Future<void> init() async {
    try {
      _isInitialized = true;
      if (kDebugMode) {
        debugPrint('OnboardingAnalyticsModule: Initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('OnboardingAnalyticsModule: Failed to initialize - $e');
      }
      rethrow;
    }
  }

  /// Shutdown the module
  Future<void> shutdown() async {
    try {
      _onboardingStartTime = null;
      _currentStepStartTime = null;
      _stepDurations.clear();
      _isInitialized = false;
      if (kDebugMode) {
        debugPrint('OnboardingAnalyticsModule: Shutdown successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('OnboardingAnalyticsModule: Failed to shutdown - $e');
      }
    }
  }

  /// Start tracking onboarding session
  Future<void> startOnboarding() async {
    if (!_isInitialized) {
      if (kDebugMode) {
        debugPrint(
            'OnboardingAnalyticsModule: Cannot start - module not initialized');
      }
      return;
    }

    try {
      _onboardingStartTime = DateTime.now();
      _stepDurations.clear();

      await Posthog().capture(
        eventName: 'onboarding_started',
        properties: {
          'timestamp': _onboardingStartTime!.toIso8601String(),
        },
      );

      if (kDebugMode) {
        debugPrint('OnboardingAnalyticsModule: Onboarding started');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('OnboardingAnalyticsModule: Failed to start onboarding - $e');
      }
    }
  }

  /// Track when user enters a step
  Future<void> trackStepEntry({
    required int stepNumber,
    required String stepName,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized) {
      if (kDebugMode) {
        debugPrint(
            'OnboardingAnalyticsModule: Cannot track step entry - module not initialized');
      }
      return;
    }

    try {
      _currentStepStartTime = DateTime.now();

      final properties = <String, Object>{
        'step_number': stepNumber,
        'step_name': stepName,
        'timestamp': _currentStepStartTime!.toIso8601String(),
      };

      if (metadata != null) {
        properties.addAll(metadata.map((k, v) => MapEntry(k, v as Object)));
      }

      await Posthog().capture(
        eventName: 'onboarding_step_entered',
        properties: properties,
      );

      if (kDebugMode) {
        debugPrint(
            'OnboardingAnalyticsModule: Step $stepNumber entered - $stepName');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('OnboardingAnalyticsModule: Failed to track step entry - $e');
      }
    }
  }

  /// Track when user completes a step
  Future<void> trackStepExit({
    required int stepNumber,
    required String stepName,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized) {
      if (kDebugMode) {
        debugPrint(
            'OnboardingAnalyticsModule: Cannot track step exit - module not initialized');
      }
      return;
    }

    try {
      // Calculate step duration
      int? durationSeconds;
      if (_currentStepStartTime != null) {
        durationSeconds =
            DateTime.now().difference(_currentStepStartTime!).inSeconds;
        _stepDurations[stepNumber] = durationSeconds;
      }

      final properties = <String, Object>{
        'step_number': stepNumber,
        'step_name': stepName,
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (durationSeconds != null) properties['duration_seconds'] = durationSeconds;
      if (metadata != null) {
        properties.addAll(metadata.map((k, v) => MapEntry(k, v as Object)));
      }

      await Posthog().capture(
        eventName: 'onboarding_step_completed',
        properties: properties,
      );

      if (kDebugMode) {
        debugPrint(
            'OnboardingAnalyticsModule: Step $stepNumber completed - $stepName (${durationSeconds}s)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('OnboardingAnalyticsModule: Failed to track step exit - $e');
      }
    }
  }

  /// Set user properties for segmentation
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    if (!_isInitialized) {
      if (kDebugMode) {
        debugPrint(
            'OnboardingAnalyticsModule: Cannot set properties - module not initialized');
      }
      return;
    }

    try {
      final currentUserId = await Posthog().getDistinctId();
      await Posthog().identify(
        userId: currentUserId,
        userProperties: Map<String, Object>.from(properties),
      );

      if (kDebugMode) {
        debugPrint(
            'OnboardingAnalyticsModule: User properties set - ${properties.keys.join(", ")}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            'OnboardingAnalyticsModule: Failed to set user properties - $e');
      }
    }
  }

  /// Track onboarding completion
  Future<void> trackOnboardingComplete() async {
    if (!_isInitialized) {
      if (kDebugMode) {
        debugPrint(
            'OnboardingAnalyticsModule: Cannot track completion - module not initialized');
      }
      return;
    }

    try {
      // Calculate total duration
      int? totalDurationSeconds;
      if (_onboardingStartTime != null) {
        totalDurationSeconds =
            DateTime.now().difference(_onboardingStartTime!).inSeconds;
      }

      // Calculate average step duration
      double? averageStepDuration;
      if (_stepDurations.isNotEmpty) {
        averageStepDuration = _stepDurations.values.reduce((a, b) => a + b) /
            _stepDurations.length;
      }

      await Posthog().capture(
        eventName: 'onboarding_completed',
        properties: {
          'steps_completed': _stepDurations.length,
          if (totalDurationSeconds != null)
            'total_duration_seconds': totalDurationSeconds,
          if (averageStepDuration != null)
            'average_step_duration_seconds': averageStepDuration.round(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (kDebugMode) {
        debugPrint(
            'OnboardingAnalyticsModule: Onboarding completed (${totalDurationSeconds}s total, ${_stepDurations.length} steps)');
      }

      // Reset tracking
      _onboardingStartTime = null;
      _currentStepStartTime = null;
      _stepDurations.clear();
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            'OnboardingAnalyticsModule: Failed to track completion - $e');
      }
    }
  }

  /// Track feature adoption during onboarding
  Future<void> trackFeatureAdoption({
    required String featureName,
    required dynamic value,
  }) async {
    if (!_isInitialized) {
      if (kDebugMode) {
        debugPrint(
            'OnboardingAnalyticsModule: Cannot track feature - module not initialized');
      }
      return;
    }

    try {
      await Posthog().capture(
        eventName: 'onboarding_feature_adopted',
        properties: {
          'feature_name': featureName,
          'value': value,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (kDebugMode) {
        debugPrint(
            'OnboardingAnalyticsModule: Feature adopted - $featureName: $value');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            'OnboardingAnalyticsModule: Failed to track feature adoption - $e');
      }
    }
  }

  /// Reset tracking (for testing or restart)
  Future<void> reset() async {
    _onboardingStartTime = null;
    _currentStepStartTime = null;
    _stepDurations.clear();

    if (kDebugMode) {
      debugPrint('OnboardingAnalyticsModule: Tracking reset');
    }
  }

  /// Get onboarding stats
  Map<String, dynamic> getStats() {
    return {
      'initialized': _isInitialized,
      'onboarding_in_progress': _onboardingStartTime != null,
      'steps_completed': _stepDurations.length,
      'current_duration_seconds': _onboardingStartTime != null
          ? DateTime.now().difference(_onboardingStartTime!).inSeconds
          : 0,
    };
  }
}
