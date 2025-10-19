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

  LifeVisualization({
    super.key,
    required this.currentAge,
    required this.lifeExpectancy,
    required this.daysWasted,
    this.showWasted = false,
  });

  @override
  Widget build(BuildContext context) {
    final yearsLived = currentAge;
    // final yearsWasted = (daysWasted / 365).floor();
    final yearsWasted = 4;

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

    // Calculate position for "This is what you have left" text
    // Position it in the geometric center of remaining life zone
    final totalProcessedYears = yearsLived + (showWasted ? yearsWasted : 0);

    // Find first and last remaining year
    final firstRemainingYear = totalProcessedYears + 1;
    final lastRemainingYear = lifeExpectancy;

    // Calculate bounding box of remaining years zone
    final firstYearIndex = firstRemainingYear - 1;
    final lastYearIndex = lastRemainingYear - 1;

    final firstRow = firstYearIndex ~/ columns;
    final firstCol = firstYearIndex % columns;
    final lastRow = lastYearIndex ~/ columns;
    final lastCol = lastYearIndex % columns;

    // Calculate geometric center of the bounding box
    final centerRow = (firstRow + lastRow) / 2;
    final centerCol = (firstCol + lastCol) / 2;

    // Calculate grid dimensions
    final totalGridWidth = (columns * dotSize) + ((columns - 1) * spacing);

    // Calculate pixel position from center of container
    // Container has padding of 24px, and the grid is centered within the inner area
    final containerInnerWidth = availableWidth - (24 * 2);
    final gridStartX = (containerInnerWidth - totalGridWidth) / 2 + 24;

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
              // Dashed border around remaining life zone
              if (showWasted)
                _buildDashedBorder(
                  firstRow: firstRow,
                  firstCol: firstCol,
                  lastRow: lastRow,
                  lastCol: lastCol,
                  dotSize: dotSize,
                  spacing: spacing,
                  gridStartX: gridStartX,
                ),

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

              // if (showWasted)
              //   Positioned(
              //     top: textTopPosition,
              //     right: 12, // Position at right edge with small margin
              //     child: Container(
              //       padding: const EdgeInsets.symmetric(
              //         horizontal: 12,
              //         vertical: 6,
              //       ),
              //       decoration: BoxDecoration(
              //         color: Colors.black.withValues(alpha: 0.7),
              //         borderRadius: BorderRadius.circular(8),
              //       ),
              //       child: FastText.callout(
              //         'This is what\nyou have left',
              //         color: OnboardingTheme.labelPrimary,
              //         textAlign: TextAlign.right,
              //       ),
              //     ),
              //   ),
            ],
          ),
        ),

        const SizedBox(height: OnboardingTheme.space24),

        // Legend with iOS styling
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildDashedBorder({
    required int firstRow,
    required int firstCol,
    required int lastRow,
    required int lastCol,
    required double dotSize,
    required double spacing,
    required double gridStartX,
  }) {
    // Calculate bounding box dimensions with padding
    final padding = 8.0; // Padding around the region

    // Calculate top position (starting from first remaining row)
    final top = (firstRow * (dotSize + spacing)) - padding;

    // Width should encompass the remaining years in each row
    // Calculate based on actual columns needed for remaining life zone
    final width = (8 * dotSize) + (7 * spacing) + (padding * 2);

    // Height from first remaining row to last row
    final height = ((lastRow - firstRow + 1) * dotSize) +
        ((lastRow - firstRow) * spacing) +
        (padding * 2);

    return Positioned(
      left: 0,
      right: 0,
      top: top,
      child: Center(
        child: CustomPaint(
          size: Size(width, height),
          painter: DashedBorderPainter(
            color: OnboardingTheme.goldColor.withValues(alpha: 0.9),
            strokeWidth: 2,
            dashWidth: 4,
            dashSpace: 4,
          ),
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
          child: FastText.body(
            label,
            color: OnboardingTheme.labelPrimary,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for dashed border
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw dashed rectangle
    _drawDashedLine(
      canvas,
      paint,
      Offset(0, 0),
      Offset(size.width, 0),
    ); // Top
    _drawDashedLine(
      canvas,
      paint,
      Offset(size.width, 0),
      Offset(size.width, size.height),
    ); // Right
    _drawDashedLine(
      canvas,
      paint,
      Offset(size.width, size.height),
      Offset(0, size.height),
    ); // Bottom
    _drawDashedLine(
      canvas,
      paint,
      Offset(0, size.height),
      Offset(0, 0),
    ); // Left
  }

  void _drawDashedLine(
    Canvas canvas,
    Paint paint,
    Offset start,
    Offset end,
  ) {
    final totalDistance = (end - start).distance;
    final dashCount = (totalDistance / (dashWidth + dashSpace)).floor();

    var currentDistance = 0.0;
    final direction = (end - start) / totalDistance;

    for (var i = 0; i < dashCount; i++) {
      final dashStart = start + (direction * currentDistance);
      final dashEnd = start + (direction * (currentDistance + dashWidth));
      canvas.drawLine(dashStart, dashEnd, paint);
      currentDistance += dashWidth + dashSpace;
    }

    // Draw remaining dash if any
    if (currentDistance < totalDistance) {
      final dashStart = start + (direction * currentDistance);
      final dashEnd = start + (direction * totalDistance);
      canvas.drawLine(dashStart, dashEnd, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
