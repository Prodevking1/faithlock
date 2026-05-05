import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_v3_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// V3 Reveal Screen - Opal-style "bad news / good news".
/// Personalizes the punch using the user's actual hours/day data.
class V3RevealScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const V3RevealScreen({super.key, required this.onComplete});

  @override
  State<V3RevealScreen> createState() => _V3RevealScreenState();
}

class _V3RevealScreenState extends State<V3RevealScreen> {
  final controller = Get.find<ScriptureOnboardingV3Controller>();

  bool _showHeader = false;
  bool _showBadNews = false;
  bool _showGoodNews = false;
  bool _showButton = false;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _showHeader = true);
    await AnimationUtils.mediumHaptic();

    await Future.delayed(const Duration(milliseconds: 900));
    setState(() => _showBadNews = true);
    await AnimationUtils.heavyHaptic();

    await Future.delayed(const Duration(milliseconds: 1400));
    setState(() => _showGoodNews = true);
    await AnimationUtils.mediumHaptic();

    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _showButton = true);
    await AnimationUtils.lightHaptic();
  }

  Future<void> _onContinue() async {
    await AnimationUtils.heavyHaptic();
    setState(() => _opacity = 0.0);
    await Future.delayed(const Duration(milliseconds: 500));
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final stats = controller.calculateRevealStats();
    final daysPerYear = stats['daysPerYear'] as int;
    final lifetimeYears = stats['lifetimeYears'] as String;

    return OnboardingWrapper(
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 500),
        child: Padding(
          padding: const EdgeInsets.only(
            left: OnboardingTheme.horizontalPadding,
            right: OnboardingTheme.horizontalPadding,
            top: 100,
            bottom: OnboardingTheme.verticalPadding,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FadeIn(
                  visible: _showHeader,
                  child: Text(
                    'Some not-so-good news,\nand some great news.',
                    style: OnboardingTheme.title2.copyWith(
                      color: OnboardingTheme.labelPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: OnboardingTheme.space40),
                _FadeIn(
                  visible: _showBadNews,
                  child: _RevealCard(
                    label: 'The bad news',
                    accent: OnboardingTheme.systemRed,
                    body:
                        "Your screen has become a second altar — one that asks for your time, your peace, your attention. You'll spend $daysPerYear days on your phone this year. You're on track to spend $lifetimeYears years of your life looking down at your screen, and not praying.",
                  ),
                ),
                const SizedBox(height: OnboardingTheme.space20),
                _FadeIn(
                  visible: _showGoodNews,
                  child: _RevealCard(
                    label: 'The good news',
                    accent: OnboardingTheme.goldColor,
                    body:
                        "FaithLock gives back your time — to the One who gave you life. Same hours, for a completely different app.",
                  ),
                ),
                const SizedBox(height: OnboardingTheme.space40),
                _FadeIn(
                  visible: _showButton,
                  child: FastButton(
                    text: 'Redeem my time',
                    onTap: _onContinue,
                    backgroundColor: OnboardingTheme.goldColor,
                    textColor: OnboardingTheme.backgroundColor,
                    style: FastButtonStyle.filled,
                  ),
                ),
                const SizedBox(height: OnboardingTheme.space24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FadeIn extends StatelessWidget {
  final bool visible;
  final Widget child;
  const _FadeIn({required this.visible, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 0.05),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }
}

class _RevealCard extends StatelessWidget {
  final String label;
  final String body;
  final Color accent;

  const _RevealCard({
    required this.label,
    required this.body,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(OnboardingTheme.space20),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(OnboardingTheme.radiusLarge),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: OnboardingTheme.caption.copyWith(
              color: accent,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: OnboardingTheme.space12),
          Text(
            body,
            style: OnboardingTheme.body.copyWith(
              color: OnboardingTheme.labelPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
