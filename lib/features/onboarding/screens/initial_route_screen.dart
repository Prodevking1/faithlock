import 'package:faithlock/config/app_config.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/screens/scripture_onboarding_screen.dart';
import 'package:faithlock/features/onboarding/screens/scripture_onboarding_v3_screen.dart';
import 'package:faithlock/navigation/screens/main_screen.dart';
import 'package:faithlock/services/storage/preferences_service.dart';
import 'package:faithlock/services/subscription/paywall_guard_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InitialRouteScreen extends StatefulWidget {
  const InitialRouteScreen({super.key});

  @override
  State<InitialRouteScreen> createState() => _InitialRouteScreenState();
}

class _InitialRouteScreenState extends State<InitialRouteScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for first frame before navigating
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _determineInitialRoute();
    });
  }

  Future<void> _determineInitialRoute() async {
    try {
      // Dev bypass: skip onboarding & paywall entirely
      if (AppConfig.bypassPaywall) {
        debugPrint('⚡ [InitialRoute] bypassPaywall enabled - going straight to MainScreen');
        Get.put(ScriptureOnboardingController(), permanent: true);
        Get.off(() => const MainScreen());
        return;
      }

      // Check if user has completed onboarding
      final prefs = PreferencesService();
      final hasCompletedOnboarding =
          await prefs.readBool('scripture_onboarding_complete') ?? false;
      final hasSummaryComplete =
          await prefs.readBool('onboarding_summary_complete') ?? false;
      final hasAccessedFeatures =
          await prefs.readBool('has_accessed_app_features') ?? false;

      debugPrint('📋 [InitialRoute] Onboarding completed: $hasCompletedOnboarding');
      debugPrint('📋 [InitialRoute] Summary completed: $hasSummaryComplete');
      debugPrint('📋 [InitialRoute] Features accessed: $hasAccessedFeatures');

      if (!hasCompletedOnboarding) {
        // Route to V3 if enabled, otherwise fall back to V2.
        // V3 controller extends V2/V1 so all downstream code keeps working.
        if (AppConfig.enableOnboardingV3) {
          debugPrint('🎯 [InitialRoute] Navigating to V3 onboarding');
          Get.off(() => const ScriptureOnboardingV3Screen());
        } else {
          debugPrint('🎯 [InitialRoute] Navigating to V2 onboarding (fallback)');
          Get.off(() => const ScriptureOnboardingScreen());
        }
        return;
      }

      // User has completed onboarding but not summary - show summary screen
      if (!hasSummaryComplete) {
        debugPrint('🎯 [InitialRoute] Navigating to summary screen (step 11)');
        final controller = Get.put(ScriptureOnboardingController(), permanent: true);
        controller.currentStep.value = 11; // Jump to summary step
        Get.off(() => const ScriptureOnboardingScreen());
        return;
      }

      // User has completed summary but never accessed features (never paid)
      // Keep them on summary until they pay
      if (!hasAccessedFeatures) {
        debugPrint('🎯 [InitialRoute] User never accessed features - returning to summary');
        final controller = Get.put(ScriptureOnboardingController(), permanent: true);
        controller.currentStep.value = 11; // Jump to summary step
        Get.off(() => const ScriptureOnboardingScreen());
        return;
      }

      // User has completed both and accessed features before - initialize controller for MainScreen
      Get.put(ScriptureOnboardingController(), permanent: true);

      // Check subscription status
      debugPrint('✅ [InitialRoute] User previously accessed features - checking subscription');
      final paywallGuard = PaywallGuardService();
      final hasAccess = await paywallGuard.checkSubscriptionAccess(
        placementId: 'app_launch',
        showPaywallIfInactive: true,
      );

      // If user has active subscription, go to MainScreen
      // Otherwise, PaywallGuardService will handle navigation to paywall/expired screen
      if (hasAccess) {
        debugPrint('✅ [InitialRoute] Access granted - navigating to MainScreen');
        Get.off(() => const MainScreen());
      }
    } catch (e) {
      debugPrint('❌ [InitialRoute] Error determining route: $e');
      if (AppConfig.enableOnboardingV3) {
        Get.off(() => const ScriptureOnboardingV3Screen());
      } else {
        Get.off(() => const ScriptureOnboardingScreen());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
