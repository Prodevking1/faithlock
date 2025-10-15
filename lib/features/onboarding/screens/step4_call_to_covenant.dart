import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/feather_cursor.dart';
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

  // Phase 4.4 - The Covenant
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

    // Phase 4.4: The Covenant (wait for user)
    await _phase44TheCovenant();
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
  }

  Future<void> _phase44TheCovenant() async {
    setState(() {
      _visionIntroText = '';
      _showVisionList = false;
      _visionList.clear();
    });

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
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: OnboardingTheme.horizontalPadding,
                    vertical: OnboardingTheme.verticalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
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

                      // Phase 4.4 - The Covenant
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
            ],
          ),
        ),
      ),
    );
  }
}
