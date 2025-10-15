
/// **FastListTile** - Platform-adaptive list item with rich customization and iOS Settings styling.
///
/// **Use Case:**
/// Individual list items for settings screens, menus, contact lists, or any scenario where you need
/// a structured list item with title, subtitle, icons, and interactive elements. Provides iOS Settings
/// app styling with proper typography, spacing, and interaction patterns while supporting Material
/// Design for Android.
///
/// **Key Features:**
/// - Platform-adaptive styling (CupertinoListTile on iOS, Material ListTile on Android)
/// - Built-in switch integration for toggle settings (iOS native switch styling)
/// - Automatic navigation chevron display for actionable items
/// - Selection state highlighting with iOS-appropriate colors
/// - Haptic feedback support on iOS for enhanced user experience
/// - Grouped style option with rounded corners and borders
/// - Support for leading icons or custom widgets
/// - Custom trailing widgets or automatic chevron placement
/// - Proper iOS typography sizes and colors (17pt title, 15pt subtitle)
/// - Enabled/disabled state management with appropriate visual feedback
///
/// **Important Parameters:**
/// - `title`: Primary text displayed in the list tile (required)
/// - `subtitle`: Secondary text displayed below the title
/// - `leadingIcon`: Icon displayed at the start of the tile
/// - `leadingWidget`: Custom widget at the start (overrides leadingIcon)
/// - `trailingWidget`: Custom widget at the end of the tile
/// - `onTap`: Callback when the tile is tapped
/// - `showChevron`: Whether to show navigation chevron for actionable items (default true)
/// - `switchValue`: Switch state for toggle functionality
/// - `onSwitchChanged`: Callback when switch value changes
/// - `isSelected`: Whether the tile is currently selected (shows highlight)
/// - `useGroupedStyle`: Use grouped styling with rounded corners
/// - `enabled`: Whether the tile accepts interaction
/// - `hapticFeedback`: Enable haptic feedback on iOS (default true)
///
/// **Usage Examples:**
/// ```dart
/// // Basic settings item with navigation
/// FastListTile(
///   title: 'Privacy & Security',
///   subtitle: 'Manage your privacy settings',
///   leadingIcon: Icons.security,
///   onTap: () => navigateToPrivacySettings()
/// )
///
/// // Toggle setting with switch
/// FastListTile(
///   title: 'Location Services',
///   subtitle: 'Allow apps to access your location',
///   leadingIcon: Icons.location_on,
///   switchValue: locationEnabled,
///   onSwitchChanged: (value) => toggleLocationServices(value),
///   showChevron: false
/// )
///
/// // Contact list item
/// FastListTile(
///   title: 'John Doe',
///   subtitle: 'john.doe@example.com',
///   leadingWidget: CircleAvatar(child: Text('JD')),
///   trailingWidget: Icon(Icons.phone),
///   onTap: () => callContact()
/// )
///
/// // Selected item with custom styling
/// FastListTile(
///   title: 'Selected Option',
///   isSelected: true,
///   useGroupedStyle: true,
///   tileColor: Colors.blue[50],
///   onTap: () => selectOption()
/// )
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FastListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? leadingWidget;
  final Widget? trailingWidget;
  final VoidCallback? onTap;
  final Color? tileColor;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final bool isThreeLine;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final bool dense;
  final bool enabled;
  final Color? borderColor;
  final double? borderRadius;

  /// Whether to show navigation chevron (iOS only)
  final bool showChevron;

  /// Whether to use grouped list styling with rounded corners
  final bool useGroupedStyle;

  /// Whether this tile is selected (shows iOS selection highlight)
  final bool isSelected;

  /// Switch value for CupertinoSwitch integration
  final bool? switchValue;

  /// Switch change callback for CupertinoSwitch integration
  final ValueChanged<bool>? onSwitchChanged;

  /// Whether to add haptic feedback on tap (iOS only)
  final bool hapticFeedback;

  const FastListTile({
    required this.title,
    this.subtitle,
    super.key,
    this.leadingIcon,
    this.leadingWidget,
    this.trailingWidget,
    this.onTap,
    this.tileColor,
    this.padding,
    this.elevation,
    this.isThreeLine = false,
    this.titleStyle,
    this.subtitleStyle,
    this.dense = false,
    this.enabled = true,
    this.borderColor,
    this.borderRadius,
    this.showChevron = true,
    this.useGroupedStyle = false,
    this.isSelected = false,
    this.switchValue,
    this.onSwitchChanged,
    this.hapticFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return isIOS ? _buildCupertinoTile(context) : _buildMaterialTile(context);
  }

  Widget _buildMaterialTile(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: elevation ?? 1.0,
      color: tileColor ?? theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
        side: borderColor != null
            ? BorderSide(color: borderColor!)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: padding ??
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: leadingWidget ??
            (leadingIcon != null
                ? Icon(
                    leadingIcon,
                    color:
                        enabled ? theme.iconTheme.color : theme.disabledColor,
                  )
                : null),
        title: Text(
          title,
          style: titleStyle ?? theme.textTheme.titleMedium,
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                maxLines: isThreeLine ? 3 : 1,
                overflow: TextOverflow.ellipsis,
                style: subtitleStyle ?? theme.textTheme.bodyMedium,
              )
            : null,
        trailing: trailingWidget,
        onTap: enabled ? onTap : null,
        dense: dense,
        enabled: enabled,
      ),
    );
  }

  Widget _buildCupertinoTile(BuildContext context) {
    final Widget tileContent = CupertinoListTile(
      title: Text(
        title,
        style: titleStyle ?? TextStyle(
          color: CupertinoColors.label.resolveFrom(context),
          fontSize: 17, // iOS standard list title size
          fontWeight: FontWeight.w400,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              maxLines: isThreeLine ? 3 : 1,
              overflow: TextOverflow.ellipsis,
              style: subtitleStyle ?? TextStyle(
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                fontSize: 15, // iOS standard subtitle size
                fontWeight: FontWeight.w400,
              ),
            )
          : null,
      leading: leadingWidget ??
          (leadingIcon != null
              ? Icon(
                  leadingIcon,
                  color: enabled
                      ? CupertinoColors.activeBlue.resolveFrom(context)
                      : CupertinoColors.inactiveGray.resolveFrom(context),
                  size: 29, // iOS standard icon size
                )
              : null),
      trailing: _buildTrailingWidget(),
      onTap: enabled ? _handleTap : null,
      backgroundColor: _getTileBackgroundColor(context),
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 11.0, // iOS standard vertical padding
      ),
    );

    // Apply grouped style if enabled
    if (useGroupedStyle) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: _getTileBackgroundColor(context),
          borderRadius: BorderRadius.circular(10), // iOS grouped style radius
          border: Border.all(
            color: CupertinoColors.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
        child: tileContent,
      );
    }

    return tileContent;
  }

  Widget? _buildTrailingWidget() {
    // Switch integration takes priority
    if (switchValue != null && onSwitchChanged != null) {
      return CupertinoSwitch(
        value: switchValue!,
        onChanged: enabled ? onSwitchChanged : null,
      );
    }

    // Custom trailing widget
    if (trailingWidget != null) {
      return trailingWidget;
    }

    // Show chevron for navigation
    if (showChevron && onTap != null && enabled) {
      return const CupertinoListTileChevron();
    }

    return null;
  }

  Color _getTileBackgroundColor(BuildContext context) {
    if (isSelected) {
      return CupertinoColors.systemGrey5.resolveFrom(context); // iOS selection highlight
    }
    return tileColor ?? CupertinoColors.systemBackground.resolveFrom(context);
  }

  void _handleTap() {
    if (hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    onTap?.call();
  }
}
