import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/feather_cursor.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Step 3.5: Testimonials - Social Proof with Premium iOS Design
/// Shows real user testimonials with elegant cards and premium badges
class Step35Testimonials extends StatefulWidget {
  final VoidCallback onComplete;

  const Step35Testimonials({
    super.key,
    required this.onComplete,
  });

  @override
  State<Step35Testimonials> createState() => _Step35TestimonialsState();
}

class _Step35TestimonialsState extends State<Step35Testimonials> {
  final controller = Get.find<ScriptureOnboardingController>();

  // Animation states
  String _headerText = '';
  bool _showHeaderCursor = false;
  bool _showBadges = false;
  bool _showTestimonials = false;
  int _visibleTestimonialIndex = -1;
  bool _showContinueButton = false;

  double _opacity = 1.0;

  // Testimonials data
  final List<Map<String, String>> _testimonials = [
    {
      'name': 'David M.',
      'age': '24',
      'before': '6h/day scrolling, 0 prayer',
      'after': '1h30/day, daily prayer habit',
      'result': 'My relationship with God was transformed.',
      'duration': '2 weeks',
    },
    {
      'name': 'Sarah K.',
      'age': '29',
      'before': 'Addicted to social media',
      'after': 'Free and focused on eternal things',
      'result': 'I finally feel spiritually alive again.',
      'duration': '3 weeks',
    },
    {
      'name': 'Marcus T.',
      'age': '32',
      'before': 'No self-control, always distracted',
      'after': 'Disciplined prayer warrior',
      'result': 'Scripture became my shield, not my phone.',
      'duration': '1 month',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));

    await AnimationUtils.typeText(
      fullText:
          'Others felt the same pain you just saw.\n\nHere\'s what happened...',
      onUpdate: (text) => setState(() => _headerText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showHeaderCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 1500);

    setState(() {
      _headerText = '';
      _showHeaderCursor = false;
    });

    setState(() => _showBadges = true);
    await AnimationUtils.mediumHaptic();
    await AnimationUtils.pause(durationMs: 1500);

    setState(() => _showTestimonials = true);
    for (int i = 0; i < _testimonials.length; i++) {
      setState(() => _visibleTestimonialIndex = i);
      await AnimationUtils.lightHaptic();
      await AnimationUtils.pause(durationMs: 2500);
    }

    await AnimationUtils.pause(durationMs: 1000);

    setState(() => _showContinueButton = true);
    await AnimationUtils.mediumHaptic();
  }

  Future<void> _onContinue() async {
    await AnimationUtils.heavyHaptic();
    setState(() => _opacity = 0.0);
    await Future.delayed(const Duration(milliseconds: 500));
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 1000),
        child: Stack(
          children: [
            // Main scrollable content
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 100, // Space for fixed button
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: OnboardingTheme.horizontalPadding,
                    right: OnboardingTheme.horizontalPadding,
                    top: 80, // Space for progress bar
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      // Header text
                      if (_headerText.isNotEmpty)
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: OnboardingTheme.title3.copyWith(
                              color: OnboardingTheme.labelPrimary,
                            ),
                            children: [
                              TextSpan(text: _headerText),
                              if (_showHeaderCursor)
                                const WidgetSpan(
                                  child: FeatherCursor(),
                                  alignment: PlaceholderAlignment.middle,
                                ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      if (_showBadges) ...[
                        Text(
                          'Join believers who transformed their lives',
                          textAlign: TextAlign.center,
                          style: OnboardingTheme.callout.copyWith(
                            color: OnboardingTheme.goldColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildPremiumBadges(),
                        const SizedBox(height: 32),
                      ],

                      // Testimonial cards (compact)
                      if (_showTestimonials)
                        ..._testimonials.asMap().entries.map((entry) {
                          final index = entry.key;
                          final testimonial = entry.value;
                          return AnimatedOpacity(
                            opacity:
                                index <= _visibleTestimonialIndex ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 600),
                            child: AnimatedSlide(
                              offset: index <= _visibleTestimonialIndex
                                  ? Offset.zero
                                  : const Offset(0, 0.3),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOut,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _buildTestimonialCard(testimonial),
                              ),
                            ),
                          );
                        }),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Fixed Continue button at bottom
            if (_showContinueButton)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: OnboardingTheme.horizontalPadding,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        OnboardingTheme.backgroundColor.withValues(alpha: 0.0),
                        OnboardingTheme.backgroundColor,
                      ],
                    ),
                  ),
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 600),
                    child: FastButton(
                      text: 'Continue',
                      onTap: _onContinue,
                      backgroundColor: OnboardingTheme.goldColor,
                      textColor: OnboardingTheme.backgroundColor,
                      style: FastButtonStyle.filled,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBadges() {
    return Center(
      child: _buildBadge(
        icon: '🏆',
        text: 'Best app',
        subtitle: 'Faith & Focus',
      ),
    );
  }

  Widget _buildBadge({
    required String icon,
    required String text,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            OnboardingTheme.goldColor.withValues(alpha: 0.15),
            OnboardingTheme.goldColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: OnboardingTheme.goldColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: OnboardingTheme.callout.copyWith(
                  color: OnboardingTheme.goldColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: OnboardingTheme.caption.copyWith(
                  color: OnboardingTheme.labelSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(Map<String, String> testimonial) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OnboardingTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: OnboardingTheme.cardBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name + Age + Duration (compact)
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      OnboardingTheme.goldColor.withValues(alpha: 0.3),
                      OnboardingTheme.goldColor.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: OnboardingTheme.goldColor.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    testimonial['name']![0],
                    style: OnboardingTheme.callout.copyWith(
                      color: OnboardingTheme.goldColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testimonial['name']!,
                      style: OnboardingTheme.subhead.copyWith(
                        color: OnboardingTheme.labelPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${testimonial['age']} years old',
                      style: OnboardingTheme.caption.copyWith(
                        color: OnboardingTheme.labelSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: OnboardingTheme.systemGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  testimonial['duration']!,
                  style: OnboardingTheme.caption.copyWith(
                    color: OnboardingTheme.systemGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Before/After (compact, no arrow)
          Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBeforeAfter(
                label: 'Before',
                text: testimonial['before']!,
                color: OnboardingTheme.systemRed,
              ),
              _buildBeforeAfter(
                label: 'After',
                text: testimonial['after']!,
                color: OnboardingTheme.systemGreen,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Result quote (compact)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: OnboardingTheme.goldColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: OnboardingTheme.goldColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              '"${testimonial['result']!}"',
              style: OnboardingTheme.caption.copyWith(
                color: OnboardingTheme.labelPrimary,
                fontStyle: FontStyle.italic,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeforeAfter({
    required String label,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(
          color: color.withValues(alpha: .05),
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: OnboardingTheme.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: OnboardingTheme.caption.copyWith(
              color: OnboardingTheme.labelPrimary,
              fontSize: 14,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
