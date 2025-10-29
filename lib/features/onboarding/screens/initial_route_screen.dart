import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/screens/onboarding_summary_screen.dart';
import 'package:faithlock/features/onboarding/screens/scripture_onboarding_screen.dart';
import 'package:faithlock/navigation/screens/main_screen.dart';
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
    _determineInitialRoute();
  }

  Future<void> _determineInitialRoute() async {
    await Future.delayed(const Duration(milliseconds: 100));

    final controller = Get.put(
      ScriptureOnboardingController(),
      permanent: true,
    );

    final onboardingComplete = await controller.isOnboardingComplete();
    debugPrint('🔍 [InitialRoute] Onboarding complete: $onboardingComplete');

    if (!onboardingComplete) {
      debugPrint('📖 [InitialRoute] → ScriptureOnboardingScreen');
      Get.off(() => ScriptureOnboardingScreen());
      return;
    }

    final summaryComplete = await controller.isSummaryComplete();
    debugPrint('🔍 [InitialRoute] Summary complete: $summaryComplete');

    if (!summaryComplete) {
      debugPrint('📊 [InitialRoute] → OnboardingSummaryScreen (first time)');
      Get.off(() => const OnboardingSummaryScreen());
      return;
    }

    // Step 3: Check if user has ever accessed app features
    final hasAccessedFeatures = await controller.hasAccessedFeatures();
    debugPrint(
        '🔍 [InitialRoute] Has accessed features: $hasAccessedFeatures');

    // If user never accessed features, show summary again
    // This handles the case where user completed onboarding but never subscribed
    if (!hasAccessedFeatures) {
      debugPrint(
          '📊 [InitialRoute] → OnboardingSummaryScreen (never accessed features)');
      Get.off(() => const OnboardingSummaryScreen());
      return;
    }

    // Step 4: Check subscription status
    final hasSubscription = PaywallGuardService().hasActiveSubscription();
    debugPrint('🔍 [InitialRoute] Has subscription: $hasSubscription');

    if (!hasSubscription) {
      debugPrint('🚪 [InitialRoute] → PaywallScreen/ExpiredScreen');
      // PaywallGuardService will decide between PaywallScreen or SubscriptionExpiredScreen
      await PaywallGuardService().checkSubscriptionAccess(
        placementId: 'initial_route_guard',
        showPaywallIfInactive: true,
      );
      return;
    }

    // Step 5: All checks passed - navigate to MainScreen
    debugPrint('✅ [InitialRoute] → MainScreen');
    Get.offAll(() => const MainScreen());
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
