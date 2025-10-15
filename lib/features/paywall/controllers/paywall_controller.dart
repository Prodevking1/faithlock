import 'package:faithlock/services/subscription/revenuecat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Paywall controller managing subscription flow and business logic
class PaywallController extends GetxController {
  static const String _keyTrialReminderEnabled = 'trial_reminder_enabled';
  static const String _keyPromoCodeApplied = 'promo_code_applied';

  // Services
  RevenueCatService get _revenueCat => RevenueCatService.instance;

  // Observable state
  final RxBool isLoading = false.obs;
  final RxBool trialReminderEnabled = true.obs;
  final RxBool freeTrialEnabled = true.obs;
  final RxBool showPromoCodeField = false.obs;
  final RxString promoCode = ''.obs;
  final RxString selectedPlan = 'monthly'.obs;
  final RxString lastError = ''.obs;

  // Form controllers
  final TextEditingController promoCodeController = TextEditingController();

  // Plan options
  final List<PlanOption> availablePlans = [
    PlanOption(
      id: 'weekly',
      title: 'Weekly',
      price: '\$4.99',
      period: 'per week',
      savings: null,
      trialDays: 7,
    ),
    PlanOption(
      id: 'monthly',
      title: 'Monthly',
      price: '\$19.99',
      period: 'per month',
      savings: 'Save 60%',
      trialDays: 7,
      isPopular: true,
    ),
    PlanOption(
      id: 'yearly',
      title: 'Yearly',
      price: '\$99.99',
      period: 'per year',
      savings: 'Save 75%',
      trialDays: 7,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _bindPromoCodeController();
  }

  @override
  void onClose() {
    promoCodeController.dispose();
    super.onClose();
  }

  /// Get selected plan details
  PlanOption get selectedPlanDetails {
    return availablePlans.firstWhere(
      (plan) => plan.id == selectedPlan.value,
      orElse: () => availablePlans[1], // Default to monthly
    );
  }

  /// Get subscription timeline steps
  List<TimelineStep> getTimelineSteps() {
    final selectedPlanData = selectedPlanDetails;

    return [
      TimelineStep(
        day: 'Today',
        title: 'Start Free Trial',
        description: 'Unlock premium access for free. No charges today.',
        icon: Icons.lock_open,
        iconColor: const Color(0xFF4CAF50),
        isCompleted: false,
      ),
      TimelineStep(
        day: 'Day ${selectedPlanData.trialDays - 2}',
        title: 'Trial Reminder',
        description: trialReminderEnabled.value
            ? 'Get notified before your trial ends.'
            : 'No reminder (disabled by you).',
        icon: Icons.notifications_active,
        iconColor: trialReminderEnabled.value
            ? const Color(0xFF4CAF50)
            : Colors.grey,
        isCompleted: false,
      ),
      TimelineStep(
        day: 'Day ${selectedPlanData.trialDays}',
        title: 'Billing Starts',
        description: 'Subscription begins at ${selectedPlanData.price} ${selectedPlanData.period}. Cancel anytime before.',
        icon: Icons.credit_card,
        iconColor: const Color(0xFF4CAF50),
        isCompleted: false,
      ),
    ];
  }

  /// Start subscription with selected plan
  Future<void> startSubscription() async {
    try {
      isLoading.value = true;
      lastError.value = '';

      // Get available offerings
      final offerings = await _revenueCat.getOfferings();
      if (offerings.isEmpty) {
        throw Exception('No subscription plans available');
      }

      // Find the selected plan package
      final offering = offerings.first;
      final packages = offering.availablePackages;

      // Map our plan IDs to RevenueCat packages
      final packageMap = {
        'weekly': packages.where((p) => p.storeProduct.identifier.contains('weekly')).firstOrNull,
        'monthly': packages.where((p) => p.storeProduct.identifier.contains('monthly')).firstOrNull,
        'yearly': packages.where((p) => p.storeProduct.identifier.contains('yearly')).firstOrNull,
      };

      final selectedPackage = packageMap[selectedPlan.value];
      if (selectedPackage == null) {
        throw Exception('Selected plan not available');
      }

      // Attempt purchase
      final result = await _revenueCat.purchaseSubscription(selectedPackage);

      if (result.success) {
        // Schedule trial reminder if enabled
        if (trialReminderEnabled.value) {
          await _scheduleTrialReminder();
        }

        // Show success feedback
        HapticFeedback.mediumImpact();
        Get.snackbar(
          'Success! 🎉',
          'Your free trial has started. Enjoy premium features!',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green[800],
          icon: const Icon(Icons.check_circle, color: Colors.green),
          duration: const Duration(seconds: 3),
        );

        // Navigate to main app or close paywall
        _handleSuccessfulSubscription();
      } else {
        throw Exception(result.error ?? 'Purchase failed');
      }
    } catch (e) {
      lastError.value = e.toString();

      // Show error feedback
      HapticFeedback.lightImpact();
      Get.snackbar(
        'Purchase Failed',
        e.toString(),
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
        icon: const Icon(Icons.error, color: Colors.red),
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final result = await _revenueCat.restorePurchases();

      if (result.success && result.hasActiveSubscriptions) {
        HapticFeedback.mediumImpact();
        Get.snackbar(
          'Purchases Restored! ✅',
          'Your subscription has been restored successfully.',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green[800],
          icon: const Icon(Icons.check_circle, color: Colors.green),
          duration: const Duration(seconds: 3),
        );

        _handleSuccessfulSubscription();
      } else if (result.success && !result.hasActiveSubscriptions) {
        Get.snackbar(
          'No Purchases Found',
          'No active subscriptions found to restore.',
          backgroundColor: Colors.orange.withOpacity(0.1),
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
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
        icon: const Icon(Icons.error, color: Colors.red),
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Apply promo code
  Future<void> applyPromoCode() async {
    if (promoCode.value.trim().isEmpty) {
      Get.snackbar(
        'Invalid Code',
        'Please enter a valid promo code.',
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange[800],
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      isLoading.value = true;

      final result = await _revenueCat.applyPromoCode(promoCode.value.trim());

      if (result.success) {
        HapticFeedback.mediumImpact();
        Get.snackbar(
          'Promo Code Applied! 🎉',
          'Your discount has been applied successfully.',
          backgroundColor: Colors.green.withOpacity(0.1),
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
      Get.snackbar(
        'Invalid Promo Code',
        'The promo code you entered is not valid.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
        icon: const Icon(Icons.error, color: Colors.red),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleTrialReminder(bool enabled) async {
    trialReminderEnabled.value = enabled;

  }

  void toogleFreeTrial() {
    freeTrialEnabled.value = !freeTrialEnabled.value;
  }

  /// Select subscription plan
  void selectPlan(String planId) {
    selectedPlan.value = planId;
    HapticFeedback.selectionClick();
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
