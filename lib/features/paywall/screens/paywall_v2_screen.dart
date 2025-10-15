import 'package:faithlock/features/paywall/controllers/paywall_controller.dart';
import 'package:faithlock/features/paywall/widgets/paywall_features.dart';
import 'package:faithlock/features/paywall/widgets/paywall_footer.dart';
import 'package:faithlock/features/paywall/widgets/paywall_plans.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/buttons/fast_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// This paywall screen is follow this structure
// 1. Description
// 2. List of benefits/features
// 3. List of plans
// 4. Footer with terms and links
class PaywallV2Screen extends StatefulWidget {
  const PaywallV2Screen({super.key});

  @override
  State<PaywallV2Screen> createState() => _PaywallV2ScreenState();
}

class _PaywallV2ScreenState extends State<PaywallV2Screen> {
  final PaywallController controller = Get.put(PaywallController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: FastIconButton(
                    icon:
                        const Icon(Icons.close, size: 24, color: Colors.black),
                    onTap: () => Get.back(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              PaywallFeatures(),
              const SizedBox(height: 12),
              PaywallPlans(controller: controller),
              const SizedBox(height: 8),
              _buildActionButtons(),
              const SizedBox(height: 32),
              PaywallFooter(controller: controller),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Obx(() => Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FastButton(
                onTap: controller.isLoading.value
                    ? null
                    : controller.startSubscription,
                icon: const Icon(Icons.star, size: 20, color: Colors.white),
                text:
                    'START ${controller.selectedPlanDetails.trialDays}-DAY FREE TRIAL',
              ),
            ),
          ],
        ));
  }
}
