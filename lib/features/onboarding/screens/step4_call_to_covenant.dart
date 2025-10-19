import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/feather_cursor.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Step 4: Call to Covenant - Holiness Vision + Sacred Commitment
/// Combines holiness vision with covenant acceptance
class Step4CallToCovenant extends StatefulWidget {
  final VoidCallback onComplete;

  const Step4CallToCovenant({
    super.key,
    required this.onComplete,
  });

  @override
  State<Step4CallToCovenant> createState() => _Step4CallToCovenantState();
}

class _Step4CallToCovenantState extends State<Step4CallToCovenant> {
  final controller = Get.find<ScriptureOnboardingController>();

  // Phase 4.1 - Divine Standard
  String _standardText = '';
  bool _showStandardCursor = false;

  // Phase 4.2 - Scripture Foundation
  String _scriptureText = '';
  bool _showScriptureCursor = false;

  // Phase 4.3 - Vision of Transformation
  String _visionIntroText = '';
  bool _showVisionIntroCursor = false;
  List<String> _visionList = [];
  bool _showVisionList = false;

  // Phase 4.4 - 30-Day Goals Selection
  bool _showGoalsSelection = false;
  final List<String> _availableGoals = [
    'Restore my prayer life',
    'Break phone addiction',
    'Heal relationships',
    'Find my purpose',
    'Overcome fear/anxiety',
    'Build discipline',
    'Grow in holiness',
  ];
  final Set<String> _selectedGoals = {};

  // Phase 4.5 - The Covenant
  String _covenantText = '';
  bool _showCovenantCursor = false;

  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Phase 4.1: Divine Standard
    await _phase41DivineStandard();

    // Phase 4.2: Scripture Foundation
    await _phase42ScriptureFoundation();

    // Phase 4.3: Vision of Transformation
    await _phase43VisionOfTransformation();

    // Phase 4.4: 30-Day Goals Selection (wait for user interaction)
    // Phase 4.5: The Covenant (triggered after goals selection)
  }

  Future<void> _phase41DivineStandard() async {
    await AnimationUtils.typeText(
      fullText: 'God is not calling you to moderation.\n\nHe\'s calling you to holiness.',
      onUpdate: (text) => setState(() => _standardText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showStandardCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 2000, withHaptic: true);
  }

  Future<void> _phase42ScriptureFoundation() async {
    setState(() {
      _standardText = '';
      _showStandardCursor = false;
    });

    await AnimationUtils.typeText(
      fullText: 'Be holy, for I am holy.\n— 1 Peter 1:16',
      onUpdate: (text) => setState(() => _scriptureText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showScriptureCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 2000);
  }

  Future<void> _phase43VisionOfTransformation() async {
    setState(() {
      _scriptureText = '';
      _showScriptureCursor = false;
    });

    await AnimationUtils.typeText(
      fullText: 'Imagine a life where you are:',
      onUpdate: (text) => setState(() => _visionIntroText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showVisionIntroCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 1000);

    setState(() => _showVisionList = true);

    final visions = [
      '• Free from digital bondage',
      '• Sensitive to the Spirit\'s voice',
      '• Living for eternal impact',
    ];

    for (final vision in visions) {
      setState(() => _visionList.add(vision));
      await AnimationUtils.lightHaptic();
      await AnimationUtils.pause(durationMs: 1000);
    }

    await AnimationUtils.pause(durationMs: 2000);

    // Transition to Phase 4.4: 30-Day Goals
    await _phase44GoalsSelection();
  }

  Future<void> _phase44GoalsSelection() async {
    setState(() {
      _visionIntroText = '';
      _showVisionList = false;
      _visionList.clear();
      _showGoalsSelection = true;
    });

    await AnimationUtils.mediumHaptic();
  }

  void _onGoalToggle(String goal) async {
    setState(() {
      if (_selectedGoals.contains(goal)) {
        _selectedGoals.remove(goal);
      } else {
        if (_selectedGoals.length < 3) {
          _selectedGoals.add(goal);
        }
      }
    });
    await AnimationUtils.lightHaptic();
  }

  Future<void> _proceedToCovenant() async {
    if (_selectedGoals.isEmpty) return;

    await controller.save30DayGoals(_selectedGoals.toList());
    await AnimationUtils.heavyHaptic();

    setState(() => _showGoalsSelection = false);

    await AnimationUtils.pause(durationMs: 500);

    // Phase 4.5: The Covenant
    await _phase45TheCovenant();
  }

  Future<void> _phase45TheCovenant() async {
    await AnimationUtils.typeText(
      fullText:
          'God wants to do this and MORE in your life.\n\nBut it requires your daily "yes".',
      onUpdate: (text) => setState(() => _covenantText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showCovenantCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 2000);

    setState(() => _covenantText = '');

    await AnimationUtils.typeText(
      fullText:
          'Before God, ${controller.userName.value}, I commit to guard my heart.\n\nI will use Scripture as my shield.',
      onUpdate: (text) => setState(() => _covenantText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showCovenantCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 3000, withHaptic: true, heavy: true);

    // Transition to next step
    setState(() => _opacity = 0.0);
    await Future.delayed(const Duration(milliseconds: 1000));
    await AnimationUtils.heavyHaptic();
    await Future.delayed(const Duration(milliseconds: 500));

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
                      // Phase 4.1 - Divine Standard
                      if (_standardText.isNotEmpty)
                        RichText(
                          text: TextSpan(
                            style: OnboardingTheme.emphasisText,
                            children: [
                              TextSpan(text: _standardText),
                              if (_showStandardCursor)
                                const WidgetSpan(
                                  child: FeatherCursor(),
                                  alignment: PlaceholderAlignment.middle,
                                ),
                            ],
                          ),
                        ),

                      // Phase 4.2 - Scripture Foundation
                      if (_scriptureText.isNotEmpty)
                        RichText(
                          text: TextSpan(
                            style: OnboardingTheme.verseText,
                            children: [
                              TextSpan(text: _scriptureText),
                              if (_showScriptureCursor)
                                const WidgetSpan(
                                  child: FeatherCursor(),
                                  alignment: PlaceholderAlignment.middle,
                                ),
                            ],
                          ),
                        ),

                      // Phase 4.3 - Vision of Transformation
                      if (_visionIntroText.isNotEmpty)
                        RichText(
                          text: TextSpan(
                            style: OnboardingTheme.emphasisText,
                            children: [
                              TextSpan(text: _visionIntroText),
                              if (_showVisionIntroCursor)
                                const WidgetSpan(
                                  child: FeatherCursor(),
                                  alignment: PlaceholderAlignment.middle,
                                ),
                            ],
                          ),
                        ),

                      if (_showVisionList) ...[
                        const SizedBox(height: 30),
                        ..._visionList.map(
                          (vision) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              vision,
                              style: OnboardingTheme.bodyText.copyWith(
                                color: OnboardingTheme.blueSpirit,
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Phase 4.4 - 2-Week Goals Selection
                      if (_showGoalsSelection) ...[
                        const SizedBox(height: 20),
                        Text(
                          'What do you want God to do in your life in the next 2 weeks?',
                          style: OnboardingTheme.callout.copyWith(
                            color: OnboardingTheme.labelPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Select 1-3 goals:',
                          style: OnboardingTheme.subhead.copyWith(
                            color: OnboardingTheme.goldColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._availableGoals.map((goal) => _buildGoalOption(goal)),
                        const SizedBox(height: 32),
                        Center(
                          child: FastButton(
                            text: 'Continue',
                            onTap: _selectedGoals.isNotEmpty ? _proceedToCovenant : null,
                            backgroundColor: OnboardingTheme.goldColor,
                            textColor: OnboardingTheme.backgroundColor,
                            style: FastButtonStyle.filled,
                            isDisabled: _selectedGoals.isEmpty,
                          ),
                        ),
                      ],

                      // Phase 4.5 - The Covenant
                      if (_covenantText.isNotEmpty)
                        RichText(
                          text: TextSpan(
                            style: OnboardingTheme.emphasisText,
                            children: [
                              TextSpan(text: _covenantText),
                              if (_showCovenantCursor)
                                const WidgetSpan(
                                  child: FeatherCursor(),
                                  alignment: PlaceholderAlignment.middle,
                                ),
                            ],
                          ),
                        ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalOption(String goal) {
    final isSelected = _selectedGoals.contains(goal);
    final canSelect = _selectedGoals.length < 3 || isSelected;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: GestureDetector(
        onTap: canSelect ? () => _onGoalToggle(goal) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? OnboardingTheme.goldColor.withValues(alpha: 0.15)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? OnboardingTheme.goldColor
                  : OnboardingTheme.labelSecondary.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? OnboardingTheme.goldColor
                        : OnboardingTheme.labelSecondary.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  color: isSelected ? OnboardingTheme.goldColor : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: OnboardingTheme.backgroundColor,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  goal,
                  style: OnboardingTheme.subhead.copyWith(
                    color: isSelected
                        ? OnboardingTheme.labelPrimary
                        : canSelect
                            ? OnboardingTheme.labelPrimary.withValues(alpha: 0.8)
                            : OnboardingTheme.labelSecondary,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
