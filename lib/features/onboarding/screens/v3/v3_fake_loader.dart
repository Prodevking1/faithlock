import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/shared/widgets/mascot/judah_mascot.dart';
import 'package:flutter/material.dart';

/// V3 Fake Loader - Calculates user's "spiritual time profile".
/// Pure perception screen: builds anticipation before the reveal.
class V3FakeLoader extends StatefulWidget {
  final VoidCallback onComplete;
  const V3FakeLoader({super.key, required this.onComplete});

  @override
  State<V3FakeLoader> createState() => _V3FakeLoaderState();
}

class _V3FakeLoaderState extends State<V3FakeLoader>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  int _stepIndex = 0;

  static const _steps = [
    'Analyzing your screen habits…',
    'Comparing time on phone vs. time in prayer…',
    'Calculating what could be reclaimed…',
    'Preparing your honest reflection…',
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..forward();
    _runSequence();
  }

  Future<void> _runSequence() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1100));
      if (!mounted) return;
      setState(() => _stepIndex = i);
      await AnimationUtils.lightHaptic();
    }
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    await AnimationUtils.heavyHaptic();
    widget.onComplete();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: OnboardingTheme.horizontalPadding,
          vertical: OnboardingTheme.verticalPadding,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const JudahMascot(
              state: JudahState.sleeping,
              size: JudahSize.l,
              showMessage: false,
            ),
            const SizedBox(height: OnboardingTheme.space40),
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, _) {
                return SizedBox(
                  width: 220,
                  child: LinearProgressIndicator(
                    value: _progressController.value,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(8),
                    backgroundColor:
                        OnboardingTheme.labelTertiary.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      OnboardingTheme.goldColor,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: OnboardingTheme.space24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                _steps[_stepIndex],
                key: ValueKey(_stepIndex),
                style: OnboardingTheme.callout.copyWith(
                  color: OnboardingTheme.labelSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
