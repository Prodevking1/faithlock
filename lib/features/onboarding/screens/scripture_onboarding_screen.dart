import 'package:faithlock/app_routes.dart';
import 'package:faithlock/features/faithlock/controllers/faithlock_settings_controller.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/screens/step1_5_name_capture.dart';
import 'package:faithlock/features/onboarding/screens/step1_divine_revelation.dart';
import 'package:faithlock/features/onboarding/screens/step2_self_confrontation.dart';
import 'package:faithlock/features/onboarding/screens/step3_5_testimonials.dart';
import 'package:faithlock/features/onboarding/screens/step3_eternal_warfare.dart';
import 'package:faithlock/features/onboarding/screens/step4_call_to_covenant.dart';
import 'package:faithlock/features/onboarding/screens/step5_armor_configuration.dart';
import 'package:faithlock/features/onboarding/screens/step6_final_encouragement.dart';
import 'package:faithlock/features/onboarding/screens/step7_screen_time_permission.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Main Scripture Lock onboarding screen with personalized flow
class ScriptureOnboardingScreen extends StatelessWidget {
  const ScriptureOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ScriptureOnboardingController());

    return Obx(() {
      switch (controller.currentStep.value) {
        case 1:
          return Step1DivineRevelation(
            onComplete: () => controller.nextStep(),
          );

        case 2: // Step 1.5 - Name Capture
          return Step1_5NameCapture(
            onComplete: () => controller.nextStep(),
          );

        case 3: // Step 2 - Self Confrontation
          return Step2SelfConfrontation(
            onComplete: () => controller.nextStep(),
          );

        case 4: // Step 3 - Eternal Warfare
          return Step3EternalWarfare(
            onComplete: () => controller.nextStep(),
          );

        case 5: // Step 4 - Call to Covenant
          return Step4CallToCovenant(
            onComplete: () => controller.nextStep(),
          );

        case 6: // Step 5 - Armor Configuration
          return Step5ArmorConfiguration(
            onComplete: () => controller.nextStep(),
          );

        case 7: // Step 6 - Final Encouragement
          return Step6FinalEncouragement(
            onComplete: () => controller.nextStep(),
          );

        case 8: // Step 7 - Testimonials (Social Proof before paywall)
          return Step35Testimonials(
            onComplete: () => controller.nextStep(),
          );

        case 9: // Step 8 - Screen Time Permission
          return Step7ScreenTimePermission(
            onComplete: () async {
              FaithLockSettingsController().requestScreenTimePermission();

              // ✅ Mark onboarding as completed before navigating
              await controller.completeOnboarding();

              Get.offAllNamed(AppRoutes.home);
            },
          );

        default:
          return Scaffold(
            body: Center(
              child: Text(
                'Step ${controller.currentStep.value} - Error',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            backgroundColor: Colors.black,
          );
      }
    });
  }
}
