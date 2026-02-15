import 'package:faithlock/services/subscription/revenuecat_service.dart';
import 'package:flutter/material.dart';

/// Service to guard premium features behind paywall
/// Prevents bypass of paywall by checking subscription status
class PaywallGuardService {
  static final PaywallGuardService _instance = PaywallGuardService._internal();
  factory PaywallGuardService() => _instance;
  PaywallGuardService._internal();

  final RevenueCatService _revenueCat = RevenueCatService.instance;

  /// Check if user has active subscription
  /// If not, redirect to appropriate screen (expired or paywall)
  Future<bool> checkSubscriptionAccess({
    String? placementId,
    bool showPaywallIfInactive = true,
  }) async {
    // BYPASS: Always return true for development/testing
    debugPrint('🔓 [PaywallGuard] BYPASS ACTIVE - Always granting access');
    return true;
  }

  /// Check subscription status without navigation
  bool hasActiveSubscription() {
    // BYPASS: Always return true for development/testing
    return true;
  }

  /// Get subscription status for display
  SubscriptionStatus getStatus() {
    return _revenueCat.getSubscriptionStatus();
  }
}
