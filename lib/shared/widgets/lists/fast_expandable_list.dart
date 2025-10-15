/// **FastExpandableList** - Collapsible list widget with smooth animations and platform styling.
///
/// **Use Case:** 
/// Accordion-style lists for FAQs, settings categories, menu sections, or any grouped content 
/// where you want to save space and allow users to expand sections on demand. Perfect for 
/// organizing related items in expandable/collapsible sections with smooth animations.
///
/// **Key Features:**
/// - Platform-adaptive styling (Cupertino containers on iOS, Material Cards on Android)
/// - Smooth expand/collapse animations with customizable duration
/// - Animated rotation icon that indicates expand/collapse state
/// - Customizable card appearance with elevation and color options
/// - Custom title styling and margin control
/// - Accessible tap area for easy interaction
/// - Memory-efficient with proper animation controller disposal
///
/// **Important Parameters:**
/// - `title`: Header text displayed in the expandable section (required)
/// - `children`: List of widgets to display when expanded (required)
/// - `cardColor`: Background color of the expandable container
/// - `elevation`: Shadow depth for the card (Material Design)
/// - `margin`: External spacing around the expandable list
/// - `titleStyle`: Custom text style for the header title
///
/// **Usage Examples:**
/// ```dart
/// // Basic FAQ section
/// FastExpandableList(
///   title: 'Frequently Asked Questions',
///   children: [
///     ListTile(title: Text('How do I reset my password?')),
///     ListTile(title: Text('How do I change my email?')),
///     ListTile(title: Text('How do I delete my account?')),
///   ]
/// )
///
/// // Settings category with custom styling
/// FastExpandableList(
///   title: 'Privacy Settings',
///   cardColor: Colors.grey[50],
///   elevation: 4.0,
///   titleStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
///   children: [
///     SwitchListTile(title: Text('Location Services'), value: true),
///     SwitchListTile(title: Text('Analytics'), value: false),
///   ]
/// )
///
/// // Menu section with custom margin
/// FastExpandableList(
///   title: 'Advanced Options',
///   margin: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
///   children: [
///     ListTile(title: Text('Developer Mode'), trailing: Icon(Icons.code)),
///     ListTile(title: Text('Debug Info'), trailing: Icon(Icons.bug_report)),
///   ]
/// )
/// ```

import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FastExpandableList extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final Color? cardColor;
  final double elevation;
  final EdgeInsetsGeometry? margin;
  final TextStyle? titleStyle;

  const FastExpandableList({
    required this.title,
    required this.children,
    super.key,
    this.cardColor,
    this.elevation = 2.0,
    this.margin,
    this.titleStyle,
  });

  @override
  _ExpandableListState createState() => _ExpandableListState();
}

class _ExpandableListState extends State<FastExpandableList>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Platform.isIOS;
    final ThemeData theme = Theme.of(context);
    final TextStyle defaultTitleStyle = theme.textTheme.titleMedium!;
    final TextStyle appliedTitleStyle = widget.titleStyle ?? defaultTitleStyle;

    return isIOS
        ? _buildCupertino(context, appliedTitleStyle)
        : _buildMaterial(context, appliedTitleStyle);
  }

  Widget _buildMaterial(BuildContext context, TextStyle titleStyle) {
    return Card(
      elevation: widget.elevation, // Use the new elevation parameter
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8.0),
      color:
          widget.cardColor ?? Colors.white, // Use the new card color parameter
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              widget.title,
              style: titleStyle,
            ),
            trailing: AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
              ),
            ),
            onTap: _toggleExpanded,
          ),
          SizeTransition(
            sizeFactor: _animation,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: widget.children,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCupertino(BuildContext context, TextStyle titleStyle) {
    return Container(
      margin: widget.margin ??
          const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: widget.cardColor ?? CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12.0),
        // boxShadow: <BoxShadow>[
        //   BoxShadow(
        //     color: CupertinoColors.black.withOpacity(0.1),
        //     blurRadius: 4.0,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: Column(
        children: <Widget>[
          CupertinoButton(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            onPressed: _toggleExpanded,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.title,
                    style: titleStyle.copyWith(
                      color: CupertinoColors.label,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _isExpanded
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down,
                    color: CupertinoColors.systemGrey,
                    size: 20.0,
                  ),
                ),
              ],
            ),
          ),
          SizeTransition(
            sizeFactor: _animation,
            axisAlignment: -1.0,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: widget.children,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
