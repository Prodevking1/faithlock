import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../posthog_service.dart';

/// Module for conversion tracking and funnels
class ConversionModule {
  final PostHogService _postHogService;
  bool _isInitialized = false;
  final Map<String, List<String>> _activeFunnels = {};
  final Map<String, DateTime> _funnelStartTimes = {};
  final Map<String, Map<String, dynamic>> _conversionContext = {};

  ConversionModule(this._postHogService);

  /// Initialize the conversion module
  Future<void> init() async {
    try {
      _isInitialized = true;
      debugPrint('ConversionModule: Initialized successfully');
    } catch (e) {
      debugPrint('ConversionModule: Failed to initialize - $e');
      rethrow;
    }
  }

  /// Shutdown the module
  Future<void> shutdown() async {
    try {
      _isInitialized = false;
      _activeFunnels.clear();
      _funnelStartTimes.clear();
      _conversionContext.clear();
      debugPrint('ConversionModule: Shutdown successfully');
    } catch (e) {
      debugPrint('ConversionModule: Failed to shutdown - $e');
    }
  }

  /// Reset the module
  Future<void> reset() async {
    try {
      _activeFunnels.clear();
      _funnelStartTimes.clear();
      _conversionContext.clear();
      debugPrint('ConversionModule: Reset successfully');
    } catch (e) {
      debugPrint('ConversionModule: Failed to reset - $e');
    }
  }

  /// Track a conversion event
  Future<void> trackConversion({
    required String conversionType,
    required String conversionName,
    double? conversionValue,
    String? currency,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint(
          'ConversionModule: Cannot track conversion - module not initialized');
      return;
    }

    try {
      await Posthog().capture(
        eventName: 'conversion_completed',
        properties: {
          'conversion_type': conversionType,
          'conversion_name': conversionName,
          'conversion_value': conversionValue?.toDouble() ?? 0,
          'currency': currency ?? 'USD',
          'timestamp': DateTime.now().toIso8601String(),
          ...?properties,
        },
      );

      debugPrint(
          'ConversionModule: Conversion tracked - $conversionType:$conversionName');
    } catch (e) {
      debugPrint('ConversionModule: Failed to track conversion - $e');
    }
  }

  /// Start tracking a funnel
  Future<void> startFunnel({
    required String funnelName,
    required List<String> steps,
    Map<String, dynamic>? context,
  }) async {
    if (!_isInitialized) {
      debugPrint(
          'ConversionModule: Cannot start funnel - module not initialized');
      return;
    }

    try {
      _activeFunnels[funnelName] = List.from(steps);
      _funnelStartTimes[funnelName] = DateTime.now();
      if (context != null) {
        _conversionContext[funnelName] = context;
      }

      await Posthog().capture(
        eventName: 'funnel_started',
        properties: {
          'funnel_name': funnelName,
          'funnel_steps': steps,
          'step_count': steps.length,
          'context': context ?? {},
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      debugPrint(
          'ConversionModule: Funnel started - $funnelName (${steps.length} steps)');
    } catch (e) {
      debugPrint('ConversionModule: Failed to start funnel - $e');
    }
  }

  /// Track funnel step completion
  Future<void> trackFunnelStep({
    required String funnelName,
    required String stepName,
    Map<String, dynamic>? stepProperties,
  }) async {
    if (!_isInitialized) {
      debugPrint(
          'ConversionModule: Cannot track funnel step - module not initialized');
      return;
    }

    if (!_activeFunnels.containsKey(funnelName)) {
      debugPrint('ConversionModule: Funnel $funnelName not active');
      return;
    }

    try {
      final steps = _activeFunnels[funnelName]!;
      final stepIndex = steps.indexOf(stepName);
      final startTime = _funnelStartTimes[funnelName];
      final context = _conversionContext[funnelName] ?? {};

      if (stepIndex == -1) {
        debugPrint(
            'ConversionModule: Step $stepName not found in funnel $funnelName');
        return;
      }

      await Posthog().capture(
        eventName: 'funnel_step_completed',
        properties: {
          'funnel_name': funnelName,
          'step_name': stepName,
          'step_index': stepIndex,
          'step_position': '${stepIndex + 1}/${steps.length}',
          if (startTime != null)
            'time_to_step': DateTime.now().difference(startTime).inSeconds,
          'context': context,
          'step_properties': stepProperties ?? {},
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Check if this is the last step
      if (stepIndex == steps.length - 1) {
        await _completeFunnel(funnelName);
      }

      debugPrint(
          'ConversionModule: Funnel step tracked - $funnelName:$stepName');
    } catch (e) {
      debugPrint('ConversionModule: Failed to track funnel step - $e');
    }
  }

  /// Track funnel abandonment
  Future<void> abandonFunnel({
    required String funnelName,
    String? abandonmentReason,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint(
          'ConversionModule: Cannot abandon funnel - module not initialized');
      return;
    }

    if (!_activeFunnels.containsKey(funnelName)) {
      debugPrint('ConversionModule: Funnel $funnelName not active');
      return;
    }

    try {
      final startTime = _funnelStartTimes[funnelName];
      final context = _conversionContext[funnelName] ?? {};

      await Posthog().capture(
        eventName: 'funnel_abandoned',
        properties: {
          'funnel_name': funnelName,
          'abandonment_reason': abandonmentReason ?? 'Unknown',
          if (startTime != null)
            'time_in_funnel': DateTime.now().difference(startTime).inSeconds,
          'context': context,
          'timestamp': DateTime.now().toIso8601String(),
          ...?properties,
        },
      );

      // Clean up funnel tracking
      _activeFunnels.remove(funnelName);
      _funnelStartTimes.remove(funnelName);
      _conversionContext.remove(funnelName);

      debugPrint('ConversionModule: Funnel abandoned - $funnelName');
    } catch (e) {
      debugPrint('ConversionModule: Failed to abandon funnel - $e');
    }
  }

  /// Track revenue event
  Future<void> trackRevenue({
    required double amount,
    required String currency,
    String? productId,
    String? transactionId,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint(
          'ConversionModule: Cannot track revenue - module not initialized');
      return;
    }

    try {
      await Posthog().capture(
        eventName: 'revenue_tracked',
        properties: {
          'revenue_amount': amount,
          'currency': currency,
          'product_id': productId ?? 'Unknown',
          'transaction_id': transactionId ?? 'Unknown',
          'timestamp': DateTime.now().toIso8601String(),
          ...?properties,
        },
      );

      debugPrint('ConversionModule: Revenue tracked - $amount $currency');
    } catch (e) {
      debugPrint('ConversionModule: Failed to track revenue - $e');
    }
  }

  /// Track goal completion
  Future<void> trackGoal({
    required String goalName,
    String? goalCategory,
    double? goalValue,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint(
          'ConversionModule: Cannot track goal - module not initialized');
      return;
    }

    try {
      await Posthog().capture(
        eventName: 'goal_completed',
        properties: {
          'goal_name': goalName,
          'goal_category': goalCategory ?? 'Unknown',
          'goal_value': goalValue?.toDouble() ?? 0,
          'timestamp': DateTime.now().toIso8601String(),
          ...?properties,
        },
      );

      debugPrint('ConversionModule: Goal tracked - $goalName');
    } catch (e) {
      debugPrint('ConversionModule: Failed to track goal - $e');
    }
  }

  /// Track user cohort conversion
  Future<void> trackCohortConversion({
    required String cohortName,
    required String conversionEvent,
    int? daysSinceInstall,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint(
          'ConversionModule: Cannot track cohort conversion - module not initialized');
      return;
    }

    try {
      await Posthog().capture(
        eventName: 'cohort_conversion',
        properties: {
          'cohort_name': cohortName,
          'conversion_event': conversionEvent,
          'days_since_install': daysSinceInstall?.toDouble() ?? 0,
          'timestamp': DateTime.now().toIso8601String(),
          ...?properties,
        },
      );

      debugPrint(
          'ConversionModule: Cohort conversion tracked - $cohortName:$conversionEvent');
    } catch (e) {
      debugPrint('ConversionModule: Failed to track cohort conversion - $e');
    }
  }

  /// Get active funnels
  Map<String, List<String>> get activeFunnels =>
      Map.unmodifiable(_activeFunnels);

  /// Check if funnel is active
  bool isFunnelActive(String funnelName) =>
      _activeFunnels.containsKey(funnelName);

  /// Private method to complete funnel
  Future<void> _completeFunnel(String funnelName) async {
    try {
      final startTime = _funnelStartTimes[funnelName];
      final context = _conversionContext[funnelName] ?? {};
      final steps = _activeFunnels[funnelName]!;

      await Posthog().capture(
        eventName: 'funnel_completed',
        properties: {
          'funnel_name': funnelName,
          'total_steps': steps.length,
          if (startTime != null)
            'completion_time':
                DateTime.now().difference(startTime).inSeconds.toDouble(),
          'context': context,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Clean up funnel tracking
      _activeFunnels.remove(funnelName);
      _funnelStartTimes.remove(funnelName);
      _conversionContext.remove(funnelName);

      debugPrint('ConversionModule: Funnel completed - $funnelName');
    } catch (e) {
      debugPrint('ConversionModule: Failed to complete funnel - $e');
    }
  }
}
