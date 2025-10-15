import 'package:faithlock/features/onboarding/models/interactive_action_model.dart';
import 'package:flutter/material.dart';

/// Trust indicator model
class TrustIndicator {
  final IconData icon;
  final String text;
  final Color color;

  const TrustIndicator({
    required this.icon,
    required this.text,
    required this.color,
  });
}

/// Enhanced onboarding step model with interactive actions
class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  final Color? color;
  final TrustIndicator? trustIndicator;

  // Interactive actions for this step
  final List<InteractiveAction>? actions;

  // Step behavior
  final bool canSkip;
  final bool requiresActions;
  final String? skipLabel;
  final String? continueLabel;

  const OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    this.color,
    this.trustIndicator,
    this.actions,
    this.canSkip = true,
    this.requiresActions = false,
    this.skipLabel,
    this.continueLabel,
  });

  bool get hasActions => actions != null && actions!.isNotEmpty;

  List<InteractiveAction> get requiredActions =>
    actions?.where((action) => action.isRequired).toList() ?? [];
}
