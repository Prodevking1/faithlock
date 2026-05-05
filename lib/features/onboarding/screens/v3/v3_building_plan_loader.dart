import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_v3_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/shared/widgets/mascot/judah_mascot.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// V3 Building Plan Loader - Pre-paywall theatrical loader.
/// Communicates value before the paywall: "we crafted this for you".
class V3BuildingPlanLoader extends StatefulWidget {
  final VoidCallback onComplete;
  const V3BuildingPlanLoader({super.key, required this.onComplete});

  @override
  State<V3BuildingPlanLoader> createState() => _V3BuildingPlanLoaderState();
}

class _V3BuildingPlanLoaderState extends State<V3BuildingPlanLoader>
    with TickerProviderStateMixin {
  final controller = Get.find<ScriptureOnboardingV3Controller>();
  late AnimationController _progressController;
  int _stepIndex = 0;

  static const _steps = [
    'Building your personalized plan…',
    'Configuring your prayer rhythm…',
    'Selecting verses for your tradition…',
    'Sealing your covenant…',
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..forward();
    _runSequence();
  }

  Future<void> _runSequence() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      setState(() => _stepIndex = i);
      await AnimationUtils.lightHaptic();
    }
    await Future.delayed(const Duration(milliseconds: 700));
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
    final name = controller.userName.value;
    final greeting = name.isNotEmpty && name != 'User'
        ? 'Almost there, $name.'
        : 'Almost there.';

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
              state: JudahState.proud,
              size: JudahSize.l,
              showMessage: false,
            ),
            const SizedBox(height: OnboardingTheme.space24),
            Text(
              greeting,
              style: OnboardingTheme.title3.copyWith(
                color: OnboardingTheme.goldColor,
              ),
            ),
            const SizedBox(height: OnboardingTheme.space24),
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
            const SizedBox(height: OnboardingTheme.space20),
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
