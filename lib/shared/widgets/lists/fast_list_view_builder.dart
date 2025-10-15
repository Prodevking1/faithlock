// AppListViewBuilder is a high-performance ListView that builds its items on-demand.
// It adapts to iOS and Android platforms, providing native scrolling behavior and styling.
//
// Key features:
// - Automatically adapts to iOS or Android platform
// - Efficiently builds list items only when they're needed
// - Implements platform-specific scrolling physics and styling
// - Supports custom item builders and separators
// - Allows for infinite scrolling with minimal memory usage
// - Optionally includes pull-to-refresh functionality

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppListViewBuilder extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool primary;
  final Axis scrollDirection;
  final bool reverse;
  final IndexedWidgetBuilder? separatorBuilder;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? itemExtent;
  final Widget? prototypeItem;
  final bool enableRefresh;
  final Future<void> Function()? onRefresh;

  const AppListViewBuilder({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    this.controller,
    this.primary = false,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.separatorBuilder,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.itemExtent,
    this.prototypeItem,
    this.enableRefresh = false,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Platform.isIOS;
    final ScrollPhysics defaultPhysics = isIOS
        ? const BouncingScrollPhysics()
        : const ClampingScrollPhysics();

    Widget listView = separatorBuilder != null
        ? ListView.separated(
            itemCount: itemCount,
            itemBuilder: itemBuilder,
            separatorBuilder: separatorBuilder!,
            shrinkWrap: shrinkWrap,
            physics: physics ?? defaultPhysics,
            padding: padding,
            controller: controller,
            primary: primary,
            scrollDirection: scrollDirection,
            reverse: reverse,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
          )
        : ListView.builder(
            itemCount: itemCount,
            itemBuilder: itemBuilder,
            shrinkWrap: shrinkWrap,
            physics: physics ?? defaultPhysics,
            padding: padding,
            controller: controller,
            primary: primary,
            scrollDirection: scrollDirection,
            reverse: reverse,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
            itemExtent: itemExtent,
            prototypeItem: prototypeItem,
          );

    if (enableRefresh && onRefresh != null) {
      listView = isIOS
          ? CupertinoScrollbar(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  CupertinoSliverRefreshControl(
                    onRefresh: onRefresh,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = itemBuilder(context, index);
                        if (separatorBuilder != null && index < itemCount - 1) {
                          return Column(
                            children: [
                              item,
                              separatorBuilder!(context, index),
                            ],
                          );
                        }
                        return item;
                      },
                      childCount: itemCount,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: onRefresh!,
              child: listView,
            );
    }

    return listView;
  }
}
