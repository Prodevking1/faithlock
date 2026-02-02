import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_v2_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// V2 Commitment Level - "How committed are you?" pre-commitment screen
/// 5 levels from curious to on fire, drives sunk cost and self-identification
class V2CommitmentLevel extends StatefulWidget {
  final VoidCallback onComplete;

  const V2CommitmentLevel({
    super.key,
    required this.onComplete,
  });

  @override
  State<V2CommitmentLevel> createState() => _V2CommitmentLevelState();
}

class _V2CommitmentLevelState extends State<V2CommitmentLevel> {
  final controller =
      Get.find<ScriptureOnboardingController>() as ScriptureOnboardingV2Controller;

  bool _showContent = false;
  String? _selectedLevel;
  double _opacity = 1.0;

  List<_CommitmentOption> get _levels => [
    _CommitmentOption(
      id: 'curious',
      title: 'commitment_curious'.tr,
      subtitle: 'commitment_curiousSub'.tr,
      icon: Icons.search,
      color: OnboardingTheme.labelSecondary,
    ),
    _CommitmentOption(
      id: 'interested',
      title: 'commitment_interested'.tr,
      subtitle: 'commitment_interestedSub'.tr,
      icon: Icons.lightbulb_outline,
      color: OnboardingTheme.systemBlue,
    ),
    _CommitmentOption(
      id: 'ready',
      title: 'commitment_ready'.tr,
      subtitle: 'commitment_readySub'.tr,
      icon: Icons.trending_up,
      color: OnboardingTheme.systemOrange,
    ),
    _CommitmentOption(
      id: 'all_in',
      title: 'commitment_allIn'.tr,
      subtitle: 'commitment_allInSub'.tr,
      icon: Icons.local_fire_department,
      color: OnboardingTheme.goldColor,
    ),
    _CommitmentOption(
      id: 'on_fire',
      title: 'commitment_onFire'.tr,
      subtitle: 'commitment_onFireSub'.tr,
      icon: Icons.whatshot,
      color: OnboardingTheme.systemRed,
    ),
  ];

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

  void _onLevelSelected(String levelId) {
    setState(() => _selectedLevel = levelId);
    AnimationUtils.lightHaptic();
  }

  Future<void> _onContinue() async {
    if (_selectedLevel == null) return;

    await controller.saveCommitmentLevel(_selectedLevel!);
    await AnimationUtils.heavyHaptic();

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
              children: [
                Text(
                  'commitment_title'.tr,
                  style: OnboardingTheme.title2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: OnboardingTheme.space8),
                Text(
                  'commitment_subtitle'.tr,
                  style: OnboardingTheme.callout,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: OnboardingTheme.space32),

                // Commitment levels
                ..._levels.map((level) => _buildLevelOption(level)),

                const SizedBox(height: OnboardingTheme.space32),

                FastButton(
                  text: 'continue_btn'.tr,
                  onTap: _selectedLevel != null ? _onContinue : null,
                  backgroundColor: OnboardingTheme.goldColor,
                  textColor: OnboardingTheme.backgroundColor,
                  style: FastButtonStyle.filled,
                  isDisabled: _selectedLevel == null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelOption(_CommitmentOption level) {
    final isSelected = _selectedLevel == level.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: OnboardingTheme.space12),
      child: GestureDetector(
        onTap: () => _onLevelSelected(level.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? level.color.withValues(alpha: 0.15)
                : OnboardingTheme.cardBackground,
            border: Border.all(
              color: isSelected
                  ? level.color
                  : OnboardingTheme.cardBorder,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(OnboardingTheme.radiusMedium),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? level.color.withValues(alpha: 0.2)
                      : OnboardingTheme.cardBackground,
                ),
                child: Icon(
                  level.icon,
                  color: isSelected ? level.color : OnboardingTheme.labelTertiary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.title,
                      style: OnboardingTheme.body.copyWith(
                        color: isSelected
                            ? OnboardingTheme.labelPrimary
                            : OnboardingTheme.labelPrimary.withValues(alpha: 0.8),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      level.subtitle,
                      style: OnboardingTheme.caption.copyWith(
                        color: isSelected
                            ? level.color
                            : OnboardingTheme.labelTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: level.color,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommitmentOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _CommitmentOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
