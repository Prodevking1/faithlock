/// **FastMultitaskingLayout** - iPad multitasking-aware layout with automatic mode detection and adaptation.
///
/// **Use Case:**
/// Use this when building iPad apps that need to adapt to Split View, Slide Over, and
/// full-screen modes. Essential for professional iPad apps that support multitasking
/// and need to provide optimal layouts in all multitasking scenarios.
///
/// **Key Features:**
/// - Automatic multitasking mode detection (fullScreen, splitView, slideOver, compact)
/// - iPad Pro/Air/Mini specific optimizations
/// - Adaptive margins and spacing for each mode
/// - Grid layouts that respond to available space
/// - Navigation patterns that adapt to space constraints
/// - Text scaling for different multitasking contexts
///
/// **Important Parameters:**
/// - `builder`: Function that builds UI based on current multitasking mode
/// - `fullScreenChild`: Widget for full-screen iPad mode
/// - `splitViewChild`: Widget for iPad split view mode
/// - `slideOverChild`: Widget for iPad slide over mode
/// - `compactChild`: Widget for iPhone or compact iPad mode
/// - `automaticPadding`: Auto-apply iOS standard margins (default: true)
///
/// **Usage Example:**
/// ```dart
/// // Adaptive layout for all multitasking modes
/// FastMultitaskingLayout(
///   builder: (context, mode) {
///     switch (mode) {
///       case MultitaskingMode.fullScreen:
///         return WideLayout();
///       case MultitaskingMode.splitView:
///         return CompactLayout();
///       default:
///         return MobileLayout();
///     }
///   },
/// )
/// ```

import 'package:faithlock/core/constants/core/ios_spacing.dart';
import 'package:faithlock/core/utils/ios_platform_detector.dart';
import 'package:flutter/material.dart';

/// iPad multitasking layout modes
enum MultitaskingMode {
  fullScreen,
  splitView,
  slideOver,
  compact,
}
class FastMultitaskingLayout extends StatefulWidget {
  final Widget Function(BuildContext context, MultitaskingMode mode) builder;
  final Widget? fullScreenChild;
  final Widget? splitViewChild;
  final Widget? slideOverChild;
  final Widget? compactChild;
  final EdgeInsets? padding;
  final bool automaticPadding;

  const FastMultitaskingLayout({
    super.key,
    required this.builder,
    this.fullScreenChild,
    this.splitViewChild,
    this.slideOverChild,
    this.compactChild,
    this.padding,
    this.automaticPadding = true,
  });

  /// Convenience constructor for simple layouts
  const FastMultitaskingLayout.simple({
    super.key,
    required Widget fullScreenChild,
    required Widget compactChild,
    this.padding,
    this.automaticPadding = true,
  })  : builder = _simpleBuilder,
        fullScreenChild = fullScreenChild,
        splitViewChild = null,
        slideOverChild = null,
        compactChild = compactChild;

  static Widget _simpleBuilder(BuildContext context, MultitaskingMode mode) {
    final layout =
        context.findAncestorWidgetOfExactType<FastMultitaskingLayout>();
    switch (mode) {
      case MultitaskingMode.fullScreen:
        return layout?.fullScreenChild ?? const SizedBox.shrink();
      case MultitaskingMode.splitView:
      case MultitaskingMode.slideOver:
      case MultitaskingMode.compact:
        return layout?.compactChild ?? const SizedBox.shrink();
    }
  }

  @override
  State<FastMultitaskingLayout> createState() => _FastMultitaskingLayoutState();
}

class _FastMultitaskingLayoutState extends State<FastMultitaskingLayout> {
  MultitaskingMode _currentMode = MultitaskingMode.fullScreen;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMultitaskingMode();
  }

  void _updateMultitaskingMode() {
    final newMode = _detectMultitaskingMode();
    if (newMode != _currentMode) {
      setState(() {
        _currentMode = newMode;
      });
    }
  }

  MultitaskingMode _detectMultitaskingMode() {
    if (!IOSPlatformDetector.isIPad(context)) {
      return MultitaskingMode.compact;
    }

    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    // iPad Pro 12.9" full screen: 1024x1366 (portrait), 1366x1024 (landscape)
    // iPad Pro 11" full screen: 834x1194 (portrait), 1194x834 (landscape)
    // iPad Air/Mini full screen: 820x1180 (portrait), 1180x820 (landscape)

    if (orientation == Orientation.portrait) {
      // Portrait mode detection
      if (size.width >= 1000) {
        return MultitaskingMode.fullScreen;
      } else if (size.width >= 600) {
        return MultitaskingMode.splitView;
      } else {
        return MultitaskingMode.slideOver;
      }
    } else {
      // Landscape mode detection
      if (size.width >= 1300) {
        return MultitaskingMode.fullScreen;
      } else if (size.width >= 800) {
        return MultitaskingMode.splitView;
      } else {
        return MultitaskingMode.slideOver;
      }
    }
  }

  EdgeInsets _getAdaptiveMargins() {
    if (!widget.automaticPadding) {
      return widget.padding ?? EdgeInsets.zero;
    }

    EdgeInsets baseMargins;
    switch (_currentMode) {
      case MultitaskingMode.fullScreen:
        baseMargins = IOSSpacing.iPadMargins;
        break;
      case MultitaskingMode.splitView:
        baseMargins = const EdgeInsets.symmetric(horizontal: 12.0);
        break;
      case MultitaskingMode.slideOver:
        baseMargins = const EdgeInsets.symmetric(horizontal: 8.0);
        break;
      case MultitaskingMode.compact:
        baseMargins = IOSSpacing.iPhoneMargins;
        break;
    }

    return baseMargins + (widget.padding ?? EdgeInsets.zero);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _getAdaptiveMargins(),
      child: widget.builder(context, _currentMode),
    );
  }
}

/// Responsive grid that adapts to multitasking
class FastMultitaskingGrid extends StatelessWidget {
  final List<Widget> children;
  final int fullScreenColumns;
  final int splitViewColumns;
  final int slideOverColumns;
  final int compactColumns;
  final double spacing;
  final double runSpacing;
  final EdgeInsets? padding;

  const FastMultitaskingGrid({
    super.key,
    required this.children,
    this.fullScreenColumns = 3,
    this.splitViewColumns = 2,
    this.slideOverColumns = 1,
    this.compactColumns = 1,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return FastMultitaskingLayout(
      padding: padding,
      builder: (context, mode) {
        final columns = _getColumnsForMode(mode);

        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: runSpacing,
          physics: IOSPlatformDetector.isIOS
              ? const BouncingScrollPhysics()
              : const ClampingScrollPhysics(),
          children: children,
        );
      },
    );
  }

  int _getColumnsForMode(MultitaskingMode mode) {
    switch (mode) {
      case MultitaskingMode.fullScreen:
        return fullScreenColumns;
      case MultitaskingMode.splitView:
        return splitViewColumns;
      case MultitaskingMode.slideOver:
        return slideOverColumns;
      case MultitaskingMode.compact:
        return compactColumns;
    }
  }
}

/// Navigation that adapts to multitasking
class FastMultitaskingNavigation extends StatelessWidget {
  final Widget Function(BuildContext context, bool isCompact) builder;
  final Widget? sidebar;
  final Widget? content;
  final double sidebarWidth;

  const FastMultitaskingNavigation({
    super.key,
    required this.builder,
    this.sidebar,
    this.content,
    this.sidebarWidth = 320.0,
  });

  /// Convenience constructor for sidebar navigation
  const FastMultitaskingNavigation.sidebar({
    super.key,
    required Widget sidebar,
    required Widget content,
    this.sidebarWidth = 320.0,
  })  : builder = _sidebarBuilder,
        sidebar = sidebar,
        content = content;

  static Widget _sidebarBuilder(BuildContext context, bool isCompact) {
    final navigation =
        context.findAncestorWidgetOfExactType<FastMultitaskingNavigation>();

    if (isCompact ||
        navigation?.sidebar == null ||
        navigation?.content == null) {
      return navigation?.content ?? const SizedBox.shrink();
    }

    return Row(
      children: [
        SizedBox(
          width: navigation!.sidebarWidth,
          child: navigation.sidebar!,
        ),
        const VerticalDivider(width: 1),
        Expanded(child: navigation.content!),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FastMultitaskingLayout(
      builder: (context, mode) {
        final isCompact = mode == MultitaskingMode.slideOver ||
            mode == MultitaskingMode.compact;
        return builder(context, isCompact);
      },
    );
  }
}

/// Text that scales appropriately for multitasking
class FastMultitaskingText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double fullScreenScale;
  final double splitViewScale;
  final double slideOverScale;
  final double compactScale;

  const FastMultitaskingText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fullScreenScale = 1.0,
    this.splitViewScale = 0.9,
    this.slideOverScale = 0.8,
    this.compactScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return FastMultitaskingLayout(
      automaticPadding: false,
      builder: (context, mode) {
        final scale = _getScaleForMode(mode);
        final scaledStyle = style?.copyWith(
          fontSize: (style?.fontSize ?? 17.0) * scale,
        );

        return Text(
          text,
          style: scaledStyle,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }

  double _getScaleForMode(MultitaskingMode mode) {
    switch (mode) {
      case MultitaskingMode.fullScreen:
        return fullScreenScale;
      case MultitaskingMode.splitView:
        return splitViewScale;
      case MultitaskingMode.slideOver:
        return slideOverScale;
      case MultitaskingMode.compact:
        return compactScale;
    }
  }
}

/// Mixin for widgets that need multitasking awareness
mixin MultitaskingAwareMixin<T extends StatefulWidget> on State<T> {
  MultitaskingMode _currentMode = MultitaskingMode.fullScreen;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMultitaskingMode();
  }

  void _updateMultitaskingMode() {
    final newMode = _detectMultitaskingMode();
    if (newMode != _currentMode) {
      final oldMode = _currentMode;
      setState(() {
        _currentMode = newMode;
      });
      onMultitaskingModeChanged(oldMode, newMode);
    }
  }

  MultitaskingMode _detectMultitaskingMode() {
    if (!IOSPlatformDetector.isIPad(context)) {
      return MultitaskingMode.compact;
    }

    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.portrait) {
      if (size.width >= 1000) return MultitaskingMode.fullScreen;
      if (size.width >= 600) return MultitaskingMode.splitView;
      return MultitaskingMode.slideOver;
    } else {
      if (size.width >= 1300) return MultitaskingMode.fullScreen;
      if (size.width >= 800) return MultitaskingMode.splitView;
      return MultitaskingMode.slideOver;
    }
  }

  /// Override this method to handle multitasking mode changes
  void onMultitaskingModeChanged(
      MultitaskingMode oldMode, MultitaskingMode newMode) {}

  /// Current multitasking mode
  MultitaskingMode get currentMode => _currentMode;

  /// Whether app is in compact mode (iPhone or iPad slide over)
  bool get isCompactMode =>
      _currentMode == MultitaskingMode.compact ||
      _currentMode == MultitaskingMode.slideOver;

  /// Whether app is in full screen mode
  bool get isFullScreenMode => _currentMode == MultitaskingMode.fullScreen;

  /// Whether app is in split view mode
  bool get isSplitViewMode => _currentMode == MultitaskingMode.splitView;

  /// Get appropriate margins for current mode
  EdgeInsets get adaptiveMargins {
    switch (_currentMode) {
      case MultitaskingMode.fullScreen:
        return IOSSpacing.iPadMargins;
      case MultitaskingMode.splitView:
        return const EdgeInsets.symmetric(horizontal: 12.0);
      case MultitaskingMode.slideOver:
        return const EdgeInsets.symmetric(horizontal: 8.0);
      case MultitaskingMode.compact:
        return IOSSpacing.iPhoneMargins;
    }
  }

  /// Get appropriate column count for current mode
  int getAdaptiveColumns({
    int fullScreen = 3,
    int splitView = 2,
    int slideOver = 1,
    int compact = 1,
  }) {
    switch (_currentMode) {
      case MultitaskingMode.fullScreen:
        return fullScreen;
      case MultitaskingMode.splitView:
        return splitView;
      case MultitaskingMode.slideOver:
        return slideOver;
      case MultitaskingMode.compact:
        return compact;
    }
  }
}
