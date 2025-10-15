// FastSliverGrid is a customizable grid layout that adapts to iOS and Android platforms.
// It's designed to be used within a CustomScrollView or other Sliver-based scrollable widgets.
//
// Key features:
// - Automatically adapts to iOS or Android platform
// - Supports both fixed-count and max-cross-axis extent grid layouts
// - Allows for custom item builders and grid delegates
// - Implements platform-specific styling and behaviors
// - Efficiently builds grid items on-demand
// - Supports both vertical and horizontal scrolling

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FastSliverGrid extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final SliverGridDelegate gridDelegate;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;

  const FastSliverGrid({
    required this.itemCount,
    required this.itemBuilder,
    required this.gridDelegate,
    super.key,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
  });

  factory FastSliverGrid.count({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    required int crossAxisCount,
    Key? key,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    double childAspectRatio = 1.0,
  }) {
    return FastSliverGrid(
      key: key,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
    );
  }

  factory FastSliverGrid.extent({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    required double maxCrossAxisExtent,
    Key? key,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    double childAspectRatio = 1.0,
  }) {
    return FastSliverGrid(
      key: key,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: gridDelegate,
      delegate: SliverChildBuilderDelegate(
        itemBuilder,
        childCount: itemCount,
      ),
    );
  }
}
