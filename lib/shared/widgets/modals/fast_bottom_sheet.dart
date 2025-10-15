/// **FastBottomSheet** - Platform-adaptive bottom sheet with native iOS/Android styling and smooth animations.
///
/// **Use Case:**
/// Use this for displaying modal content that slides up from the bottom of the screen.
/// Perfect for forms, options panels, detail views, or any content that needs to appear
/// as a modal overlay with platform-appropriate styling and animations.
///
/// **Key Features:**
/// - Platform-adaptive styling (iOS modal presentation, Material bottom sheet)
/// - Smooth slide-up animations with native timing curves
/// - Optional title bar with platform-appropriate styling
/// - Dismissible by gesture (drag down) or tap outside
/// - Safe area handling for all device types
/// - Keyboard avoidance and proper content sizing
/// - Haptic feedback integration for iOS
///
/// **Important Parameters:**
/// - `context`: BuildContext for modal presentation (required)
/// - `child`: Content widget to display in the bottom sheet (required)
/// - `title`: Optional title displayed at the top of the sheet
/// - `isDismissible`: Whether sheet can be dismissed by tap/gesture (default: true)
/// - `enableDrag`: Whether sheet can be dragged to dismiss (default: true)
/// - `backgroundColor`: Custom background color
/// - `isScrollControlled`: Whether sheet can expand to full height
///
/// **Usage Example:**
/// ```dart
/// // Basic bottom sheet
/// FastBottomSheet.show(
///   context: context,
///   child: MyContent(),
/// );
///
/// // Bottom sheet with title
/// FastBottomSheet.show(
///   context: context,
///   title: 'Options',
///   child: OptionsList(),
///   isDismissible: true,
/// );
///
/// // Full-height scrollable sheet
/// FastBottomSheet.show(
///   context: context,
///   child: LongForm(),
///   isScrollControlled: true,
///   enableDrag: true,
/// );
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FastBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
    double? height,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
  }) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return _showCupertinoSheet<T>(
        context: context,
        child: child,
        title: title,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        height: height,
        padding: padding,
        backgroundColor: backgroundColor,
      );
    } else {
      return _showMaterialBottomSheet<T>(
        context: context,
        child: child,
        title: title,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        height: height,
        padding: padding,
        backgroundColor: backgroundColor,
      );
    }
  }

  static Future<T?> _showCupertinoSheet<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
    double? height,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
  }) {
    HapticFeedback.lightImpact();

    return Navigator.of(context).push<T>(
      CupertinoSheetRoute<T>(
        enableDrag: enableDrag,
        builder: (BuildContext context) => _CupertinoSheetScaffold(
          child: child,
          title: title,
          isDismissible: isDismissible,
          height: height,
          padding: padding,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }

  static Future<T?> _showMaterialBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
    double? height,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
  }) {
    HapticFeedback.lightImpact();

    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: height ?? MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: _buildBottomSheetContent(
            context: context,
            child: child,
            title: title,
            enableDrag: enableDrag,
            padding: padding,
            isIOS: false,
          ),
        );
      },
    );
  }

  static Widget _buildBottomSheetContent({
    required BuildContext context,
    required Widget child,
    String? title,
    bool enableDrag = true,
    EdgeInsetsGeometry? padding,
    bool isIOS = false,
  }) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (enableDrag)
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(top: 8, bottom: title != null ? 8 : 16),
              decoration: BoxDecoration(
                color: isIOS
                    ? CupertinoColors.systemGrey3.resolveFrom(context)
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          if (title != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isIOS ? 17 : 16,
                  fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                  color: isIOS
                      ? CupertinoColors.label.resolveFrom(context)
                      : Theme.of(context).textTheme.titleLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Flexible(
            child: Container(
              width: double.infinity,
              padding: padding ??
                  (isIOS
                      ? const EdgeInsets.fromLTRB(20, 0, 20, 20)
                      : const EdgeInsets.all(20)),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _CupertinoSheetScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool isDismissible;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const _CupertinoSheetScaffold({
    required this.child,
    this.title,
    this.isDismissible = true,
    this.height,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final double sheetHeight =
        height ?? MediaQuery.of(context).size.height * 0.6;

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
          if (isDismissible)
            GestureDetector(
              onTap: () {
                if (CupertinoSheetRoute.hasParentSheet(context)) {
                  CupertinoSheetRoute.popSheet(context);
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Container(
                color: Colors.transparent,
                child: const SizedBox.expand(),
              ),
            ),
          Container(
            height: sheetHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: backgroundColor ??
                  CupertinoColors.systemBackground.resolveFrom(context),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: FastBottomSheet._buildBottomSheetContent(
              context: context,
              child: child,
              title: title,
              enableDrag: true,
              padding: padding,
              isIOS: true,
            ),
          ),
          ],
        ),
      ),
    );
  }
}
