import 'package:faithlock/app_routes.dart';
import 'package:faithlock/services/analytics/posthog/export.dart';
import 'package:faithlock/services/notifications/winback_notification_service.dart';
import 'package:faithlock/services/subscription/revenuecat_service.dart';
import 'package:faithlock/shared/widgets/notifications/fast_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart' hide PurchaseResult;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Paywall controller managing subscription flow and business logic
class PaywallController extends GetxController
    with GetTickerProviderStateMixin {
  static const String _keyTrialReminderEnabled = 'trial_reminder_enabled';
  static const String _keyPromoCodeApplied = 'promo_code_applied';

  // Services
  RevenueCatService get _revenueCat => RevenueCatService.instance;
  final PostHogService _analytics = PostHogService.instance;

  // Observable state
  final RxBool isLoading = true.obs;
  final RxBool trialReminderEnabled = true.obs;
  // 🚫 DISABLED: Apple App Review rejection - Free trial toggle
  // Will be re-enabled once Apple approves this feature
  // final RxBool freeTrialEnabled = true.obs;
  final RxBool showPromoCodeField = false.obs;
  final RxString promoCode = ''.obs;
  final RxInt selectedPlanIndex = 0.obs;
  final RxString lastError = ''.obs;
  final RxBool isPurchasing = false.obs;

  // Win-back promo state
  final RxBool isWinBackPromo = false.obs;

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
    _checkWinBackPromo();
    _loadOfferings();
  }

  /// Check if user is eligible for win-back promo (48h window)
  Future<void> _checkWinBackPromo() async {
    try {
      final eligible = await WinBackNotificationService().isPromoEligible();
      isWinBackPromo.value = eligible;

      if (eligible) {
        debugPrint('🎁 [Paywall] Win-back promo detected — will pre-select monthly');

        // Track promo paywall viewed
        if (_analytics.isReady) {
          _analytics.events.trackCustom('winback_promo_paywall_viewed', {
            'placement_id': placementId ?? 'unknown',
            'timestamp': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      debugPrint('⚠️ [Paywall] Error checking win-back promo: $e');
    }
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

      // If win-back promo is active, pre-select weekly plan (lower commitment)
      if (isWinBackPromo.value) {
        final weeklyIndex =
            availablePackages.indexWhere((pkg) => !isYearlyPackage(pkg));
        if (weeklyIndex != -1) {
          selectedPlanIndex.value = weeklyIndex;
          debugPrint('🎁 [Paywall] Pre-selected weekly plan for win-back promo');
        } else {
          selectedPlanIndex.value = 0;
        }
      } else {
        // Select yearly plan by default if available
        selectedPlanIndex.value =
            availablePackages.indexWhere(isYearlyPackage);
        if (selectedPlanIndex.value == -1) {
          selectedPlanIndex.value = 0;
        }
      }

      // 🚫 DISABLED: Apple App Review rejection - Free trial toggle
      // Will be re-enabled once Apple approves this feature
      // Check if selected plan is yearly
      // if (selectedPlanIndex.value < availablePackages.length) {
      //   freeTrialEnabled.value =
      //       isYearlyPackage(availablePackages[selectedPlanIndex.value]);
      // }

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

  /// Check if selected package has a free trial
  bool get hasFreeTrial {
    if (selectedPlanIndex.value >= packages.length) return false;
    final selectedPackage = packages[selectedPlanIndex.value];
    return selectedPackage.storeProduct.introductoryPrice != null;
  }

  /// Get CTA button text based on selected plan
  String get ctaButtonText {
    return hasFreeTrial ? 'Start Free Trial' : 'Start Your Journey';
  }

  void selectPlan(int index) async {
    if (index < 0 || index >= packages.length) return;

    // Haptic feedback on plan selection
    HapticFeedback.selectionClick();

    cardAnimationController.forward().then((_) {
      cardAnimationController.reverse();
    });

    selectedPlanIndex.value = index;

    // 🚫 DISABLED: Apple App Review rejection - Free trial toggle
    // Will be re-enabled once Apple approves this feature
    // final isYearly = isYearlyPackage(packages[index]);
    // freeTrialEnabled.value = isYearly;

    // if (isYearly) {
    //   switchAnimationController.forward();
    // } else {
    //   switchAnimationController.reverse();
    // }

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

  // 🚫 DISABLED: Apple App Review rejection - Free trial toggle
  // Will be re-enabled once Apple approves this feature
  // Reason: Apple rejected the ability for users to disable free trial
  // This functionality allows users to opt-out of free trial periods
  // void toggleFreeTrial(bool value) {
  //   freeTrialEnabled.value = value;

  //   // If enabling trial, switch to yearly plan
  //   if (value) {
  //     final yearlyIndex = packages.indexWhere(isYearlyPackage);
  //     if (yearlyIndex != -1) {
  //       selectedPlanIndex.value = yearlyIndex;
  //     }
  //   }

  //   // If disabling trial and current plan is yearly, switch to non-yearly
  //   if (!value && selectedPlanIndex.value < packages.length) {
  //     if (isYearlyPackage(packages[selectedPlanIndex.value])) {
  //       final nonYearlyIndex =
  //           packages.indexWhere((pkg) => !isYearlyPackage(pkg));
  //       if (nonYearlyIndex != -1) {
  //         selectedPlanIndex.value = nonYearlyIndex;
  //       }
  //     }
  //   }

  //   if (value) {
  //     switchAnimationController.forward();
  //   } else {
  //     switchAnimationController.reverse();
  //   }
  // }

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
      return '$price/year';
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
    debugPrint('📊 getSavingsText called for package: ${package.identifier}');
    debugPrint('📊 Package period: ${package.storeProduct.subscriptionPeriod}');
    debugPrint('📊 Is yearly? ${isYearlyPackage(package)}');

    if (isYearlyPackage(package)) {
      final weeklyPackage = packages.firstWhereOrNull((pkg) {
        final period = pkg.storeProduct.subscriptionPeriod;
        if (period == null) return false;
        final periodLower = period.toLowerCase();
        // Check for ISO 8601 format: P1W or text format containing 'week'
        return periodLower.contains('p1w') ||
            periodLower.contains('week') ||
            (periodLower.contains('w') && !periodLower.contains('y'));
      });

      debugPrint('📊 Weekly package found: ${weeklyPackage?.identifier}');

      if (weeklyPackage == null) {
        debugPrint('📊 No weekly package found - returning empty');
        return '';
      }

      final yearlyPrice = package.storeProduct.price;
      final weeklyPrice = weeklyPackage.storeProduct.price;
      final yearlyEquivalent = weeklyPrice * 52; // 52 weeks in a year
      final savingsAmount = yearlyEquivalent - yearlyPrice;
      final savingsPercentage = (savingsAmount / yearlyEquivalent) * 100;

      debugPrint(
          '📊 Savings calculation: yearly=$yearlyPrice, weekly=$weeklyPrice, equivalent=$yearlyEquivalent, savings=$savingsAmount, percentage=${savingsPercentage.toStringAsFixed(0)}%');

      if (savingsAmount > 0) {
        final result = 'Save ${savingsPercentage.toStringAsFixed(0)}%';
        debugPrint('📊 Returning: $result');
        return result;
      }

      debugPrint('📊 Savings <= 0 - returning empty');
      return '';
    }

    // No badge for non-yearly plans
    debugPrint('📊 Not yearly plan - returning empty');
    return '';
  }

  void closePaywall() {
    // Trigger win-back sequence when user closes without subscribing
    WinBackNotificationService()
        .scheduleWinBackSequence(source: 'paywall_closed');

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

      // Attempt purchase — use promotional offer if win-back promo
      final PurchaseResult result;
      if (isWinBackPromo.value) {
        debugPrint('🎁 [Paywall] Attempting purchase with promotional offer');
        result =
            await _revenueCat.purchaseWithPromotionalOffer(selectedPackage);
      } else {
        result = await _revenueCat.purchaseSubscription(selectedPackage);
      }

      if (result.success) {
        debugPrint('✅ [Paywall] Purchase successful!');
        debugPrint(
            '📦 [Paywall] Customer Info: ${result.customerInfo?.entitlements.active}');

        // Clear win-back promo eligibility after successful purchase
        if (isWinBackPromo.value) {
          await WinBackNotificationService().clearPromoEligible();

          // Track promo conversion
          if (_analytics.isReady) {
            _analytics.events.trackCustom('winback_promo_converted', {
              'plan_type': getPlanTitle(selectedPackage).toLowerCase(),
              'plan_id': selectedPackage.identifier,
              'revenue': product.price,
              'currency': product.currencyCode,
              'timestamp': DateTime.now().toIso8601String(),
            });
          }
        }

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

        // Navigate to main app or close paywall
        // Note: Don't show toast before navigation as it causes overlay errors
        await _handleSuccessfulSubscription();
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
          planType:
              getPlanTitle(packages[selectedPlanIndex.value]).toLowerCase(),
          planId: packages[selectedPlanIndex.value].identifier,
          reason: e.toString(),
          errorCode: e is PlatformException ? e.code : null,
        );
      }

      // Show error feedback
      HapticFeedback.lightImpact();
      FastToast.error(
        e.toString(),
        title: 'Purchase Failed',
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

        await _handleSuccessfulSubscription();
      } else if (result.success && !result.hasActiveSubscriptions) {
        FastToast.warning(
          'No active subscriptions found to restore.',
          title: 'No Purchases Found',
        );
      } else {
        throw Exception(result.error ?? 'Restore failed');
      }
    } catch (e) {
      lastError.value = e.toString();

      FastToast.error(
        'Could not restore purchases. Please try again.',
        title: 'Restore Failed',
      );
    } finally {
      isPurchasing.value = false;
    }
  }

  /// Apply promo code
  Future<void> applyPromoCode() async {
    if (promoCode.value.trim().isEmpty) {
      FastToast.warning(
        'Please enter a valid promo code.',
        title: 'Invalid Code',
      );
      return;
    }

    try {
      isPurchasing.value = true;

      final result = await _revenueCat.applyPromoCode(promoCode.value.trim());

      if (result.success) {
        HapticFeedback.mediumImpact();
        FastToast.success(
          'Your discount has been applied successfully.',
          title: 'Promo Code Applied!',
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
      FastToast.error(
        'The promo code you entered is not valid.',
        title: 'Invalid Promo Code',
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
    launchUrl(Uri.parse('https://appbiz-studio.com/apps/faithlock/privacy/'));
  }

  void openTermsOfService() {
    launchUrl(Uri.parse('https://appbiz-studio.com/apps/faithlock/terms/'));
  }

  void openSubscriptionTerms() {
    // Implement URL launcher or webview
    print('Opening Subscription Terms');
  }

  /// Private methods

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    trialReminderEnabled.value =
        prefs.getBool(_keyTrialReminderEnabled) ?? true;
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

  Future<void> _handleSuccessfulSubscription() async {
    // Wait a bit for RevenueCat to propagate subscription state
    // This prevents the initial route screen from checking too early
    await Future.delayed(const Duration(milliseconds: 1500));

    debugPrint(
        '✅ [Paywall] Subscription successful - navigating to MainScreen');
    Get.offAllNamed(AppRoutes.main);
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
