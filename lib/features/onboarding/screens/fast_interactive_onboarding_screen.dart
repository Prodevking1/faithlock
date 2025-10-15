import 'package:faithlock/features/onboarding/controllers/interactive_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/models/onboarding_step_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FastInteractiveOnboardingScreen extends StatefulWidget {
  const FastInteractiveOnboardingScreen({super.key});

  @override
  State<FastInteractiveOnboardingScreen> createState() =>
      _FastInteractiveOnboardingScreenState();
}

class _FastInteractiveOnboardingScreenState
    extends State<FastInteractiveOnboardingScreen> {
  final FastInteractiveOnboardingController controller =
      Get.put(FastInteractiveOnboardingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar épuré
            _buildCleanTopBar(),

            // Content
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: (index) {
                  if (index >= 0 && index < controller.steps.length) {
                    controller.currentStepIndex.value = index;
                  }
                },
                itemCount: controller.steps.length,
                itemBuilder: (context, index) {
                  return _buildCleanStepPage(controller.steps[index]);
                },
              ),
            ),

            // Bottom section épuré
            _buildCleanBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanTopBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back button simple
          Obx(() => controller.isFirstStep
              ? const SizedBox(width: 40)
              : IconButton(
                  onPressed: controller.previousStep,
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 24,
                )),

          const Spacer(),

          // Progress simple
          Obx(() {
            final progress = (controller.currentStepIndex.value + 1) /
                controller.steps.length;
            return Container(
              width: 100,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            );
          }),

          const Spacer(),

          // Skip simple
          Obx(() => controller.showSkipButton
              ? TextButton(
                  onPressed: controller.skipStep,
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : const SizedBox(width: 40)),
        ],
      ),
    );
  }

  Widget _buildCleanStepPage(OnboardingStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Icon simple
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: step.color ?? Colors.black87,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              step.icon,
              size: 40,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            step.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            step.description,
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Trust indicator simple
          if (step.trustIndicator != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    step.trustIndicator!.icon,
                    size: 16,
                    color: step.color ?? Colors.black87,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    step.trustIndicator!.text,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildCleanBottomSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Obx(() {
        final currentStep = controller.currentStep;
        return Column(
          children: [
            // Step indicators simples
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(controller.steps.length, (index) {
                final isActive = index == controller.currentStepIndex.value;
                final isCompleted = index < controller.currentStepIndex.value;

                return Container(
                  width: isActive ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isCompleted || isActive
                        ? Colors.black87
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            // Main button simple
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => controller.nextStep(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentStep.color ?? Colors.black87,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  controller.buttonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
