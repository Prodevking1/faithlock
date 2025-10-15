/// **FastSlider** - Cross-platform slider for selecting numeric values from a range.
///
/// **Use Case:** 
/// Perfect for settings that require users to select a value from a continuous or discrete range,
/// such as volume controls, brightness adjustment, price ranges, or any numeric input where
/// visual feedback is important. Adapts to platform design conventions automatically.
///
/// **Key Features:**
/// - Platform-adaptive styling (CupertinoSlider on iOS, Material Slider on Android)
/// - Continuous or discrete value selection with divisions
/// - Customizable colors for active/inactive track and thumb
/// - Optional label display for current value (Android)
/// - Consistent API across platforms
/// - Native platform interactions and animations
///
/// **Important Parameters:**
/// - `value`: Current slider value (required, must be between min and max)
/// - `onChanged`: Callback when value changes (ValueChanged<double>)
/// - `min`: Minimum value of the slider (default 0.0)
/// - `max`: Maximum value of the slider (default 1.0)
/// - `divisions`: Number of discrete divisions (null for continuous)
/// - `label`: Value label to display (Android only)
/// - `activeColor`: Color of the active track portion
/// - `inactiveColor`: Color of the inactive track portion
/// - `thumbColor`: Color of the slider thumb/handle
///
/// **Usage Examples:**
/// ```dart
/// // Volume control slider
/// FastSlider(
///   value: volume,
///   min: 0.0,
///   max: 100.0,
///   divisions: 100,
///   label: '${volume.round()}%',
///   onChanged: (value) => setState(() => volume = value)
/// )
///
/// // Brightness adjustment
/// FastSlider(
///   value: brightness,
///   activeColor: Colors.amber,
///   onChanged: (value) => updateBrightness(value)
/// )
///
/// // Price range selector
/// FastSlider(
///   value: maxPrice,
///   min: 0.0,
///   max: 1000.0,
///   divisions: 20,
///   label: '\$${maxPrice.round()}',
///   onChanged: (value) => filterByPrice(value)
/// )
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FastSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;

  const FastSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
  });

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return CupertinoSlider(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        divisions: divisions,
        activeColor: activeColor ?? CupertinoColors.activeBlue,
        thumbColor: thumbColor ?? CupertinoColors.white,
      );
    } else {
      return Slider(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        activeColor: activeColor ?? Theme.of(context).primaryColor,
        inactiveColor: inactiveColor ?? Theme.of(context).disabledColor,
        thumbColor: thumbColor,
      );
    }
  }
}