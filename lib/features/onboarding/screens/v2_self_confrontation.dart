import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/feather_cursor.dart';
import 'package:faithlock/features/onboarding/widgets/life_visualization.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/controls/fast_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// V2 Self-Confrontation - Lighter version
/// Keeps: sliders + comparison ratio + annual conversion + life visualization
/// Cuts: daily/weekly stats, spiritual list, Psalm, justify question
class V2SelfConfrontation extends StatefulWidget {
  final VoidCallback onComplete;

  const V2SelfConfrontation({
    super.key,
    required this.onComplete,
  });

  @override
  State<V2SelfConfrontation> createState() => _V2SelfConfrontationState();
}

class _V2SelfConfrontationState extends State<V2SelfConfrontation> {
  final controller = Get.find<ScriptureOnboardingController>();

  // Phase 2.1 - Introduction
  String _introText1 = '';
  String _introText2 = '';
  bool _showIntro1Cursor = false;
  bool _showIntro2Cursor = false;

  // Phase 2.2 - Input
  bool _showInput = false;
  double _hoursPerDay = 0.0;

  // Phase 2.2B - Prayer Frequency Input
  bool _showPrayerInput = false;
  double _prayerTimesPerWeek = 0.0;
  String _comparisonText = '';
  bool _showComparisonCursor = false;

  // Phase 2.3 - Progressive Revelation (lighter)
  String _revelationText = '';
  bool _showRevelationCursor = false;
  bool _showLifeVisualization = false;
  bool _showWastedInVisualization = false;

  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Phase 2.1: Introduction
    await _phase21Introduction();

    // Phase 2.2: Input Collection (user interaction)
    await _phase22InputCollection();
  }

  Future<void> _phase21Introduction() async {
    final userName = controller.userName.value;

    // Type first line (iOS-optimized timing)
    await AnimationUtils.typeText(
      fullText: 'selfConf_idol'.tr,
      onUpdate: (text) => setState(() => _introText1 = text),
      onCursorVisibility: (visible) =>
          setState(() => _showIntro1Cursor = visible),
    );

    await AnimationUtils.pause(durationMs: AnimationUtils.pauseMedium);

    // Type second line
    await AnimationUtils.typeText(
      fullText: 'selfConf_honest'.trParams({'name': userName}),
      onUpdate: (text) => setState(() => _introText2 = text),
      onCursorVisibility: (visible) =>
          setState(() => _showIntro2Cursor = visible),
    );

    await AnimationUtils.pause(durationMs: AnimationUtils.pauseMedium);
  }

  Future<void> _phase22InputCollection() async {
    // Clear intro texts and show input
    setState(() {
      _introText1 = '';
      _introText2 = '';
      _showIntro1Cursor = false;
      _showIntro2Cursor = false;
      _showInput = true;
    });
    await AnimationUtils.mediumHaptic();
  }

  void _onSliderChanged(double value) {
    AnimationUtils.mediumHaptic();
    setState(() => _hoursPerDay = value);
  }

  Future<void> _proceedToPrayerInput() async {
    setState(() {
      _showInput = false;
      _introText1 = '';
      _introText2 = '';
    });

    await controller.saveHoursPerDay(_hoursPerDay);
    await AnimationUtils.heavyHaptic();

    // Phase 2.2B: Prayer Frequency Input
    await _phase22BPrayerInput();
  }

  Future<void> _phase22BPrayerInput() async {
    await AnimationUtils.pause(durationMs: 500);

    // Type question
    await AnimationUtils.typeText(
      fullText: 'selfConf_prayerIntro'.tr,
      onUpdate: (text) => setState(() => _introText1 = text),
      onCursorVisibility: (visible) =>
          setState(() => _showIntro1Cursor = visible),
    );

    await AnimationUtils.pause(durationMs: 800);

    setState(() {
      _introText1 = '';
      _showIntro1Cursor = false;
      _showPrayerInput = true;
    });

    await AnimationUtils.mediumHaptic();
  }

  void _onPrayerSliderChanged(double value) {
    AnimationUtils.mediumHaptic();
    setState(() => _prayerTimesPerWeek = value);
  }

  Future<void> _proceedToComparison() async {
    if (_prayerTimesPerWeek == 0) return;

    setState(() => _showPrayerInput = false);

    await controller.savePrayerFrequency(_prayerTimesPerWeek.toInt());
    await AnimationUtils.heavyHaptic();

    // Calculate comparison
    await _showPrayerPhoneComparison();
  }

  Future<void> _showPrayerPhoneComparison() async {
    await AnimationUtils.pause(durationMs: 500);

    final phoneHoursPerYear = _hoursPerDay * 365;
    final prayerMinutesPerWeek = _prayerTimesPerWeek * 10; // 10 min average per prayer
    final prayerHoursPerYear = (prayerMinutesPerWeek * 52) / 60;

    final ratio = prayerHoursPerYear > 0
        ? (phoneHoursPerYear / prayerHoursPerYear).toStringAsFixed(0)
        : '∞';

    await AnimationUtils.typeText(
      fullText: 'selfConf_comparison'.trParams({
        'phoneHours': phoneHoursPerYear.toInt().toString(),
        'prayerHours': prayerHoursPerYear.toInt().toString(),
        'ratio': ratio,
      }),
      onUpdate: (text) => setState(() => _comparisonText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showComparisonCursor = visible),
    );

    await AnimationUtils.pause(durationMs: 3000, withHaptic: true, heavy: true);

    setState(() {
      _comparisonText = '';
      _showComparisonCursor = false;
    });

    await AnimationUtils.pause(durationMs: 500);

    // Phase 2.3: Progressive Revelation
    await _phase23ProgressiveRevelation();

    // Transition to next step (iOS-optimized)
    await AnimationUtils.pause(durationMs: AnimationUtils.pauseLong);
    setState(() => _opacity = 0.0);
    await Future.delayed(Duration(milliseconds: AnimationUtils.fadeMs));
    await AnimationUtils.heavyHaptic();
    await Future.delayed(Duration(milliseconds: AnimationUtils.pauseShort));

    widget.onComplete();
  }

  // Get iOS-style color based on hours (subtle severity gradient)
  Color _getSliderColor() {
    if (_hoursPerDay == 0) return OnboardingTheme.labelTertiary;
    if (_hoursPerDay < 2) return OnboardingTheme.systemGreen; // Minimal - green
    if (_hoursPerDay < 4) return OnboardingTheme.goldColor; // Caution - gold
    if (_hoursPerDay < 6)
      return OnboardingTheme.systemOrange; // Warning - orange
    return OnboardingTheme.systemRed; // Critical - red
  }

  // Get message based on hours (severity text)
  String _getSeverityMessage() {
    if (_hoursPerDay == 0) return 'selfConf_selectHonest'.tr;
    if (_hoursPerDay < 2) return 'selfConf_severity1'.tr;
    if (_hoursPerDay < 4) return 'selfConf_severity2'.tr;
    if (_hoursPerDay < 6) return 'selfConf_severity3'.tr;
    if (_hoursPerDay < 10) return 'selfConf_severity4'.tr;
    return 'selfConf_severity5'.tr;
  }

  // Get iOS-style color based on prayer frequency
  Color _getPrayerSliderColor() {
    if (_prayerTimesPerWeek == 0) return OnboardingTheme.labelTertiary;
    if (_prayerTimesPerWeek < 4) return OnboardingTheme.systemRed; // Less than daily - red
    if (_prayerTimesPerWeek < 7) return OnboardingTheme.systemOrange; // Almost daily - orange
    if (_prayerTimesPerWeek < 14) return OnboardingTheme.goldColor; // 1-2x daily - gold
    return OnboardingTheme.systemGreen; // 2-3x daily - green
  }

  // Get message based on prayer frequency
  String _getPrayerMessage() {
    if (_prayerTimesPerWeek == 0) return 'selfConf_prayerHonest'.tr;
    if (_prayerTimesPerWeek < 4) return 'selfConf_prayer1'.tr;
    if (_prayerTimesPerWeek < 7) return 'selfConf_prayer2'.tr;
    if (_prayerTimesPerWeek < 14) return 'selfConf_prayer3'.tr;
    if (_prayerTimesPerWeek < 21) return 'selfConf_prayer4'.tr;
    return 'selfConf_prayer5'.tr;
  }

  Future<void> _phase23ProgressiveRevelation() async {
    final stats = controller.calculateTimeStats();
    final fullDays = stats['fullDays'];

    // Annual conversion - THE PUNCH (kept from V1)
    await AnimationUtils.typeText(
      fullText: 'selfConf_revelation'.trParams({'days': fullDays.toString()}),
      onUpdate: (text) => setState(() => _revelationText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showRevelationCursor = visible),
    );

    await AnimationUtils.pause(
        durationMs: AnimationUtils.autoContinueMs,
        withHaptic: true,
        heavy: true);

    // Life Visualization
    setState(() => _revelationText = '');
    await AnimationUtils.pause(durationMs: AnimationUtils.pauseMedium);

    await AnimationUtils.typeText(
      fullText: 'selfConf_thisIsYourLife'.trParams({'name': controller.userName.value}),
      onUpdate: (text) => setState(() => _revelationText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showRevelationCursor = visible),
    );

    await AnimationUtils.pause(durationMs: AnimationUtils.pauseLong);

    setState(() {
      _revelationText = '';
      _showRevelationCursor = false;
      _showLifeVisualization = true;
    });

    await AnimationUtils.mediumHaptic();
    await AnimationUtils.pause(durationMs: 3000);

    // Reveal wasted years
    await AnimationUtils.typeText(
      fullText: 'selfConf_redDots'.tr,
      onUpdate: (text) => setState(() => _revelationText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showRevelationCursor = visible),
    );

    await AnimationUtils.pause(durationMs: AnimationUtils.pauseLong);

    setState(() => _showWastedInVisualization = true);
    await AnimationUtils.heavyHaptic();

    await AnimationUtils.pause(durationMs: 4000);
  }

  // Format hours (remove .0 for whole numbers)
  String _formatHours() {
    if (_hoursPerDay == _hoursPerDay.roundToDouble()) {
      return _hoursPerDay.toInt().toString();
    }
    return _hoursPerDay.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 1000),
        child: Padding(
          padding: const EdgeInsets.only(
            left: OnboardingTheme.horizontalPadding,
            right: OnboardingTheme.horizontalPadding,
            top: 100, // Space for progress bar
            bottom: OnboardingTheme.verticalPadding,
          ),
          child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Phase 2.1 - Introduction (centered)
                    if (_introText1.isNotEmpty || _introText2.isNotEmpty) ...[
                      RichText(
                        text: TextSpan(
                          style: OnboardingTheme.title2,
                          children: [
                            TextSpan(text: _introText1),
                            if (_showIntro1Cursor)
                              const WidgetSpan(
                                child: FeatherCursor(),
                                alignment: PlaceholderAlignment.middle,
                              ),
                          ],
                        ),
                      ),
                      if (_introText2.isNotEmpty)
                        const SizedBox(height: OnboardingTheme.space24),
                      if (_introText2.isNotEmpty)
                        RichText(
                          text: TextSpan(
                            style: OnboardingTheme.title2,
                            children: [
                              TextSpan(text: _introText2),
                              if (_showIntro2Cursor)
                                const WidgetSpan(
                                  child: FeatherCursor(),
                                  alignment: PlaceholderAlignment.middle,
                                ),
                            ],
                          ),
                        ),
                    ],

                    // Phase 2.2 - Input Collection
                    if (_showInput) ...[
                      Text(
                        'selfConf_phoneQuestion'.tr,
                        style: OnboardingTheme.title3,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: OnboardingTheme.space32),
                      // iOS-style number display
                      Center(
                        child: Text(
                          _formatHours(),
                          style: OnboardingTheme.displayNumber.copyWith(
                            color: _getSliderColor(),
                          ),
                        ),
                      ),
                      const SizedBox(height: OnboardingTheme.space4),
                      Center(
                        child: Text(
                          'selfConf_hoursPerDay'.tr,
                          style: OnboardingTheme.displayUnit,
                        ),
                      ),
                      const SizedBox(height: OnboardingTheme.space40),
                      // Compact slider
                      Center(
                        child: FastSlider(
                          value: _hoursPerDay,
                          min: 0,
                          max: 16,
                          divisions: 16,
                          activeColor: _getSliderColor(),
                          onChanged: _onSliderChanged,
                        ),
                      ),
                      const SizedBox(height: OnboardingTheme.space24),
                      // iOS-style severity message
                      Center(
                        child: Text(
                          _getSeverityMessage(),
                          style: OnboardingTheme.subhead.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _getSliderColor(),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: OnboardingTheme.space48),
                      // Continue button
                      Center(
                        child: FastButton(
                          text: 'continue_btn'.tr,
                          onTap: _hoursPerDay > 0 ? _proceedToPrayerInput : null,
                          backgroundColor: OnboardingTheme.goldColor,
                          textColor: OnboardingTheme.backgroundColor,
                          style: FastButtonStyle.filled,
                        ),
                      ),
                    ],

                    // Phase 2.2B - Prayer Frequency Input
                    if (_showPrayerInput) ...[
                      Text(
                        'selfConf_prayerQuestion'.tr,
                        style: OnboardingTheme.title3,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: OnboardingTheme.space32),
                      // iOS-style number display
                      Center(
                        child: Text(
                          _prayerTimesPerWeek.toInt().toString(),
                          style: OnboardingTheme.displayNumber.copyWith(
                            color: _getPrayerSliderColor(),
                          ),
                        ),
                      ),
                      const SizedBox(height: OnboardingTheme.space4),
                      Center(
                        child: Text(
                          'selfConf_timesPerWeek'.tr,
                          style: OnboardingTheme.displayUnit,
                        ),
                      ),
                      const SizedBox(height: OnboardingTheme.space40),
                      // Compact slider
                      Center(
                        child: FastSlider(
                          value: _prayerTimesPerWeek,
                          min: 0,
                          max: 21,
                          divisions: 21,
                          activeColor: _getPrayerSliderColor(),
                          onChanged: _onPrayerSliderChanged,
                        ),
                      ),
                      const SizedBox(height: OnboardingTheme.space24),
                      // iOS-style prayer message
                      Center(
                        child: Text(
                          _getPrayerMessage(),
                          style: OnboardingTheme.subhead.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _getPrayerSliderColor(),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: OnboardingTheme.space48),
                      // Continue button
                      Center(
                        child: FastButton(
                          text: 'continue_btn'.tr,
                          onTap: _prayerTimesPerWeek > 0 ? _proceedToComparison : null,
                          backgroundColor: OnboardingTheme.goldColor,
                          textColor: OnboardingTheme.backgroundColor,
                          style: FastButtonStyle.filled,
                        ),
                      ),
                    ],

                    // Phase 2.2C - Comparison Text
                    if (_comparisonText.isNotEmpty) ...[
                      RichText(
                        text: TextSpan(
                          style: OnboardingTheme.title3.copyWith(
                            color: OnboardingTheme.systemRed,
                          ),
                          children: [
                            TextSpan(text: _comparisonText),
                            if (_showComparisonCursor)
                              const WidgetSpan(
                                child: FeatherCursor(),
                                alignment: PlaceholderAlignment.middle,
                              ),
                          ],
                        ),
                      ),
                    ],

                    // Phase 2.3 - Progressive Revelation
                    if (_revelationText.isNotEmpty) ...[
                      RichText(
                        text: TextSpan(
                          style: _revelationText.contains('Psalm')
                              ? OnboardingTheme.body
                                  .copyWith(color: OnboardingTheme.goldColor)
                              : OnboardingTheme.title3,
                          children: [
                            TextSpan(text: _revelationText),
                            if (_showRevelationCursor)
                              const WidgetSpan(
                                child: FeatherCursor(),
                                alignment: PlaceholderAlignment.middle,
                              ),
                          ],
                        ),
                      ),
                    ],

                    // Life Visualization
                    if (_showLifeVisualization) ...[
                      const SizedBox(height: 40),
                      LifeVisualization(
                        currentAge: controller.userAge.value,
                        lifeExpectancy: 80,
                        daysWasted: controller
                            .calculateLifeStats()['daysWastedInFuture'],
                        showWasted: _showWastedInVisualization,
                      ),
                    ],
            ],
          ),
        ),
      ),
    );
  }
}
