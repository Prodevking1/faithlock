/// **FastRefreshControl** - Cross-platform pull-to-refresh wrapper for any scrollable content.
///
/// **Use Case:** 
/// Add pull-to-refresh functionality to any scrollable widget like lists, grids, or custom content. 
/// Automatically adapts to platform conventions (iOS pull indicator vs Android circular indicator).
///
/// **Key Features:**
/// - Platform-adaptive refresh indicators (CupertinoSliverRefreshControl on iOS, RefreshIndicator on Android)
/// - Works with any child widget that can scroll
/// - Customizable refresh indicator color and displacement
/// - Seamless integration with existing scroll views
/// - Consistent API across platforms
///
/// **Important Parameters:**
/// - `child`: The scrollable widget to wrap (required)
/// - `onRefresh`: Async function called when refresh is triggered (required)
/// - `color`: Color of the refresh indicator (Android only)
/// - `displacement`: Distance from top where indicator appears (Android only, default 40.0)
///
/// **Usage Examples:**
/// ```dart
/// // Basic refresh wrapper
/// FastRefreshControl(
///   onRefresh: () async => await loadData(),
///   child: ListView(children: items)
/// )
///
/// // Custom styled refresh
/// FastRefreshControl(
///   color: Colors.blue,
///   displacement: 60.0,
///   onRefresh: () async => await refreshContent(),
///   child: SingleChildScrollView(child: content)
/// )
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FastRefreshControl extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final double displacement;

  const FastRefreshControl({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.displacement = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return CustomScrollView(
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: onRefresh,
            builder: (context, refreshState, pulledExtent, refreshTriggerPullDistance, refreshIndicatorExtent) {
              return Container(
                alignment: Alignment.center,
                child: const CupertinoActivityIndicator(),
              );
            },
          ),
          SliverToBoxAdapter(child: child),
        ],
      );
    } else {
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: color ?? Theme.of(context).primaryColor,
        displacement: displacement,
        child: child,
      );
    }
  }
}

/// **FastSliverRefreshControl** - Pull-to-refresh for CustomScrollView with multiple slivers.
///
/// **Use Case:** 
/// Add pull-to-refresh to complex scroll layouts using CustomScrollView with multiple sliver widgets.
/// Perfect for screens with headers, lists, grids combined in a single scrollable view.
///
/// **Important Parameters:**
/// - `slivers`: List of sliver widgets for CustomScrollView (required)
/// - `onRefresh`: Async function called when refresh is triggered (required)
/// - `color`: Color of the refresh indicator (Android only)

class FastSliverRefreshControl extends StatelessWidget {
  final List<Widget> slivers;
  final Future<void> Function() onRefresh;
  final Color? color;

  const FastSliverRefreshControl({
    super.key,
    required this.slivers,
    required this.onRefresh,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return CustomScrollView(
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: onRefresh,
          ),
          ...slivers,
        ],
      );
    } else {
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: color ?? Theme.of(context).primaryColor,
        child: CustomScrollView(slivers: slivers),
      );
    }
  }
}

/// **FastListRefreshControl** - Pull-to-refresh ListView with predefined children.
///
/// **Use Case:** 
/// Create a refreshable list when you have a fixed set of widget children.
/// Combines ListView functionality with pull-to-refresh in a single component.
///
/// **Important Parameters:**
/// - `children`: List of widgets to display (required)
/// - `onRefresh`: Async function called when refresh is triggered (required)
/// - `controller`: ScrollController for programmatic control
/// - `padding`: Internal padding around the list
/// - `color`: Color of the refresh indicator (Android only)

class FastListRefreshControl extends StatelessWidget {
  final List<Widget> children;
  final Future<void> Function() onRefresh;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const FastListRefreshControl({
    super.key,
    required this.children,
    required this.onRefresh,
    this.controller,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return CustomScrollView(
        controller: controller,
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: onRefresh,
          ),
          SliverPadding(
            padding: padding ?? EdgeInsets.zero,
            sliver: SliverList(
              delegate: SliverChildListDelegate(children),
            ),
          ),
        ],
      );
    } else {
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: color ?? Theme.of(context).primaryColor,
        child: ListView(
          controller: controller,
          padding: padding,
          children: children,
        ),
      );
    }
  }
}

/// **FastListViewRefreshControl** - Pull-to-refresh ListView.builder with data-driven approach.
///
/// **Use Case:** 
/// Create a refreshable list from a data source with builder pattern. Perfect for dynamic lists
/// that are generated from data models, with optional separators between items.
///
/// **Important Parameters:**
/// - `items`: List of data items to display (required)
/// - `itemBuilder`: Function to build widget from each item (required)
/// - `onRefresh`: Async function called when refresh is triggered (required)
/// - `controller`: ScrollController for programmatic control
/// - `padding`: Internal padding around the list
/// - `separator`: Optional widget to show between list items
/// - `color`: Color of the refresh indicator (Android only)

class FastListViewRefreshControl<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final Widget? separator;
  final Color? color;

  const FastListViewRefreshControl({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    this.controller,
    this.padding,
    this.separator,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return CustomScrollView(
        controller: controller,
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: onRefresh,
          ),
          SliverPadding(
            padding: padding ?? EdgeInsets.zero,
            sliver: separator != null
                ? SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final itemIndex = index ~/ 2;
                        if (index.isEven) {
                          return itemBuilder(context, items[itemIndex], itemIndex);
                        } else {
                          return separator!;
                        }
                      },
                      childCount: items.length * 2 - 1,
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => itemBuilder(context, items[index], index),
                      childCount: items.length,
                    ),
                  ),
          ),
        ],
      );
    } else {
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: color ?? Theme.of(context).primaryColor,
        child: separator != null
            ? ListView.separated(
                controller: controller,
                padding: padding,
                itemCount: items.length,
                separatorBuilder: (context, index) => separator!,
                itemBuilder: (context, index) => itemBuilder(context, items[index], index),
              )
            : ListView.builder(
                controller: controller,
                padding: padding,
                itemCount: items.length,
                itemBuilder: (context, index) => itemBuilder(context, items[index], index),
              ),
      );
    }
  }
}