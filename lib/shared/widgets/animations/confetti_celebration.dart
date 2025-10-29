import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

/// Confetti celebration widget
/// Shows confetti animation for success moments
class ConfettiCelebration extends StatefulWidget {
  final Widget child;
  final bool autoStart;
  final Duration duration;

  const ConfettiCelebration({
    super.key,
    required this.child,
    this.autoStart = true,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration> {
  late ConfettiController _controllerCenter;
  late ConfettiController _controllerLeft;
  late ConfettiController _controllerRight;

  @override
  void initState() {
    super.initState();

    _controllerCenter = ConfettiController(duration: widget.duration);
    _controllerLeft = ConfettiController(duration: widget.duration);
    _controllerRight = ConfettiController(duration: widget.duration);

    if (widget.autoStart) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _startConfetti();
      });
    }
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    _controllerLeft.dispose();
    _controllerRight.dispose();
    super.dispose();
  }

  void _startConfetti() {
    _controllerCenter.play();
    _controllerLeft.play();
    _controllerRight.play();
  }

  Path _drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(
        halfWidth + externalRadius * cos(step),
        halfWidth + externalRadius * sin(step),
      );
      path.lineTo(
        halfWidth + internalRadius * cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * sin(step + halfDegreesPerStep),
      );
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        // Center confetti (shoots upward)
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _controllerCenter,
            blastDirection: pi / 2,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.yellow,
            ],
            createParticlePath: _drawStar,
          ),
        ),

        // Left confetti
        Align(
          alignment: Alignment.centerLeft,
          child: ConfettiWidget(
            confettiController: _controllerLeft,
            blastDirection: 0,
            blastDirectionality: BlastDirectionality.directional,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 10,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ),

        // Right confetti
        Align(
          alignment: Alignment.centerRight,
          child: ConfettiWidget(
            confettiController: _controllerRight,
            blastDirection: pi,
            blastDirectionality: BlastDirectionality.directional,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 10,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ),
      ],
    );
  }
}
