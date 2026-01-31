import 'package:faithlock/features/onboarding/screens/rating_request_screen.dart';
import 'package:faithlock/services/analytics/posthog/config/event_templates.dart';
import 'package:faithlock/services/analytics/posthog/posthog_service.dart';
import 'package:faithlock/services/storage/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';

class RateAppService {
  static const String _keyHasRated = 'has_rated_app';
  static const String _keyLastPrompt = 'last_rate_prompt_date';
  static const String _keyOnboardingPromptShown =
      'onboarding_rate_prompt_shown';
  static const String _keyFirstPrayerPromptShown =
      'first_prayer_rate_prompt_shown';

  final PreferencesService _storage = PreferencesService();
  final InAppReview _inAppReview = InAppReview.instance;
  final PostHogService _analytics = PostHogService.instance;

  Future<bool> hasRatedApp() async {
    return await _storage.readBool(_keyHasRated) ?? false;
  }

  Future<bool> shouldShowOnboardingPrompt() async {
    final shown = await _storage.readBool(_keyOnboardingPromptShown) ?? false;
    return !shown;
  }

  Future<bool> shouldShowFirstPrayerPrompt() async {
    final shown = await _storage.readBool(_keyFirstPrayerPromptShown) ?? false;
    return !shown;
  }

  Future<void> showOnboardingPrompt({bool useOnboardingWrapper = false}) async {
    if (!await shouldShowOnboardingPrompt()) return;

    await _storage.writeBool(_keyOnboardingPromptShown, true);
    await _storage.writeString(
        _keyLastPrompt, DateTime.now().toIso8601String());

    await Get.to(
      () => RatingRequestScreen(
        title: 'Ready to help others? 💛',
        message:
            'If you\'re excited about your spiritual journey with FaithLock, help others discover it too!',
        useOnboardingWrapper: useOnboardingWrapper,
        onRate: () async {
          if (_analytics.isReady) {
            await _analytics.events.track(
              PostHogEventType.rateIntentShown,
              {
                'source': 'onboarding',
                'timestamp': DateTime.now().toIso8601String(),
              },
            );
          }
          await _rateApp();
          await Future.delayed(const Duration(seconds: 1));
          Get.back();
        },
        onSkip: () {
          if (_analytics.isReady) {
            _analytics.events.track(
              PostHogEventType.rateIntentSkipped,
              {
                'source': 'onboarding',
                'timestamp': DateTime.now().toIso8601String(),
              },
            );
          }
          Get.back();
        },
      ),
    );
  }

  Future<void> showFirstPrayerPrompt() async {
    if (!await shouldShowFirstPrayerPrompt()) return;

    await _storage.writeBool(_keyFirstPrayerPromptShown, true);
    await _storage.writeString(
        _keyLastPrompt, DateTime.now().toIso8601String());

    await Future.delayed(const Duration(seconds: 2));

    await Get.to(
      () => RatingRequestScreen(
        title: 'Amazing! 🙏✨',
        message:
            'You just completed your first prayer unlock! If FaithLock is helping you, would you share your story?',
        onRate: () async {
          if (_analytics.isReady) {
            await _analytics.events.track(
              PostHogEventType.rateIntentShown,
              {
                'source': 'first_prayer',
                'timestamp': DateTime.now().toIso8601String(),
              },
            );
          }
          await _rateApp();
          await Future.delayed(const Duration(milliseconds: 500));
          Get.back();
        },
        onSkip: () {
          if (_analytics.isReady) {
            _analytics.events.track(
              PostHogEventType.rateIntentSkipped,
              {
                'source': 'first_prayer',
                'timestamp': DateTime.now().toIso8601String(),
              },
            );
          }
          Get.back();
        },
      ),
    );
  }

  Future<void> showRatingOnProfile() async {
    try {
      if (_analytics.isReady) {
        await _analytics.events.track(
          PostHogEventType.rateIntentShown,
          {
            'source': 'profile',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      }
      await _rateApp();
      Get.back();
    } catch (e) {}
  }

  Future<void> _rateApp() async {
    try {
      debugPrint('🔔 Requesting in-app review...');

      // Request in-app review (works on TestFlight if quota not exhausted)
      await _inAppReview.requestReview();

      await _storage.writeBool(_keyHasRated, true);
      debugPrint('✅ In-app review requested');

      if (_analytics.isReady) {
        await _analytics.events.track(
          PostHogEventType.rateCompleted,
          {
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      }
    } catch (e) {
      debugPrint('❌ Error showing rating: $e');
    }
  }
}
