import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:flutter/material.dart';

/// Fingerprint scanner widget with animated scanning effect
class FingerprintScanner extends StatefulWidget {
  final String userName;
  final VoidCallback onComplete;

  const FingerprintScanner({
    super.key,
    required this.userName,
    required this.onComplete,
  });

  @override
  State<FingerprintScanner> createState() => _FingerprintScannerState();
}

class _FingerprintScannerState extends State<FingerprintScanner>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _sealController;
  late Animation<double> _scanAnimation;
  late Animation<double> _sealAnimation;

  bool _isScanning = false;
  bool _scanComplete = false;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _sealController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    _sealAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _sealController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    _sealController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    if (_isScanning) return;

    setState(() => _isScanning = true);
    await _scanController.forward();

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _scanComplete = true;
      _isScanning = false;
    });

    await _sealController.forward();
    await Future.delayed(const Duration(milliseconds: 1500));

    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _startScan(),
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          border: Border.all(
            color: _scanComplete
                ? OnboardingTheme.goldColor
                : OnboardingTheme.goldColor.withValues(alpha: 0.5),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
          gradient: _scanComplete
              ? LinearGradient(
                  colors: [
                    OnboardingTheme.goldColor.withValues(alpha: 0.1),
                    OnboardingTheme.goldColor.withValues(alpha: 0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fingerprint icon or seal
            if (!_scanComplete)
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.fingerprint,
                    size: 120,
                    color: OnboardingTheme.goldColor.withValues(alpha: 0.3),
                  ),
                  if (_isScanning)
                    AnimatedBuilder(
                      animation: _scanAnimation,
                      builder: (context, child) {
                        return Positioned(
                          top: 120 * _scanAnimation.value,
                          child: Container(
                            width: 140,
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  OnboardingTheme.goldColor,
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: OnboardingTheme.goldColor
                                      .withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              )
            else
              AnimatedBuilder(
                animation: _sealAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _sealAnimation.value,
                    child: Column(
                      children: [
                        // Golden seal with checkmark
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                OnboardingTheme.goldColor,
                                OnboardingTheme.goldColor.withValues(alpha: 0.7),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: OnboardingTheme.goldColor
                                    .withValues(alpha: 0.5),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 60,
                            color: OnboardingTheme.backgroundColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // User name
                        Text(
                          widget.userName,
                          style: OnboardingTheme.emphasisText.copyWith(
                            color: OnboardingTheme.goldColor,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'COVENANT SEALED',
                          style: OnboardingTheme.referenceText.copyWith(
                            color: OnboardingTheme.goldColor,
                            fontSize: 14,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 30),

            // Instructions
            Text(
              _isScanning
                  ? 'Scanning...'
                  : _scanComplete
                      ? 'Covenant sealed before God'
                      : 'Hold your thumb to seal covenant',
              style: OnboardingTheme.bodyText.copyWith(
                fontSize: 16,
                color: _scanComplete
                    ? OnboardingTheme.goldColor
                    : OnboardingTheme.grayColor,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
