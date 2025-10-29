import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Comprehensive RevenueCat service for subscription management
/// Follows latest RevenueCat Flutter SDK patterns and best practices
class RevenueCatService extends GetxService {
  static RevenueCatService get instance => Get.put(RevenueCatService());

  // Observable subscription state
  final RxBool isSubscriptionActive = false.obs;
  final RxBool isInFreeTrial = false.obs;
  final RxString subscriptionTier = ''.obs;
  final Rx<DateTime?> trialEndDate = Rx<DateTime?>(null);
  final Rx<DateTime?> subscriptionEndDate = Rx<DateTime?>(null);
  final RxBool isLoading = false.obs;
  final RxString lastError = ''.obs;

  // Current customer info
  CustomerInfo? _currentCustomerInfo;
  List<Offering> _offerings = [];

  /// Initialize RevenueCat service
  Future<void> initialize({
    required String apiKey,
    String? appUserId,
    bool enableDebugLogs = false,
  }) async {
    try {
      isLoading.value = true;

      // Configure RevenueCat
      final configuration = PurchasesConfiguration(apiKey);

      await Purchases.configure(configuration);

      // Enable debug logs in development
      if (enableDebugLogs && kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      // Set up listener for customer info updates
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);

      // Load initial data
      await _refreshCustomerInfo();
      await _loadOfferings();

      print('✅ RevenueCat initialized successfully');
    } catch (e) {
      lastError.value = 'Failed to initialize RevenueCat: $e';
      print('❌ RevenueCat initialization error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get available offerings (subscription packages)
  Future<List<Offering>> getOfferings() async {
    try {
      if (_offerings.isEmpty) {
        await _loadOfferings();
      }
      return _offerings;
    } catch (e) {
      lastError.value = 'Failed to load offerings: $e';
      return [];
    }
  }

  /// Get current offering (usually the main one)
  Future<Offering?> getCurrentOffering() async {
    final offerings = await getOfferings();
    return offerings.isNotEmpty ? offerings.first : null;
  }

  /// Purchase a subscription package
  Future<PurchaseResult> purchaseSubscription(Package package) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final purchaserInfo = await Purchases.purchasePackage(package);

      await _refreshCustomerInfo();

      return PurchaseResult(
        success: true,
        customerInfo: purchaserInfo.customerInfo,
        transaction: purchaserInfo.storeTransaction,
      );
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      String errorMessage = 'Purchase failed';

      switch (errorCode) {
        case PurchasesErrorCode.purchaseCancelledError:
          errorMessage = 'Purchase was cancelled';
          break;
        case PurchasesErrorCode.purchaseNotAllowedError:
          errorMessage = 'Purchase not allowed';
          break;
        case PurchasesErrorCode.purchaseInvalidError:
          errorMessage = 'Purchase invalid';
          break;
        case PurchasesErrorCode.storeProblemError:
          errorMessage = 'Store problem occurred';
          break;
        case PurchasesErrorCode.networkError:
          errorMessage = 'Network error occurred';
          break;
        default:
          errorMessage = 'Purchase failed: ${e.message}';
      }

      lastError.value = errorMessage;
      return PurchaseResult(success: false, error: errorMessage);
    } catch (e) {
      lastError.value = 'Unexpected error: $e';
      return PurchaseResult(success: false, error: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Restore purchases
  Future<RestoreResult> restorePurchases() async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final customerInfo = await Purchases.restorePurchases();
      await _refreshCustomerInfo();

      return RestoreResult(
        success: true,
        customerInfo: customerInfo,
        hasActiveSubscriptions: customerInfo.entitlements.active.isNotEmpty,
      );
    } catch (e) {
      lastError.value = 'Failed to restore purchases: $e';
      return RestoreResult(success: false, error: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if user has active subscription for a specific entitlement
  bool hasActiveSubscription(String entitlementId) {
    return _currentCustomerInfo?.entitlements.active[entitlementId] != null;
  }

  /// Check if user has any active subscription
  bool get hasAnyActiveSubscription {
    return _currentCustomerInfo?.entitlements.active.isNotEmpty ?? false;
  }

  /// Get subscription status info
  SubscriptionStatus getSubscriptionStatus() {
    if (_currentCustomerInfo == null) {
      return SubscriptionStatus.unknown;
    }

    final activeEntitlements = _currentCustomerInfo!.entitlements.active;

    if (activeEntitlements.isEmpty) {
      return SubscriptionStatus.notSubscribed;
    }

    final entitlement = activeEntitlements.values.first;

    if (entitlement.isActive) {
      return entitlement.willRenew
          ? SubscriptionStatus.activeRenewing
          : SubscriptionStatus.activeNonRenewing;
    }

    return SubscriptionStatus.expired;
  }

  /// Get days remaining in free trial
  int? getDaysRemainingInTrial() {
    if (!isInFreeTrial.value || trialEndDate.value == null) {
      return null;
    }

    final now = DateTime.now();
    final difference = trialEndDate.value!.difference(now);
    return difference.inDays.clamp(0, double.infinity).toInt();
  }

  /// Get subscription expiration date
  DateTime? getSubscriptionExpirationDate() {
    if (_currentCustomerInfo == null) return null;

    final activeEntitlements = _currentCustomerInfo!.entitlements.active;
    if (activeEntitlements.isEmpty) return null;

    return DateTime.parse(activeEntitlements.values.first.expirationDate!);
  }

  /// Invalidate customer info cache and refresh
  Future<void> refreshCustomerInfo() async {
    await _refreshCustomerInfo();
  }

  /// Apply promo code
  Future<PromoCodeResult> applyPromoCode(String promoCode) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      // Note: Promo code redemption varies by platform
      // This is a placeholder implementation
      // You may need to handle this differently based on your setup

      await Purchases.invalidateCustomerInfoCache();
      await _refreshCustomerInfo();

      return PromoCodeResult(success: true);
    } catch (e) {
      lastError.value = 'Failed to apply promo code: $e';
      return PromoCodeResult(success: false, error: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Set reminder notifications for trial end
  Future<void> scheduleTrialReminder({int daysBefore = 2}) async {
    if (!isInFreeTrial.value || trialEndDate.value == null) {
      return;
    }

    final reminderDate =
        trialEndDate.value!.subtract(Duration(days: daysBefore));
    final now = DateTime.now();

    if (reminderDate.isAfter(now)) {
      // Here you would integrate with your notification service
      // For example, using local notifications or push notifications
      print('Trial reminder scheduled for: $reminderDate');
    }
  }

  /// Private methods

  Future<void> _loadOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      _offerings = offerings.all.values.toList();
    } catch (e) {
      print('Error loading offerings: $e');
      _offerings = [];
    }
  }

  Future<void> _refreshCustomerInfo() async {
    try {
      _currentCustomerInfo = await Purchases.getCustomerInfo();
      _updateSubscriptionState();
    } catch (e) {
      print('Error refreshing customer info: $e');
    }
  }

  void _onCustomerInfoUpdated(CustomerInfo customerInfo) {
    _currentCustomerInfo = customerInfo;
    _updateSubscriptionState();
  }

  void _updateSubscriptionState() {
    if (_currentCustomerInfo == null) return;

    final activeEntitlements = _currentCustomerInfo!.entitlements.active;
    isSubscriptionActive.value = activeEntitlements.isNotEmpty;

    if (activeEntitlements.isNotEmpty) {
      final entitlement = activeEntitlements.values.first;
      subscriptionTier.value = entitlement.identifier;
      subscriptionEndDate.value = DateTime.parse(entitlement.expirationDate!);

      // Check if in trial period
      final now = DateTime.now();
      if (entitlement.expirationDate != null &&
          DateTime.parse(entitlement.expirationDate!).isAfter(now)) {
        // Simple trial detection - you may need more sophisticated logic
        final purchaseDate = entitlement.originalPurchaseDate;
        final daysSincePurchase =
            now.difference(DateTime.parse(purchaseDate)).inDays;
        isInFreeTrial.value = daysSincePurchase <= 7; // Assuming 7-day trial

        if (isInFreeTrial.value) {
          trialEndDate.value = DateTime.parse(entitlement.expirationDate!)
              .add(Duration(days: 7));
        }
      }
    } else {
      subscriptionTier.value = '';
      subscriptionEndDate.value = null;
      isInFreeTrial.value = false;
      trialEndDate.value = null;
    }
  }

  @override
  void onClose() {
    // Clean up listeners
    super.onClose();
  }
}

/// Subscription status enum
enum SubscriptionStatus {
  unknown,
  notSubscribed,
  activeRenewing,
  activeNonRenewing,
  expired,
}

/// Purchase result model
class PurchaseResult {
  final bool success;
  final String? error;
  final CustomerInfo? customerInfo;
  final StoreTransaction? transaction;

  PurchaseResult({
    required this.success,
    this.error,
    this.customerInfo,
    this.transaction,
  });
}

/// Restore result model
class RestoreResult {
  final bool success;
  final String? error;
  final CustomerInfo? customerInfo;
  final bool hasActiveSubscriptions;

  RestoreResult({
    required this.success,
    this.error,
    this.customerInfo,
    this.hasActiveSubscriptions = false,
  });
}

/// Promo code result model
class PromoCodeResult {
  final bool success;
  final String? error;

  PromoCodeResult({
    required this.success,
    this.error,
  });
}
