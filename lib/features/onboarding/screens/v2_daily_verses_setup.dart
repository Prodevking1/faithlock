import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_v2_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/services/notifications/daily_verse_notification_service.dart';
import 'package:faithlock/services/notifications/local_notification_service.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/mascot/judah_mascot.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// V2 Daily Verses Setup - NEW screen
/// Replaces notification permission step with a value-driven verse delivery setup
/// Judah pointing + clock icon, frequency chips, time pickers, permission request
class V2DailyVersesSetup extends StatefulWidget {
  final VoidCallback onComplete;

  const V2DailyVersesSetup({
    super.key,
    required this.onComplete,
  });

  @override
  State<V2DailyVersesSetup> createState() => _V2DailyVersesSetupState();
}

class _V2DailyVersesSetupState extends State<V2DailyVersesSetup> {
  final controller =
      Get.find<ScriptureOnboardingController>() as ScriptureOnboardingV2Controller;

  bool _showContent = false;
  int _selectedFrequency = 1; // 1, 2, or 3 times per day

  // Default times based on frequency
  final List<TimeOfDay> _selectedTimes = [
    const TimeOfDay(hour: 8, minute: 0), // Morning
  ];

  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _showContent = true);
    await AnimationUtils.mediumHaptic();
  }

  void _onFrequencyChanged(int frequency) {
    setState(() {
      _selectedFrequency = frequency;
      // Adjust time slots based on frequency
      _selectedTimes.clear();
      if (frequency >= 1) {
        _selectedTimes.add(const TimeOfDay(hour: 8, minute: 0)); // Morning
      }
      if (frequency >= 2) {
        _selectedTimes.add(const TimeOfDay(hour: 12, minute: 30)); // Noon
      }
      if (frequency >= 3) {
        _selectedTimes.add(const TimeOfDay(hour: 20, minute: 0)); // Evening
      }
    });
    AnimationUtils.lightHaptic();
  }

  Future<void> _showTimePicker(int index) async {
    final currentTime = _selectedTimes[index];
    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: OnboardingTheme.goldColor,
              surface: Color(0xFF1C1C1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTimes[index] = picked);
      await AnimationUtils.lightHaptic();
    }
  }

  Future<void> _onActivate() async {
    await AnimationUtils.heavyHaptic();

    // Save preferences
    await controller.saveDailyVerseFrequency(_selectedFrequency);
    await controller.saveDailyVerseTimes(_selectedTimes);

    // Request notification permission
    final notifService = LocalNotificationService();
    await notifService.requestPermissions();

    // Enable daily verse notifications with all selected times
    final dailyVerseService = DailyVerseNotificationService();
    await dailyVerseService.enableWithMultipleTimes(_selectedTimes);

    // Fade out and proceed
    setState(() => _opacity = 0.0);
    await Future.delayed(const Duration(milliseconds: 800));
    widget.onComplete();
  }

  Future<void> _onSkip() async {
    await AnimationUtils.lightHaptic();
    setState(() => _opacity = 0.0);
    await Future.delayed(const Duration(milliseconds: 600));
    widget.onComplete();
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _getTimeLabel(int index) {
    switch (index) {
      case 0:
        return 'dailyVerses_morning'.tr;
      case 1:
        return 'dailyVerses_afternoon'.tr;
      case 2:
        return 'dailyVerses_evening'.tr;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 800),
        child: AnimatedOpacity(
          opacity: _showContent ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: OnboardingTheme.horizontalPadding,
              right: OnboardingTheme.horizontalPadding,
              top: 70,
              bottom: OnboardingTheme.verticalPadding,
            ),
            child: Column(
              children: [
                // Judah pointing with clock context
                JudahMascot(
                  state: JudahState.pointing,
                  size: JudahSize.l,
                  message: 'dailyVerses_mascot'.tr,
                ),
                const SizedBox(height: OnboardingTheme.space24),

                // Title
                Text(
                  'dailyVerses_title'.tr,
                  style: OnboardingTheme.title2.copyWith(
                    color: OnboardingTheme.labelPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: OnboardingTheme.space8),
                Text(
                  'dailyVerses_subtitle'.tr,
                  style: OnboardingTheme.callout.copyWith(
                    color: OnboardingTheme.labelSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: OnboardingTheme.space32),

                // Frequency selection
                Text(
                  'dailyVerses_frequency'.tr,
                  style: OnboardingTheme.subhead.copyWith(
                    color: OnboardingTheme.goldColor,
                  ),
                ),
                const SizedBox(height: OnboardingTheme.space16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [1, 2, 3].map((freq) => _buildFrequencyChip(freq)).toList(),
                ),
                const SizedBox(height: OnboardingTheme.space32),

                // Time pickers
                Text(
                  'dailyVerses_when'.tr,
                  style: OnboardingTheme.subhead.copyWith(
                    color: OnboardingTheme.goldColor,
                  ),
                ),
                const SizedBox(height: OnboardingTheme.space16),
                ...List.generate(
                  _selectedTimes.length,
                  (index) => _buildTimePicker(index),
                ),
                const SizedBox(height: OnboardingTheme.space40),

                // Activate button
                FastButton(
                  text: 'dailyVerses_activate'.tr,
                  onTap: _onActivate,
                  backgroundColor: OnboardingTheme.goldColor,
                  textColor: OnboardingTheme.backgroundColor,
                  style: FastButtonStyle.filled,
                ),
                const SizedBox(height: OnboardingTheme.space16),

                // Skip link
                GestureDetector(
                  onTap: _onSkip,
                  child: Text(
                    'dailyVerses_later'.tr,
                    style: OnboardingTheme.subhead.copyWith(
                      color: OnboardingTheme.labelTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencyChip(int frequency) {
    final isSelected = _selectedFrequency == frequency;
    final label = '${frequency}x';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: () => _onFrequencyChanged(frequency),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? OnboardingTheme.goldColor
                : OnboardingTheme.cardBackground,
            border: Border.all(
              color: isSelected
                  ? OnboardingTheme.goldColor
                  : OnboardingTheme.cardBorder,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(OnboardingTheme.radiusMedium),
          ),
          child: Text(
            label,
            style: OnboardingTheme.body.copyWith(
              color: isSelected
                  ? OnboardingTheme.backgroundColor
                  : OnboardingTheme.labelPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: OnboardingTheme.space12),
      child: GestureDetector(
        onTap: () => _showTimePicker(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: OnboardingTheme.cardBackground,
            border: Border.all(
              color: OnboardingTheme.goldColor.withValues(alpha: 0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(OnboardingTheme.radiusMedium),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.clock,
                color: OnboardingTheme.goldColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                _getTimeLabel(index),
                style: OnboardingTheme.subhead.copyWith(
                  color: OnboardingTheme.labelSecondary,
                ),
              ),
              const Spacer(),
              Text(
                _formatTime(_selectedTimes[index]),
                style: OnboardingTheme.body.copyWith(
                  color: OnboardingTheme.labelPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                CupertinoIcons.chevron_right,
                color: OnboardingTheme.labelTertiary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
