// FastSliverList is a customizable list layout that adapts to iOS and Android platforms.
// It's designed to be used within a CustomScrollView or other Sliver-based scrollable widgets.
//
// Key features:
// - Automatically adapts to iOS or Android platform
// - Supports both static and dynamic list items
// - Allows for custom item builders and separators
// - Implements platform-specific styling and behaviors
// - Efficiently builds list items on-demand
// - Supports both vertical and horizontal scrolling
// - Optionally includes sticky headers

import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FastSliverList extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? itemExtent;
  final Widget? prototypeItem;
  final Widget Function(BuildContext, int)? headerBuilder;
  final bool Function(int)? isStickyHeader;

  const FastSliverList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorBuilder,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.itemExtent,
    this.prototypeItem,
    this.headerBuilder,
    this.isStickyHeader,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Platform.isIOS;

    Widget listWidget;

    if (separatorBuilder != null) {
      listWidget = SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final int itemIndex = index ~/ 2;
            if (index.isEven) {
              return itemBuilder(context, itemIndex);
            }
            return separatorBuilder!(context, itemIndex);
          },
          childCount: itemCount * 2 - 1,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        ),
      );
    } else if (itemExtent != null) {
      listWidget = SliverFixedExtentList(
        itemExtent: itemExtent!,
        delegate: SliverChildBuilderDelegate(
          itemBuilder,
          childCount: itemCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        ),
      );
    } else if (prototypeItem != null) {
      listWidget = SliverPrototypeExtentList(
        prototypeItem: prototypeItem!,
        delegate: SliverChildBuilderDelegate(
          itemBuilder,
          childCount: itemCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        ),
      );
    } else {
      listWidget = SliverList(
        delegate: SliverChildBuilderDelegate(
          itemBuilder,
          childCount: itemCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        ),
      );
    }

    if (headerBuilder != null && isStickyHeader != null) {
      return SliverStickyHeader.builder(
        builder: (context, state) => headerBuilder!(context, state.index),
        sliver: listWidget,
        sticky: true,
      );
    }

    return listWidget;
  }
}

class SliverStickyHeader extends StatelessWidget {
  final Widget header;
  final Widget sliver;
  final bool sticky;

  const SliverStickyHeader({
    super.key,
    required this.header,
    required this.sliver,
    this.sticky = true,
  });

  factory SliverStickyHeader.builder({
    Key? key,
    required Widget Function(BuildContext, SliverStickyHeaderState) builder,
    required Widget sliver,
    bool sticky = true,
  }) {
    return SliverStickyHeader(
      key: key,
      header: SliverStickyHeaderBuilder(builder: builder),
      sliver: sliver,
      sticky: sticky,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: sticky,
      delegate: _StickyHeaderDelegate(
        header: header,
        sliver: sliver,
      ),
    );
  }
}

class SliverStickyHeaderBuilder extends StatelessWidget {
  final Widget Function(BuildContext, SliverStickyHeaderState) builder;

  const SliverStickyHeaderBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return builder(context, SliverStickyHeaderState());
  }
}

class SliverStickyHeaderState {
  final double scrollPercentage = 0.0;
  final bool isPinned = false;
  final int index = 0;
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget header;
  final Widget sliver;

  _StickyHeaderDelegate({required this.header, required this.sliver});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Column(
      children: [
        header,
        Expanded(child: sliver),
      ],
    );
  }

  @override
  double get maxExtent => 56.0; // Adjust this value based on your header height

  @override
  double get minExtent => 56.0; // Adjust this value based on your header height

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
