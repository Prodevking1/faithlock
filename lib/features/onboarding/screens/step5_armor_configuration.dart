import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/feather_cursor.dart';
import 'package:faithlock/shared/widgets/buttons/fast_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Step 5: Armor Configuration - Spiritual Setup
/// User chooses verse categories, problem apps, and intensity
class Step5ArmorConfiguration extends StatefulWidget {
  final VoidCallback onComplete;

  const Step5ArmorConfiguration({
    super.key,
    required this.onComplete,
  });

  @override
  State<Step5ArmorConfiguration> createState() =>
      _Step5ArmorConfigurationState();
}

class _Step5ArmorConfigurationState extends State<Step5ArmorConfiguration> {
  final controller = Get.find<ScriptureOnboardingController>();

  // Phase 7.1 - Introduction
  String _introText = '';
  bool _showIntroCursor = false;

  // Phase 7.2 - Category Selection
  bool _showCategorySelection = false;
  final List<String> _availableCategories = [
    'Temptation',
    'Fear & Anxiety',
    'Pride',
    'Lust',
    'Anger',
  ];
  final Set<String> _selectedCategories = {};

  // Phase 7.3 - App Selection (showing placeholder for now)
  bool _showAppSelection = false;

  // Phase 7.4 - Intensity Selection
  bool _showIntensitySelection = false;
  String _selectedIntensity = 'Balanced';

  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Phase 7.1: Introduction
    await _phase71Introduction();

    // Phase 7.2: Category Selection (user interaction)
    await _phase72CategorySelection();
  }

  Future<void> _phase71Introduction() async {
    final userName = controller.userName.value;

    await AnimationUtils.typeText(
      fullText:
          'Now, $userName, let\'s equip you with spiritual armor.\n\nChoose your weapon: God\'s Word.',
      onUpdate: (text) => setState(() => _introText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showIntroCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 2000);
  }

  Future<void> _phase72CategorySelection() async {
    setState(() {
      _introText = '';
      _showIntroCursor = false;
      _showCategorySelection = true;
    });

    await AnimationUtils.mediumHaptic();
  }

  void _onCategoryToggle(String category) async {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        if (_selectedCategories.length < 5) {
          _selectedCategories.add(category);
        }
      }
    });
    await AnimationUtils.lightHaptic();
  }

  Future<void> _onContinueFromCategories() async {
    if (_selectedCategories.isEmpty) return;

    await controller.saveVerseCategories(_selectedCategories.toList());
    await AnimationUtils.heavyHaptic();

    // Phase 7.3: App Selection (simplified for MVP)
    setState(() {
      _showCategorySelection = false;
      _showAppSelection = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    // Skip to intensity for now
    await _phase74IntensitySelection();
  }

  Future<void> _phase74IntensitySelection() async {
    setState(() {
      _showAppSelection = false;
      _showIntensitySelection = true;
    });

    await AnimationUtils.mediumHaptic();
  }

  void _onIntensitySelected(String intensity) async {
    setState(() => _selectedIntensity = intensity);
    await AnimationUtils.lightHaptic();
  }

  Future<void> _onComplete() async {
    await controller.saveIntensityLevel(_selectedIntensity);
    await AnimationUtils.heavyHaptic();

    // Transition to next step
    setState(() => _opacity = 0.0);
    await Future.delayed(const Duration(milliseconds: 1000));
    await AnimationUtils.heavyHaptic();
    await Future.delayed(const Duration(milliseconds: 1500));

    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTheme.backgroundColor,
      body: SafeArea(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 1000),
          child: Stack(
            children: [
              // Back button
              if (controller.currentStep.value > 1)
                Positioned(
                  top: 16,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: OnboardingTheme.goldColor,
                      size: 24,
                    ),
                    onPressed: () => controller.previousStep(),
                  ),
                ),
              // Main content
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: OnboardingTheme.horizontalPadding,
                    vertical: OnboardingTheme.verticalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Phase 7.1 - Introduction
                      if (_introText.isNotEmpty)
                        RichText(
                          text: TextSpan(
                            style: OnboardingTheme.emphasisText,
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

                      // Phase 7.2 - Category Selection
                      if (_showCategorySelection) ...[
                        Text(
                          'Select your spiritual battles (3-5):',
                          style: OnboardingTheme.bodyText.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        ..._availableCategories.map(
                          (category) => _buildCategoryOption(category),
                        ),
                        const SizedBox(height: 40),
                        if (_selectedCategories.isNotEmpty &&
                            _selectedCategories.length >= 3)
                          Center(
                            child: FastButton(
                              text: 'Continue',
                              onTap: _onContinueFromCategories,
                              backgroundColor: OnboardingTheme.goldColor,
                              textColor: OnboardingTheme.backgroundColor,
                              style: FastButtonStyle.filled,
                            ),
                          ),
                      ],

                      // Phase 7.4 - Intensity Selection
                      if (_showIntensitySelection) ...[
                        Text(
                          'Choose your protection level:',
                          style: OnboardingTheme.bodyText.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildIntensityOption(
                          'Gentle',
                          '1 verse per unlock',
                        ),
                        _buildIntensityOption(
                          'Balanced',
                          '2 verses per unlock',
                        ),
                        _buildIntensityOption(
                          'Warrior',
                          '3 verses per unlock',
                        ),
                        const SizedBox(height: 40),
                        Center(
                          child: FastButton(
                            text: 'Lock & Load',
                            onTap: _onComplete,
                            backgroundColor: OnboardingTheme.goldColor,
                            textColor: OnboardingTheme.backgroundColor,
                            style: FastButtonStyle.filled,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryOption(String category) {
    final isSelected = _selectedCategories.contains(category);

    return GestureDetector(
      onTap: () => _onCategoryToggle(category),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? OnboardingTheme.goldColor
                : OnboardingTheme.grayColor.withValues(alpha: 0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? OnboardingTheme.goldColor.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? OnboardingTheme.goldColor
                      : OnboardingTheme.grayColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
                color: isSelected ? OnboardingTheme.goldColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: OnboardingTheme.backgroundColor,
                      size: 20,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Text(
              category,
              style: OnboardingTheme.bodyText.copyWith(
                fontSize: 20,
                color: isSelected
                    ? OnboardingTheme.goldColor
                    : OnboardingTheme.beigeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntensityOption(String level, String description) {
    final isSelected = _selectedIntensity == level;

    return GestureDetector(
      onTap: () => _onIntensitySelected(level),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? OnboardingTheme.goldColor
                : OnboardingTheme.grayColor.withValues(alpha: 0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? OnboardingTheme.goldColor.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              level,
              style: OnboardingTheme.bodyText.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? OnboardingTheme.goldColor
                    : OnboardingTheme.beigeColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: OnboardingTheme.referenceText.copyWith(
                fontSize: 16,
                color: OnboardingTheme.grayColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
