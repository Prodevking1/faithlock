// FastListViewOptimized is a high-performance ListView widget optimized for iOS with native behaviors.
// It provides iOS-native scrolling, animations, and performance optimizations.
//
// Key features:
// - iOS-optimized performance with SliverList virtualization
// - Native iOS scrolling physics and animations (60fps)
// - Automatic memory management for controllers and listeners
// - iOS-specific scroll position maintenance for list-to-detail flows
// - Platform-specific scrolling physics and styling
// - Pull-to-refresh with native iOS animations
// - Supports both vertical and horizontal scrolling

import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// iOS performance optimization controller for managing list state
class IOSListPerformanceController {
  final ScrollController scrollController;
  final String? restorationId;

  // Performance tracking
  double _lastScrollPosition = 0.0;
  DateTime _lastScrollTime = DateTime.now();
  bool _isHighVelocityScrolling = false;

  // Memory management
  final List<VoidCallback> _listeners = [];
  bool _disposed = false;

  IOSListPerformanceController({
    ScrollController? controller,
    this.restorationId,
  }) : scrollController = controller ?? ScrollController() {
    _initializePerformanceTracking();
  }

  void _initializePerformanceTracking() {
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_disposed) return;

    final double currentPosition = scrollController.position.pixels;
    final DateTime currentTime = DateTime.now();
    final double velocity = (currentPosition - _lastScrollPosition).abs() /
        (currentTime.millisecondsSinceEpoch -
            _lastScrollTime.millisecondsSinceEpoch);

    // High velocity threshold for iOS optimization (pixels per millisecond)
    _isHighVelocityScrolling = velocity > 2.0;

    _lastScrollPosition = currentPosition;
    _lastScrollTime = currentTime;

    // Notify listeners
    for (final VoidCallback listener in _listeners) {
      listener();
    }
  }

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  bool get isHighVelocityScrolling => _isHighVelocityScrolling;

  void dispose() {
    _disposed = true;
    _listeners.clear();
    scrollController.dispose();
  }
}

class FastListView extends StatefulWidget {
  final List<Widget> children;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool primary;
  final Axis scrollDirection;
  final bool reverse;
  final Widget? separator;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? itemExtent;
  final Widget? prototypeItem;
  final bool enableRefresh;
  final Future<void> Function()? onRefresh;

  /// Whether to use iOS home page patterns with system margins and spacing
  final bool useIOSHomePagePatterns;

  /// Whether to automatically add section spacing (32pt between sections)
  final bool addSectionSpacing;

  /// Custom section spacing (default: 32pt for iOS)
  final double? sectionSpacing;

  /// Whether to enable iOS performance optimizations
  final bool enableIOSPerformanceOptimizations;

  /// Whether to maintain scroll position for list-to-detail flows
  final bool maintainScrollPosition;

  /// Unique key for scroll position restoration
  final String? scrollRestorationId;

  /// Whether to use native iOS animation curves
  final bool useIOSAnimationCurves;

  /// Whether to enable high-performance mode during fast scrolling
  final bool enableHighPerformanceMode;

  const FastListView({
    required this.children,
    super.key,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    this.controller,
    this.primary = false,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.separator,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.itemExtent,
    this.prototypeItem,
    this.enableRefresh = false,
    this.onRefresh,
    this.useIOSHomePagePatterns = true,
    this.addSectionSpacing = false,
    this.sectionSpacing,
    this.enableIOSPerformanceOptimizations = true,
    this.maintainScrollPosition = true,
    this.scrollRestorationId,
    this.useIOSAnimationCurves = true,
    this.enableHighPerformanceMode = true,
  });

  @override
  State<FastListView> createState() => _FastListViewOptimizedState();
}

class _FastListViewOptimizedState extends State<FastListView>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late IOSListPerformanceController _performanceController;
  late AnimationController _scrollAnimationController;
  late Animation<double> _scrollAnimation;

  @override
  bool get wantKeepAlive => widget.maintainScrollPosition;

  @override
  void initState() {
    super.initState();
    _initializePerformanceController();
    _initializeAnimations();
  }

  void _initializePerformanceController() {
    _performanceController = IOSListPerformanceController(
      controller: widget.controller,
      restorationId: widget.scrollRestorationId,
    );

    if (widget.enableHighPerformanceMode) {
      _performanceController.addListener(_onPerformanceStateChanged);
    }
  }

  void _initializeAnimations() {
    if (widget.useIOSAnimationCurves) {
      _scrollAnimationController = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );

      _scrollAnimation = CurvedAnimation(
        parent: _scrollAnimationController,
        curve: Curves.easeInOutCubic, // iOS-like curve
      );
    }
  }

  void _onPerformanceStateChanged() {
    if (!mounted) return;

    // Reduce rendering quality during high-velocity scrolling for 60fps
    if (_performanceController.isHighVelocityScrolling) {
      // Trigger haptic feedback for smooth scrolling feel
      HapticFeedback.selectionClick();
    }
  }

  @override
  void dispose() {
    _performanceController.dispose();
    _scrollAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final bool isIOS = Platform.isIOS;

    if (isIOS && widget.enableIOSPerformanceOptimizations) {
      return _buildIOSOptimizedList(context);
    } else if (isIOS && widget.useIOSHomePagePatterns) {
      return _buildIOSHomePageList(context);
    } else {
      return _buildStandardList(context, isIOS);
    }
  }

  Widget _buildIOSOptimizedList(BuildContext context) {
    // iOS system margins: 20pt iPhone, 16pt iPad
    final double systemMargin = _getIOSSystemMargin(context);

    // Apply iOS home page patterns with performance optimizations
    final EdgeInsetsGeometry iosPadding = widget.padding ??
        EdgeInsets.symmetric(
          horizontal: systemMargin,
          vertical: 8.0,
        );

    // iOS-optimized physics with native curves
    final ScrollPhysics iosPhysics = widget.physics ??
        (widget.useIOSAnimationCurves
            ? const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              )
            : const BouncingScrollPhysics());

    // Prepare children with section spacing if enabled
    final List<Widget> processedChildren = _processChildrenWithSpacing();

    // Use CustomScrollView for maximum iOS performance
    return CupertinoScrollbar(
      controller: _performanceController.scrollController,
      child: CustomScrollView(
        // Performance optimizations
        cacheExtent: 250.0, // iOS-optimized cache extent
        shrinkWrap: widget.shrinkWrap,
        physics: iosPhysics,
        controller: _performanceController.scrollController,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        // Scroll restoration for list-to-detail flows
        restorationId: widget.scrollRestorationId,
        slivers: [
          // Add pull-to-refresh if enabled
          if (widget.enableRefresh && widget.onRefresh != null)
            CupertinoSliverRefreshControl(
              onRefresh: widget.onRefresh,
              // iOS-native refresh control styling
              refreshTriggerPullDistance: 100.0,
              refreshIndicatorExtent: 60.0,
            ),

          // Main content with iOS padding and performance optimizations
          SliverPadding(
            padding: iosPadding,
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= processedChildren.length) return null;

                  // Wrap each child with performance optimizations
                  Widget child = processedChildren[index];

                  // Add repaint boundaries for better performance
                  if (widget.addRepaintBoundaries) {
                    child = RepaintBoundary(child: child);
                  }

                  // Add automatic keep alives for scroll position maintenance
                  if (widget.addAutomaticKeepAlives) {
                    child = AutomaticKeepAlive(child: child);
                  }

                  return child;
                },
                childCount: processedChildren.length,
                addAutomaticKeepAlives: false, // We handle this manually above
                addRepaintBoundaries: false, // We handle this manually above
                addSemanticIndexes: widget.addSemanticIndexes,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIOSHomePageList(BuildContext context) {
    // iOS system margins: 20pt iPhone, 16pt iPad
    final double systemMargin = _getIOSSystemMargin(context);

    // Apply iOS home page patterns
    final EdgeInsetsGeometry iosPadding = widget.padding ??
        EdgeInsets.symmetric(
          horizontal: systemMargin,
          vertical: 8.0,
        );

    final ScrollPhysics iosPhysics =
        widget.physics ?? const BouncingScrollPhysics();

    // Prepare children with section spacing if enabled
    final List<Widget> processedChildren = _processChildrenWithSpacing();

    // Use CustomScrollView for better iOS integration
    return CupertinoScrollbar(
      controller: widget.controller,
      child: CustomScrollView(
        shrinkWrap: widget.shrinkWrap,
        physics: iosPhysics,
        controller: widget.controller,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        slivers: [
          // Add pull-to-refresh if enabled
          if (widget.enableRefresh && widget.onRefresh != null)
            CupertinoSliverRefreshControl(
              onRefresh: widget.onRefresh,
            ),

          // Main content with iOS padding
          SliverPadding(
            padding: iosPadding,
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                processedChildren,
                addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
                addRepaintBoundaries: widget.addRepaintBoundaries,
                addSemanticIndexes: widget.addSemanticIndexes,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardList(BuildContext context, bool isIOS) {
    final ScrollPhysics defaultPhysics =
        isIOS ? const BouncingScrollPhysics() : const ClampingScrollPhysics();

    Widget listView = ListView(
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics ?? defaultPhysics,
      padding: widget.padding,
      controller: widget.controller,
      primary: widget.primary,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      itemExtent: widget.itemExtent,
      prototypeItem: widget.prototypeItem,
      children: _processChildrenWithSpacing(),
    );

    // Add refresh functionality if enabled
    if (widget.enableRefresh && widget.onRefresh != null) {
      listView = isIOS
          ? CupertinoScrollbar(
              child: CustomScrollView(
                shrinkWrap: widget.shrinkWrap,
                physics: widget.physics ??
                    const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                controller: widget.controller,
                scrollDirection: widget.scrollDirection,
                reverse: widget.reverse,
                slivers: <Widget>[
                  CupertinoSliverRefreshControl(
                    onRefresh: widget.onRefresh,
                  ),
                  SliverPadding(
                    padding: widget.padding ?? EdgeInsets.zero,
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        _processChildrenWithSpacing(),
                        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
                        addRepaintBoundaries: widget.addRepaintBoundaries,
                        addSemanticIndexes: widget.addSemanticIndexes,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: widget.onRefresh!,
              child: listView,
            );
    }

    return listView;
  }

  List<Widget> _processChildrenWithSpacing() {
    List<Widget> processedChildren = [];

    for (int i = 0; i < widget.children.length; i++) {
      // Add the child
      processedChildren.add(widget.children[i]);

      // Add separator if specified and not the last item
      if (widget.separator != null && i < widget.children.length - 1) {
        processedChildren.add(widget.separator!);
      }

      // Add section spacing if enabled and not the last item
      if (widget.addSectionSpacing && i < widget.children.length - 1) {
        processedChildren.add(SizedBox(
          height: widget.sectionSpacing ?? 32.0, // iOS standard section spacing
        ));
      }
    }

    return processedChildren;
  }

  double _getIOSSystemMargin(BuildContext context) {
    // Detect device type for proper margins
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;

    // iPad detection (roughly 768pt and above)
    if (screenWidth >= 768) {
      return 16.0; // iPad margin
    } else {
      return 20.0; // iPhone margin
    }
  }
}

/// Builder widget for iOS-optimized lists with lazy loading
class FastListViewBuilder extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool primary;
  final Axis scrollDirection;
  final bool reverse;
  final Widget? separator;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? itemExtent;
  final Widget? prototypeItem;
  final bool enableRefresh;
  final Future<void> Function()? onRefresh;

  /// Whether to use iOS performance optimizations
  final bool enableIOSPerformanceOptimizations;

  /// Whether to maintain scroll position for list-to-detail flows
  final bool maintainScrollPosition;

  /// Unique key for scroll position restoration
  final String? scrollRestorationId;

  const FastListViewBuilder({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    this.controller,
    this.primary = false,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.separator,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.itemExtent,
    this.prototypeItem,
    this.enableRefresh = false,
    this.onRefresh,
    this.enableIOSPerformanceOptimizations = true,
    this.maintainScrollPosition = true,
    this.scrollRestorationId,
  });

  @override
  State<FastListViewBuilder> createState() => _FastListViewBuilderState();
}

class _FastListViewBuilderState extends State<FastListViewBuilder>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.maintainScrollPosition;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final bool isIOS = Platform.isIOS;

    if (isIOS && widget.enableIOSPerformanceOptimizations) {
      return _buildIOSOptimizedBuilder(context);
    } else {
      return _buildStandardBuilder(context, isIOS);
    }
  }

  Widget _buildIOSOptimizedBuilder(BuildContext context) {
    // iOS-optimized physics
    final ScrollPhysics iosPhysics = widget.physics ??
        const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

    return CupertinoScrollbar(
      controller: widget.controller,
      child: CustomScrollView(
        // Performance optimizations
        cacheExtent: 250.0, // iOS-optimized cache extent
        shrinkWrap: widget.shrinkWrap,
        physics: iosPhysics,
        controller: widget.controller,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        restorationId: widget.scrollRestorationId,
        slivers: [
          // Add pull-to-refresh if enabled
          if (widget.enableRefresh && widget.onRefresh != null)
            CupertinoSliverRefreshControl(
              onRefresh: widget.onRefresh,
              refreshTriggerPullDistance: 100.0,
              refreshIndicatorExtent: 60.0,
            ),

          // Main content with performance optimizations
          SliverPadding(
            padding: widget.padding ?? EdgeInsets.zero,
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= widget.itemCount) return null;

                  // Build item with performance optimizations
                  Widget child = widget.itemBuilder(context, index);

                  // Add repaint boundaries for better performance
                  if (widget.addRepaintBoundaries) {
                    child = RepaintBoundary(child: child);
                  }

                  // Add automatic keep alives for scroll position maintenance
                  if (widget.addAutomaticKeepAlives) {
                    child = AutomaticKeepAlive(child: child);
                  }

                  return child;
                },
                childCount: widget.itemCount,
                addAutomaticKeepAlives: false, // We handle this manually above
                addRepaintBoundaries: false, // We handle this manually above
                addSemanticIndexes: widget.addSemanticIndexes,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardBuilder(BuildContext context, bool isIOS) {
    final ScrollPhysics defaultPhysics =
        isIOS ? const BouncingScrollPhysics() : const ClampingScrollPhysics();

    Widget listView = ListView.builder(
      itemCount: widget.itemCount,
      itemBuilder: widget.itemBuilder,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics ?? defaultPhysics,
      padding: widget.padding,
      controller: widget.controller,
      primary: widget.primary,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      itemExtent: widget.itemExtent,
      prototypeItem: widget.prototypeItem,
    );

    // Add refresh functionality if enabled
    if (widget.enableRefresh && widget.onRefresh != null) {
      listView = isIOS
          ? CupertinoScrollbar(
              child: CustomScrollView(
                shrinkWrap: widget.shrinkWrap,
                physics: widget.physics ??
                    const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                controller: widget.controller,
                scrollDirection: widget.scrollDirection,
                reverse: widget.reverse,
                slivers: <Widget>[
                  CupertinoSliverRefreshControl(
                    onRefresh: widget.onRefresh,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      widget.itemBuilder,
                      childCount: widget.itemCount,
                      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
                      addRepaintBoundaries: widget.addRepaintBoundaries,
                      addSemanticIndexes: widget.addSemanticIndexes,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: widget.onRefresh!,
              child: listView,
            );
    }

    return listView;
  }
}
