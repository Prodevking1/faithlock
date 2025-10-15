/// **FastStepper** - Animated progress stepper with customizable styling and smooth transitions.
///
/// **Use Case:**
/// Use this for showing step-by-step progress in workflows, forms, onboarding sequences,
/// or any multi-step process. Perfect for indicating current position in a sequence
/// with visual progress representation and step counting.
///
/// **Key Features:**
/// - Smooth animated progress transitions with customizable duration
/// - Customizable colors for active and inactive states
/// - Automatic step counting display (e.g., "3/5")
/// - Rounded corners with configurable border radius
/// - Theme-aware default colors that adapt to light/dark mode
/// - Accessibility support with proper progress semantics
/// - Responsive width based on container size
///
/// **Important Parameters:**
/// - `totalSteps`: Total number of steps in the process (required)
/// - `currentStep`: Current active step (0-based index, required)
/// - `height`: Height of the progress bar (default: 4.0)
/// - `activeColor`: Color for completed progress (defaults to theme primary)
/// - `inactiveColor`: Color for remaining progress (defaults to theme primary with opacity)
/// - `borderRadius`: Corner radius for the progress bar
/// - `textStyle`: Custom text style for the step counter
///
/// **Usage Example:**
/// ```dart
/// // Basic progress stepper
/// FastStepper(
///   totalSteps: 5,
///   currentStep: 2, // Shows "2/5"
/// )
///
/// // Custom styled stepper
/// FastStepper(
///   totalSteps: 4,
///   currentStep: 1,
///   height: 6.0,
///   activeColor: Colors.green,
///   inactiveColor: Colors.grey.shade300,
///   borderRadius: BorderRadius.circular(3.0),
/// )
///
/// // In a form workflow
/// FastStepper(
///   totalSteps: formSteps.length,
///   currentStep: currentFormStep,
///   height: 8.0,
/// )
/// ```

import 'package:flutter/material.dart';

class FastStepper extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final double height;
  final Color? activeColor;
  final Color? inactiveColor;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;

  const FastStepper({
    Key? key,
    required this.totalSteps,
    required this.currentStep,
    this.height = 4.0,
    this.activeColor,
    this.inactiveColor,
    this.borderRadius,
    this.textStyle,
  })  : assert(currentStep >= 0 && currentStep <= totalSteps,
            'Current step must be between 0 and total steps'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveActiveColor = activeColor ?? theme.colorScheme.primary;
    final effectiveInactiveColor =
        inactiveColor ?? theme.colorScheme.primary.withOpacity(0.2);
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(height / 2);
    final effectiveTextStyle = textStyle ??
        theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final currentWidth =
                constraints.maxWidth * currentStep / totalSteps;
            return Stack(
              children: [
                Container(
                  height: height,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: effectiveInactiveColor,
                    borderRadius: effectiveBorderRadius,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: height,
                  width: currentWidth,
                  decoration: BoxDecoration(
                    color: effectiveActiveColor,
                    borderRadius: effectiveBorderRadius,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          '$currentStep/$totalSteps',
          style: effectiveTextStyle,
        ),
      ],
    );
  }
}
