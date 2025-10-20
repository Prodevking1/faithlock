import 'package:faithlock/core/constants/core/fast_colors.dart';
import 'package:faithlock/features/paywall/controllers/paywall_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: const SizedBox(width: 48),
        title: _buildHeader(isDark),
        actions: [
          Obx(() {
            return TweenAnimationBuilder<double>(
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
                      color: Colors.black.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.black54,
                    ),
                  ),
                );
              },
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Flexible(
          child: Text(
            'faithlock',
            style: TextStyle(
              letterSpacing: -0.5,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: FastColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: FastColors.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'PRO',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: CircularProgressIndicator.adaptive(
        valueColor: AlwaysStoppedAnimation<Color>(
          isDark ? Colors.white : FastColors.primary,
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark, PaywallController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: isDark ? Colors.white54 : Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              controller.lastError.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => controller.onInit(),
              style: ElevatedButton.styleFrom(
                backgroundColor: FastColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, PaywallController controller, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Visual representation
          _buildVisualRepresentation(),

          Obx(() => SizedBox(
              height: controller.selectedPlanIndex.value == 1 ? 12 : 48)),

          // Features list
          Flexible(child: _buildFeaturesList(isDark)),

          Obx(() => SizedBox(
              height: controller.selectedPlanIndex.value == 1 ? 8 : 20)),

          // Pricing plans
          Obx(() => _buildPricingPlans(isDark, controller)),

          const SizedBox(height: 12),

          // Free trial toggle
          Obx(() => _buildFreeTrialToggle(isDark, controller)),

          Obx(() => SizedBox(
              height: controller.selectedPlanIndex.value == 1 ? 16 : 8)),

          // Unlock button
          Obx(() {
            return Column(
              children: [
                if (controller.selectedPlanIndex.value == 1) ...[
                  Text(
                    'Cancel anytime on the App Store',
                    style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                ],
                _buildUnlockButton(controller),
              ],
            );
          }),

          const SizedBox(height: 12),

          // Footer links
          _buildFooterLinks(isDark, controller),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildVisualRepresentation() {
    return Image.asset(
      height: 130,
      'assets/images/paywall-before-after.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 130,
          decoration: BoxDecoration(
            color: FastColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(
              Icons.star,
              size: 48,
              color: FastColors.primary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturesList(bool isDark) {
    final features = [
      {'icon': Icons.record_voice_over, 'text': 'Unlimited live talks'},
      {'icon': Icons.description_outlined, 'text': 'Auto summaries & insights'},
      {'icon': Icons.favorite, 'text': 'Support the developer'},
      {'icon': Icons.verified_user, 'text': 'Remove annoying paywall'},
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              Icon(
                feature['icon'] as IconData,
                size: 24,
                color: FastColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                feature['text'] as String,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
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
        final isYearly = controller.isYearlyPackage(package);

        return Column(
          children: [
            if (index > 0) const SizedBox(height: 12),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? FastColors.primaryLight.withValues(alpha: 0.04)
                        : (isDark ? Colors.grey[800] : Colors.grey[50]),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? FastColors.primary
                          : (isDark ? Colors.grey[600]! : Colors.grey[200]!),
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
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              controller.getPriceText(package),
                              style: TextStyle(
                                fontSize: 15,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isYearly) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: FastColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            controller.getSavingsText(package),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: FastColors.primary,
                          size: 24,
                        )
                      else
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? Colors.white54 : Colors.black26,
                              width: 2,
                            ),
                          ),
                        ),
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

  Widget _buildFreeTrialToggle(bool isDark, PaywallController controller) {
    return AnimatedBuilder(
      animation: controller.switchAnimation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Start with free trial',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            CupertinoSwitch(
              value: controller.freeTrialEnabled.value,
              onChanged: controller.toggleFreeTrial,
              activeTrackColor: FastColors.primary,
            ),
          ],
        );
      },
    );
  }

  Widget _buildUnlockButton(PaywallController controller) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed:
            controller.isPurchasing.value ? null : controller.startSubscription,
        style: ElevatedButton.styleFrom(
          backgroundColor: FastColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: FastColors.primary.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: controller.isPurchasing.value
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Unlock Premium',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildFooterLinks(bool isDark, PaywallController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: controller.restorePurchases,
          child: Text(
            'Restore',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 13,
            ),
          ),
        ),
        TextButton(
          onPressed: controller.openPrivacyPolicy,
          child: Text(
            'Privacy',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 13,
            ),
          ),
        ),
        TextButton(
          onPressed: controller.openTermsOfService,
          child: Text(
            'Terms',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
