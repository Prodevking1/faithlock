import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_v3_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/shared/widgets/cozy/cozy.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

/// V3 Glowe Attribution Screen - Asks users how they found Glowe
/// Uses HugeIcons for platform logos
/// Placed before the final two steps (Screen Time permission and Attribution)
class V3GloweAttribution extends StatefulWidget {
  final VoidCallback onComplete;
  const V3GloweAttribution({super.key, required this.onComplete});

  @override
  State<V3GloweAttribution> createState() => _V3GloweAttributionState();
}

class _V3GloweAttributionState extends State<V3GloweAttribution> {
  final controller = Get.find<ScriptureOnboardingV3Controller>();
  String? _selected;
  double _opacity = 1.0;

  static const _sources = [
    _Source('tiktok', 'TikTok', HugeIcons.strokeRoundedMusicNote01, Color(0xFFFE2C55)),
    _Source('instagram', 'Instagram', HugeIcons.strokeRoundedCamera01, Color(0xFFE4405F)),
    _Source('appstore', 'App Store', HugeIcons.strokeRoundedAppStore, Color(0xFF0071E3)),
    _Source('ai', 'AI (ChatGPT, etc.)', HugeIcons.strokeRoundedBrain, Color(0xFF4A4A4A)),
    _Source('google', 'Google', HugeIcons.strokeRoundedSearch01, Color(0xFF4285F4)),
  ];

  Future<void> _onContinue() async {
    if (_selected == null) return;

    await controller.saveGloweAttribution(_selected!);
    await AnimationUtils.heavyHaptic();

    setState(() => _opacity = 0.0);
    await Future.delayed(const Duration(milliseconds: 400));
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 400),
        child: Stack(
          children: [
            Positioned.fill(
              bottom: 110,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 96, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How did you find Glowe?',
                      style: CozyText.title,
                    ),
                    const SizedBox(height: CozyTokens.space24),
                    ..._sources.asMap().entries.map((entry) {
                      final index = entry.key;
                      final src = entry.value;
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 350 + (index * 60)),
                        curve: Curves.easeOut,
                        builder: (context, value, child) => Transform.translate(
                          offset: Offset(0, 16 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _SourceCard(
                            source: src,
                            isSelected: _selected == src.id,
                            onTap: () {
                              AnimationUtils.lightHaptic();
                              setState(() => _selected = src.id);
                            },
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      CozyColors.background.withValues(alpha: 0),
                      CozyColors.background,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CozyButton(
                        text: 'Skip',
                        onTap: () {
                          AnimationUtils.lightHaptic();
                          widget.onComplete();
                        },
                        variant: CozyButtonVariant.secondary,
                      ),
                    ),
                    const SizedBox(width: CozyTokens.space16),
                    Expanded(
                      child: CozyButton(
                        text: 'Continue',
                        onTap: _selected != null ? _onContinue : null,
                        isDisabled: _selected == null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Source {
  final String id;
  final String label;
  final IconData icon;
  final Color iconColor;
  const _Source(this.id, this.label, this.icon, this.iconColor);
}

class _SourceCard extends StatelessWidget {
  final _Source source;
  final bool isSelected;
  final VoidCallback onTap;

  const _SourceCard({
    required this.source,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = CozyColors.primary;
    return CozyTappable(
      onTap: onTap,
      pressedScale: 0.98,
      child: AnimatedContainer(
        duration: CozyTokens.base,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: ShapeDecoration(
          color: isSelected ? CozyColors.selectedFill : CozyColors.surface,
          shape: CozyTokens.smooth(
            CozyTokens.radiusLg,
            side: BorderSide(
              color: isSelected ? accent : CozyColors.outline,
              width: CozyTokens.borderWidth,
            ),
          ),
          shadows: CozyTokens.shadowHard,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Center(
                child: HugeIcon(
                  icon: source.icon,
                  size: 18,
                  color: source.iconColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                source.label,
                style: CozyText.body.copyWith(
                  color: isSelected ? accent : CozyColors.ink,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: CozyColors.surface, width: 2),
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedTick02,
                  size: 14,
                  color: CozyColors.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
