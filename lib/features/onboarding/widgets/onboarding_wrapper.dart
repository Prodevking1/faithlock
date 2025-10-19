import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Onboarding wrapper that provides consistent UI elements across all steps
/// Includes progress bar at top and optional back button
class OnboardingWrapper extends StatelessWidget {
  final Widget child;
  final bool showBackButton;

  const OnboardingWrapper({
    super.key,
    required this.child,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScriptureOnboardingController>();

    return Scaffold(
      backgroundColor: OnboardingTheme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            child,

            // Progress bar at top (always visible)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Obx(() => OnboardingProgressBar(
                    currentStep: controller.currentStep.value,
                  )),
            ),

            // Back button (optional, commented out for now)
            // if (showBackButton && controller.currentStep.value > 1)
            //   Positioned(
            //     top: 60,
            //     left: 16,
            //     child: OnboardingBackButton(
            //       onPressed: () => controller.previousStep(),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
