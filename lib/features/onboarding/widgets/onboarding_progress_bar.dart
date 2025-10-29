import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Onboarding progress bar widget
/// Shows "Step X of 9" with a linear progress indicator
class OnboardingProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 9,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;
    final controller = Get.find<ScriptureOnboardingController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        spacing: 8,
        children: [
          GestureDetector(
            onTap: () {
              if (currentStep <= 1) return;
              controller.previousStep();
            },
            child: Container(
              height: 30,
              width: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: currentStep <= 1
                    ? OnboardingTheme.labelTertiary.withValues(alpha: 0.3)
                    : OnboardingTheme.goldColor,
              ),
              child: Icon(
                CupertinoIcons.back,
                color: currentStep <= 1
                    ? OnboardingTheme.labelTertiary
                    : OnboardingTheme.backgroundColor,
                size: 20,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 14,
              borderRadius: BorderRadius.circular(12),
              backgroundColor:
                  OnboardingTheme.labelTertiary.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                OnboardingTheme.goldColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
