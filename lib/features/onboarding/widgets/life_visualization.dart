import 'package:faithlock/features/onboarding/constants/onboarding_theme.dart';
import 'package:faithlock/shared/widgets/typography/fast_text.dart';
import 'package:flutter/material.dart';

/// Life Visualization Widget - Powerful impact visualization
/// Shows life as dots in a grid with wasted time overlay
class LifeVisualization extends StatelessWidget {
  final int currentAge;
  final int lifeExpectancy;
  final int daysWasted;
  final bool showWasted;

  const LifeVisualization({
    super.key,
    required this.currentAge,
    required this.lifeExpectancy,
    required this.daysWasted,
    this.showWasted = false,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate stats
    final yearsLived = currentAge;
    final yearsWasted = (daysWasted / 365).floor();

    // Grid: 8 columns x 10 rows = 80 dots for 80 years
    const int columns = 8;
    const int rows = 10;

    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth =
        screenWidth - (OnboardingTheme.horizontalPadding * 2);

    // Calculate dot size - smaller dots like in screenshots
    const spacing = 12.0;
    final dotSize =
        (availableWidth - (spacing * (columns - 1))) / columns * 0.3;

    return Column(
      children: [
        // Main grid container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: OnboardingTheme.cardBackground,
            borderRadius: BorderRadius.circular(OnboardingTheme.radiusLarge),
            border: Border.all(
              color: OnboardingTheme.cardBorder,
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Grid of dots
              Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(rows, (rowIndex) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: rowIndex < rows - 1 ? spacing : 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(columns, (colIndex) {
                        final dotIndex = rowIndex * columns + colIndex;
                        final year = dotIndex + 1;

                        if (year > lifeExpectancy) {
                          // Empty dot (beyond life expectancy)
                          return _buildDot(
                            dotSize: dotSize,
                            color: OnboardingTheme.labelTertiary,
                            opacity: 0.1,
                            isLast: colIndex == columns - 1,
                          );
                        }

                        final isLived = year <= yearsLived;
                        final isWasted = showWasted &&
                            year > yearsLived &&
                            year <= (yearsLived + yearsWasted);

                        Color dotColor;
                        double opacity;

                        if (isWasted) {
                          dotColor = OnboardingTheme.systemRed;
                          opacity = 1.0;
                        } else if (isLived) {
                          dotColor = OnboardingTheme.systemGreen;
                          opacity = 1.0;
                        } else {
                          dotColor = OnboardingTheme.labelTertiary;
                          opacity = 0.3;
                        }

                        return _buildDot(
                          dotSize: dotSize,
                          color: dotColor,
                          opacity: opacity,
                          isLast: colIndex == columns - 1,
                        );
                      }),
                    ),
                  );
                }),
              ),

              // Overlay text (only shown when wasted is revealed)
              if (showWasted)
                Positioned.fill(
                  child: Center(
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: FastText.body('This is what\nyou have left')),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: OnboardingTheme.space24),

        // Legend with iOS styling
        Column(
          children: [
            _buildLegendItem(
              color: OnboardingTheme.systemGreen,
              label: showWasted
                  ? 'You are here (assuming age $currentAge)'
                  : 'Life lived',
            ),
            const SizedBox(height: OnboardingTheme.space12),
            _buildLegendItem(
              color: OnboardingTheme.labelTertiary.withValues(alpha: 0.3),
              label: 'Life remaining',
            ),
            if (showWasted) ...[
              const SizedBox(height: OnboardingTheme.space12),
              _buildLegendItem(
                color: OnboardingTheme.systemRed,
                label: '$yearsWasted years spent looking down at\nyour phone',
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDot({
    required double dotSize,
    required Color color,
    required double opacity,
    required bool isLast,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: isLast ? 0 : 12),
      child: Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          color: color.withValues(alpha: opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: OnboardingTheme.space12),
        Flexible(
          child: Text(
            label,
            style: OnboardingTheme.body.copyWith(
              color: OnboardingTheme.labelPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
