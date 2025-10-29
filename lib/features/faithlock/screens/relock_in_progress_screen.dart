import 'dart:math';
import 'package:faithlock/core/constants/core/fast_colors.dart';
import 'package:faithlock/features/faithlock/services/screen_time_service.dart';
import 'package:faithlock/shared/widgets/animations/confetti_celebration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Encouraging Bible verses for re-lock success
const List<Map<String, String>> encouragingVerses = [
  {
    'text': 'I can do all things through Christ who strengthens me',
    'reference': 'Philippians 4:13',
  },
  {
    'text': 'The Lord is my strength and my shield',
    'reference': 'Psalm 28:7',
  },
  {
    'text': 'Be strong and courageous. Do not be afraid',
    'reference': 'Joshua 1:9',
  },
  {
    'text': 'God is our refuge and strength, an ever-present help in trouble',
    'reference': 'Psalm 46:1',
  },
  {
    'text': 'Resist the devil, and he will flee from you',
    'reference': 'James 4:7',
  },
  {
    'text': 'No temptation has overtaken you except what is common to mankind',
    'reference': '1 Corinthians 10:13',
  },
  {
    'text': 'The Lord will fight for you; you need only to be still',
    'reference': 'Exodus 14:14',
  },
  {
    'text': 'Greater is He who is in you than he who is in the world',
    'reference': '1 John 4:4',
  },
  {
    'text': 'In all these things we are more than conquerors through Him',
    'reference': 'Romans 8:37',
  },
  {
    'text': 'You will keep in perfect peace those whose minds are steadfast',
    'reference': 'Isaiah 26:3',
  },
];

/// Screen displayed when re-locking apps after unlock timer expires
/// Automatically applies shields and navigates back to main screen
class RelockInProgressScreen extends StatefulWidget {
  const RelockInProgressScreen({super.key});

  @override
  State<RelockInProgressScreen> createState() => _RelockInProgressScreenState();
}

class _RelockInProgressScreenState extends State<RelockInProgressScreen>
    with SingleTickerProviderStateMixin {
  final ScreenTimeService _screenTimeService = ScreenTimeService();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isRelocking = true;
  bool _relockSuccess = false;
  String _statusMessage = 'Re-locking in progress...';

  // Random encouraging verse
  late Map<String, String> _selectedVerse;

  @override
  void initState() {
    super.initState();

    // Select a random verse
    final random = Random();
    _selectedVerse = encouragingVerses[random.nextInt(encouragingVerses.length)];

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();

    // Start re-locking process
    _performRelock();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _performRelock() async {
    try {
      // Add slight delay for animation to start
      await Future.delayed(const Duration(milliseconds: 800));

      // Apply shields
      await _screenTimeService.applyShields();

      // Update state
      setState(() {
        _isRelocking = false;
        _relockSuccess = true;
        _statusMessage = 'Apps successfully re-locked!';
      });

      // Wait for user to read the verse before navigating back
      await Future.delayed(const Duration(seconds: 4));

      // Navigate back to main screen
      if (mounted) {
        Get.offAllNamed('/main');
      }
    } catch (e) {
      debugPrint('❌ Error re-locking apps: $e');

      setState(() {
        _isRelocking = false;
        _relockSuccess = false;
        _statusMessage = 'Error during re-lock';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      backgroundColor: FastColors.surface(context),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: _isRelocking
                            ? FastColors.primary.withValues(alpha: 0.1)
                            : _relockSuccess
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isRelocking
                            ? CupertinoIcons.lock_rotation
                            : _relockSuccess
                                ? CupertinoIcons.lock_fill
                                : CupertinoIcons.exclamationmark_triangle,
                        size: 60,
                        color: _isRelocking
                            ? FastColors.primary
                            : _relockSuccess
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Status message
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: FastColors.primaryText(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),

                // Loading indicator
                if (_isRelocking)
                  FadeTransition(
                    opacity: _opacityAnimation,
                    child: CupertinoActivityIndicator(
                      radius: 16,
                      color: FastColors.primary,
                    ),
                  ),

                // Success message with Bible verse
                if (!_isRelocking && _relockSuccess) ...[
                  FadeTransition(
                    opacity: _opacityAnimation,
                    child: Text(
                      'Your apps are now protected',
                      style: TextStyle(
                        fontSize: 16,
                        color: FastColors.secondaryText(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Bible verse
                  FadeTransition(
                    opacity: _opacityAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: FastColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: FastColors.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '"${_selectedVerse['text']}"',
                            style: TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                              color: FastColors.primaryText(context),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '— ${_selectedVerse['reference']}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: FastColors.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Error message with retry button
                if (!_isRelocking && !_relockSuccess) ...[
                  FadeTransition(
                    opacity: _opacityAnimation,
                    child: Text(
                      'An error occurred',
                      style: TextStyle(
                        fontSize: 16,
                        color: FastColors.secondaryText(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CupertinoButton.filled(
                    onPressed: () {
                      setState(() {
                        _isRelocking = true;
                        _statusMessage = 'Re-locking in progress...';
                      });
                      _performRelock();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    // Show confetti when successfully re-locked
    if (_relockSuccess) {
      return ConfettiCelebration(child: scaffold);
    }

    return scaffold;
  }
}
