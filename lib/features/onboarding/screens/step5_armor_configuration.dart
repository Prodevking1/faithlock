import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/feather_cursor.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Step 5: Armor Configuration - Spiritual Setup
/// User chooses verse categories, problem apps, and intensity
class Step5ArmorConfiguration extends StatefulWidget {
  final VoidCallback onComplete;

  const Step5ArmorConfiguration({
    super.key,
    required this.onComplete,
  });

  @override
  State<Step5ArmorConfiguration> createState() =>
      _Step5ArmorConfigurationState();
}

class _Step5ArmorConfigurationState extends State<Step5ArmorConfiguration> {
  final controller = Get.find<ScriptureOnboardingController>();

  // Phase 7.1 - Introduction
  String _introText = '';
  bool _showIntroCursor = false;

  // Phase 7.2 - Category Selection
  bool _showCategorySelection = false;
  final List<String> _availableCategories = [
    'Temptation',
    'Fear & Anxiety',
    'Pride',
    'Lust',
    'Anger',
  ];
  final Set<String> _selectedCategories = {};

  // Phase 7.3 - App Selection (showing placeholder for now)
  bool _showAppSelection = false;

  // Phase 7.4 - Intensity Selection
  bool _showIntensitySelection = false;
  String _selectedIntensity = 'Balanced';

  // Phase 7.5 - Schedule Times Selection
  bool _showScheduleSelection = false;
  final List<Map<String, dynamic>> _schedules = [
    {
      'name': 'Morning Focus',
      'icon': '🌅',
      'start': const TimeOfDay(hour: 8, minute: 0),
      'end': const TimeOfDay(hour: 10, minute: 0),
      'enabled': true,
    },
    {
      'name': 'Afternoon Lock',
      'icon': '☀️',
      'start': const TimeOfDay(hour: 12, minute: 0),
      'end': const TimeOfDay(hour: 16, minute: 0),
      'enabled': true,
    },
    {
      'name': 'Night Protection',
      'icon': '🌙',
      'start': const TimeOfDay(hour: 20, minute: 0),
      'end': const TimeOfDay(hour: 23, minute: 0),
      'enabled': true,
    },
  ];

  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Phase 7.1: Introduction
    await _phase71Introduction();

    // Phase 7.2: Category Selection (user interaction)
    await _phase72CategorySelection();
  }

  Future<void> _phase71Introduction() async {
    final userName = controller.userName.value;

    await AnimationUtils.typeText(
      fullText:
          'Now, $userName, let\'s equip you with spiritual armor.\n\nChoose your weapon: God\'s Word.',
      onUpdate: (text) => setState(() => _introText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showIntroCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 2000);
  }

  Future<void> _phase72CategorySelection() async {
    setState(() {
      _introText = '';
      _showIntroCursor = false;
      _showCategorySelection = true;
    });

    await AnimationUtils.mediumHaptic();
  }

  void _onCategoryToggle(String category) async {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        if (_selectedCategories.length < 5) {
          _selectedCategories.add(category);
        }
      }
    });
    await AnimationUtils.lightHaptic();
  }

  Future<void> _onContinueFromCategories() async {
    if (_selectedCategories.isEmpty) return;

    await controller.saveVerseCategories(_selectedCategories.toList());
    await AnimationUtils.heavyHaptic();

    // Phase 7.3: App Selection (simplified for MVP)
    setState(() {
      _showCategorySelection = false;
      _showAppSelection = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    // Skip to intensity for now
    await _phase74IntensitySelection();
  }

  Future<void> _phase74IntensitySelection() async {
    setState(() {
      _showAppSelection = false;
      _showIntensitySelection = true;
    });

    await AnimationUtils.mediumHaptic();
  }

  void _onIntensitySelected(String intensity) async {
    setState(() => _selectedIntensity = intensity);
    await AnimationUtils.lightHaptic();
  }

  Future<void> _onContinueFromIntensity() async {
    await controller.saveIntensityLevel(_selectedIntensity);
    await AnimationUtils.heavyHaptic();

    // Phase 7.5: Schedule Times Selection
    setState(() {
      _showIntensitySelection = false;
      _showScheduleSelection = true;
    });
  }

  void _toggleSchedule(int index) {
    setState(() {
      _schedules[index]['enabled'] = !_schedules[index]['enabled'];
    });
    AnimationUtils.lightHaptic();
  }

  Future<void> _editScheduleTime(int index, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _schedules[index][isStart ? 'start' : 'end'] as TimeOfDay,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: OnboardingTheme.goldColor,
              onPrimary: OnboardingTheme.backgroundColor,
              surface: OnboardingTheme.cardBackground,
              onSurface: OnboardingTheme.labelPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _schedules[index][isStart ? 'start' : 'end'] = picked;
      });
      await AnimationUtils.mediumHaptic();
    }
  }

  Future<void> _onComplete() async {
    // Save schedules to controller
    final enabledSchedules = _schedules
        .where((s) => s['enabled'] == true)
        .toList();

    if (enabledSchedules.isEmpty) {
      // Show warning that at least one schedule should be enabled
      return;
    }

    await controller.saveSchedules(enabledSchedules);
    await AnimationUtils.heavyHaptic();

    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 1000),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: OnboardingTheme.horizontalPadding,
              right: OnboardingTheme.horizontalPadding,
              top: 100, // Space for progress bar
              bottom: OnboardingTheme.verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                        // Phase 7.1 - Introduction
                        if (_introText.isNotEmpty)
                          RichText(
                            text: TextSpan(
                              style: OnboardingTheme.emphasisText,
                              children: [
                                TextSpan(text: _introText),
                                if (_showIntroCursor)
                                  const WidgetSpan(
                                    child: FeatherCursor(),
                                    alignment: PlaceholderAlignment.middle,
                                  ),
                              ],
                            ),
                          ),

                        // Phase 7.2 - Category Selection
                        if (_showCategorySelection) ...[
                          Text(
                            'Select your spiritual battles (3-5):',
                            style: OnboardingTheme.title3.copyWith(
                              color: OnboardingTheme.labelPrimary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ..._availableCategories.map(
                            (category) => _buildCategoryOption(category),
                          ),
                          const SizedBox(height: 40),
                          if (_selectedCategories.isNotEmpty &&
                              _selectedCategories.length >= 3)
                            Center(
                              child: FastButton(
                                text: 'Continue',
                                onTap: _onContinueFromCategories,
                                backgroundColor: OnboardingTheme.goldColor,
                                textColor: OnboardingTheme.backgroundColor,
                                style: FastButtonStyle.filled,
                              ),
                            ),
                        ],

                        // Phase 7.4 - Intensity Selection
                        if (_showIntensitySelection) ...[
                          Text(
                            'Choose your protection level:',
                            style: OnboardingTheme.title3.copyWith(
                              color: OnboardingTheme.labelPrimary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildIntensityOption(
                            'Gentle',
                            '1 verse per unlock',
                          ),
                          _buildIntensityOption(
                            'Balanced',
                            '2 verses per unlock',
                          ),
                          _buildIntensityOption(
                            'Warrior',
                            '3 verses per unlock',
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: FastButton(
                              text: 'Continue',
                              onTap: _onContinueFromIntensity,
                              backgroundColor: OnboardingTheme.goldColor,
                              textColor: OnboardingTheme.backgroundColor,
                              style: FastButtonStyle.filled,
                            ),
                          ),
                        ],

                        // Phase 7.5 - Schedule Times Selection
                        if (_showScheduleSelection) ...[
                          Text(
                            'When should we lock your apps?',
                            style: OnboardingTheme.title3.copyWith(
                              color: OnboardingTheme.labelPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'We\'ll lock your apps during these times. You can adjust or disable any:',
                            style: OnboardingTheme.body.copyWith(
                              color: OnboardingTheme.labelSecondary,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ..._schedules.asMap().entries.map((entry) {
                            final index = entry.key;
                            final schedule = entry.value;
                            return _buildScheduleOption(index, schedule);
                          }),
                          const SizedBox(height: 40),
                          Center(
                            child: FastButton(
                              text: 'Activate Protection',
                              onTap: _onComplete,
                              backgroundColor: OnboardingTheme.goldColor,
                              textColor: OnboardingTheme.backgroundColor,
                              style: FastButtonStyle.filled,
                            ),
                          ),
                        ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryOption(String category) {
    final isSelected = _selectedCategories.contains(category);

    return GestureDetector(
      onTap: () => _onCategoryToggle(category),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? OnboardingTheme.goldColor.withValues(alpha: 0.15)
              : OnboardingTheme.cardBackground,
          borderRadius: BorderRadius.circular(OnboardingTheme.radiusMedium),
          border: Border.all(
            color: isSelected
                ? OnboardingTheme.goldColor
                : OnboardingTheme.cardBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // iOS-style checkmark circle
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected ? OnboardingTheme.goldColor : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? OnboardingTheme.goldColor
                      : OnboardingTheme.labelTertiary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: OnboardingTheme.backgroundColor,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category,
                style: OnboardingTheme.body.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? OnboardingTheme.goldColor
                      : OnboardingTheme.labelPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntensityOption(String level, String description) {
    final isSelected = _selectedIntensity == level;

    return GestureDetector(
      onTap: () => _onIntensitySelected(level),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? OnboardingTheme.goldColor.withValues(alpha: 0.15)
              : OnboardingTheme.cardBackground,
          borderRadius: BorderRadius.circular(OnboardingTheme.radiusMedium),
          border: Border.all(
            color: isSelected
                ? OnboardingTheme.goldColor
                : OnboardingTheme.cardBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // iOS-style radio circle
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected ? OnboardingTheme.goldColor : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? OnboardingTheme.goldColor
                      : OnboardingTheme.labelTertiary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: OnboardingTheme.backgroundColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level,
                    style: OnboardingTheme.body.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? OnboardingTheme.goldColor
                          : OnboardingTheme.labelPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: OnboardingTheme.footnote.copyWith(
                      fontSize: 13,
                      color: OnboardingTheme.labelSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleOption(int index, Map<String, dynamic> schedule) {
    final isEnabled = schedule['enabled'] as bool;
    final icon = schedule['icon'] as String;
    final name = schedule['name'] as String;
    final start = schedule['start'] as TimeOfDay;
    final end = schedule['end'] as TimeOfDay;

    String formatTime(TimeOfDay time) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEnabled
            ? OnboardingTheme.cardBackground
            : OnboardingTheme.cardBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(OnboardingTheme.radiusMedium),
        border: Border.all(
          color: isEnabled
              ? OnboardingTheme.goldColor.withValues(alpha: 0.3)
              : OnboardingTheme.cardBorder,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icon & Name
              Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: OnboardingTheme.body.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isEnabled
                        ? OnboardingTheme.labelPrimary
                        : OnboardingTheme.labelTertiary,
                  ),
                ),
              ),
              // Toggle switch
              GestureDetector(
                onTap: () => _toggleSchedule(index),
                child: Container(
                  width: 51,
                  height: 31,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isEnabled
                        ? OnboardingTheme.goldColor
                        : OnboardingTheme.labelTertiary.withValues(alpha: 0.3),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment:
                        isEnabled ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      width: 27,
                      height: 27,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isEnabled) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _editScheduleTime(index, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: OnboardingTheme.backgroundColor,
                        borderRadius:
                            BorderRadius.circular(OnboardingTheme.radiusSmall),
                        border: Border.all(
                          color: OnboardingTheme.goldColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start',
                            style: OnboardingTheme.footnote.copyWith(
                              fontSize: 11,
                              color: OnboardingTheme.labelTertiary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatTime(start),
                            style: OnboardingTheme.body.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: OnboardingTheme.goldColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '→',
                  style: TextStyle(
                    fontSize: 20,
                    color: OnboardingTheme.labelTertiary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _editScheduleTime(index, false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: OnboardingTheme.backgroundColor,
                        borderRadius:
                            BorderRadius.circular(OnboardingTheme.radiusSmall),
                        border: Border.all(
                          color: OnboardingTheme.goldColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End',
                            style: OnboardingTheme.footnote.copyWith(
                              fontSize: 11,
                              color: OnboardingTheme.labelTertiary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatTime(end),
                            style: OnboardingTheme.body.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: OnboardingTheme.goldColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
