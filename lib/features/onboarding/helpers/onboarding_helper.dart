import 'package:faithlock/features/onboarding/screens/fast_interactive_onboarding_screen.dart';
import 'package:faithlock/features/onboarding/screens/fast_onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Helper class to simplify onboarding selection and navigation
class OnboardingHelper {
  /// Launch the appropriate onboarding based on requirements
  /// 
  /// [needsUserInteraction] - true for interactive onboarding, false for simple
  static void launch({required bool needsUserInteraction}) {
    if (needsUserInteraction) {
      Get.to(() => FastInteractiveOnboardingScreen());
    } else {
      Get.to(() => FastOnboardingScreen());
    }
  }

  /// Launch simple onboarding (information only)
  static void launchSimple() {
    Get.to(() => FastOnboardingScreen());
  }

  /// Launch interactive onboarding (with user input/permissions)
  static void launchInteractive() {
    Get.to(() => FastInteractiveOnboardingScreen());
  }

  /// Smart launcher that determines onboarding type based on requirements
  static void smartLaunch({
    bool needsUserInput = false,
    bool needsPermissions = false,
    bool needsPreferences = false,
    bool needsConfiguration = false,
  }) {
    final needsInteraction = needsUserInput || 
                            needsPermissions || 
                            needsPreferences || 
                            needsConfiguration;
    
    launch(needsUserInteraction: needsInteraction);
  }

  /// Replace current route with onboarding
  static void replace({required bool needsUserInteraction}) {
    if (needsUserInteraction) {
      Get.off(() => FastInteractiveOnboardingScreen());
    } else {
      Get.off(() => FastOnboardingScreen());
    }
  }

  /// Clear navigation stack and launch onboarding
  static void restart({required bool needsUserInteraction}) {
    if (needsUserInteraction) {
      Get.offAll(() => FastInteractiveOnboardingScreen());
    } else {
      Get.offAll(() => FastOnboardingScreen());
    }
  }

  /// Get recommended onboarding type as string for debugging
  static String getRecommendation({
    bool needsUserInput = false,
    bool needsPermissions = false,
    bool needsPreferences = false,
    bool needsConfiguration = false,
  }) {
    final needsInteraction = needsUserInput || 
                            needsPermissions || 
                            needsPreferences || 
                            needsConfiguration;
    
    if (needsInteraction) {
      return 'FastInteractiveOnboardingScreen (with actions)';
    } else {
      return 'FastOnboardingScreen (simple)';
    }
  }

  /// Show decision dialog for manual selection (useful for testing)
  static void showSelectionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Choose Onboarding Type'),
        content: const Text('Which onboarding do you want to launch?'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              launchSimple();
            },
            child: const Text('Simple'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              launchInteractive();
            },
            child: const Text('Interactive'),
          ),
        ],
      ),
    );
  }
}