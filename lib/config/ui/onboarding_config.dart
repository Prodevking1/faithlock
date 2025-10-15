import 'package:flutter/material.dart';

class OnboardingStep {
  final String id;
  final String title;
  final String description;
  final String imagePath;
  final IconData? icon;
  final Color? backgroundColor;
  final List<String>? bulletPoints;
  final String? ctaText;
  final String? skipText;
  final int order;
  final bool isRequired;
  final Map<String, dynamic>? metadata;

  const OnboardingStep({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    this.icon,
    this.backgroundColor,
    this.bulletPoints,
    this.ctaText,
    this.skipText,
    required this.order,
    this.isRequired = false,
    this.metadata,
  });
}

class OnboardingConfig {
  static const bool enableOnboarding = true;
  static const bool allowSkip = true;
  static const int minimumStepsToComplete = 3;
  static const Duration animationDuration = Duration(milliseconds: 300);

  static const List<OnboardingStep> steps = [
    OnboardingStep(
      id: 'welcome',
      title: 'Welcome to Fast App',
      description: 'The best application to manage your daily activities',
      imagePath: 'assets/images/onboarding/welcome.png',
      icon: Icons.waving_hand,
      backgroundColor: Colors.blue,
      bulletPoints: [
        'Simple and intuitive',
        'Secure and fast',
        'Always available',
      ],
      ctaText: 'Get Started',
      order: 1,
      isRequired: true,
    ),
    OnboardingStep(
      id: 'features',
      title: 'Powerful Features',
      description: 'Discover everything you can do with Fast App',
      imagePath: 'assets/images/onboarding/features.png',
      icon: Icons.star,
      backgroundColor: Colors.purple,
      bulletPoints: [
        'Complete data management',
        'Real-time synchronization',
        'Detailed analytics',
        'Smart notifications',
      ],
      ctaText: 'Next',
      skipText: 'Skip',
      order: 2,
    ),
    OnboardingStep(
      id: 'security',
      title: 'Maximum Security',
      description: 'Your data is protected with the best technologies',
      imagePath: 'assets/images/onboarding/security.png',
      icon: Icons.security,
      backgroundColor: Colors.green,
      bulletPoints: [
        'End-to-end encryption',
        'Biometric authentication',
        'Automatic backup',
      ],
      ctaText: 'Next',
      skipText: 'Skip',
      order: 3,
    ),
    OnboardingStep(
      id: 'notifications',
      title: 'Stay Informed',
      description: 'Enable notifications to never miss anything',
      imagePath: 'assets/images/onboarding/notifications.png',
      icon: Icons.notifications,
      backgroundColor: Colors.orange,
      ctaText: 'Allow Notifications',
      skipText: 'Later',
      order: 4,
      metadata: {
        'permission_type': 'notifications',
        'is_optional': true,
      },
    ),
    OnboardingStep(
      id: 'account',
      title: 'Create Your Account',
      description: 'Join thousands of satisfied users',
      imagePath: 'assets/images/onboarding/account.png',
      icon: Icons.person,
      backgroundColor: Colors.teal,
      ctaText: 'Create Account',
      skipText: 'Sign In',
      order: 5,
      metadata: {
        'action_type': 'auth',
        'primary_action': 'signup',
        'secondary_action': 'signin',
      },
    ),
  ];

  static OnboardingStep? getStepById(String id) {
    try {
      return steps.firstWhere((step) => step.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<OnboardingStep> getRequiredSteps() {
    return steps.where((step) => step.isRequired).toList();
  }

  static List<OnboardingStep> getStepsByOrder() {
    return List.from(steps)..sort((a, b) => a.order.compareTo(b.order));
  }
}
