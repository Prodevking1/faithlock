import 'package:faithlock/features/paywall/controllers/paywall_controller.dart';

import 'package:faithlock/features/paywall/widgets/paywall_features.dart';
import 'package:faithlock/features/paywall/widgets/paywall_footer.dart';
import 'package:faithlock/features/paywall/widgets/paywall_header.dart';
import 'package:faithlock/features/paywall/widgets/paywall_plans.dart';
import 'package:faithlock/features/paywall/widgets/paywall_timeline.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final PaywallController controller = Get.put(PaywallController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header with close button and app branding
            PaywallHeader(controller: controller),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Premium features showcase
                    PaywallFeatures(),

                    const SizedBox(height: 32),

                    // Subscription timeline
                    PaywallTimeline(controller: controller),

                    const SizedBox(height: 32),

                    // Subscription plans
                    PaywallPlans(controller: controller),

                    const SizedBox(height: 24),

                    // Start trial button and restore purchases
                    _buildActionButtons(),

                    const SizedBox(height: 24),

                    // Footer with terms and links
                    PaywallFooter(controller: controller),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Obx(() => Column(
          children: [
            // Main CTA button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.startSubscription,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'START ${controller.selectedPlanDetails.trialDays}-DAY FREE TRIAL',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Restore purchases button
            TextButton(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.restorePurchases,
              child: Text(
                'Restore Purchases',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ));
  }
}
