/// **FastPickerWheel** - Cross-platform picker wheel with iOS CupertinoPicker and Material wheel scroll view.
///
/// **Use Case:**
/// Use this for selecting single items from a list with a spinning wheel interface.
/// Perfect for date/time selection, option picking, measurement values, or any
/// scenario where users need to choose from predefined options with tactile feedback.
///
/// **Key Features:**
/// - Platform-adaptive styling (iOS CupertinoPicker, Material ListWheelScrollView)
/// - Generic type support for any data type with custom item builders
/// - Configurable wheel physics (diameter ratio, magnification, item extent)
/// - Modal presentation with native platform styling and animations
/// - Multi-column picker support for complex selections (dates, coordinates)
/// - Haptic feedback integration for iOS interactions
/// - GetX internationalization support for buttons and labels
///
/// **Important Parameters:**
/// - `items`: List of items to display in the picker (required)
/// - `itemBuilder`: Function to convert items to display strings (required)
/// - `selectedItem`: Currently selected item for initial state
/// - `onSelectedItemChanged`: Callback when selection changes
/// - `itemExtent`: Height of each picker item (default: 32.0)
/// - `diameterRatio`: Wheel curvature ratio (default: 1.07)
/// - `useMagnifier`: Whether to magnify center item
/// - `magnification`: Magnification factor for center item
///
/// **Usage Example:**
/// ```dart
/// // Basic picker wheel
/// FastPickerWheel<String>(
///   items: ['Option 1', 'Option 2', 'Option 3'],
///   itemBuilder: (item) => item,
///   onSelectedItemChanged: (selected) => print(selected),
/// )
///
/// // Modal picker
/// final result = await FastPickerWheel.showPicker<String>(
///   context: context,
///   items: ['Small', 'Medium', 'Large'],
///   itemBuilder: (item) => item,
///   title: 'Select Size',
/// );
///
/// // Multi-column picker (date selection)
/// final dateIndices = await FastMultiPickerWheel.showPicker(
///   context: context,
///   columns: [
///     ['01', '02', '03'], // days
///     ['Jan', 'Feb', 'Mar'], // months
///     ['2023', '2024', '2025'], // years
///   ],
///   selectedIndices: [0, 0, 0],
///   title: 'Select Date',
/// );
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FastPickerWheel<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedItem;
  final ValueChanged<T>? onSelectedItemChanged;
  final String Function(T) itemBuilder;
  final double itemExtent;
  final double diameterRatio;
  final bool useMagnifier;
  final double magnification;
  final FixedExtentScrollController? controller;

  const FastPickerWheel({
    super.key,
    required this.items,
    this.selectedItem,
    this.onSelectedItemChanged,
    required this.itemBuilder,
    this.itemExtent = 32.0,
    this.diameterRatio = 1.07,
    this.useMagnifier = false,
    this.magnification = 1.0,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return CupertinoPicker(
        itemExtent: itemExtent,
        diameterRatio: diameterRatio,
        useMagnifier: useMagnifier,
        magnification: magnification,
        scrollController: controller,
        onSelectedItemChanged: (int index) {
          onSelectedItemChanged?.call(items[index]);
        },
        children: items.map((item) => Center(
          child: Text(
            itemBuilder(item),
            style: TextStyle(
              fontSize: 18,
              color: CupertinoColors.label.resolveFrom(context),
            ),
          ),
        )).toList(),
      );
    } else {
      return SizedBox(
        height: itemExtent * 5,
        child: ListWheelScrollView.useDelegate(
          itemExtent: itemExtent,
          diameterRatio: diameterRatio,
          useMagnifier: useMagnifier,
          magnification: magnification,
          controller: controller,
          onSelectedItemChanged: (int index) {
            onSelectedItemChanged?.call(items[index]);
          },
          childDelegate: ListWheelChildBuilderDelegate(
            builder: (context, index) {
              if (index < 0 || index >= items.length) return null;
              return Center(
                child: Text(
                  itemBuilder(items[index]),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              );
            },
            childCount: items.length,
          ),
        ),
      );
    }
  }

  static Future<T?> showPicker<T>({
    required BuildContext context,
    required List<T> items,
    required String Function(T) itemBuilder,
    T? selectedItem,
    String? title,
    String? confirmText,
    String? cancelText,
  }) async {
    T? result = selectedItem;

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      await showCupertinoModalPopup<T>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 250,
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: Column(
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground.resolveFrom(context),
                    border: Border(
                      bottom: BorderSide(
                        color: CupertinoColors.systemGrey4.resolveFrom(context),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          cancelText ?? 'cancel'.tr,
                          style: TextStyle(
                            color: CupertinoColors.systemBlue.resolveFrom(context),
                          ),
                        ),
                      ),
                      if (title != null)
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.label.resolveFrom(context),
                          ),
                        ),
                      CupertinoButton(
                        onPressed: () => Navigator.of(context).pop(result),
                        child: Text(
                          confirmText ?? 'done'.tr,
                          style: TextStyle(
                            color: CupertinoColors.systemBlue.resolveFrom(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FastPickerWheel<T>(
                    items: items,
                    selectedItem: selectedItem,
                    itemBuilder: itemBuilder,
                    onSelectedItemChanged: (item) => result = item,
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      result = await showDialog<T>(
        context: context,
        builder: (BuildContext context) {
          T? dialogResult = selectedItem;
          
          return AlertDialog(
            title: title != null ? Text(title) : null,
            content: SizedBox(
              height: 200,
              width: double.maxFinite,
              child: FastPickerWheel<T>(
                items: items,
                selectedItem: selectedItem,
                itemBuilder: itemBuilder,
                onSelectedItemChanged: (item) => dialogResult = item,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  cancelText ?? 'cancel'.tr,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(dialogResult),
                child: Text(
                  confirmText ?? 'done'.tr,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return result;
  }
}

class FastMultiPickerWheel extends StatelessWidget {
  final List<List<String>> columns;
  final List<int> selectedIndices;
  final ValueChanged<List<int>>? onSelectedItemChanged;
  final double itemExtent;

  const FastMultiPickerWheel({
    super.key,
    required this.columns,
    required this.selectedIndices,
    this.onSelectedItemChanged,
    this.itemExtent = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(columns.length, (columnIndex) {
        return Expanded(
          child: FastPickerWheel<String>(
            items: columns[columnIndex],
            selectedItem: selectedIndices[columnIndex] < columns[columnIndex].length
                ? columns[columnIndex][selectedIndices[columnIndex]]
                : null,
            itemBuilder: (item) => item,
            itemExtent: itemExtent,
            onSelectedItemChanged: (item) {
              final index = columns[columnIndex].indexOf(item);
              if (index != -1) {
                final newIndices = List<int>.from(selectedIndices);
                newIndices[columnIndex] = index;
                onSelectedItemChanged?.call(newIndices);
              }
            },
          ),
        );
      }),
    );
  }

  static Future<List<int>?> showPicker({
    required BuildContext context,
    required List<List<String>> columns,
    required List<int> selectedIndices,
    String? title,
    String? confirmText,
    String? cancelText,
  }) async {
    List<int> result = List.from(selectedIndices);

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      await showCupertinoModalPopup<List<int>>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 250,
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: Column(
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground.resolveFrom(context),
                    border: Border(
                      bottom: BorderSide(
                        color: CupertinoColors.systemGrey4.resolveFrom(context),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          cancelText ?? 'cancel'.tr,
                          style: TextStyle(
                            color: CupertinoColors.systemBlue.resolveFrom(context),
                          ),
                        ),
                      ),
                      if (title != null)
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.label.resolveFrom(context),
                          ),
                        ),
                      CupertinoButton(
                        onPressed: () => Navigator.of(context).pop(result),
                        child: Text(
                          confirmText ?? 'done'.tr,
                          style: TextStyle(
                            color: CupertinoColors.systemBlue.resolveFrom(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FastMultiPickerWheel(
                    columns: columns,
                    selectedIndices: selectedIndices,
                    onSelectedItemChanged: (indices) => result = indices,
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      final newResult = await showDialog<List<int>>(
        context: context,
        builder: (BuildContext context) {
          List<int> dialogResult = List.from(selectedIndices);
          
          return AlertDialog(
            title: title != null ? Text(title) : null,
            content: SizedBox(
              height: 200,
              width: double.maxFinite,
              child: FastMultiPickerWheel(
                columns: columns,
                selectedIndices: selectedIndices,
                onSelectedItemChanged: (indices) => dialogResult = indices,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  cancelText ?? 'cancel'.tr,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(dialogResult),
                child: Text(
                  confirmText ?? 'done'.tr,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      );
      if (newResult != null) result = newResult;
    }

    return result;
  }
}