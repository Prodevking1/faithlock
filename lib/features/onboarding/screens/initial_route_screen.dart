import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/screens/scripture_onboarding_screen.dart';
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
        // User hasn't completed onboarding - show V2 onboarding flow
        // V2 screen creates its own controllers (registered as both base + V2 types)
        debugPrint('🎯 [InitialRoute] Navigating to V2 onboarding');
        Get.off(() => const ScriptureOnboardingScreen());
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
      // Fallback to V2 onboarding on error
      Get.off(() => const ScriptureOnboardingScreen());
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
