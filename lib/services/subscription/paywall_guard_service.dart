import 'package:faithlock/features/onboarding/screens/onboarding_summary_screen.dart';
import 'package:faithlock/services/subscription/revenuecat_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../features/paywall/screens/subscription_expired_screen.dart';

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

    // Original code (commented out):
    try {
      debugPrint('🔒 [PaywallGuard] Checking subscription access...');
      if (!_revenueCat.isInitialized) {
        debugPrint(
            '⚠️ [PaywallGuard] RevenueCat not yet initialized - assuming no subscription');
        if (showPaywallIfInactive) {
          debugPrint('🚪 [PaywallGuard] Showing onboarding summary...');
          Get.offAll(() => const OnboardingSummaryScreen());
        }
        return false;
      }
      await _revenueCat.refreshCustomerInfo();
      debugPrint('✅ [PaywallGuard] Customer info refreshed');
      final hasSubscription = _revenueCat.hasAnyActiveSubscription;
      if (hasSubscription) {
        debugPrint('✅ [PaywallGuard] Active subscription found');
        return true;
      }
      debugPrint('⚠️ [PaywallGuard] No active subscription');
      if (showPaywallIfInactive) {
        final expiredInfo = await _checkExpiredSubscription();
        if (expiredInfo.hadSubscription) {
          debugPrint(
              '🔄 [PaywallGuard] Expired subscription detected - showing expired screen');
          Get.offAll(() => SubscriptionExpiredScreen(
                wasTrialUser: expiredInfo.wasTrialUser,
                expirationDate: expiredInfo.expirationDate,
              ));
        } else {
          debugPrint('🚪 [PaywallGuard] Never subscribed - showing paywall...');
          Get.offAll(() => Get.offAll(() => OnboardingSummaryScreen()));
        }
      }
      return false;
    } catch (e) {
      debugPrint('❌ [PaywallGuard] Error checking subscription: $e');
      return false;
    }
  }

  /// Check if user had an expired subscription
  Future<_ExpiredSubscriptionInfo> _checkExpiredSubscription() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final allEntitlements = customerInfo.entitlements.all;

      // Check if user has any past entitlements (active or inactive)
      if (allEntitlements.isEmpty) {
        return _ExpiredSubscriptionInfo(
          hadSubscription: false,
          wasTrialUser: false,
        );
      }

      // Find the most recent entitlement
      final sortedEntitlements = allEntitlements.values.toList()
        ..sort((a, b) {
          final aDate = DateTime.parse(a.latestPurchaseDate);
          final bDate = DateTime.parse(b.latestPurchaseDate);
          return bDate.compareTo(aDate);
        });

      final mostRecentEntitlement = sortedEntitlements.first;

      // Check if user ever had an active entitlement but it's now expired
      final hadActiveSubscription = !mostRecentEntitlement.isActive &&
          mostRecentEntitlement.expirationDate != null;

      if (hadActiveSubscription) {
        // Determine if it was a trial
        final purchaseDate =
            DateTime.parse(mostRecentEntitlement.originalPurchaseDate);
        final expirationDate =
            DateTime.parse(mostRecentEntitlement.expirationDate!);
        final subscriptionDuration = expirationDate.difference(purchaseDate);

        // Consider it a trial if it lasted <= 14 days
        final wasTrialUser = subscriptionDuration.inDays <= 14;

        return _ExpiredSubscriptionInfo(
          hadSubscription: true,
          wasTrialUser: wasTrialUser,
          expirationDate: expirationDate,
        );
      }

      return _ExpiredSubscriptionInfo(
        hadSubscription: false,
        wasTrialUser: false,
      );
    } catch (e) {
      debugPrint('❌ [PaywallGuard] Error checking expired subscription: $e');
      return _ExpiredSubscriptionInfo(
        hadSubscription: false,
        wasTrialUser: false,
      );
    }
  }

  /// Check subscription status without navigation
  bool hasActiveSubscription() {
    // BYPASS: Always return true for development/testing
    return true;

    // Original code (commented out):
    // try {
    //   return _revenueCat.hasAnyActiveSubscription;
    // } catch (e) {
    //   debugPrint('⚠️ [PaywallGuard] RevenueCat not yet initialized: $e');
    //   return false;
    // }
  }

  /// Get subscription status for display
  SubscriptionStatus getStatus() {
    return _revenueCat.getSubscriptionStatus();
  }
}

/// Helper class to track expired subscription info
class _ExpiredSubscriptionInfo {
  final bool hadSubscription;
  final bool wasTrialUser;
  final DateTime? expirationDate;

  _ExpiredSubscriptionInfo({
    required this.hadSubscription,
    required this.wasTrialUser,
    this.expirationDate,
  });
}
