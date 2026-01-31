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
      // Initialize controller needed by MainScreen and onboarding
      Get.put(ScriptureOnboardingController(), permanent: true);

      // Check if user has completed onboarding
      final prefs = PreferencesService();
      final hasCompletedOnboarding =
          await prefs.readBool('scripture_onboarding_complete') ?? false;

      debugPrint('📋 [InitialRoute] Onboarding completed: $hasCompletedOnboarding');

      if (!hasCompletedOnboarding) {
        // User hasn't completed onboarding - show onboarding flow
        debugPrint('🎯 [InitialRoute] Navigating to onboarding');
        Get.off(() => const ScriptureOnboardingScreen());
        return;
      }

      // User has completed onboarding - check subscription status
      debugPrint('✅ [InitialRoute] Onboarding completed - checking subscription');
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
      // Fallback to onboarding on error
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
