/// **FastSegmentedControl** - Cross-platform segmented control for selecting between options.
///
/// **Use Case:** 
/// Perfect for allowing users to select between 2-5 related options like view modes (List/Grid), 
/// time periods (Day/Week/Month), or categories. Provides native iOS segmented control appearance 
/// on iOS and custom Material-styled segments on Android.
///
/// **Key Features:**
/// - Platform-adaptive styling (CupertinoSlidingSegmentedControl on iOS, custom Material design on Android)
/// - Generic type support for any data type as option keys
/// - Customizable colors for selected/unselected states
/// - Built-in haptic feedback on selection
/// - Responsive layout that adapts to content
/// - Smooth selection animations
///
/// **Important Parameters:**
/// - `children`: Map of option keys to widget labels (required)
/// - `groupValue`: Currently selected option key
/// - `onValueChanged`: Callback when selection changes (ValueChanged<T>)
/// - `selectedColor`: Color for selected option background
/// - `unselectedColor`: Color for unselected options background
/// - `borderColor`: Border color for Android style (Android only)
/// - `padding`: Internal padding for segments
/// - `hapticFeedback`: Enable tactile feedback on selection
///
/// **Usage Examples:**
/// ```dart
/// // Basic view mode selector
/// FastSegmentedControl<String>(
///   children: {
///     'list': Text('List'),
///     'grid': Text('Grid')
///   },
///   groupValue: currentView,
///   onValueChanged: (value) => setState(() => currentView = value)
/// )
///
/// // Time period selector with custom colors
/// FastSegmentedControl<Period>(
///   children: {
///     Period.day: Text('Day'),
///     Period.week: Text('Week'),
///     Period.month: Text('Month')
///   },
///   groupValue: selectedPeriod,
///   selectedColor: Colors.blue,
///   onValueChanged: (period) => updatePeriod(period)
/// )
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FastSegmentedControl<T extends Object> extends StatelessWidget {
  final Map<T, Widget> children;
  final T? groupValue;
  final ValueChanged<T>? onValueChanged;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;

  final bool hapticFeedback;

  const FastSegmentedControl({
    super.key,
    required this.children,
    this.groupValue,
    this.onValueChanged,
    this.selectedColor,
    this.unselectedColor,
    this.borderColor,
    this.padding,
    this.hapticFeedback = true,
  });

  void _handleValueChanged(T value) {
    if (hapticFeedback) {
      HapticFeedback.selectionClick();
    }
    onValueChanged?.call(value);
  }

  void _handleSlidingValueChanged(T? value) {
    if (value != null) {
      _handleValueChanged(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: CupertinoSlidingSegmentedControl<T>(
          children: children,
          groupValue: groupValue,
          onValueChanged: _handleSlidingValueChanged,
          thumbColor: selectedColor ?? CupertinoColors.systemBackground,
          backgroundColor: unselectedColor ?? CupertinoColors.systemGrey6,
          padding: padding ?? const EdgeInsets.all(4),
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor ?? Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: children.entries.map((entry) {
            final bool isSelected = entry.key == groupValue;
            final bool isFirst = children.keys.first == entry.key;
            final bool isLast = children.keys.last == entry.key;

            return Expanded(
              child: GestureDetector(
                onTap: () => _handleValueChanged(entry.key),
                child: Container(
                  padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                      ? (selectedColor ?? Theme.of(context).primaryColor)
                      : (unselectedColor ?? Colors.transparent),
                    borderRadius: BorderRadius.only(
                      topLeft: isFirst ? const Radius.circular(7) : Radius.zero,
                      bottomLeft: isFirst ? const Radius.circular(7) : Radius.zero,
                      topRight: isLast ? const Radius.circular(7) : Radius.zero,
                      bottomRight: isLast ? const Radius.circular(7) : Radius.zero,
                    ),
                  ),
                  child: Center(
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: isSelected
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      child: entry.value,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    }
  }
}
