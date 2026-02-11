import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/paywall/controllers/paywall_controller.dart';
// 🚫 DISABLED: Unused import (CupertinoSwitch is commented out)
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PaywallScreen extends StatelessWidget {
  final String? placementId;
  final bool redirectToHomeOnClose;

  const PaywallScreen({
    super.key,
    this.placementId,
    this.redirectToHomeOnClose = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaywallController(
      placementId: placementId,
      redirectToHomeOnClose: redirectToHomeOnClose,
    ));

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: OnboardingTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: OnboardingTheme.backgroundColor,
        elevation: 0,
        leading: const SizedBox(width: 48),
        title: _buildHeader(isDark),
        actions: [
          TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 5),
              builder: (context, value, child) {
                if (value < 1.0) {
                  return Container(
                    height: 24,
                    width: 24,
                    margin: const EdgeInsets.only(right: 8),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: value,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.grey),
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    ),
                  );
                }
                return GestureDetector(
                  onTap: controller.closePaywall,
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                );
              }),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.packages.isEmpty) {
                  return _buildLoadingState(isDark);
                }

                if (controller.lastError.value.isNotEmpty &&
                    controller.packages.isEmpty) {
                  return _buildErrorState(isDark, controller);
                }

                return _buildContent(context, controller, isDark);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'faithlock',
          style: OnboardingTheme.title2.copyWith(
            color: OnboardingTheme.goldColor,
          ),
        ),
        const SizedBox(width: OnboardingTheme.space8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: OnboardingTheme.space8,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: OnboardingTheme.goldColor,
            borderRadius: BorderRadius.circular(OnboardingTheme.radiusSmall),
          ),
          child: Text(
            'PRO',
            style: OnboardingTheme.callout.copyWith(
              color: OnboardingTheme.backgroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: CircularProgressIndicator.adaptive(
        valueColor: AlwaysStoppedAnimation<Color>(
          OnboardingTheme.goldColor,
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark, PaywallController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(OnboardingTheme.space20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: OnboardingTheme.labelTertiary,
            ),
            const SizedBox(height: OnboardingTheme.space16),
            Text(
              controller.lastError.value,
              style: OnboardingTheme.body.copyWith(
                color: OnboardingTheme.labelSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: OnboardingTheme.space24),
            ElevatedButton(
              onPressed: () => controller.onInit(),
              style: ElevatedButton.styleFrom(
                backgroundColor: OnboardingTheme.goldColor,
                foregroundColor: OnboardingTheme.backgroundColor,
              ),
              child: Text(
                'Retry',
                style: OnboardingTheme.callout.copyWith(
                  color: OnboardingTheme.backgroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, PaywallController controller, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: OnboardingTheme.horizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: OnboardingTheme.space20),

          // Social proof stat
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: OnboardingTheme.space16,
              vertical: OnboardingTheme.space12,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  OnboardingTheme.goldColor.withValues(alpha: 0.1),
                  OnboardingTheme.goldColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(OnboardingTheme.radiusMedium),
              border: Border.all(
                color: OnboardingTheme.goldColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(OnboardingTheme.space8),
                  decoration: BoxDecoration(
                    color: OnboardingTheme.goldColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shield,
                    size: 24,
                    color: OnboardingTheme.goldColor,
                  ),
                ),
                const SizedBox(width: OnboardingTheme.space12),
                Expanded(
                  child: Text(
                    'Users report 70% less screen time and 92% stronger faith',
                    style: OnboardingTheme.callout.copyWith(
                      fontSize: 19,
                      color: OnboardingTheme.labelPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: OnboardingTheme.space32),

          // Features list
          _buildFeaturesList(isDark),

          // Win-back promo banner
          Obx(() {
            if (!controller.isWinBackPromo.value) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding:
                  const EdgeInsets.only(bottom: OnboardingTheme.space20),
              child: Container(
                padding: const EdgeInsets.all(OnboardingTheme.space16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      OnboardingTheme.goldColor.withValues(alpha: 0.15),
                      OnboardingTheme.goldColor.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(OnboardingTheme.radiusMedium),
                  border: Border.all(
                    color: OnboardingTheme.goldColor.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.all(OnboardingTheme.space8),
                      decoration: BoxDecoration(
                        color:
                            OnboardingTheme.goldColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.card_giftcard,
                        size: 20,
                        color: OnboardingTheme.goldColor,
                      ),
                    ),
                    const SizedBox(width: OnboardingTheme.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your free week is here',
                            style: OnboardingTheme.callout.copyWith(
                              color: OnboardingTheme.goldColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '7 days free — no payment required',
                            style: OnboardingTheme.footnote.copyWith(
                              color: OnboardingTheme.labelSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: OnboardingTheme.space12),

          // Pricing plans
          Obx(() => _buildPricingPlans(isDark, controller)),

          const SizedBox(height: OnboardingTheme.space20),

          // 🚫 DISABLED: Apple App Review rejection - Free trial toggle
          // Will be re-enabled once Apple approves this feature
          // Free trial toggle
          // _buildFreeTrialToggle(isDark, controller),

          const SizedBox(height: OnboardingTheme.space24),

          _buildUnlockButton(controller),

          // Unlock button
          // Obx(() {
          //   // final selectedIndex = controller.selectedPlanIndex.value;
          //   return Column(
          //     children: [
          //       // if (selectedIndex == 1) ...[
          //       //   Text(
          //       //     'Cancel anytime. No commitment required.',
          //       //     style: OnboardingTheme.caption.copyWith(
          //       //       color: OnboardingTheme.labelSecondary,
          //       //     ),
          //       //   ),
          //       //   const SizedBox(height: OnboardingTheme.space12),
          //       // ],
          //       _buildUnlockButton(controller),
          //     ],
          //   );
          // }),

          const SizedBox(height: OnboardingTheme.space20),

          // Footer links
          _buildFooterLinks(isDark, controller),

          const SizedBox(height: OnboardingTheme.space24),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(bool isDark) {
    final features = [
      {'icon': Icons.auto_awesome, 'text': 'Deepen your spiritual journey'},
      {'icon': Icons.psychology, 'text': 'Build stronger faith habits'},
      {'icon': Icons.shield, 'text': 'Stay protected from distractions'},
      {'icon': Icons.trending_up, 'text': 'Grow closer to your purpose'},
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: OnboardingTheme.space8),
          child: Row(
            children: [
              Icon(
                feature['icon'] as IconData,
                size: 24,
                color: OnboardingTheme.goldColor,
              ),
              const SizedBox(width: OnboardingTheme.space12),
              Text(
                feature['text'] as String,
                style: OnboardingTheme.callout.copyWith(
                  color: OnboardingTheme.labelPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPricingPlans(bool isDark, PaywallController controller) {
    if (controller.packages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: controller.packages.asMap().entries.map((entry) {
        final int index = entry.key;
        final package = entry.value;
        final isSelected = controller.selectedPlanIndex.value == index;

        return Column(
          children: [
            if (index > 0) const SizedBox(height: OnboardingTheme.space12),
            GestureDetector(
              onTap: () => controller.selectPlan(index),
              child: AnimatedBuilder(
                animation: controller.cardScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isSelected
                        ? (1.0 + (controller.cardScaleAnimation.value * 0.005))
                        : 1.0,
                    child: child,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  constraints: const BoxConstraints(minHeight: 50),
                  padding: const EdgeInsets.all(OnboardingTheme.space12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? OnboardingTheme.goldColor.withValues(alpha: 0.1)
                        : OnboardingTheme.cardBackground,
                    borderRadius:
                        BorderRadius.circular(OnboardingTheme.radiusMedium),
                    border: Border.all(
                      color: isSelected
                          ? OnboardingTheme.goldColor
                          : OnboardingTheme.labelTertiary
                              .withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.getPlanTitle(package),
                              style: OnboardingTheme.callout.copyWith(
                                color: OnboardingTheme.labelPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              controller.getPriceText(package),
                              style: OnboardingTheme.subhead.copyWith(
                                color: OnboardingTheme.labelSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (controller.getSavingsText(package).isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: OnboardingTheme.space8,
                            vertical: OnboardingTheme.space8,
                          ),
                          decoration: BoxDecoration(
                            color: OnboardingTheme.goldColor,
                            borderRadius: BorderRadius.circular(
                                OnboardingTheme.radiusSmall),
                          ),
                          child: Text(
                            controller.getSavingsText(package),
                            style: OnboardingTheme.caption.copyWith(
                              color: OnboardingTheme.backgroundColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: OnboardingTheme.space8),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // 🚫 DISABLED: Apple App Review rejection - Free trial toggle
  // Will be re-enabled once Apple approves this feature
  // Reason: Apple rejected the ability for users to disable free trial
  // This UI allows users to toggle free trial on/off
  // Widget _buildFreeTrialToggle(bool isDark, PaywallController controller) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Text(
  //         'Enable free trial',
  //         style: OnboardingTheme.callout.copyWith(
  //           color: OnboardingTheme.labelPrimary,
  //         ),
  //       ),
  //       Obx(() => CupertinoSwitch(
  //             value: controller.freeTrialEnabled.value,
  //             onChanged: controller.toggleFreeTrial,
  //             activeTrackColor: OnboardingTheme.goldColor,
  //           )),
  //     ],
  //   );
  // }

  Widget _buildUnlockButton(PaywallController controller) {
    return Obx(() {
      final hasFreeTrial = controller.selectedPlanIndex.value <
              controller.packages.length &&
          controller.packages[controller.selectedPlanIndex.value].storeProduct
                  .introductoryPrice !=
              null;

      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: controller.isPurchasing.value
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      controller.startSubscription();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: OnboardingTheme.goldColor,
                foregroundColor: OnboardingTheme.backgroundColor,
                disabledBackgroundColor:
                    OnboardingTheme.goldColor.withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(OnboardingTheme.radiusMedium),
                ),
              ),
              child: controller.isPurchasing.value
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          OnboardingTheme.backgroundColor,
                        ),
                      ),
                    )
                  : Text(
                      hasFreeTrial
                          ? 'paywall_tryForZero'.tr
                          : 'paywall_startJourney'.tr,
                      style: OnboardingTheme.callout.copyWith(
                        color: OnboardingTheme.backgroundColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          if (hasFreeTrial) ...[
            const SizedBox(height: OnboardingTheme.space8),
            Text(
              'paywall_riskReversal'.tr,
              style: OnboardingTheme.footnote.copyWith(
                color: OnboardingTheme.labelSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      );
    });
  }

  Widget _buildFooterLinks(bool isDark, PaywallController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: controller.restorePurchases,
          child: Text(
            'Restore',
            style: OnboardingTheme.footnote.copyWith(
              color: OnboardingTheme.labelSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: controller.openPrivacyPolicy,
          child: Text(
            'Privacy',
            style: OnboardingTheme.footnote.copyWith(
              color: OnboardingTheme.labelSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: controller.openTermsOfService,
          child: Text(
            'Terms',
            style: OnboardingTheme.footnote.copyWith(
              color: OnboardingTheme.labelSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
