import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/utils/animation_utils.dart';
import 'package:faithlock/features/onboarding/widgets/feather_cursor.dart';
import 'package:faithlock/features/onboarding/widgets/onboarding_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Step 3: Eternal Warfare - Accountability + Spiritual Battle
/// Combines eternal judgment perspective with spiritual warfare revelation
class Step3EternalWarfare extends StatefulWidget {
  final VoidCallback onComplete;

  const Step3EternalWarfare({
    super.key,
    required this.onComplete,
  });

  @override
  State<Step3EternalWarfare> createState() => _Step3EternalWarfareState();
}

class _Step3EternalWarfareState extends State<Step3EternalWarfare>
    with TickerProviderStateMixin {
  final controller = Get.find<ScriptureOnboardingController>();

  // Phase 3.1 - Scripture Warning
  String _scriptureText = '';
  bool _showScriptureCursor = false;

  // Phase 3.2 - Visual Timeline
  bool _showTimeline = false;
  late AnimationController _timelineController;
  late Animation<double> _timelineAnimation;

  // Phase 3.3 - The Reckoning
  String _reckoningText = '';
  bool _showReckoningCursor = false;
  List<String> _questions = [];
  bool _showQuestions = false;

  // Phase 3.4 - Enemy Revealed
  String _enemyText = '';
  bool _showEnemyCursor = false;

  // Phase 3.5 - What's Lost
  String _lossIntroText = '';
  bool _showLossIntroCursor = false;
  List<String> _lossList = [];
  bool _showLossList = false;

  // Phase 3.6 - The Solution
  String _solutionText = '';
  bool _showSolutionCursor = false;
  bool _showSolutionStats = false;

  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _timelineController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _timelineAnimation = CurvedAnimation(
      parent: _timelineController,
      curve: Curves.easeInOut,
    );
    _startAnimation();
  }

  @override
  void dispose() {
    _timelineController.dispose();
    super.dispose();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Phase 3.1: Scripture Warning
    await _phase31ScriptureWarning();

    // Phase 3.2: Visual Timeline - SUPPRIMÉ
    // await _phase32VisualTimeline();

    // Phase 3.3: The Reckoning
    await _phase33TheReckoning();

    // Phase 3.4: Enemy Revealed
    await _phase34EnemyRevealed();

    // Phase 3.5: What's Lost
    await _phase35WhatsLost();

    // Phase 3.6: The Solution
    await _phase36TheSolution();

    // Transition to next step
    await AnimationUtils.pause(durationMs: 2000);
    setState(() => _opacity = 0.0);
    await Future.delayed(const Duration(milliseconds: 1000));
    await AnimationUtils.heavyHaptic();
    await Future.delayed(const Duration(milliseconds: 1500));

    widget.onComplete();
  }

  Future<void> _phase31ScriptureWarning() async {
    await AnimationUtils.typeText(
      fullText:
          'We will give account for every careless word.\n— Matthew 12:36',
      onUpdate: (text) => setState(() => _scriptureText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showScriptureCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 2000);
  }

  Future<void> _phase32VisualTimeline() async {
    setState(() {
      _scriptureText = '';
      _showScriptureCursor = false;
      _showTimeline = true;
    });

    await AnimationUtils.mediumHaptic();
    _timelineController.forward();

    await Future.delayed(const Duration(milliseconds: 3500));
    await AnimationUtils.pause(durationMs: 1500);
  }

  Future<void> _phase33TheReckoning() async {
    setState(() => _showTimeline = false);

    final stats = controller.calculateTimeStats();
    final fullDays = stats['fullDays'];

    await AnimationUtils.typeText(
      fullText: 'If Christ returned today, how would you explain:',
      onUpdate: (text) => setState(() => _reckoningText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showReckoningCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 1000);

    setState(() => _showQuestions = true);

    final questions = [
      '- These $fullDays days on your screen?',
      '- The prayers you didn\'t pray?',
      '- The people you didn\'t serve?',
    ];

    for (final question in questions) {
      setState(() => _questions.add(question));
      await AnimationUtils.lightHaptic();
      await AnimationUtils.pause(durationMs: 1000);
    }

    await AnimationUtils.pause(durationMs: 2500, withHaptic: true, heavy: true);
  }

  Future<void> _phase34EnemyRevealed() async {
    setState(() {
      _reckoningText = '';
      _showQuestions = false;
      _questions.clear();
    });

    await AnimationUtils.typeText(
      fullText: 'There is an enemy...\n\nAnd he wants you distracted.',
      onUpdate: (text) => setState(() => _enemyText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showEnemyCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 2000, withHaptic: true);
  }

  Future<void> _phase35WhatsLost() async {
    setState(() {
      _enemyText = '';
      _showEnemyCursor = false;
    });

    await AnimationUtils.typeText(
      fullText: 'Every scroll steals from you:',
      onUpdate: (text) => setState(() => _lossIntroText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showLossIntroCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 1000);

    setState(() => _showLossList = true);

    final losses = [
      '• Your intimacy with God',
      '• Your spiritual sensitivity',
      '• Your purpose and calling',
    ];

    for (final loss in losses) {
      setState(() => _lossList.add(loss));
      await AnimationUtils.lightHaptic();
      await AnimationUtils.pause(durationMs: 1000);
    }

    await AnimationUtils.pause(durationMs: 2500, withHaptic: true, heavy: true);
  }

  Future<void> _phase36TheSolution() async {
    setState(() {
      _lossIntroText = '';
      _showLossIntroCursor = false;
      _showLossList = false;
      _lossList.clear();
    });

    await AnimationUtils.pause(durationMs: 1000);

    await AnimationUtils.typeText(
      fullText: 'But there is hope...',
      onUpdate: (text) => setState(() => _solutionText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showSolutionCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 1500);

    setState(() => _solutionText = '');

    final lifeStats = controller.calculateLifeStats();
    final daysSaved = lifeStats['daysSavedIn2Weeks'];

    await AnimationUtils.typeText(
      fullText:
          'In just 2 weeks with this app,\nyou could save ${daysSaved.toStringAsFixed(1)} days of your life back.',
      onUpdate: (text) => setState(() => _solutionText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showSolutionCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 2000, withHaptic: true);

    setState(() => _showSolutionStats = true);
    await AnimationUtils.mediumHaptic();

    await AnimationUtils.pause(durationMs: 2500);

    setState(() {
      _solutionText = '';
      _showSolutionCursor = false;
    });

    await AnimationUtils.typeText(
      fullText: '${controller.userName.value}, will you fight for your life?',
      onUpdate: (text) => setState(() => _solutionText = text),
      onCursorVisibility: (visible) =>
          setState(() => _showSolutionCursor = visible),
      speedMs: 40,
    );

    await AnimationUtils.pause(durationMs: 2500, withHaptic: true, heavy: true);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 1000),
        child: Padding(
          padding: const EdgeInsets.only(
            left: OnboardingTheme.horizontalPadding,
            right: OnboardingTheme.horizontalPadding,
            top: 100, // Space for progress bar
            bottom: OnboardingTheme.verticalPadding,
          ),
          child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Phase 3.1 - Scripture Warning
                    if (_scriptureText.isNotEmpty)
                      RichText(
                        text: TextSpan(
                          style: OnboardingTheme.verseText,
                          children: [
                            TextSpan(text: _scriptureText),
                            if (_showScriptureCursor)
                              const WidgetSpan(
                                child: FeatherCursor(),
                                alignment: PlaceholderAlignment.middle,
                              ),
                          ],
                        ),
                      ),

                    // Phase 3.2 - Visual Timeline
                    if (_showTimeline) ...[
                      const SizedBox(height: 40),
                      _buildTimeline(),
                    ],

                    // Phase 3.3 - The Reckoning
                    if (_reckoningText.isNotEmpty)
                      RichText(
                        text: TextSpan(
                          style: OnboardingTheme.emphasisText,
                          children: [
                            TextSpan(text: _reckoningText),
                            if (_showReckoningCursor)
                              const WidgetSpan(
                                child: FeatherCursor(),
                                alignment: PlaceholderAlignment.middle,
                              ),
                          ],
                        ),
                      ),

                    if (_showQuestions) ...[
                      const SizedBox(height: 30),
                      ..._questions.map(
                        (question) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            question,
                            style: OnboardingTheme.bodyText.copyWith(
                              color: OnboardingTheme.redAlert,
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Phase 3.4 - Enemy Revealed
                    if (_enemyText.isNotEmpty)
                      RichText(
                        text: TextSpan(
                          style: OnboardingTheme.emphasisText,
                          children: [
                            TextSpan(text: _enemyText),
                            if (_showEnemyCursor)
                              const WidgetSpan(
                                child: FeatherCursor(),
                                alignment: PlaceholderAlignment.middle,
                              ),
                          ],
                        ),
                      ),

                    // Phase 3.5 - What's Lost
                    if (_lossIntroText.isNotEmpty)
                      RichText(
                        text: TextSpan(
                          style: OnboardingTheme.emphasisText,
                          children: [
                            TextSpan(text: _lossIntroText),
                            if (_showLossIntroCursor)
                              const WidgetSpan(
                                child: FeatherCursor(),
                                alignment: PlaceholderAlignment.middle,
                              ),
                          ],
                        ),
                      ),

                    if (_showLossList) ...[
                      const SizedBox(height: 30),
                      ..._lossList.map(
                        (loss) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text(
                            loss,
                            style: OnboardingTheme.bodyText,
                          ),
                        ),
                      ),
                    ],

                    // Phase 3.6 - The Solution
                    if (_solutionText.isNotEmpty)
                      RichText(
                        text: TextSpan(
                          style: _solutionText.contains('hope')
                              ? OnboardingTheme.emphasisText.copyWith(
                                  color: OnboardingTheme.blueSpirit,
                                )
                              : OnboardingTheme.bodyText,
                          children: [
                            TextSpan(text: _solutionText),
                            if (_showSolutionCursor)
                              const WidgetSpan(
                                child: FeatherCursor(),
                                alignment: PlaceholderAlignment.middle,
                              ),
                          ],
                        ),
                      ),

                    if (_showSolutionStats) ...[
                      const SizedBox(height: 40),
                      _buildSolutionStats(),
                    ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return AnimatedBuilder(
      animation: _timelineAnimation,
      builder: (context, child) {
        return Column(
          children: [
            // Timeline visualization
            SizedBox(
              height: 100,
              child: Stack(
                children: [
                  // Main timeline line
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 50,
                    child: Container(
                      height: 2,
                      color: OnboardingTheme.goldColor,
                    ),
                  ),

                  // Birth marker
                  Positioned(
                    left: 0,
                    top: 30,
                    child: Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: OnboardingTheme.goldColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Birth',
                          style: OnboardingTheme.referenceText,
                        ),
                      ],
                    ),
                  ),

                  // Current position (animated)
                  Positioned(
                    left: _timelineAnimation.value * 200,
                    top: 20,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.person,
                          color: OnboardingTheme.goldColor,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You',
                          style: OnboardingTheme.referenceText.copyWith(
                            color: OnboardingTheme.goldColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Death marker
                  Positioned(
                    right: 80,
                    top: 30,
                    child: Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: OnboardingTheme.redAlert,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Death',
                          style: OnboardingTheme.referenceText.copyWith(
                            color: OnboardingTheme.redAlert,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Eternity marker
                  Positioned(
                    right: 0,
                    top: 30,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.all_inclusive,
                          color: OnboardingTheme.blueSpirit,
                          size: 20,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Eternity',
                          style: OnboardingTheme.referenceText.copyWith(
                            color: OnboardingTheme.blueSpirit,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSolutionStats() {
    final lifeStats = controller.calculateLifeStats();
    final daysSavedIn2Weeks = lifeStats['daysSavedIn2Weeks'];
    final daysSavedPerYear = lifeStats['daysSavedPerYear'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(
          color: OnboardingTheme.blueSpirit.withValues(alpha: 0.3),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        color: OnboardingTheme.blueSpirit.withValues(alpha: 0.05),
      ),
      child: Column(
        children: [
          // Icon
          const Icon(
            Icons.trending_up,
            color: OnboardingTheme.blueSpirit,
            size: 48,
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Your Freedom Projection',
            style: OnboardingTheme.bodyText.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: OnboardingTheme.blueSpirit,
            ),
          ),
          const SizedBox(height: 20),

          // Growth curve visualization
          SizedBox(
            height: 70,
            child: CustomPaint(
              size: const Size(double.infinity, 70),
              painter: GrowthCurvePainter(
                progress: 1.0, // Full animation when shown
                color: OnboardingTheme.blueSpirit,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Stats
          _buildStatRow(
            'In 2 weeks',
            '${daysSavedIn2Weeks.toStringAsFixed(1)} days saved',
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            'In 1 year',
            '${daysSavedPerYear} days saved',
          ),
          const SizedBox(height: 20),

          // Footer
          Text(
            'Based on 80% reduction in phone usage',
            style: OnboardingTheme.referenceText.copyWith(
              fontSize: 11,
              color: OnboardingTheme.grayColor,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: OnboardingTheme.bodyText.copyWith(
            fontSize: 14,
            color: OnboardingTheme.grayColor,
          ),
        ),
        Text(
          value,
          style: OnboardingTheme.bodyText.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: OnboardingTheme.blueSpirit,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for growth curve visualization
/// Draws a smooth wavy curve that grows upward from left to right
class GrowthCurvePainter extends CustomPainter {
  final double progress;
  final Color color;

  GrowthCurvePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Start from bottom left
    final startY = size.height * 0.8;
    path.moveTo(0, startY);

    // Draw smooth wavy curve that rises to top right
    final numWaves = 3;
    final segmentWidth = size.width / (numWaves * 2);

    for (int i = 0; i < numWaves * 2; i++) {
      final x = (i + 1) * segmentWidth * progress;
      if (x > size.width) break;

      // Calculate vertical position (rising trend with wave)
      final baseProgress = x / size.width;
      final baseY = startY - (baseProgress * size.height * 0.7);

      // Add subtle wave
      final wave = (i % 2 == 0 ? 1 : -1) * size.height * 0.08;
      final y = baseY + wave;

      // Use quadratic bezier for smooth curve
      final controlX = x - segmentWidth / 2;
      final controlY = (baseY + wave / 2);

      path.quadraticBezierTo(controlX, controlY, x, y);
    }

    canvas.drawPath(path, paint);

    // Draw filled area under curve
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width * progress, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw dots at peaks for emphasis
    for (int i = 0; i < numWaves; i++) {
      final x = (i * 2 + 1) * segmentWidth * progress;
      if (x > size.width) break;

      final baseProgress = x / size.width;
      final baseY = startY - (baseProgress * size.height * 0.7);
      final y = baseY - size.height * 0.08;

      canvas.drawCircle(
        Offset(x, y),
        3,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GrowthCurvePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
