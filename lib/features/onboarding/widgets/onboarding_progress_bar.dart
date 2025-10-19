import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:flutter/material.dart';

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          // Progress indicator text
          Text(
            'Step $currentStep of $totalSteps',
            style: OnboardingTheme.caption.copyWith(
              color: OnboardingTheme.labelSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
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
