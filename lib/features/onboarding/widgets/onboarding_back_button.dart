import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:flutter/material.dart';

/// Onboarding back button with rounded container
/// iOS-style premium design
class OnboardingBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const OnboardingBackButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: OnboardingTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: OnboardingTheme.goldColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: OnboardingTheme.goldColor,
          size: 18,
        ),
      ),
    );
  }
}
