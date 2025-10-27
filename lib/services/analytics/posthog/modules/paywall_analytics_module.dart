import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../posthog_service.dart';

/// Module for tracking paywall and monetization analytics
///
/// ✅ ÉVÉNEMENTS ACTIFS (Critiques pour business decisions):
/// - paywall_viewed: Source de trafic et volume
/// - paywall_plan_selected: Préférence de plan (optionnel)
/// - paywall_purchase_completed: REVENUE et conversions
/// - paywall_purchase_failed: Identification des blocages
///
/// ❌ ÉVÉNEMENTS DÉSACTIVÉS (Redondants):
/// - paywall_purchase_started: Calculable via completed + failed
/// - paywall_dismissed: Calculable via bounce_rate = 1 - (completed/viewed)
/// - paywall_promo_code_applied: Rarement utilisé
class PaywallAnalyticsModule {
  final PostHogService _postHogService;
  bool _isInitialized = false;

  // Track paywall session
  DateTime? _paywallViewTime;
  String? _currentSource;

  PaywallAnalyticsModule(this._postHogService);

  /// Initialize the paywall analytics module
  Future<void> init() async {
    try {
      _isInitialized = true;
      if (kDebugMode) {
        debugPrint('PaywallAnalyticsModule: Initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PaywallAnalyticsModule: Failed to initialize - $e');
      }
      rethrow;
    }
  }

  /// Shutdown the module
  Future<void> shutdown() async {
    try {
      _paywallViewTime = null;
      _currentSource = null;
      _isInitialized = false;
      if (kDebugMode) {
        debugPrint('PaywallAnalyticsModule: Shutdown successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PaywallAnalyticsModule: Failed to shutdown - $e');
      }
    }
  }

  /// Track when paywall is viewed
  Future<void> trackPaywallViewed({
    required String source, // 'onboarding', 'profile', 'feature_locked', etc.
    String? placementId,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized) {
      if (kDebugMode) {
        debugPrint(
            'PaywallAnalyticsModule: Cannot track view - module not initialized');
      }
      return;
    }

    try {
      _paywallViewTime = DateTime.now();
      _currentSource = source;

      final properties = <String, Object>{
        'source': source,
        'timestamp': _paywallViewTime!.toIso8601String(),
      };

      if (placementId != null) properties['placement_id'] = placementId;
      if (metadata != null) {
        properties.addAll(metadata.map((k, v) => MapEntry(k, v as Object)));
      }

      await Posthog().capture(
        eventName: 'paywall_viewed',
        properties: properties,
      );

      if (kDebugMode) {
        debugPrint('PaywallAnalyticsModule: Paywall viewed from $source');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PaywallAnalyticsModule: Failed to track paywall view - $e');
      }
    }
  }

  /// Track when user selects a plan
  Future<void> trackPlanSelected({
    required String planType, // 'weekly', 'monthly', 'yearly'
    required String planId,
    required double price,
    required String currency,
    String? trialPeriod,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized) {
      if (kDebugMode) {
        debugPrint(
            'PaywallAnalyticsModule: Cannot track selection - module not initialized');
      }
      return;
    }

    try {
      final properties = <String, Object>{
        'plan_type': planType,
        'plan_id': planId,
        'price': price,
        'currency': currency,
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (trialPeriod != null) properties['trial_period'] = trialPeriod;
      if (_currentSource != null) properties['source'] = _currentSource!;
      if (metadata != null) {
        properties.addAll(metadata.map((k, v) => MapEntry(k, v as Object)));
      }

      await Posthog().capture(
        eventName: 'paywall_plan_selected',
        properties: properties,
      );

      if (kDebugMode) {
        debugPrint(
            'PaywallAnalyticsModule: Plan selected - $planType (\$$price)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PaywallAnalyticsModule: Failed to track plan selection - $e');
      }
    }
  }

  /// ❌ DÉSACTIVÉ - Événement redondant
  ///
  /// Raison: Si purchase_completed OU purchase_failed, c'est qu'il a started
  /// Métrique équivalente: total_attempts = completed + failed
  ///
  /// Pour réactiver: Décommenter le code ci-dessous
  // Future<void> trackPurchaseStarted({
  //   required String planType,
  //   required String planId,
  //   required double price,
  //   required String currency,
  //   bool hasTrial = false,
  //   Map<String, dynamic>? metadata,
  // }) async {
  //   // Code désactivé pour réduire le bruit dans PostHog
  // }

  /// Track successful purchase completion
  Future<void> trackPurchaseCompleted({
    required String planType,
    required String planId,
    required double revenue,
    required String currency,
    String? transactionId,
    bool isTrialStart = false,
    bool isRestore = false,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized) {
      if (kDebugMode) {
        debugPrint(
            'PaywallAnalyticsModule: Cannot track purchase - module not initialized');
      }
      return;
    }

    try {
      final properties = <String, Object>{
        'plan_type': planType,
        'plan_id': planId,
        'revenue': revenue,
        'currency': currency,
        'is_trial_start': isTrialStart,
        'is_restore': isRestore,
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (transactionId != null) properties['transaction_id'] = transactionId;
      if (_currentSource != null) properties['source'] = _currentSource!;
      if (metadata != null) {
        properties.addAll(metadata.map((k, v) => MapEntry(k, v as Object)));
      }

      // Track purchase event
      await Posthog().capture(
        eventName: 'paywall_purchase_completed',
        properties: properties,
      );

      // Update user properties
      await _updateSubscriptionStatus(
        status: isTrialStart ? 'trial' : 'premium',
        plan: planType,
        revenue: revenue,
      );

      if (kDebugMode) {
        debugPrint(
            'PaywallAnalyticsModule: Purchase completed - $planType (\$$revenue)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            'PaywallAnalyticsModule: Failed to track purchase completion - $e');
      }
    }
  }

  /// Track purchase failure
  Future<void> trackPurchaseFailed({
    required String planType,
    required String planId,
    required String reason,
    String? errorCode,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized) {
      if (kDebugMode) {
        debugPrint(
            'PaywallAnalyticsModule: Cannot track failure - module not initialized');
      }
      return;
    }

    try {
      final properties = <String, Object>{
        'plan_type': planType,
        'plan_id': planId,
        'failure_reason': reason,
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (errorCode != null) properties['error_code'] = errorCode;
      if (_currentSource != null) properties['source'] = _currentSource!;
      if (metadata != null) {
        properties.addAll(metadata.map((k, v) => MapEntry(k, v as Object)));
      }

      await Posthog().capture(
        eventName: 'paywall_purchase_failed',
        properties: properties,
      );

      if (kDebugMode) {
        debugPrint(
            'PaywallAnalyticsModule: Purchase failed - $planType: $reason');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PaywallAnalyticsModule: Failed to track purchase failure - $e');
      }
    }
  }

  /// ❌ DÉSACTIVÉ - Événement redondant
  ///
  /// Raison: bounce_rate = 1 - (purchase_completed / paywall_viewed)
  /// Métrique équivalente: dismissed = viewed - completed
  ///
  /// Pour réactiver: Décommenter le code ci-dessous
  // Future<void> trackPaywallDismissed({
  //   String? lastSelectedPlan,
  //   Map<String, dynamic>? metadata,
  // }) async {
  //   // Code désactivé - bounce rate calculable sans cet événement
  // }

  /// ❌ DÉSACTIVÉ - Rarement utilisé
  ///
  /// Raison: Promo codes peu utilisés, ajoute du bruit
  /// Si vous lancez une campagne promo active: Réactiver cet événement
  ///
  /// Pour réactiver: Décommenter le code ci-dessous
  // Future<void> trackPromoCodeApplied({
  //   required String promoCode,
  //   required bool success,
  //   String? discountValue,
  //   Map<String, dynamic>? metadata,
  // }) async {
  //   // Code désactivé - réactiver si campagne promo lancée
  // }

  /// Update subscription status user properties
  Future<void> _updateSubscriptionStatus({
    required String status,
    required String plan, 
    required double revenue,
  }) async {
    try {
      final currentUserId = await Posthog().getDistinctId();

      // Get current lifetime value and add new revenue
      final properties = {
        'subscription_status': status,
        'subscription_plan': plan,
        'subscription_updated_at': DateTime.now().toIso8601String(),
      };

      // Update lifetime value incrementally
      await Posthog().identify(
        userId: currentUserId,
        userProperties: Map<String, Object>.from(properties),
      );

      // Track revenue increment separately
      await Posthog().capture(
        eventName: '\$revenue',
        properties: {
          'revenue': revenue,
          'currency': 'USD',
        },
      );

      if (kDebugMode) {
        debugPrint(
            'PaywallAnalyticsModule: Subscription status updated - $status/$plan');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            'PaywallAnalyticsModule: Failed to update subscription status - $e');
      }
    }
  }

  /// Reset tracking (for testing or new session)
  Future<void> reset() async {
    _paywallViewTime = null;
    _currentSource = null;

    if (kDebugMode) {
      debugPrint('PaywallAnalyticsModule: Tracking reset');
    }
  }

  /// Get paywall stats
  Map<String, dynamic> getStats() {
    return {
      'initialized': _isInitialized,
      'paywall_active': _paywallViewTime != null,
      'current_source': _currentSource,
      'session_duration_seconds': _paywallViewTime != null
          ? DateTime.now().difference(_paywallViewTime!).inSeconds
          : 0,
    };
  }
}
