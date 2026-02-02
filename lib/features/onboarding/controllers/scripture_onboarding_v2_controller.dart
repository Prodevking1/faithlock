import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/services/analytics/posthog/export.dart';
import 'package:faithlock/services/storage/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// V2 Onboarding Controller - Independent flow with optimized step sequence
/// Extends V1 to reuse data persistence + calculation methods
class ScriptureOnboardingV2Controller extends ScriptureOnboardingController {
  // V2 storage keys
  static const String _keyCommitmentLevel = 'v2_commitment_level';
  static const String _keyDailyVerseFrequency = 'v2_daily_verse_frequency';
  static const String _keyDailyVerseTimes = 'v2_daily_verse_times';

  @override
  int get totalSteps => 11;

  // V2 state
  final RxString commitmentLevel = RxString('');
  final RxInt dailyVerseFrequency = RxInt(1);
  final RxList<TimeOfDay> dailyVerseTimes = <TimeOfDay>[].obs;

  final StorageService _v2Storage = StorageService();

  /// V2 step names for analytics
  String getV2StepName(int step) {
    switch (step) {
      case 1:
        return 'Welcome';
      case 2:
        return 'Name Capture';
      case 3:
        return 'Divine Revelation';
      case 4:
        return 'Self Confrontation V2';
      case 5:
        return 'Goals Selection';
      case 6:
        return 'Fingerprint Seal';
      case 7:
        return 'Screen Time Permission';
      case 8:
        return 'Daily Verses Setup';
      case 9:
        return 'Summary V2';
      case 10:
        return 'Commitment Level';
      case 11:
        return 'Free For You';
      default:
        return 'Unknown Step';
    }
  }

  final PostHogService _v2Analytics = PostHogService.instance;

  /// Override nextStep for V2 flow with proper analytics tracking
  @override
  void nextStep() async {
    // Track step exit before moving
    if (_v2Analytics.isReady) {
      try {
        final metadata = _getV2StepMetadata(currentStep.value);
        await _v2Analytics.onboarding.trackStepExit(
          stepNumber: currentStep.value,
          stepName: getV2StepName(currentStep.value),
          metadata: metadata,
        );
      } catch (e) {
        debugPrint('Failed to track V2 step exit: $e');
      }
    }

    if (currentStep.value < totalSteps) {
      currentStep.value++;

      // Track new step entry
      if (_v2Analytics.isReady) {
        try {
          await _v2Analytics.onboarding.trackStepEntry(
            stepNumber: currentStep.value,
            stepName: getV2StepName(currentStep.value),
          );
        } catch (e) {
          debugPrint('Failed to track V2 step entry: $e');
        }
      }
    }
  }

  /// Get V2-specific metadata for each step
  Map<String, dynamic>? _getV2StepMetadata(int step) {
    switch (step) {
      case 2: // Name Capture
        return {
          if (userName.value.isNotEmpty) 'user_name_provided': true,
          if (userAge.value > 0) 'user_age': userAge.value,
        };
      case 4: // Self Confrontation V2
        return {
          'hours_per_day': hoursPerDay.value,
          'prayer_times_per_week': prayerTimesPerWeek.value,
        };
      case 5: // Goals Selection
        return {
          'goals_count': thirtyDayGoals.length,
          'goals': thirtyDayGoals.toList(),
        };
      case 8: // Daily Verses Setup
        return {
          'verse_frequency': dailyVerseFrequency.value,
          'verse_times_count': dailyVerseTimes.length,
        };
      case 10: // Commitment Level
        return {
          'commitment_level': commitmentLevel.value,
        };
      default:
        return null;
    }
  }

  /// Save commitment level
  Future<void> saveCommitmentLevel(String level) async {
    commitmentLevel.value = level;
    await _v2Storage.writeString(_keyCommitmentLevel, level);
  }

  /// Save daily verse frequency (1, 2, or 3 times per day)
  Future<void> saveDailyVerseFrequency(int frequency) async {
    dailyVerseFrequency.value = frequency;
    await _v2Storage.writeString(
        _keyDailyVerseFrequency, frequency.toString());
  }

  /// Save daily verse notification times
  Future<void> saveDailyVerseTimes(List<TimeOfDay> times) async {
    dailyVerseTimes.value = times;
    final timesStr = times
        .map((t) => '${t.hour}:${t.minute}')
        .join(',');
    await _v2Storage.writeString(_keyDailyVerseTimes, timesStr);
  }

  /// Calculate projected improvement stats for Summary V2
  Map<String, dynamic> calculateProjection() {
    final hours = hoursPerDay.value;
    final prayer = prayerTimesPerWeek.value;

    // Week 1 projections (30% reduction)
    final week1Hours = hours * 0.7;
    final week1Prayer = prayer < 7 ? (prayer + 3).clamp(0, 14) : prayer + 2;

    // Week 2 projections (50% reduction)
    final week2Hours = hours * 0.5;
    final week2Prayer = prayer < 7 ? (prayer + 5).clamp(0, 21) : prayer + 4;

    // Month 1 projections (70% reduction)
    final month1Hours = hours * 0.3;
    final month1Prayer = prayer < 7 ? 7 : prayer + 7; // at least daily

    // Time reclaimed
    final dailyReclaimed = hours - month1Hours;
    final yearlyReclaimedDays = (dailyReclaimed * 365) / 24;

    return {
      'currentHours': hours,
      'currentPrayer': prayer,
      'week1Hours': week1Hours,
      'week1Prayer': week1Prayer,
      'week2Hours': week2Hours,
      'week2Prayer': week2Prayer,
      'month1Hours': month1Hours,
      'month1Prayer': month1Prayer,
      'dailyReclaimed': dailyReclaimed,
      'yearlyReclaimedDays': yearlyReclaimedDays.floor(),
    };
  }

  /// Get personalized target date (30 days from now)
  DateTime get targetDate => DateTime.now().add(const Duration(days: 30));

  /// Format target date
  String get formattedTargetDate {
    final months = [
      'january', 'february', 'march', 'april', 'may', 'june',
      'july', 'august', 'september', 'october', 'november', 'december'
    ];
    final d = targetDate;
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
