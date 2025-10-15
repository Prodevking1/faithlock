/// **FastAppBar** - Cross-platform app bar that automatically adapts to iOS and Android design patterns.
///
/// **Use Case:** 
/// Use this when you need a navigation bar that looks native on both iOS and Android without 
/// writing platform-specific code. Ideal for screen headers, navigation, and title display.
///
/// **Key Features:**
/// - Auto-adapts to platform (CupertinoNavigationBar on iOS, Material AppBar on Android)
/// - iOS large title support with smooth scroll transitions
/// - Native blur effects and platform-specific styling
/// - Consistent API across platforms
///
/// **Important Parameters:**
/// - `title`: Main title widget (typically Text)
/// - `actions`: Right-side action buttons (List<Widget>)
/// - `leading`: Left-side widget (auto back button if null)
/// - `useLargeTitle`: iOS only - enables large scrollable title
/// - `largeTitleText`: Text for iOS large title mode
/// - `backgroundColor`: Custom background color
/// - `centerTitle`: Android only - centers the title
/// - `useIOSBlur`: iOS only - enables native blur effect
/// - `elevation`: Android only - shadow depth
///
/// **Usage Example:**
/// ```dart
/// // Basic usage
/// FastAppBar(title: Text('Settings'))
///
/// // iOS with large title
/// FastAppBar(
///   useLargeTitle: true,
///   largeTitleText: 'Messages',
///   actions: [IconButton(icon: Icon(Icons.add), onPressed: () {})]
/// )
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FastAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double elevation;
  final bool centerTitle;
  final bool useLargeTitle;
  final String? largeTitleText;
  
  /// Whether to use iOS blur effect (only on iOS)
  final bool useIOSBlur;
  
  /// Whether to automatically handle leading back button
  final bool automaticallyImplyLeading;
  
  /// Search bar widget to show under large title
  final Widget? searchBar;

  const FastAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.elevation = 4.0,
    this.centerTitle = true,
    this.useLargeTitle = false,
    this.largeTitleText,
    this.useIOSBlur = true,
    this.automaticallyImplyLeading = true,
    this.searchBar,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      if (useLargeTitle && largeTitleText != null) {
        return CupertinoSliverNavigationBar(
          largeTitle: Text(
            largeTitleText!,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          middle: title,
          leading: automaticallyImplyLeading ? leading : leading,
          trailing: actions != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                )
              : null,
          backgroundColor: useIOSBlur ? null : backgroundColor,
          border: useIOSBlur ? null : Border(
            bottom: BorderSide(
              color: CupertinoColors.separator.resolveFrom(context),
              width: 0.0,
            ),
          ),
          stretch: true,
          // Add search bar support under large title
          // Note: Search bar would typically be added to the sliver list below this
        );
      } else {
        return CupertinoNavigationBar(
          middle: title,
          leading: automaticallyImplyLeading ? leading : leading,
          trailing: actions != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                )
              : null,
          backgroundColor: useIOSBlur ? null : backgroundColor,
          border: useIOSBlur ? null : Border(
            bottom: BorderSide(
              color: CupertinoColors.separator.resolveFrom(context),
              width: 0.0,
            ),
          ),
        );
      }
    } else {
      return Material(
        elevation: elevation,
        color: backgroundColor ?? Theme.of(context).primaryColor,
        child: SafeArea(
          child: Container(
            height: kToolbarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: <Widget>[
                if (leading != null) leading!,
                Expanded(
                  child: centerTitle
                      ? Center(child: title)
                      : Align(alignment: Alignment.centerLeft, child: title),
                ),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Size get preferredSize {
    // For iOS large title mode, return expanded height
    // Note: CupertinoSliverNavigationBar handles dynamic sizing internally
    if (useLargeTitle) {
      return const Size.fromHeight(kToolbarHeight + 52); // Large title space
    }
    return const Size.fromHeight(kToolbarHeight);
  }
  
  /// Creates a search bar widget that integrates with large title
  Widget? createSearchBarForLargeTitle() {
    if (searchBar != null && useLargeTitle) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: searchBar,
      );
    }
    return null;
  }
}
