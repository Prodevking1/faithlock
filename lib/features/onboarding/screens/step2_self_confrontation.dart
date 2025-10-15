import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/feather_cursor.dart';
import 'package:faithlock/features/onboarding/widgets/life_visualization.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/controls/fast_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Step 2: Self-Confrontation - Pain Point Calculator
/// Forces honest self-assessment and reveals magnitude of time lost
class Step2SelfConfrontation extends StatefulWidget {
  final VoidCallback onComplete;

  const Step2SelfConfrontation({
    super.key,
    required this.onComplete,
  });

  @override
  State<Step2SelfConfrontation> createState() => _Step2SelfConfrontationState();
}

class _Step2SelfConfrontationState extends State<Step2SelfConfrontation> {
  final controller = Get.find<ScriptureOnboardingController>();

  // Phase 2.1 - Introduction
  String _introText1 = '';
  String _introText2 = '';
  bool _showIntro1Cursor = false;
  bool _showIntro2Cursor = false;

  // Phase 2.2 - Input
  bool _showInput = false;
  double _hoursPerDay = 0.0;

  // Phase 2.3 - Progressive Revelation
  String _revelationText = '';
  bool _showRevelationCursor = false;
  bool _showList = false;
  List<String> _listItems = [];
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
      fullText: 'Your phone has become a modern-day idol.',
      onUpdate: (text) => setState(() => _introText1 = text),
      onCursorVisibility: (visible) =>
          setState(() => _showIntro1Cursor = visible),
    );

    await AnimationUtils.pause(durationMs: AnimationUtils.pauseMedium);

    // Type second line
    await AnimationUtils.typeText(
      fullText: '$userName, let\'s be honest before God...',
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

  Future<void> _proceedToRevelation() async {
    setState(() {
      _showInput = false;
      _introText1 = '';
      _introText2 = '';
    });

    await controller.saveHoursPerDay(_hoursPerDay);
    await AnimationUtils.heavyHaptic();

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
    if (_hoursPerDay == 0) return 'Select your honest answer...';
    if (_hoursPerDay < 2) return 'Minimal usage - Stay vigilant';
    if (_hoursPerDay < 4) return 'Caution - Time slipping away';
    if (_hoursPerDay < 6) return 'Warning - Your soul is at risk';
    if (_hoursPerDay < 10) return 'CRITICAL - An idol has formed';
    return 'ENSLAVED - Complete bondage to the screen';
  }

  Future<void> _phase23ProgressiveRevelation() async {
    final stats = controller.calculateTimeStats();
    final hoursPerDay = stats['hoursPerDay'];
    final hoursPerWeek = stats['hoursPerWeek'].toStringAsFixed(1);
    final fullDays = stats['fullDays'];

    // 2.3.1 - Daily acknowledgment (iOS-optimized timing)
    await AnimationUtils.typeText(
      fullText: '${hoursPerDay.toStringAsFixed(1)} hours every single day...',
      onUpdate: (text) => setState(() => _revelationText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showRevelationCursor = visible),
    );

    await AnimationUtils.pause(durationMs: AnimationUtils.pauseLong);

    // 2.3.2 - Weekly multiplication
    setState(() => _revelationText = '');
    await AnimationUtils.typeText(
      fullText: 'That\'s $hoursPerWeek hours per week.',
      onUpdate: (text) => setState(() => _revelationText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showRevelationCursor = visible),
    );

    await AnimationUtils.pause(durationMs: AnimationUtils.pauseMedium);

    // 2.3.3 - Annual conversion (THE PUNCH)
    setState(() => _revelationText = '');
    await AnimationUtils.typeText(
      fullText: 'Over one year: $fullDays full days.',
      onUpdate: (text) => setState(() => _revelationText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showRevelationCursor = visible),
    );

    await AnimationUtils.pause(
        durationMs: AnimationUtils.autoContinueMs,
        withHaptic: true,
        heavy: true);

    // 2.3.5 - Spiritual Amplification
    setState(() => _revelationText = '');
    await AnimationUtils.typeText(
      fullText: '$fullDays days you could have spent...',
      onUpdate: (text) => setState(() => _revelationText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showRevelationCursor = visible),
    );

    setState(() => _showList = true);
    await AnimationUtils.pause(durationMs: AnimationUtils.pauseShort);

    // Add list items one by one
    final items = [
      '• In deep prayer',
      '• Studying God\'s Word',
      '• Serving others',
      '• In His presence',
    ];

    for (final item in items) {
      setState(() => _listItems.add(item));
      await AnimationUtils.lightHaptic();
      await AnimationUtils.pause(durationMs: 800);
    }

    await AnimationUtils.pause(durationMs: AnimationUtils.autoContinueMs);

    // 2.3.6 - Scripture Conviction
    setState(() {
      _revelationText = '';
      _showList = false;
      _listItems.clear();
    });

    await AnimationUtils.typeText(
      fullText:
          'Teach us to number our days,\nthat we may gain a heart of wisdom.\n— Psalm 90:12',
      onUpdate: (text) => setState(() => _revelationText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showRevelationCursor = visible),
    );

    await AnimationUtils.pause(durationMs: AnimationUtils.autoContinueMs);

    // 2.3.7 - Final Gut Punch
    setState(() => _revelationText = '');
    await AnimationUtils.typeText(
      fullText:
          'If you had to justify these $fullDays days before God today...\n\nWhat would you tell Him?',
      onUpdate: (text) => setState(() => _revelationText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showRevelationCursor = visible),
    );

    await AnimationUtils.pause(durationMs: 3000, withHaptic: true, heavy: true);

    // 2.3.8 - Show Life Visualization
    setState(() => _revelationText = '');
    await AnimationUtils.pause(durationMs: AnimationUtils.pauseMedium);

    await AnimationUtils.typeText(
      fullText: 'This is your life, ${controller.userName.value}.',
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

    // 2.3.9 - Reveal wasted years
    await AnimationUtils.typeText(
      fullText: 'The red dots?\n\nThose are the years you\'ll lose...',
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
    return Scaffold(
      backgroundColor: OnboardingTheme.backgroundColor,
      body: SafeArea(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 1000),
          child: Stack(
            children: [
              // Back button
              if (controller.currentStep.value > 1)
                Positioned(
                  top: 16,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: OnboardingTheme.goldColor,
                      size: 24,
                    ),
                    onPressed: () => controller.previousStep(),
                  ),
                ),
              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: OnboardingTheme.horizontalPadding,
                  vertical: OnboardingTheme.verticalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: _showInput
                      ? MainAxisAlignment.center
                      : (_revelationText.isNotEmpty || _showLifeVisualization)
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.end,
                  children: [
                    // Phase 2.1 - Introduction (starts from bottom)
                    if (_introText1.isNotEmpty || _introText2.isNotEmpty) ...[
                      if (!_showInput) const Spacer(),
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
                        'How many hours do you spend on your phone each day?',
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
                          'hours/day',
                          style: OnboardingTheme.displayUnit,
                        ),
                      ),
                      const SizedBox(height: OnboardingTheme.space40),
                      // Compact slider
                      Center(
                        child: FastSlider(
                          value: _hoursPerDay,
                          min: 1,
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
                          text: 'Continue',
                          onTap: _hoursPerDay > 0 ? _proceedToRevelation : null,
                          backgroundColor: OnboardingTheme.goldColor,
                          textColor: OnboardingTheme.backgroundColor,
                          style: FastButtonStyle.filled,
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

                    if (_showList) ...[
                      const SizedBox(height: OnboardingTheme.space24),
                      ..._listItems.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(
                              bottom: OnboardingTheme.space12),
                          child: Text(
                            item,
                            style: OnboardingTheme.body,
                          ),
                        ),
                      ),
                    ],

                    // Phase 2.3.8 - Life Visualization
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
            ],
          ),
        ),
      ),
    );
  }
}
