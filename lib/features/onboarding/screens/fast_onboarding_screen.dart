import 'package:faithlock/features/onboarding/controllers/onboarding_controller.dart';
import 'package:faithlock/features/onboarding/models/onboarding_step_model.dart';
import 'package:faithlock/features/onboarding/widgets/cta_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Simple onboarding screen for MVP
class FastOnboardingScreen extends StatefulWidget {
  FastOnboardingScreen({super.key});

  @override
  State<FastOnboardingScreen> createState() => _FastOnboardingScreenState();
}

class _FastOnboardingScreenState extends State<FastOnboardingScreen> {
  final OnboardingController controller = Get.put(OnboardingController());

  @override
  Widget build(BuildContext context) {
    final bool isIOS = GetPlatform.isIOS;

    return Scaffold(
      backgroundColor: isIOS ? CupertinoColors.systemBackground : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            _buildTopSection(context, isIOS),

            // Main content
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: (index) {
                  controller.currentStepIndex.value = index;
                },
                itemCount: controller.steps.length,
                itemBuilder: (context, index) {
                  return _buildStepPage(controller.steps[index], isIOS);
                },
              ),
            ),

            // Bottom section
            _buildBottomSection(context, isIOS),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context, bool isIOS) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          Obx(
            () => controller.isFirstStep
                ? const SizedBox(width: 60)
                : GestureDetector(
                    onTap: controller.previousStep,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isIOS
                            ? CupertinoColors.systemGrey6
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        isIOS ? CupertinoIcons.chevron_left : Icons.arrow_back,
                        size: 20,
                        color: isIOS
                            ? CupertinoColors.systemGrey
                            : Colors.grey[600],
                      ),
                    ),
                  ),
          ),

          // Progress text instead of skip to reduce abandonment
          Obx(() => Text(
                '${controller.currentStepIndex.value + 1} ${'onboardingStepOf'.tr} ${controller.steps.length}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isIOS ? CupertinoColors.label : Colors.grey[800],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildStepPage(OnboardingStep step, bool isIOS) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon with pulse effect
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 2),
            tween: Tween(begin: 0.95, end: 1.05),
            curve: Curves.easeInOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        step.color ??
                            (isIOS ? CupertinoColors.systemBlue : Colors.blue),
                        (step.color ??
                                (isIOS
                                    ? CupertinoColors.systemBlue
                                    : Colors.blue))
                            .withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(70),
                    boxShadow: [
                      BoxShadow(
                        color: (step.color ??
                                (isIOS
                                    ? CupertinoColors.systemBlue
                                    : Colors.blue))
                            .withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    step.icon,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
              );
            },
            onEnd: () {
              // Loop animation
              setState(() {});
            },
          ),

          const SizedBox(height: 48),

          // Title with emphasis
          Text(
            step.title,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isIOS ? CupertinoColors.label : Colors.grey[900],
              letterSpacing: -1,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Description with better readability
          Text(
            step.description,
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: isIOS ? CupertinoColors.secondaryLabel : Colors.grey[700],
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Trust indicators specific to each step
          _buildStepTrustIndicators(step, isIOS),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, bool isIOS) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 100),
            tween: Tween(begin: 0.95, end: 1.0),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: SizedBox(
                  width: double.infinity,
                  child: Obx(() => OnboardingCTAButton(
                    onPressed: controller.nextStep,
                    text: controller.isLastStep
                        ? (controller.isLoading.value ? 'Connexion...' : 'startFreeTrial'.tr)
                        : 'continue'.tr,
                    isLoading: controller.isLoading.value,
                  )),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Step indicators with progress
          Obx(() => Stack(
                alignment: Alignment.center,
                children: [
                  // Progress line
                  Container(
                    height: 2,
                    width: 100,
                    decoration: BoxDecoration(
                      color: isIOS
                          ? CupertinoColors.systemGrey5
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  // Active progress
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 2,
                    width: 100 *
                        ((controller.currentStepIndex.value + 1) /
                            controller.steps.length),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          isIOS ? CupertinoColors.systemBlue : Colors.blue,
                          isIOS ? CupertinoColors.systemPurple : Colors.purple,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      controller.steps.length,
                      (index) => _buildStepDot(
                        index,
                        controller.currentStepIndex.value,
                        isIOS,
                      ),
                    ),
                  ),
                ],
              ))
        ],
      ),
    );
  }

  Widget _buildStepDot(int index, int currentIndex, bool isIOS) {
    final isActive = index == currentIndex;
    final isCompleted = index < currentIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isCompleted || isActive ? 12 : 8,
      height: isCompleted || isActive ? 12 : 8,
      decoration: BoxDecoration(
        color: isCompleted || isActive
            ? (isIOS ? CupertinoColors.systemBlue : Colors.blue)
            : (isIOS ? CupertinoColors.systemGrey4 : Colors.grey[300]),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _buildStepTrustIndicators(OnboardingStep step, bool isIOS) {
    if (step.trustIndicator == null) {
      return const SizedBox.shrink();
    }

    final trustIndicator = step.trustIndicator!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: trustIndicator.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trustIndicator.icon,
            size: 16,
            color: trustIndicator.color,
          ),
          const SizedBox(width: 8),
          Text(
            trustIndicator.text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: trustIndicator.color,
            ),
          ),
        ],
      ),
    );
  }
}
