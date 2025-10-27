import 'package:faithlock/services/analytics/posthog/export.dart';
import 'package:faithlock/services/subscription/revenuecat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Paywall controller managing subscription flow and business logic
class PaywallController extends GetxController with GetTickerProviderStateMixin {
  static const String _keyTrialReminderEnabled = 'trial_reminder_enabled';
  static const String _keyPromoCodeApplied = 'promo_code_applied';

  // Services
  RevenueCatService get _revenueCat => RevenueCatService.instance;
  final PostHogService _analytics = PostHogService.instance;

  // Observable state
  final RxBool isLoading = true.obs;
  final RxBool trialReminderEnabled = true.obs;
  final RxBool freeTrialEnabled = true.obs;
  final RxBool showPromoCodeField = false.obs;
  final RxString promoCode = ''.obs;
  final RxInt selectedPlanIndex = 0.obs;
  final RxString lastError = ''.obs;
  final RxBool isPurchasing = false.obs;

  // RevenueCat data
  final RxList<Package> packages = <Package>[].obs;
  Offering? currentOffering;

  // Form controllers
  final TextEditingController promoCodeController = TextEditingController();

  // Animation controllers
  late AnimationController switchAnimationController;
  late AnimationController cardAnimationController;
  late Animation<double> switchAnimation;
  late Animation<double> cardScaleAnimation;

  // Configuration
  final bool redirectToHomeOnClose;
  final String? placementId;

  PaywallController({
    this.redirectToHomeOnClose = false,
    this.placementId,
  });

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _loadSettings();
    _bindPromoCodeController();
    _loadOfferings();
  }

  void _initializeAnimations() {
    switchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    switchAnimation = CurvedAnimation(
      parent: switchAnimationController,
      curve: Curves.easeInOut,
    );

    cardScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.995,
    ).animate(CurvedAnimation(
      parent: cardAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadOfferings() async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final offering = await _revenueCat.getCurrentOffering();

      if (offering == null) {
        lastError.value = 'No subscription options available';
        return;
      }

      currentOffering = offering;

      // Filter and sort packages
      final availablePackages = offering.availablePackages
          .where((pkg) => pkg.storeProduct.subscriptionPeriod != null)
          .toList();

      // Sort: yearly first, then by price descending
      availablePackages.sort((a, b) {
        final aIsYearly = isYearlyPackage(a);
        final bIsYearly = isYearlyPackage(b);

        if (aIsYearly && !bIsYearly) return -1;
        if (!aIsYearly && bIsYearly) return 1;

        return b.storeProduct.price.compareTo(a.storeProduct.price);
      });

      packages.value = availablePackages;

      // Select yearly plan by default if available
      selectedPlanIndex.value = availablePackages.indexWhere(isYearlyPackage);
      if (selectedPlanIndex.value == -1) {
        selectedPlanIndex.value = 0;
      }

      // Check if selected plan is yearly
      if (selectedPlanIndex.value < availablePackages.length) {
        freeTrialEnabled.value =
            !isYearlyPackage(availablePackages[selectedPlanIndex.value]);
      }

      // Track paywall viewed
      if (_analytics.isReady) {
        await _analytics.paywall.trackPaywallViewed(
          source: placementId ?? 'unknown',
          placementId: placementId,
        );
      }
    } catch (e) {
      lastError.value = 'Failed to load subscription options: $e';
      debugPrint('❌ Error loading offerings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool isYearlyPackage(Package package) {
    final period = package.storeProduct.subscriptionPeriod;
    if (period == null) return false;
    final periodLower = period.toLowerCase();
    return periodLower.contains('year') || periodLower.contains('y');
  }

  void selectPlan(int index) async {
    if (index < 0 || index >= packages.length) return;

    cardAnimationController.forward().then((_) {
      cardAnimationController.reverse();
    });

    selectedPlanIndex.value = index;

    final isYearly = isYearlyPackage(packages[index]);
    freeTrialEnabled.value = !isYearly;

    if (isYearly) {
      switchAnimationController.reverse();
    } else {
      switchAnimationController.forward();
    }

    // Track plan selection
    if (_analytics.isReady) {
      final selectedPackage = packages[index];
      final product = selectedPackage.storeProduct;
      await _analytics.paywall.trackPlanSelected(
        planType: getPlanTitle(selectedPackage).toLowerCase(),
        planId: selectedPackage.identifier,
        price: product.price,
        currency: product.currencyCode,
        trialPeriod: product.introductoryPrice?.period,
      );
    }
  }

  void toggleFreeTrial(bool value) {
    freeTrialEnabled.value = value;

    // If enabling trial and current plan is yearly, switch to non-yearly
    if (value && selectedPlanIndex.value < packages.length) {
      if (isYearlyPackage(packages[selectedPlanIndex.value])) {
        final nonYearlyIndex =
            packages.indexWhere((pkg) => !isYearlyPackage(pkg));
        if (nonYearlyIndex != -1) {
          selectedPlanIndex.value = nonYearlyIndex;
        }
      }
    }

    // If disabling trial, switch to yearly plan
    if (!value) {
      final yearlyIndex = packages.indexWhere(isYearlyPackage);
      if (yearlyIndex != -1) {
        selectedPlanIndex.value = yearlyIndex;
      }
    }

    if (value) {
      switchAnimationController.forward();
    } else {
      switchAnimationController.reverse();
    }
  }

  String getPlanTitle(Package package) {
    if (isYearlyPackage(package)) {
      return 'Yearly';
    }

    final period = package.storeProduct.subscriptionPeriod;
    if (period != null) {
      final unitStr = period.toLowerCase();
      if (unitStr.contains('month') || unitStr.contains('m')) {
        return 'Monthly';
      }
      if (unitStr.contains('week') || unitStr.contains('w')) {
        return 'Weekly';
      }
    }

    return package.identifier;
  }

  String getPriceText(Package package) {
    final product = package.storeProduct;
    final price = product.priceString;

    if (isYearlyPackage(package)) {
      return price;
    }

    final period = product.subscriptionPeriod;
    if (period != null) {
      final unitStr = period.toLowerCase();
      if (unitStr.contains('month') || unitStr.contains('m')) {
        return '$price/month';
      }
      if (unitStr.contains('week') || unitStr.contains('w')) {
        return '$price/week';
      }
    }

    return price;
  }

  String getSavingsText(Package package) {
    if (!isYearlyPackage(package)) return '';

    final monthlyPackage = packages.firstWhereOrNull((pkg) {
      final period = pkg.storeProduct.subscriptionPeriod;
      return period != null && period.toLowerCase().contains('month');
    });

    if (monthlyPackage == null) return 'BEST VALUE';

    final yearlyPrice = package.storeProduct.price;
    final monthlyPrice = monthlyPackage.storeProduct.price;
    final yearlyEquivalent = monthlyPrice * 12;
    final savings = ((yearlyEquivalent - yearlyPrice) / yearlyEquivalent * 100);

    if (savings > 0) {
      return 'SAVE ${savings.round()}%';
    }

    return 'BEST VALUE';
  }

  void closePaywall() {
    // ❌ trackPaywallDismissed désactivé - événement redondant
    // Métrique équivalente: bounce_rate = 1 - (completed / viewed)

    if (redirectToHomeOnClose) {
      Get.until((route) => route.isFirst);
    } else {
      Get.back(result: false);
    }
  }

  @override
  void onClose() {
    promoCodeController.dispose();
    switchAnimationController.dispose();
    cardAnimationController.dispose();
    super.onClose();
  }

  /// Start subscription with selected plan
  Future<void> startSubscription() async {
    if (selectedPlanIndex.value >= packages.length) {
      lastError.value = 'Please select a subscription plan';
      return;
    }

    try {
      isPurchasing.value = true;
      lastError.value = '';

      final selectedPackage = packages[selectedPlanIndex.value];
      final product = selectedPackage.storeProduct;

      // ❌ trackPurchaseStarted désactivé - événement redondant
      // Métrique équivalente: total_attempts = completed + failed

      // Attempt purchase
      final result = await _revenueCat.purchaseSubscription(selectedPackage);

      if (result.success) {
        // Track purchase completed
        if (_analytics.isReady) {
          await _analytics.paywall.trackPurchaseCompleted(
            planType: getPlanTitle(selectedPackage).toLowerCase(),
            planId: selectedPackage.identifier,
            revenue: product.price,
            currency: product.currencyCode,
            isTrialStart: product.introductoryPrice != null,
            isRestore: false,
          );
        }

        // Schedule trial reminder if enabled
        if (trialReminderEnabled.value) {
          await _scheduleTrialReminder();
        }

        // Show success feedback
        HapticFeedback.mediumImpact();
        Get.snackbar(
          'Success! 🎉',
          'Your free trial has started. Enjoy premium features!',
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          colorText: Colors.green[800],
          icon: const Icon(Icons.check_circle, color: Colors.green),
          duration: const Duration(seconds: 3),
        );

        // Navigate to main app or close paywall
        _handleSuccessfulSubscription();
      } else {
        // Purchase cancelled or failed
        if (result.error?.contains('cancelled') ?? false) {
          debugPrint('Purchase cancelled by user');
        } else {
          throw Exception(result.error ?? 'Purchase failed');
        }
      }
    } catch (e) {
      lastError.value = e.toString();

      // Track purchase failed
      if (_analytics.isReady) {
        await _analytics.paywall.trackPurchaseFailed(
          planType: getPlanTitle(packages[selectedPlanIndex.value]).toLowerCase(),
          planId: packages[selectedPlanIndex.value].identifier,
          reason: e.toString(),
          errorCode: e is PlatformException ? e.code : null,
        );
      }

      // Show error feedback
      HapticFeedback.lightImpact();
      Get.snackbar(
        'Purchase Failed',
        e.toString(),
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red[800],
        icon: const Icon(Icons.error, color: Colors.red),
        duration: const Duration(seconds: 4),
      );
    } finally {
      isPurchasing.value = false;
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final result = await _revenueCat.restorePurchases();

      if (result.success && result.hasActiveSubscriptions) {
        // Track restore as completed purchase
        if (_analytics.isReady && packages.isNotEmpty) {
          final currentPackage = packages[selectedPlanIndex.value];
          final product = currentPackage.storeProduct;
          await _analytics.paywall.trackPurchaseCompleted(
            planType: getPlanTitle(currentPackage).toLowerCase(),
            planId: currentPackage.identifier,
            revenue: product.price,
            currency: product.currencyCode,
            isTrialStart: false,
            isRestore: true,
          );
        }

        HapticFeedback.mediumImpact();
        Get.snackbar(
          'Purchases Restored! ✅',
          'Your subscription has been restored successfully.',
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          colorText: Colors.green[800],
          icon: const Icon(Icons.check_circle, color: Colors.green),
          duration: const Duration(seconds: 3),
        );

        _handleSuccessfulSubscription();
      } else if (result.success && !result.hasActiveSubscriptions) {
        Get.snackbar(
          'No Purchases Found',
          'No active subscriptions found to restore.',
          backgroundColor: Colors.orange.withValues(alpha: 0.1),
          colorText: Colors.orange[800],
          icon: const Icon(Icons.info, color: Colors.orange),
          duration: const Duration(seconds: 3),
        );
      } else {
        throw Exception(result.error ?? 'Restore failed');
      }
    } catch (e) {
      lastError.value = e.toString();

      Get.snackbar(
        'Restore Failed',
        'Could not restore purchases. Please try again.',
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red[800],
        icon: const Icon(Icons.error, color: Colors.red),
        duration: const Duration(seconds: 4),
      );
    } finally {
      isPurchasing.value = false;
    }
  }

  /// Apply promo code
  Future<void> applyPromoCode() async {
    if (promoCode.value.trim().isEmpty) {
      Get.snackbar(
        'Invalid Code',
        'Please enter a valid promo code.',
        backgroundColor: Colors.orange.withValues(alpha: 0.1),
        colorText: Colors.orange[800],
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      isPurchasing.value = true;

      final result = await _revenueCat.applyPromoCode(promoCode.value.trim());

      if (result.success) {
        // ❌ trackPromoCodeApplied désactivé - rarement utilisé
        // Réactiver si campagne promo active

        HapticFeedback.mediumImpact();
        Get.snackbar(
          'Promo Code Applied! 🎉',
          'Your discount has been applied successfully.',
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          colorText: Colors.green[800],
          icon: const Icon(Icons.check_circle, color: Colors.green),
          duration: const Duration(seconds: 3),
        );

        // Save promo code applied state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyPromoCodeApplied, true);

        showPromoCodeField.value = false;
        promoCodeController.clear();
      } else {
        throw Exception(result.error ?? 'Invalid promo code');
      }
    } catch (e) {
      // ❌ trackPromoCodeApplied désactivé - rarement utilisé

      Get.snackbar(
        'Invalid Promo Code',
        'The promo code you entered is not valid.',
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red[800],
        icon: const Icon(Icons.error, color: Colors.red),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isPurchasing.value = false;
    }
  }

  Future<void> toggleTrialReminder(bool enabled) async {
    trialReminderEnabled.value = enabled;
  }

  /// Toggle promo code field visibility
  void togglePromoCodeField() {
    showPromoCodeField.value = !showPromoCodeField.value;
    if (!showPromoCodeField.value) {
      promoCodeController.clear();
      promoCode.value = '';
    }
  }

  /// Open terms/privacy links
  void openPrivacyPolicy() {
    // Implement URL launcher or webview
    print('Opening Privacy Policy');
  }

  void openTermsOfService() {
    // Implement URL launcher or webview
    print('Opening Terms of Service');
  }

  void openSubscriptionTerms() {
    // Implement URL launcher or webview
    print('Opening Subscription Terms');
  }

  /// Private methods

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    trialReminderEnabled.value = prefs.getBool(_keyTrialReminderEnabled) ?? true;
  }

  void _bindPromoCodeController() {
    promoCodeController.addListener(() {
      promoCode.value = promoCodeController.text;
    });
  }

  Future<void> _scheduleTrialReminder() async {
    try {
      await _revenueCat.scheduleTrialReminder(daysBefore: 2);
    } catch (e) {
      print('Failed to schedule trial reminder: $e');
    }
  }

  void _handleSuccessfulSubscription() {
    // Navigate away from paywall
    // You can customize this based on your app flow
    Get.back(); // Close paywall
    // Or navigate to main app: Get.offAllNamed('/main');
  }
}

/// Plan option model
class PlanOption {
  final String id;
  final String title;
  final String price;
  final String period;
  final String? savings;
  final int trialDays;
  final bool isPopular;

  PlanOption({
    required this.id,
    required this.title,
    required this.price,
    required this.period,
    this.savings,
    required this.trialDays,
    this.isPopular = false,
  });
}

/// Timeline step model
class TimelineStep {
  final String day;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final bool isCompleted;

  TimelineStep({
    required this.day,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.isCompleted,
  });
}
