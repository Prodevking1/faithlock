/// **FastFormSection** - Grouped form section container with headers and footers.
///
/// **Use Case:** 
/// Organize related form fields into logical sections with optional headers and footers.
/// Perfect for settings screens, registration forms, or any form that needs to group 
/// related fields together. Follows platform conventions for visual grouping.
///
/// **Key Features:**
/// - Platform-adaptive styling (CupertinoFormSection on iOS, Card on Android)
/// - Multiple section styles: inset grouped, grouped, plain
/// - Optional header and footer text or custom widgets
/// - Automatic separator handling between form rows
/// - Customizable background colors and margins
/// - Consistent spacing and typography
///
/// **Important Parameters:**
/// - `children`: List of form row widgets to group together (required)
/// - `headerTitle`: Section header text (automatically styled per platform)
/// - `header`: Custom header widget (overrides headerTitle)
/// - `footerTitle`: Section footer text (automatically styled per platform)
/// - `footer`: Custom footer widget (overrides footerTitle)
/// - `style`: Visual style of the section (insetGrouped, grouped, plain)
/// - `backgroundColor`: Custom background color for the section
/// - `margin`: Custom margin around the section
/// - `showSeparators`: Whether to show separators between children
///
/// **Usage Examples:**
/// ```dart
/// // Basic settings section
/// FastFormSection(
///   headerTitle: 'Account Settings',
///   footerTitle: 'Changes will be saved automatically',
///   children: [
///     FastFormRow(label: 'Name', child: TextField()),
///     FastFormRow(label: 'Email', child: TextField()),
///     FastFormRow(label: 'Phone', child: TextField()),
///   ]
/// )
///
/// // Privacy section with custom styling
/// FastFormSection(
///   headerTitle: 'Privacy',
///   style: FastFormSectionStyle.grouped,
///   backgroundColor: Colors.grey[50],
///   children: [
///     FastFormRow(label: 'Public Profile', child: Switch(value: true)),
///     FastFormRow(label: 'Show Email', child: Switch(value: false)),
///   ]
/// )
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum FastFormSectionStyle {
  insetGrouped,
  grouped,
  plain,
}

class FastFormSection extends StatelessWidget {
  final String? headerTitle;
  final Widget? header;
  final String? footerTitle;
  final Widget? footer;
  final List<Widget> children;
  final FastFormSectionStyle style;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final bool showSeparators;

  const FastFormSection({
    super.key,
    this.headerTitle,
    this.header,
    this.footerTitle,
    this.footer,
    required this.children,
    this.style = FastFormSectionStyle.insetGrouped,
    this.margin,
    this.backgroundColor,
    this.showSeparators = true,
  });

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return _buildCupertinoFormSection(context);
    } else {
      return _buildMaterialFormSection(context);
    }
  }

  Widget _buildCupertinoFormSection(BuildContext context) {
    return CupertinoFormSection.insetGrouped(
      header: _buildIOSHeader(context),
      footer: _buildIOSFooter(context),
      backgroundColor: backgroundColor ?? CupertinoColors.systemGroupedBackground,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: _buildFormRows(context),
    );
  }

  Widget _buildMaterialFormSection(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null || headerTitle != null) _buildMaterialHeader(context),
          ...children,
          if (footer != null || footerTitle != null) _buildMaterialFooter(context),
        ],
      ),
    );
  }

  List<Widget> _buildFormRows(BuildContext context) {
    if (!showSeparators || children.isEmpty) return children;

    List<Widget> rows = [];
    for (int i = 0; i < children.length; i++) {
      rows.add(children[i]);
      
      // Add separator except for last item
      if (i < children.length - 1 && showSeparators) {
        rows.add(const SizedBox(height: 0)); // CupertinoFormSection handles separators
      }
    }
    return rows;
  }

  Widget? _buildIOSHeader(BuildContext context) {
    if (header != null) return header;
    if (headerTitle == null) return null;
    
    return Text(
      headerTitle!.toUpperCase(),
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: CupertinoColors.secondaryLabel,
      ),
    );
  }

  Widget? _buildIOSFooter(BuildContext context) {
    if (footer != null) return footer;
    if (footerTitle == null) return null;
    
    return Text(
      footerTitle!,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: CupertinoColors.secondaryLabel,
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
          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}