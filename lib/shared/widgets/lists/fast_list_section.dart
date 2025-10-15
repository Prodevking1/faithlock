/// **FastListSection** - Grouped list container with headers and footers following platform conventions.
///
/// **Use Case:** 
/// Create Settings-style grouped lists with headers and footers for organizing related list items.
/// Perfect for settings screens, profile forms, or any interface that needs to group related 
/// controls with descriptive headers and explanatory footers. Follows iOS Human Interface 
/// Guidelines for inset grouped style.
///
/// **Key Features:**
/// - Platform-adaptive styling (iOS Settings style with inset grouped appearance on iOS, Material Cards on Android)
/// - Optional header and footer text or custom widgets
/// - Automatic separators between list items with proper iOS spacing (54pt indent)
/// - iOS Settings-compliant typography and spacing
/// - Inset grouped style with rounded corners and margins on iOS
/// - Customizable background colors and margins
/// - Non-scrollable container that works within parent scroll views
/// - Proper letter spacing and line height following iOS design guidelines
///
/// **Important Parameters:**
/// - `children`: List of widgets to display in the section (required, typically ListTiles)
/// - `headerTitle`: Section header text (automatically styled per platform)
/// - `header`: Custom header widget (overrides headerTitle)
/// - `footerTitle`: Section footer text (automatically styled per platform)
/// - `footer`: Custom footer widget (overrides footerTitle)
/// - `showSeparators`: Whether to show separators between children (default true)
/// - `useInsetGroupedStyle`: Use iOS Settings inset grouped style with margins (default true)
/// - `backgroundColor`: Custom background color for the section
/// - `margin`: Custom margin around the section
/// - `separatorIndent`: Custom separator indent (default 54pt per iOS HIG)
///
/// **Usage Examples:**
/// ```dart
/// // Basic settings section
/// FastListSection(
///   headerTitle: 'Account',
///   footerTitle: 'Your account information is kept private and secure.',
///   children: [
///     ListTile(title: Text('Name'), trailing: Text('John Doe')),
///     ListTile(title: Text('Email'), trailing: Text('john@example.com')),
///     ListTile(title: Text('Phone'), trailing: Text('+1 234 567 8900')),
///   ]
/// )
///
/// // Privacy settings with switches
/// FastListSection(
///   headerTitle: 'Privacy',
///   children: [
///     SwitchListTile(title: Text('Location Services'), value: true),
///     SwitchListTile(title: Text('Analytics'), value: false),
///     SwitchListTile(title: Text('Crash Reports'), value: true),
///   ]
/// )
///
/// // Custom styled section
/// FastListSection(
///   header: Text('Custom Header', style: TextStyle(fontSize: 20)),
///   backgroundColor: Colors.grey[50],
///   useInsetGroupedStyle: false,
///   showSeparators: false,
///   children: [
///     ListTile(title: Text('Item 1')),
///     ListTile(title: Text('Item 2')),
///   ]
/// )
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FastListSection extends StatelessWidget {
  final String? headerTitle;
  final Widget? header;
  final String? footerTitle;
  final Widget? footer;
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final bool showSeparators;
  
  /// Whether to use iOS Settings inset grouped style with 16pt horizontal margins
  final bool useInsetGroupedStyle;
  
  /// Custom separator indent (default: 54pt from left edge per iOS HIG)
  final double? separatorIndent;

  const FastListSection({
    super.key,
    this.headerTitle,
    this.header,
    this.footerTitle,
    this.footer,
    required this.children,
    this.margin,
    this.backgroundColor,
    this.showSeparators = true,
    this.useInsetGroupedStyle = true,
    this.separatorIndent,
  });

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return _buildCupertinoSection(context);
    } else {
      return _buildMaterialSection(context);
    }
  }

  Widget _buildCupertinoSection(BuildContext context) {
    final horizontalMargin = useInsetGroupedStyle ? 16.0 : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null || headerTitle != null) _buildIOSHeader(context),
        Container(
          margin: margin ?? EdgeInsets.symmetric(
            horizontal: horizontalMargin, 
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: backgroundColor ?? CupertinoColors.secondarySystemGroupedBackground,
            borderRadius: useInsetGroupedStyle 
              ? BorderRadius.circular(10) 
              : BorderRadius.zero,
          ),
          child: ClipRRect(
            borderRadius: useInsetGroupedStyle 
              ? BorderRadius.circular(10) 
              : BorderRadius.zero,
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: children.length,
              separatorBuilder: (context, index) =>
                  showSeparators && index < children.length - 1
                      ? Divider(
                          height: 1,
                          indent: separatorIndent ?? 54, // iOS HIG: 54pt from left edge
                          endIndent: 0,
                          color: CupertinoColors.separator,
                          thickness: 0.5,
                        )
                      : const SizedBox.shrink(),
              itemBuilder: (context, index) => children[index],
            ),
          ),
        ),
        if (footer != null || footerTitle != null) _buildIOSFooter(context),
      ],
    );
  }

  Widget _buildIOSHeader(BuildContext context) {
    if (header != null) return header!;

    final horizontalPadding = useInsetGroupedStyle ? 32.0 : 16.0;
    
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 32, horizontalPadding, 8),
      child: Text(
        headerTitle?.toUpperCase() ?? '',
        style: const TextStyle(
          color: CupertinoColors.secondaryLabel, // iOS Settings header color
          fontSize: 13, // iOS Settings header size
          fontWeight: FontWeight.w400,
          letterSpacing: -0.08, // iOS Settings letter spacing
        ),
      ),
    );
  }

  Widget _buildIOSFooter(BuildContext context) {
    if (footer != null) return footer!;

    final horizontalPadding = useInsetGroupedStyle ? 32.0 : 16.0;
    
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 32),
      child: Text(
        footerTitle ?? '',
        style: const TextStyle(
          color: CupertinoColors.secondaryLabel, // iOS Settings footer color
          fontSize: 13, // iOS Settings footer size
          fontWeight: FontWeight.w400,
          height: 1.25, // iOS Settings line height
        ),
      ),
    );
  }


  Widget _buildMaterialSection(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null || headerTitle != null)
            _buildMaterialHeader(context),
          ...children,
          if (footer != null || footerTitle != null)
            _buildMaterialFooter(context),
        ],
      ),
    );
  }

  Widget _buildMaterialHeader(BuildContext context) {
    if (header != null) return header!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        headerTitle ?? '',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildMaterialFooter(BuildContext context) {
    if (footer != null) return footer!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Text(
        footerTitle ?? '',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withValues(alpha: 0.7),
            ),
      ),
    );
  }
}
