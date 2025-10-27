import 'package:faithlock/services/analytics/posthog/export.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Debug screen for testing PostHog analytics implementation
class AnalyticsTestScreen extends StatelessWidget {
  const AnalyticsTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Test'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            _buildStatusCard(),
            const SizedBox(height: 20),

            // Test All Button
            _buildTestAllButton(),
            const SizedBox(height: 20),

            // Onboarding Tests
            _buildSectionHeader('Onboarding Analytics'),
            const SizedBox(height: 12),
            _buildTestButton(
              'Test Onboarding Flow',
              Icons.school,
              Colors.blue,
              _testOnboardingFlow,
            ),
            const SizedBox(height: 8),
            _buildTestButton(
              'Test User Properties',
              Icons.person,
              Colors.cyan,
              _testUserProperties,
            ),
            const SizedBox(height: 8),
            _buildTestButton(
              'Test Feature Adoption',
              Icons.star,
              Colors.amber,
              _testFeatureAdoption,
            ),
            const SizedBox(height: 20),

            // Paywall Tests (CRITIQUES SEULEMENT)
            _buildSectionHeader('Paywall Analytics (Critiques)'),
            const SizedBox(height: 12),
            _buildTestButton(
              'Test Paywall View ✅',
              Icons.visibility,
              Colors.purple,
              _testPaywallView,
            ),
            const SizedBox(height: 8),
            _buildTestButton(
              'Test Plan Selection ⚠️',
              Icons.card_membership,
              Colors.indigo,
              _testPlanSelection,
            ),
            const SizedBox(height: 8),
            _buildTestButton(
              'Test Purchase Success ✅',
              Icons.shopping_cart,
              Colors.green,
              _testPurchaseSuccess,
            ),
            const SizedBox(height: 8),
            _buildTestButton(
              'Test Purchase Failure ✅',
              Icons.error,
              Colors.red,
              _testPurchaseFailure,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final analytics = PostHogService.instance;
    final stats = analytics.getStats();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  stats['initialized'] ? Icons.check_circle : Icons.cancel,
                  color: stats['initialized'] ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                const Text(
                  'PostHog Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusRow('Initialized', stats['initialized'].toString()),
            _buildStatusRow('Enabled', stats['enabled'].toString()),
            _buildStatusRow(
                'Modules Loaded', stats['modules_loaded'].toString()),
            _buildStatusRow(
                'Session ID', stats['session_id']?.toString() ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTestButton(
    String label,
    IconData icon,
    Color color,
    Future<void> Function() onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: () async {
        try {
          await onPressed();
          Get.snackbar(
            'Success',
            '$label completed',
            backgroundColor: Colors.green.withValues(alpha: 0.1),
            colorText: Colors.green[800],
            icon: const Icon(Icons.check_circle, color: Colors.green),
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            e.toString(),
            backgroundColor: Colors.red.withValues(alpha: 0.1),
            colorText: Colors.red[800],
            icon: const Icon(Icons.error, color: Colors.red),
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        }
      },
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildTestAllButton() {
    return ElevatedButton(
      onPressed: () async {
        try {
          await _testAllAnalytics();
          Get.snackbar(
            'Complete! 🎉',
            'All analytics tests completed successfully',
            backgroundColor: Colors.green.withValues(alpha: 0.1),
            colorText: Colors.green[800],
            icon: const Icon(Icons.check_circle, color: Colors.green),
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            e.toString(),
            backgroundColor: Colors.red.withValues(alpha: 0.1),
            colorText: Colors.red[800],
            icon: const Icon(Icons.error, color: Colors.red),
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.play_arrow, size: 28),
          SizedBox(width: 8),
          Text(
            'TEST ALL ANALYTICS',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Test All Analytics
  Future<void> _testAllAnalytics() async {
    final analytics = PostHogService.instance;
    if (!analytics.isReady) {
      throw Exception('PostHog not initialized');
    }

    // Test Onboarding
    await _testOnboardingFlow();
    await Future.delayed(const Duration(milliseconds: 500));

    await _testUserProperties();
    await Future.delayed(const Duration(milliseconds: 500));

    await _testFeatureAdoption();
    await Future.delayed(const Duration(milliseconds: 500));

    // Test Paywall (CRITIQUES SEULEMENT)
    await _testPaywallView();
    await Future.delayed(const Duration(milliseconds: 500));

    await _testPlanSelection();
    await Future.delayed(const Duration(milliseconds: 500));

    await _testPurchaseSuccess();
    await Future.delayed(const Duration(milliseconds: 500));

    await _testPurchaseFailure();

    debugPrint('✅ All analytics tests completed (critiques uniquement)');
  }

  // Onboarding Tests
  Future<void> _testOnboardingFlow() async {
    final analytics = PostHogService.instance;

    // Start onboarding
    await analytics.onboarding.startOnboarding();
    debugPrint('📝 Onboarding started');

    // Simulate 9 steps with metadata
    for (int i = 1; i <= 9; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      await analytics.onboarding.trackStepEntry(
        stepNumber: i,
        stepName: _getStepName(i),
        metadata: _getTestMetadata(i),
      );
      debugPrint('➡️  Step $i entered: ${_getStepName(i)}');

      await Future.delayed(const Duration(milliseconds: 300));
      await analytics.onboarding.trackStepExit(
        stepNumber: i,
        stepName: _getStepName(i),
        metadata: _getTestMetadata(i),
      );
      debugPrint('✅ Step $i completed');
    }

    // Complete onboarding
    await analytics.onboarding.trackOnboardingComplete();
    debugPrint('🎉 Onboarding completed');
  }

  Future<void> _testUserProperties() async {
    final analytics = PostHogService.instance;

    await analytics.onboarding.setUserProperties({
      'user_name': 'Test User',
      'user_age': 25,
      'hours_per_day': 5.0,
      'prayer_frequency': 7,
      'selected_categories': 'faith,strength,wisdom',
      'intensity_level': 'Balanced',
      'covenant_accepted': true,
    });

    debugPrint('👤 User properties set');
  }

  Future<void> _testFeatureAdoption() async {
    final analytics = PostHogService.instance;

    await analytics.onboarding.trackFeatureAdoption(
      featureName: 'verse_categories',
      value: 3,
    );

    await analytics.onboarding.trackFeatureAdoption(
      featureName: 'apps_selection',
      value: 5,
    );

    await analytics.onboarding.trackFeatureAdoption(
      featureName: 'schedules',
      value: 3,
    );

    debugPrint('⭐ Feature adoption tracked');
  }

  // Paywall Tests
  Future<void> _testPaywallView() async {
    final analytics = PostHogService.instance;

    await analytics.paywall.trackPaywallViewed(
      source: 'onboarding',
      placementId: 'test_placement',
      metadata: {
        'test_mode': true,
        'test_timestamp': DateTime.now().toIso8601String(),
      },
    );

    debugPrint('👁️  Paywall viewed');
  }

  Future<void> _testPlanSelection() async {
    final analytics = PostHogService.instance;

    await analytics.paywall.trackPlanSelected(
      planType: 'yearly',
      planId: 'test_yearly_plan',
      price: 49.99,
      currency: 'USD',
      trialPeriod: '7 days',
      metadata: {'test_mode': true},
    );

    debugPrint('💳 Plan selected');
  }

  Future<void> _testPurchaseSuccess() async {
    final analytics = PostHogService.instance;

    // ❌ trackPurchaseStarted désactivé - événement redondant

    // Purchase completed (événement critique)
    await analytics.paywall.trackPurchaseCompleted(
      planType: 'yearly',
      planId: 'test_yearly_plan',
      revenue: 49.99,
      currency: 'USD',
      isTrialStart: true,
      isRestore: false,
      metadata: {'test_mode': true},
    );
    debugPrint('✅ Purchase completed (avec \$revenue event tracking)');
  }

  Future<void> _testPurchaseFailure() async {
    final analytics = PostHogService.instance;

    await analytics.paywall.trackPurchaseFailed(
      planType: 'monthly',
      planId: 'test_monthly_plan',
      reason: 'User cancelled',
      errorCode: 'CANCELLED',
      metadata: {'test_mode': true},
    );

    debugPrint('❌ Purchase failure tracked');
  }

  // ❌ TESTS DÉSACTIVÉS - Événements non-critiques
  //
  // _testPromoCode() - Désactivé (rarement utilisé)
  // _testPaywallDismiss() - Désactivé (calculable: bounce_rate = 1 - completed/viewed)
  // _testPurchaseStarted() - Désactivé (redondant avec completed + failed)

  String _getStepName(int step) {
    switch (step) {
      case 1:
        return 'Divine Revelation';
      case 2:
        return 'Name Capture';
      case 3:
        return 'Self Confrontation';
      case 4:
        return 'Eternal Warfare';
      case 5:
        return 'Call to Covenant';
      case 6:
        return 'Armor Configuration';
      case 7:
        return 'Final Encouragement';
      case 8:
        return 'Testimonials';
      case 9:
        return 'Screen Time Permission';
      default:
        return 'Unknown Step';
    }
  }

  /// Get test metadata for each step
  Map<String, dynamic>? _getTestMetadata(int step) {
    switch (step) {
      case 2: // Name Capture
        return {
          'user_name_provided': true,
          'user_age': 25,
        };

      case 3: // Self Confrontation
        return {
          'hours_per_day': 5.0,
          'hours_category': 'heavy_usage',
        };

      case 4: // Eternal Warfare
        return {
          'prayer_times_per_week': 7,
          'prayer_frequency_category': 'daily_plus',
        };

      case 5: // Call to Covenant
        return {
          'covenant_accepted': true,
        };

      case 6: // Armor Configuration
        return {
          'schedules_configured': true,
        };

      case 7: // Final Encouragement
        return {
          'verse_categories_count': 3,
          'verse_categories': 'faith,strength,wisdom',
          'selected_apps_count': 5,
          'intensity_level': 'Balanced',
        };

      case 8: // Testimonials
        return {
          'viewed_testimonials': true,
        };

      case 9: // Screen Time Permission
        return {
          'screen_time_permission_step': true,
        };

      default:
        return null;
    }
  }
}
