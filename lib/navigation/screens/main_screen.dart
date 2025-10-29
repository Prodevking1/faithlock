import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/navigation/controllers/navigation_controller.dart';
import 'package:faithlock/services/startup_check_service.dart';
import 'package:faithlock/services/subscription/paywall_guard_service.dart';
import 'package:faithlock/shared/widgets/bars/fast_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final NavigationController controller = Get.put(NavigationController());

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Check subscription first (paywall guard)
      final hasSubscription = await PaywallGuardService()
          .checkSubscriptionAccess(placementId: 'main_screen_guard');

      if (!hasSubscription) {
        return;
      }

      // Mark that user has accessed app features (with active subscription)
      final onboardingController = Get.find<ScriptureOnboardingController>();
      final hasAccessedBefore = await onboardingController.hasAccessedFeatures();

      if (!hasAccessedBefore) {
        await onboardingController.markFeaturesAccessed();
        debugPrint('🎉 [MainScreen] First time accessing features - marked!');
      }

      // Perform startup checks only if subscribed
      StartupCheckService().performStartupChecks(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        controller.onWillPop();
      },
      child: Obx(
        () => Scaffold(
          body: IndexedStack(
            index: controller.currentIndex,
            children:
                controller.navigationItems.map((item) => item.page).toList(),
          ),
          bottomNavigationBar: FastBottomBar(
            currentIndex: controller.currentIndex,
            onTap: controller.changePage,
            items: controller.bottomBarItems,
          ),
        ),
      ),
    );
  }
}
