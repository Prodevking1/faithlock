import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/feather_cursor.dart';
import 'package:faithlock/features/onboarding/widgets/fingerprint_scanner.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Step 6: Final Encouragement - Launch into Freedom
/// Final message of hope and launch button
class Step6FinalEncouragement extends StatefulWidget {
  final VoidCallback onComplete;

  const Step6FinalEncouragement({
    super.key,
    required this.onComplete,
  });

  @override
  State<Step6FinalEncouragement> createState() =>
      _Step6FinalEncouragementState();
}

class _Step6FinalEncouragementState extends State<Step6FinalEncouragement> {
  final controller = Get.find<ScriptureOnboardingController>();

  // Phase 9.1 - Encouragement
  String _encouragementText = '';
  bool _showEncouragementCursor = false;

  // Phase 9.2 - Scripture Promise
  String _scriptureText = '';
  bool _showScriptureCursor = false;

  // Phase 9.3 - Final Message
  String _finalText = '';
  bool _showFinalCursor = false;

  // Phase 9.4 - Signature
  String _signatureText = '';
  bool _showSignatureCursor = false;
  bool _showScanner = false;
  bool _scanComplete = false;
  bool _showButton = false;

  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Phase 9.1: Encouragement
    await _phase91Encouragement();

    // Phase 9.2: Scripture Promise
    await _phase92ScripturePromise();

    // Phase 9.3: Final Message
    await _phase93FinalMessage();

    // Phase 9.4: Signature (wait for user scan)
    await _phase94Signature();
  }

  Future<void> _phase91Encouragement() async {
    final userName = controller.userName.value;

    await AnimationUtils.typeText(
      fullText:
          '$userName, you are not alone in this battle.\n\nGod\'s Word will be your shield every single day.',
      onUpdate: (text) => setState(() => _encouragementText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showEncouragementCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 2500);
  }

  Future<void> _phase92ScripturePromise() async {
    setState(() {
      _encouragementText = '';
      _showEncouragementCursor = false;
    });

    await AnimationUtils.typeText(
      fullText:
          'I can do all things through Christ who strengthens me.\n— Philippians 4:13',
      onUpdate: (text) => setState(() => _scriptureText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showScriptureCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 2500);
  }

  Future<void> _phase93FinalMessage() async {
    setState(() {
      _scriptureText = '';
      _showScriptureCursor = false;
    });

    await AnimationUtils.typeText(
      fullText:
          'Your journey to freedom starts now.\n\nEvery time you resist, you become stronger.',
      onUpdate: (text) => setState(() => _finalText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showFinalCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 2000);
  }

  Future<void> _phase94Signature() async {
    setState(() {
      _finalText = '';
      _showFinalCursor = false;
    });

    await AnimationUtils.typeText(
      fullText: '${controller.userName.value}, seal your commitment before God...',
      onUpdate: (text) => setState(() => _signatureText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showSignatureCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 1500);

    setState(() => _showScanner = true);
    await AnimationUtils.mediumHaptic();
  }

  Future<void> _onScanComplete() async {
    await controller.acceptCovenant(true);
    await AnimationUtils.heavyHaptic();

    setState(() {
      _scanComplete = true;
      _signatureText = '';
      _showSignatureCursor = false;
    });

    await AnimationUtils.pause(durationMs: 2000);

    // Show final button
    setState(() => _showButton = true);
    await AnimationUtils.mediumHaptic();
  }

  Future<void> _onBeginJourney() async {
    await controller.completeOnboarding();
    await AnimationUtils.heavyHaptic();

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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: OnboardingTheme.horizontalPadding,
                  vertical: OnboardingTheme.verticalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Phase 9.1 - Encouragement
                    if (_encouragementText.isNotEmpty)
                      RichText(
                        text: TextSpan(
                          style: OnboardingTheme.emphasisText,
                          children: [
                            TextSpan(text: _encouragementText),
                            if (_showEncouragementCursor)
                              const WidgetSpan(
                                child: FeatherCursor(),
                                alignment: PlaceholderAlignment.middle,
                              ),
                          ],
                        ),
                      ),

                    // Phase 9.2 - Scripture Promise
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

                    // Phase 9.3 - Final Message
                    if (_finalText.isNotEmpty)
                      RichText(
                        text: TextSpan(
                          style: OnboardingTheme.emphasisText,
                          children: [
                            TextSpan(text: _finalText),
                            if (_showFinalCursor)
                              const WidgetSpan(
                                child: FeatherCursor(),
                                alignment: PlaceholderAlignment.middle,
                              ),
                          ],
                        ),
                      ),

                    // Phase 9.4 - Signature
                    if (_signatureText.isNotEmpty)
                      RichText(
                        text: TextSpan(
                          style: OnboardingTheme.emphasisText,
                          children: [
                            TextSpan(text: _signatureText),
                            if (_showSignatureCursor)
                              const WidgetSpan(
                                child: FeatherCursor(),
                                alignment: PlaceholderAlignment.middle,
                              ),
                          ],
                        ),
                      ),

                    // Fingerprint scanner for final seal
                    if (_showScanner) ...[
                      const SizedBox(height: 40),
                      FingerprintScanner(
                        userName: controller.userName.value,
                        onComplete: _onScanComplete,
                      ),
                    ],

                    // Launch Button (only after seal)
                    if (_showButton) ...[
                      const SizedBox(height: 60),
                      Center(
                        child: FastButton(
                          text: 'Begin My Journey',
                          onTap: _onBeginJourney,
                          backgroundColor: OnboardingTheme.goldColor,
                          textColor: OnboardingTheme.backgroundColor,
                          style: FastButtonStyle.filled,
                        ),
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
