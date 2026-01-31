import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/feather_cursor.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:faithlock/shared/widgets/buttons/fast_plain_button.dart';
import 'package:flutter/material.dart';

/// Rating Request Screen - Matches permission screen design
class RatingRequestScreen extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback onRate;
  final VoidCallback onSkip;
  final bool useOnboardingWrapper;

  const RatingRequestScreen({
    super.key,
    required this.title,
    required this.message,
    required this.onRate,
    required this.onSkip,
    this.useOnboardingWrapper = false,
  });

  @override
  State<RatingRequestScreen> createState() => _RatingRequestScreenState();
}

class _RatingRequestScreenState extends State<RatingRequestScreen> {
  String _introText = '';
  bool _showIntroCursor = false;

  String _explanationText = '';
  bool _showExplanationCursor = false;

  bool _showButton = false;
  bool _isProcessing = false;

  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));

    await _phase1Introduction();
    await _phase2Explanation();
    await _phase3CallToAction();
  }

  Future<void> _phase1Introduction() async {
    await AnimationUtils.typeText(
      fullText: widget.title,
      onUpdate: (text) => setState(() => _introText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showIntroCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 2000);
  }

  Future<void> _phase2Explanation() async {
    setState(() {
      _introText = '';
      _showIntroCursor = false;
    });

    await AnimationUtils.typeText(
      fullText: widget.message,
      onUpdate: (text) => setState(() => _explanationText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showExplanationCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 2500);
  }

  Future<void> _phase3CallToAction() async {
    setState(() {
      _explanationText = '';
      _showExplanationCursor = false;
      _showButton = true;
    });

    await AnimationUtils.mediumHaptic();
  }

  Future<void> _onRate() async {
    if (_isProcessing) return;

    await AnimationUtils.heavyHaptic();

    setState(() {
      _isProcessing = true;
    });

    widget.onRate();
  }

  Future<void> _onSkip() async {
    if (_isProcessing) return;

    await AnimationUtils.lightHaptic();
    widget.onSkip();
  }

  Widget _buildBenefitItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: OnboardingTheme.goldColor.withValues(alpha: 0.1),
          ),
          child: Icon(
            icon,
            size: 20,
            color: OnboardingTheme.goldColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: OnboardingTheme.body.copyWith(
              color: OnboardingTheme.labelPrimary,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 1000),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: OnboardingTheme.horizontalPadding,
            right: OnboardingTheme.horizontalPadding,
            top: 100,
            bottom: OnboardingTheme.verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
                if (_introText.isNotEmpty)
                  RichText(
                    text: TextSpan(
                      style: OnboardingTheme.bodyEmphasized,
                      children: [
                        TextSpan(text: _introText),
                        if (_showIntroCursor)
                          const WidgetSpan(
                            child: FeatherCursor(),
                            alignment: PlaceholderAlignment.middle,
                          ),
                      ],
                    ),
                  ),
                if (_explanationText.isNotEmpty)
                  RichText(
                    text: TextSpan(
                      style: OnboardingTheme.bodyEmphasized,
                      children: [
                        TextSpan(text: _explanationText),
                        if (_showExplanationCursor)
                          const WidgetSpan(
                            child: FeatherCursor(),
                            alignment: PlaceholderAlignment.middle,
                          ),
                      ],
                    ),
                  ),
                if (_showButton) ...[
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      'Share Your Experience',
                      style: OnboardingTheme.title2.copyWith(
                        color: OnboardingTheme.labelPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            OnboardingTheme.goldColor.withValues(alpha: 0.2),
                            OnboardingTheme.goldColor.withValues(alpha: 0.05),
                          ],
                        ),
                        border: Border.all(
                          color:
                              OnboardingTheme.goldColor.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.favorite,
                        size: 50,
                        color: OnboardingTheme.goldColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildBenefitItem(
                    icon: Icons.people,
                    text: 'Help others discover FaithLock',
                  ),
                  const SizedBox(height: 16),
                  _buildBenefitItem(
                    icon: Icons.volunteer_activism,
                    text: 'Support our mission to spread faith',
                  ),
                  const SizedBox(height: 16),
                  _buildBenefitItem(
                    icon: Icons.auto_awesome,
                    text: 'Encourage our small team',
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: OnboardingTheme.goldColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: OnboardingTheme.goldColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: OnboardingTheme.goldColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your honest review helps us improve',
                            style: OnboardingTheme.footnote.copyWith(
                              color: OnboardingTheme.goldColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: FastButton(
                      text: _isProcessing ? 'Opening...' : 'Rate FaithLock',
                      onTap: _isProcessing ? null : _onRate,
                      backgroundColor: OnboardingTheme.goldColor,
                      textColor: OnboardingTheme.backgroundColor,
                      style: FastButtonStyle.filled,
                      isLoading: _isProcessing,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: FastPlainButton(
                      text: 'Not now',
                      onTap: _onSkip,
                      textColor: OnboardingTheme.labelTertiary,
                    ),
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use OnboardingWrapper when in onboarding context
    if (widget.useOnboardingWrapper) {
      return OnboardingWrapper(
        child: _buildContent(),
      );
    }

    // Use plain Scaffold when called outside onboarding
    return Scaffold(
      backgroundColor: OnboardingTheme.backgroundColor,
      body: SafeArea(
        child: _buildContent(),
      ),
    );
  }
}
