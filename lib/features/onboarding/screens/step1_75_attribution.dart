import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/feather_cursor.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Step 1.75: Attribution - How did you hear about FaithLock?
class Step175Attribution extends StatefulWidget {
  final VoidCallback onComplete;

  const Step175Attribution({
    super.key,
    required this.onComplete,
  });

  @override
  State<Step175Attribution> createState() => _Step175AttributionState();
}

class _Step175AttributionState extends State<Step175Attribution> {
  final controller = Get.find<ScriptureOnboardingController>();

  String _headerText = '';
  bool _showHeaderCursor = false;
  bool _showOptions = false;
  bool _showContinueButton = false;
  String? _selectedSource;
  double _opacity = 1.0;

  List<Map<String, String>> get _sources => [
        {'id': 'google', 'label': 'attribution_google'.tr, 'icon': '🔍'},
        {'id': 'friends_family', 'label': 'attribution_friends'.tr, 'icon': '👥'},
        {'id': 'tiktok', 'label': 'TikTok', 'icon': '🎵'},
        {'id': 'instagram', 'label': 'Instagram', 'icon': '📸'},
        {'id': 'ai', 'label': 'AI (ChatGPT, Gemini...)', 'icon': '🤖'},
        {'id': 'appstore', 'label': 'attribution_appstore'.tr, 'icon': '📱'},
        {'id': 'other', 'label': 'attribution_other'.tr, 'icon': '💬'},
      ];

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));

    await AnimationUtils.typeText(
      fullText: 'attribution_header'.tr,
      onUpdate: (text) => setState(() => _headerText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showHeaderCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 300);

    setState(() => _showOptions = true);
    await AnimationUtils.mediumHaptic();
  }

  void _selectSource(String sourceId) {
    setState(() {
      _selectedSource = sourceId;
      _showContinueButton = true;
    });
    AnimationUtils.lightHaptic();
  }

  Future<void> _onContinue() async {
    if (_selectedSource == null) return;

    await controller.saveAttribution(_selectedSource!);
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
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: _showContinueButton ? 100 : 0,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: OnboardingTheme.horizontalPadding,
                    right: OnboardingTheme.horizontalPadding,
                    top: 100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header text with typing animation
                      if (_headerText.isNotEmpty)
                        RichText(
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

                      const SizedBox(height: 32),

                      // Source options
                      if (_showOptions)
                        ..._sources.asMap().entries.map((entry) {
                          final index = entry.key;
                          final source = entry.value;
                          final isSelected =
                              _selectedSource == source['id'];

                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(
                                milliseconds: 400 + (index * 80)),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 10),
                              child: _buildSourceCard(
                                id: source['id']!,
                                label: source['label']!,
                                icon: source['icon']!,
                                isSelected: isSelected,
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

            // Fixed Continue button
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
                        OnboardingTheme.backgroundColor
                            .withValues(alpha: 0.0),
                        OnboardingTheme.backgroundColor,
                      ],
                    ),
                  ),
                  child: FastButton(
                    text: 'continue_btn'.tr,
                    onTap: _onContinue,
                    backgroundColor: OnboardingTheme.goldColor,
                    textColor: OnboardingTheme.backgroundColor,
                    style: FastButtonStyle.filled,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceCard({
    required String id,
    required String label,
    required String icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _selectSource(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? OnboardingTheme.goldColor.withValues(alpha: 0.15)
              : OnboardingTheme.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? OnboardingTheme.goldColor
                : OnboardingTheme.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Text(icon, style: const TextStyle(fontSize: 22)),
            // const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: OnboardingTheme.callout.copyWith(
                  color: isSelected
                      ? OnboardingTheme.goldColor
                      : OnboardingTheme.labelPrimary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.check_circle,
                color: OnboardingTheme.goldColor,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
