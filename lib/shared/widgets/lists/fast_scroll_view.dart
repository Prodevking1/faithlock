// AppCustomScrollView is a flexible, customizable scrollable widget that adapts to iOS and Android platforms.
// It combines the power of CustomScrollView with platform-specific behaviors and styling.
//
// Key features:
// - Automatically adapts to iOS or Android platform
// - Supports custom slivers as children
// - Implements platform-specific physics (bouncing for iOS, clamping for Android)
// - Allows customization of scroll controller, scroll direction, and other properties
// - Optionally includes a RefreshIndicator for pull-to-refresh functionality

import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class FastCustomScrollView extends StatelessWidget {
  final List<Widget> slivers;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final bool reverse;
  final bool? primary;
  final bool shrinkWrap;
  final Key? center;
  final double anchor;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;
  final bool enableRefresh;
  final Future<void> Function()? onRefresh;

  const FastCustomScrollView({
    required this.slivers,
    super.key,
    this.controller,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.primary,
    this.shrinkWrap = false,
    this.center,
    this.anchor = 0.0,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.enableRefresh = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Platform.isIOS;
    final ScrollPhysics defaultPhysics =
        isIOS ? const BouncingScrollPhysics() : const ClampingScrollPhysics();

    Widget scrollView = CustomScrollView(
      controller: controller,
      physics: physics ?? defaultPhysics,
      scrollDirection: scrollDirection,
      reverse: reverse,
      primary: primary,
      shrinkWrap: shrinkWrap,
      center: center,
      anchor: anchor,
      cacheExtent: cacheExtent,
      semanticChildCount: semanticChildCount,
      dragStartBehavior: dragStartBehavior,
      keyboardDismissBehavior: keyboardDismissBehavior,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
      slivers: slivers,
    );

    if (enableRefresh && onRefresh != null) {
      scrollView = isIOS
          ? CupertinoScrollbar(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: <Widget>[
                  CupertinoSliverRefreshControl(
                    onRefresh: onRefresh,
                  ),
                  ...slivers,
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: onRefresh!,
              child: scrollView,
            );
    }

    return scrollView;
  }
}
