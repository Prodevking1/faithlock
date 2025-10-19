import 'package:flutter/material.dart';
import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/widgets/feather_cursor.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';

/// Step 1: Divine Revelation - Pattern Interrupt
/// Establishes God's perspective on time and creates immediate spiritual awareness
class Step1DivineRevelation extends StatefulWidget {
  final VoidCallback onComplete;

  const Step1DivineRevelation({
    super.key,
    required this.onComplete,
  });

  @override
  State<Step1DivineRevelation> createState() => _Step1DivineRevelationState();
}

class _Step1DivineRevelationState extends State<Step1DivineRevelation> {
  String _verseText = '';
  String _questionText = '';
  bool _showVerseCursor = false;
  bool _showQuestionCursor = false;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Wait for UI to settle
    await Future.delayed(const Duration(milliseconds: 500));

    // Phase 1: Type verse (0-3s)
    await AnimationUtils.typeText(
      fullText: 'Redeem the time, for the days are evil.',
      onUpdate: (text) => setState(() => _verseText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showVerseCursor = visible),
      speedMs: 40,
      withHaptic: true,
    );

    // Add reference
    setState(() => _verseText += '\n— Ephesians 5:16');

    // Pause (1s)
    await AnimationUtils.pause(durationMs: 1000);

    // Phase 2: Type question (3-8s)
    await AnimationUtils.typeText(
      fullText:
          'God sees every moment. How are you using the time He gave you?',
      onUpdate: (text) => setState(() => _questionText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showQuestionCursor = visible),
      speedMs: 40,
      withHaptic: true,
    );

    // Let it sink in (2s)
    await AnimationUtils.pause(durationMs: 2000);

    // Phase 3: Fade out (8-10s)
    setState(() => _opacity = 0.0);
    await Future.delayed(const Duration(milliseconds: 1000));

    // Phase 4: Dark screen with heavy haptic (10-11.5s)
    await AnimationUtils.pause(
      durationMs: 1500,
      withHaptic: true,
      heavy: true,
    );

    // Transition to Step 2
    widget.onComplete();
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
                // Verse with inline cursor
                RichText(
                  text: TextSpan(
                    style: OnboardingTheme.verseText,
                    children: [
                      TextSpan(text: _verseText),
                      if (_showVerseCursor)
                        const WidgetSpan(
                          child: FeatherCursor(),
                          alignment: PlaceholderAlignment.middle,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Question with inline cursor
                RichText(
                  text: TextSpan(
                    style: OnboardingTheme.questionText,
                    children: [
                      TextSpan(text: _questionText),
                      if (_showQuestionCursor)
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
    );
  }
}
