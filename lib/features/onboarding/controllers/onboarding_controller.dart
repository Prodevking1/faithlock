import 'package:faithlock/config/app_config.dart';
import 'package:faithlock/features/onboarding/models/onboarding_content.dart';
import 'package:faithlock/services/analytics/analytics_service.dart';
import 'package:faithlock/services/api/supabase/supabase_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple onboarding controller for MVP
class OnboardingController extends GetxController {
  static const String _keyOnboardingCompleted = 'onboarding_completed';

  final AnalyticsService _analyticsService = AnalyticsService();
  final SupabaseAuthService _authService = Get.find<SupabaseAuthService>();
  late final PageController pageController;

  // Observable state
  final RxInt currentStepIndex = 0.obs;
  final RxBool isLoading = false.obs;

  // Onboarding steps
  final steps = OnboardingContent.steps;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    _trackOnboardingStart();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void _trackOnboardingStart() {
    _analyticsService.logEvent(
      'onboarding_started',
      eventProperties: {
        'total_steps': steps.length,
        'platform': GetPlatform.isIOS ? 'ios' : 'android',
      },
    );
  }

  /// Navigate to next step
  Future<void> nextStep() async {
    if (currentStepIndex.value >= steps.length - 1) {
      await completeOnboarding();
      return;
    }

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Animate to next page
    await pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    currentStepIndex.value++;

    _analyticsService.logEvent(
      'onboarding_step_viewed',
      eventProperties: {
        'step_index': currentStepIndex.value,
        'step_title': steps[currentStepIndex.value].title,
      },
    );
  }

  /// Navigate to previous step
  Future<void> previousStep() async {
    if (currentStepIndex.value <= 0) return;

    HapticFeedback.selectionClick();

    await pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    currentStepIndex.value--;
  }

  /// Skip onboarding
  Future<void> skipOnboarding() async {
    _analyticsService.logEvent(
      'onboarding_skipped',
      eventProperties: {
        'step_index': currentStepIndex.value,
      },
    );

    await _markOnboardingCompleted();
    _navigateToNextScreen();
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    _analyticsService.logEvent(
      'onboarding_completed',
      eventProperties: {
        'steps_completed': steps.length,
      },
    );

    // Celebration haptic feedback
    HapticFeedback.mediumImpact();

    await _markOnboardingCompleted();
    _navigateToNextScreen();
  }

  Future<void> _markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, true);
  }

  void _navigateToNextScreen() async {
    // Check if anonymous auth is enabled
    if (AppConfig.appFeatures.enableAnonAuth) {
      await _performAnonymousAuth();
    } else {
      // Navigate to auth screen if anonymous auth is disabled
      Get.offAllNamed('/auth/signup');
    }
  }

  /// Perform anonymous authentication and navigate to home
  Future<void> _performAnonymousAuth() async {
    try {
      isLoading.value = true;
      
      _analyticsService.logEvent(
        'anonymous_auth_started',
        eventProperties: {
          'source': 'onboarding_completion',
        },
      );

      // Sign in anonymously
      final response = await _authService.signInAnonymously();
      
      if (response.user != null) {
        _analyticsService.logEvent(
          'anonymous_auth_success',
          eventProperties: {
            'user_id': response.user!.id,
            'source': 'onboarding_completion',
          },
        );
        
        // Navigate to home screen
        Get.offAllNamed('/home');
      } else {
        throw Exception('Anonymous authentication failed');
      }
    } catch (e) {
      _analyticsService.logEvent(
        'anonymous_auth_failed',
        eventProperties: {
          'error': e.toString(),
          'source': 'onboarding_completion',
        },
      );
      
      // Fallback to auth screen on error
      Get.offAllNamed('/auth/signup');
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate directly to e-learning app (alternative flow)
  void navigateToELearning() {
    // Import will be added when this method is used
    // Get.offAll(() => ELearningApp.fromOnboarding());
    Get.offAllNamed('/e-learning');
  }

  /// Check if this is the last step
  bool get isLastStep => currentStepIndex.value >= steps.length - 1;

  /// Check if this is the first step
  bool get isFirstStep => currentStepIndex.value <= 0;

  /// Get appropriate button text
  String get buttonText => isLastStep ? 'startFreeTrial'.tr : 'continue'.tr;

  /// Check if onboarding was previously completed
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  /// Reset onboarding state (for testing)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyOnboardingCompleted);
  }
}
