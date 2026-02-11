import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/feather_cursor.dart';
import 'package:faithlock/features/onboarding/widgets/fingerprint_scanner.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
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
  String _covenantText = '';
  bool _showCovenantText = false;
  bool _showScanner = false;

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
          'finalEnc_message'.trParams({'name': userName}),
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
          'finalEnc_verse'.tr,
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
          'finalEnc_final'.tr,
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

    // // First: Show intro text
    // await AnimationUtils.typeText(
    //   fullText:
    //       '${controller.userName.value}, seal your commitment before God...',
    //   onUpdate: (text) => setState(() => _signatureText = text),
    //   onCursorVisibility: (visible) =>
    //       setState(() => _showSignatureCursor = visible),
    //   speedMs: 40,
    // );

    // await AnimationUtils.pause(durationMs: 1000);

    // // Then: Show the covenant text
    // setState(() {
    //   _showSignatureCursor = false;
    //   _covenantText =
    //       'Before God, ${controller.userName.value}, I commit to guard my heart.\n\nI will use Scripture as my shield.';
    //   _showCovenantText = true;
    // });

    // await AnimationUtils.pause(durationMs: 2000, withHaptic: true);

    // // Finally: Show scanner
    setState(() => _showScanner = true);
    await AnimationUtils.mediumHaptic();
  }

  Future<void> _onScanComplete() async {
    await controller.acceptCovenant(true);
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
              top: 40,
              bottom: OnboardingTheme.verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
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

                // Phase 9.4 - Signature intro text
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

                // Covenant text (displayed after intro)
                if (_showCovenantText) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: OnboardingTheme.goldColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: OnboardingTheme.goldColor.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      _covenantText,
                      style: OnboardingTheme.body.copyWith(
                        fontSize: 17,
                        height: 1.6,
                        color: OnboardingTheme.goldColor,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                // Fingerprint scanner for final seal
                if (_showScanner) ...[
                  const SizedBox(height: 40),
                  FingerprintScanner(
                    userName: controller.userName.value,
                    onComplete: _onScanComplete,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
