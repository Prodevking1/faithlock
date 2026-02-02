import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/mascot/judah_mascot.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// V2 Goals Selection - Simplified from Step4CallToCovenant
/// Removed: passive intro phases (Divine Standard, Scripture, Vision, Covenant)
/// Added: Judah encouraging mascot
/// Kept: Goals selection UI (1-3 goals)
class V2GoalsSelection extends StatefulWidget {
  final VoidCallback onComplete;

  const V2GoalsSelection({
    super.key,
    required this.onComplete,
  });

  @override
  State<V2GoalsSelection> createState() => _V2GoalsSelectionState();
}

class _V2GoalsSelectionState extends State<V2GoalsSelection> {
  final controller = Get.find<ScriptureOnboardingController>();

  List<String> get _availableGoals => [
    'goals_restorePrayer'.tr,
    'goals_breakAddiction'.tr,
    'goals_healRelationships'.tr,
    'goals_findPurpose'.tr,
    'goals_overcomeFear'.tr,
    'goals_buildDiscipline'.tr,
    'goals_growHoliness'.tr,
  ];
  final Set<String> _selectedGoals = {};

  double _opacity = 1.0;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _showContent = true);
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

  Future<void> _onContinue() async {
    if (_selectedGoals.isEmpty) return;

    await controller.save30DayGoals(_selectedGoals.toList());
    await AnimationUtils.heavyHaptic();

    // Fade out
    setState(() => _opacity = 0.0);
    await Future.delayed(const Duration(milliseconds: 800));

    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 800),
        child: AnimatedOpacity(
          opacity: _showContent ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: OnboardingTheme.horizontalPadding,
              right: OnboardingTheme.horizontalPadding,
              top: 80,
              bottom: OnboardingTheme.verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judah encouraging
                Center(
                  child: JudahMascot(
                    state: JudahState.encouraging,
                    size: JudahSize.l,
                    message: 'goals_mascot'.tr,
                  ),
                ),
                const SizedBox(height: OnboardingTheme.space24),

                Text(
                  'goals_title'.tr,
                  style: OnboardingTheme.callout.copyWith(
                    color: OnboardingTheme.labelPrimary,
                  ),
                ),
                const SizedBox(height: OnboardingTheme.space20),
                Text(
                  'goals_subtitle'.tr,
                  style: OnboardingTheme.subhead.copyWith(
                    color: OnboardingTheme.goldColor,
                  ),
                ),
                const SizedBox(height: OnboardingTheme.space16),
                ..._availableGoals.map((goal) => _buildGoalOption(goal)),
                const SizedBox(height: OnboardingTheme.space32),
                Center(
                  child: FastButton(
                    text: 'continue_btn'.tr,
                    onTap: _selectedGoals.isNotEmpty ? _onContinue : null,
                    backgroundColor: OnboardingTheme.goldColor,
                    textColor: OnboardingTheme.backgroundColor,
                    style: FastButtonStyle.filled,
                    isDisabled: _selectedGoals.isEmpty,
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
