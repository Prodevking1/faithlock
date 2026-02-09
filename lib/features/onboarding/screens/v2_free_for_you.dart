import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/paywall/screens/paywall_screen_v2.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/mascot/judah_mascot.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// V2 Free For You - Soft transition before paywall
/// Judah happy, reassuring tone, leads naturally into free trial offer
class V2FreeForYou extends StatefulWidget {
  const V2FreeForYou({super.key});

  @override
  State<V2FreeForYou> createState() => _V2FreeForYouState();
}

class _V2FreeForYouState extends State<V2FreeForYou> {
  final controller = Get.find<ScriptureOnboardingController>();

  bool _showMascot = false;
  bool _showTitle = false;
  bool _showBenefits = false;
  bool _showButton = false;
  final List<bool> _visibleBenefits = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Mascot
    setState(() => _showMascot = true);
    await AnimationUtils.mediumHaptic();

    await Future.delayed(const Duration(milliseconds: 600));

    // Title
    setState(() => _showTitle = true);
    await AnimationUtils.lightHaptic();

    await Future.delayed(const Duration(milliseconds: 500));

    // Benefits
    setState(() => _showBenefits = true);
    for (int i = 0; i < _visibleBenefits.length; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() => _visibleBenefits[i] = true);
      await AnimationUtils.lightHaptic();
    }

    await Future.delayed(const Duration(milliseconds: 600));

    // Button
    setState(() => _showButton = true);
    await AnimationUtils.heavyHaptic();
  }

  Future<void> _onStartFreeTrial() async {
    await AnimationUtils.heavyHaptic();
    await controller.completeOnboarding();
    Get.off(() => const PaywallScreenV2());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTheme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Content
            Positioned.fill(
              bottom: _showButton ? 130 : 0,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: OnboardingTheme.horizontalPadding,
                  right: OnboardingTheme.horizontalPadding,
                  top: 60,
                  bottom: OnboardingTheme.verticalPadding,
                ),
                child: Column(
                  children: [
                    // Judah happy
                    AnimatedOpacity(
                      opacity: _showMascot ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 600),
                      child: const JudahMascot(
                        state: JudahState.happy,
                        size: JudahSize.xl,
                        showMessage: false,
                      ),
                    ),
                    const SizedBox(height: OnboardingTheme.space32),

                    // Title
                    AnimatedOpacity(
                      opacity: _showTitle ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          Text(
                            'freeForYou_title'.tr,
                            style: OnboardingTheme.title2.copyWith(
                              color: OnboardingTheme.goldColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: OnboardingTheme.space12),
                          Text(
                            'freeForYou_subtitle'.tr,
                            style: OnboardingTheme.callout,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: OnboardingTheme.space40),

                    // Benefits
                    if (_showBenefits) ...[
                      _buildBenefit(
                        0,
                        Icons.menu_book,
                        'freeForYou_benefit1'.tr,
                      ),
                      _buildBenefit(
                        1,
                        Icons.schedule,
                        'freeForYou_benefit2'.tr,
                      ),
                      _buildBenefit(
                        2,
                        Icons.notifications_active,
                        'freeForYou_benefit3'.tr,
                      ),
                      _buildBenefit(
                        3,
                        Icons.bar_chart,
                        'freeForYou_benefit4'.tr,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Button
            if (_showButton)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        OnboardingTheme.backgroundColor.withValues(alpha: 0),
                        OnboardingTheme.backgroundColor,
                        OnboardingTheme.backgroundColor,
                      ],
                      stops: const [0.0, 0.3, 1.0],
                    ),
                  ),
                  padding: const EdgeInsets.only(
                    left: 40,
                    right: 40,
                    top: 30,
                    bottom: 50,
                  ),
                  child: AnimatedOpacity(
                    opacity: _showButton ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FastButton(
                          text: 'freeForYou_startTrial'.tr,
                          onTap: _onStartFreeTrial,
                          backgroundColor: OnboardingTheme.goldColor,
                          textColor: OnboardingTheme.backgroundColor,
                          style: FastButtonStyle.filled,
                        ),
                        const SizedBox(height: OnboardingTheme.space12),
                        Text(
                          'freeForYou_trialPeriod'.tr,
                          style: OnboardingTheme.caption.copyWith(
                            color: OnboardingTheme.labelSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(int index, IconData icon, String text) {
    return AnimatedOpacity(
      opacity: _visibleBenefits[index] ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: AnimatedSlide(
        offset: _visibleBenefits[index] ? Offset.zero : const Offset(0, 0.3),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        child: Padding(
          padding: const EdgeInsets.only(bottom: OnboardingTheme.space12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: OnboardingTheme.goldColor.withValues(alpha: 0.15),
                ),
                child: Icon(
                  icon,
                  color: OnboardingTheme.goldColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: OnboardingTheme.footnote.copyWith(
                    color: OnboardingTheme.labelPrimary,
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
