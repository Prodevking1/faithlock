import 'package:faithlock/features/onboarding/models/onboarding_step_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingContent {
  static List<OnboardingStep> get steps => [
    OnboardingStep(
      title: 'save2HoursEveryDay'.tr,
      description: 'save2HoursDescription'.tr,
      icon: Icons.rocket_launch,
      color: Colors.blue,
      trustIndicator: TrustIndicator(
        icon: Icons.timer,
        text: 'averageUserSaves'.tr,
        color: Colors.blue,
      ),
    ),
    OnboardingStep(
      title: 'everythingInOnePlace'.tr,
      description: 'everythingInOnePlaceDescription'.tr,
      icon: Icons.dashboard_customize,
      color: Colors.purple,
      trustIndicator: TrustIndicator(
        icon: Icons.verified,
        text: 'trustedByFortune500'.tr,
        color: Colors.purple,
      ),
    ),
    OnboardingStep(
      title: 'thirtyDaysFreeNoCard'.tr,
      description: 'thirtyDaysFreeDescription'.tr,
      icon: Icons.card_giftcard,
      color: Colors.green,
      trustIndicator: TrustIndicator(
        icon: Icons.security,
        text: 'secureAndPrivate'.tr,
        color: Colors.green,
      ),
    ),
  ];
}
