import 'dart:convert';
import 'package:faithlock/features/faithlock/services/screen_time_service.dart';
import 'package:faithlock/services/storage/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Controller for managing Scripture Lock onboarding flow and progress
class ScriptureOnboardingController extends GetxController {
  final StorageService _storage = StorageService();

  // Storage keys
  static const String _keyOnboardingComplete = 'scripture_onboarding_complete';
  static const String _keyUserName = 'user_name';
  static const String _keyUserAge = 'user_age';
  static const String _keyUserHoursPerDay = 'user_hours_per_day';
  static const String _keyPrayerFrequency = 'prayer_frequency_per_week';
  static const String _key30DayGoals = 'thirty_day_goals';
  static const String _keySelectedVerseCategories = 'selected_verse_categories';
  static const String _keySelectedApps = 'selected_problem_apps';
  static const String _keyIntensityLevel = 'scripture_intensity_level';
  static const String _keySacredCovenantAccepted = 'sacred_covenant_accepted';
  static const String _keySchedules = 'onboarding_schedules';

  // Observable state
  final RxInt currentStep = RxInt(5);
  final RxString userName = RxString('User');
  final RxInt userAge = RxInt(25);
  final RxDouble hoursPerDay = RxDouble(5.0);
  final RxInt prayerTimesPerWeek = RxInt(0);
  final RxList<String> thirtyDayGoals = <String>[].obs;
  final RxList<String> selectedCategories = <String>[].obs;
  final RxList<String> selectedApps = <String>[].obs;
  final RxString intensityLevel = RxString('Balanced');
  final RxBool covenantAccepted = RxBool(false);

  @override
  void onInit() {
    super.onInit();
    loadProgress();
    _initializeDefaultSchedules();
  }

  /// Initialize default schedules if none exist
  Future<void> _initializeDefaultSchedules() async {
    final existingSchedules = await _storage.readString(_keySchedules);

    // Only initialize if no schedules exist
    if (existingSchedules == null || existingSchedules.isEmpty) {
      final defaultSchedules = [
        {
          'name': 'Morning Focus',
          'icon': '🌅',
          'startHour': 8,
          'startMinute': 0,
          'endHour': 10,
          'endMinute': 0,
          'enabled': true,
        },
        {
          'name': 'Afternoon Lock',
          'icon': '☀️',
          'startHour': 12,
          'startMinute': 0,
          'endHour': 16,
          'endMinute': 0,
          'enabled': true,
        },
        {
          'name': 'Night Protection',
          'icon': '🌙',
          'startHour': 20,
          'startMinute': 0,
          'endHour': 23,
          'endMinute': 0,
          'enabled': true,
        },
      ];

      await _storage.writeString(_keySchedules, jsonEncode(defaultSchedules));
      debugPrint('✅ Default schedules initialized');
    }
  }

  /// Load any saved progress
  Future<void> loadProgress() async {
    final savedHoursStr = await _storage.readString(_keyUserHoursPerDay);
    if (savedHoursStr != null) {
      hoursPerDay.value = double.tryParse(savedHoursStr) ?? 0.0;
    }
  }

  /// Check if onboarding has been completed
  Future<bool> isOnboardingComplete() async {
    final complete = await _storage.readBool(_keyOnboardingComplete);
    return complete ?? false;
  }

  /// Move to next step (including step 1.5)
  void nextStep() {
    // Step progression: 1 → 1.5 (2) → 2 (3) → 3 (4) → 4 (5) → 5 (6) → 6 (7) → Testimonials (8) → Screen Time (9)
    if (currentStep.value < 9) {
      currentStep.value++;
    }
  }

  /// Move to previous step (if needed)
  void previousStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
    }
  }

  /// Save user name from Step 1.5
  Future<void> saveUserName(String name) async {
    userName.value = name;
    await _storage.writeString(_keyUserName, name);
  }

  /// Save user age from Step 1.5
  Future<void> saveUserAge(int age) async {
    userAge.value = age;
    await _storage.writeString(_keyUserAge, age.toString());
  }

  /// Save hours per day from Step 2
  Future<void> saveHoursPerDay(double hours) async {
    hoursPerDay.value = hours;
    await _storage.writeString(_keyUserHoursPerDay, hours.toString());
  }

  /// Save prayer frequency from Step 2B
  Future<void> savePrayerFrequency(int times) async {
    prayerTimesPerWeek.value = times;
    await _storage.writeString(_keyPrayerFrequency, times.toString());
  }

  /// Save 30-day goals from Step 4B
  Future<void> save30DayGoals(List<String> goals) async {
    thirtyDayGoals.value = goals;
    await _storage.writeString(_key30DayGoals, goals.join(','));
  }

  /// Calculate time statistics
  Map<String, dynamic> calculateTimeStats() {
    final hours = hoursPerDay.value;
    final hoursPerWeek = hours * 7;
    final hoursPerYear = hours * 365;
    final daysPerYear = hoursPerYear / 24;

    final fullDays = daysPerYear.floor();
    final remainingHours = ((daysPerYear - fullDays) * 24).round();

    return {
      'hoursPerDay': hours,
      'hoursPerWeek': hoursPerWeek,
      'hoursPerYear': hoursPerYear,
      'fullDays': fullDays,
      'remainingHours': remainingHours,
      'formatted': '$fullDays days and $remainingHours hours',
    };
  }

  /// Calculate life statistics based on age and phone usage
  Map<String, dynamic> calculateLifeStats() {
    final age = userAge.value;
    final hours = hoursPerDay.value;

    // Average life expectancy
    const int averageLifeExpectancy = 80;
    final int yearsRemaining = averageLifeExpectancy - age;
    final int totalDaysInLife = averageLifeExpectancy * 365;
    final int daysLived = age * 365;
    final int daysRemaining = yearsRemaining * 365;

    // Calculate wasted days per year and lifetime
    final double daysWastedPerYear = (hours * 365) / 24;
    final double daysWastedInFuture = daysWastedPerYear * yearsRemaining;
    final double percentageOfLifeWasted =
        (daysWastedInFuture / totalDaysInLife) * 100;

    // Calculate days saved with 2 weeks of using the app (80% reduction in usage)
    final double hoursAfterApp = hours * 0.2; // 80% reduction
    final double daysSavedPerYear = ((hours - hoursAfterApp) * 365) / 24;
    final double daysSavedIn2Weeks = (daysSavedPerYear / 365) * 14;

    return {
      'age': age,
      'averageLifeExpectancy': averageLifeExpectancy,
      'yearsRemaining': yearsRemaining,
      'totalDaysInLife': totalDaysInLife,
      'daysLived': daysLived,
      'daysRemaining': daysRemaining,
      'daysWastedPerYear': daysWastedPerYear.floor(),
      'daysWastedInFuture': daysWastedInFuture.floor(),
      'percentageOfLifeWasted': percentageOfLifeWasted,
      'daysSavedPerYear': daysSavedPerYear.floor(),
      'daysSavedIn2Weeks': daysSavedIn2Weeks,
    };
  }

  /// Save selected verse categories from Step 7
  Future<void> saveVerseCategories(List<String> categories) async {
    selectedCategories.value = categories;
    await _storage.writeString(
      _keySelectedVerseCategories,
      categories.join(','),
    );
  }

  /// Save selected apps from Step 7
  Future<void> saveSelectedApps(List<String> apps) async {
    selectedApps.value = apps;
    await _storage.writeString(_keySelectedApps, apps.join(','));
  }

  /// Save intensity level from Step 7
  Future<void> saveIntensityLevel(String level) async {
    intensityLevel.value = level;
    await _storage.writeString(_keyIntensityLevel, level);
  }

  /// Save covenant acceptance from Step 6
  Future<void> acceptCovenant(bool accepted) async {
    covenantAccepted.value = accepted;
    await _storage.writeBool(_keySacredCovenantAccepted, accepted);
  }

  /// Save schedules from Step 5 (Armor Configuration)
  Future<void> saveSchedules(List<Map<String, dynamic>> schedules) async {
    // Convert TimeOfDay to string format for storage
    final schedulesData = schedules.map((schedule) {
      final start = schedule['start'] as TimeOfDay;
      final end = schedule['end'] as TimeOfDay;

      return {
        'name': schedule['name'],
        'icon': schedule['icon'],
        'startHour': start.hour,
        'startMinute': start.minute,
        'endHour': end.hour,
        'endMinute': end.minute,
        'enabled': schedule['enabled'],
      };
    }).toList();

    await _storage.writeString(_keySchedules, jsonEncode(schedulesData));

    // Setup native DeviceActivity schedules
    try {
      final screenTimeService = Get.find<ScreenTimeService>();
      await screenTimeService.setupSchedules(schedulesData);
    } catch (e) {
      print('⚠️ Failed to setup native schedules: $e');
      // Don't throw - allow onboarding to continue
    }
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    await _storage.writeBool(_keyOnboardingComplete, true);
  }

  /// Reset onboarding (for testing)
  Future<void> resetOnboarding() async {
    await _storage.writeBool(_keyOnboardingComplete, false);
    currentStep.value = 1;
    hoursPerDay.value = 0.0;
    selectedCategories.clear();
    selectedApps.clear();
    intensityLevel.value = 'Balanced';
    covenantAccepted.value = false;
  }
}
