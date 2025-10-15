/// **FastContextMenu** - Platform-adaptive context menu with long-press activation and native styling.
///
/// **Use Case:**
/// Use this for providing contextual actions on widgets through long-press gestures.
/// Perfect for list items, images, cards, or any content that needs secondary actions
/// accessible through long-press with native iOS/Android context menu styling.
///
/// **Key Features:**
/// - Platform-adaptive styling (iOS context menu on iOS, Material popup on Android)
/// - Long-press gesture activation with haptic feedback
/// - Customizable action list with icons, titles, and destructive styling
/// - Automatic positioning and overflow handling
/// - GetX internationalization support for action labels
/// - Haptic feedback integration for iOS
/// - Accessibility support with proper semantics
///
/// **Important Parameters:**
/// - `child`: Widget that triggers the context menu on long-press
/// - `actions`: List of FastContextMenuAction items to display
/// - `onPressed`: Optional callback when child is tapped (not long-pressed)
///
/// **Usage Example:**
/// ```dart
/// // Basic context menu
/// FastContextMenu(
///   child: ListTile(title: Text('Item')),
///   actions: [
///     FastContextMenuAction(
///       title: 'Share',
///       icon: Icons.share,
///       onPressed: () => shareItem(),
///     ),
///     FastContextMenuAction(
///       title: 'Delete',
///       icon: Icons.delete,
///       isDestructive: true,
///       onPressed: () => deleteItem(),
///     ),
///   ],
/// )
///
/// // With tap and long-press actions
/// FastContextMenu(
///   child: Card(child: Text('Content')),
///   onPressed: () => openItem(),
///   actions: [
///     FastContextMenuAction(
///       title: 'Edit',
///       icon: Icons.edit,
///       onPressed: () => editItem(),
///     ),
///   ],
/// )
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FastContextMenu extends StatelessWidget {
  final Widget child;
  final List<FastContextMenuAction> actions;
  final VoidCallback? onPressed;

  const FastContextMenu({
    super.key,
    required this.child,
    required this.actions,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return CupertinoContextMenu(
            actions: actions
                .map((action) => CupertinoContextMenuAction(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).pop();
                        action.onPressed?.call();
                      },
                      isDestructiveAction: action.isDestructive,
                      trailingIcon: action.icon,
                      child: Text(action.text),
                    ))
                .toList(),
            child: Container(
              width: constraints.hasInfiniteWidth ? null : constraints.maxWidth,
              constraints: BoxConstraints(
                minHeight: 44.0,
                maxHeight: constraints.maxHeight,
                maxWidth:
                    constraints.hasInfiniteWidth ? 400.0 : constraints.maxWidth,
              ),
              child: child,
            ),
          );
        },
      );
    } else {
      return GestureDetector(
        onLongPress: () => _showAndroidContextMenu(context),
        onTap: onPressed,
        child: child,
      );
    }
  }

  void _showAndroidContextMenu(BuildContext context) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ...actions.map((action) => ListTile(
                      leading: action.icon != null ? Icon(action.icon) : null,
                      title: Text(
                        action.text,
                        style: TextStyle(
                          color: action.isDestructive ? Colors.red : null,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        action.onPressed?.call();
                      },
                    )),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FastContextMenuAction {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isDestructive;

  const FastContextMenuAction({
    required this.text,
    this.icon,
    this.onPressed,
    this.isDestructive = false,
  });
}

class FastContextMenuBuilder {
  static Widget build({
    required BuildContext context,
    required Widget child,
    required List<FastContextMenuAction> actions,
    VoidCallback? onPressed,
  }) {
    return FastContextMenu(
      actions: actions,
      onPressed: onPressed,
      child: child,
    );
  }

  static List<FastContextMenuAction> createDefaultActions({
    VoidCallback? onCopy,
    VoidCallback? onShare,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return [
      if (onCopy != null)
        FastContextMenuAction(
          text: 'copy'.tr,
          icon: CupertinoIcons.doc_on_doc,
          onPressed: onCopy,
        ),
      if (onShare != null)
        FastContextMenuAction(
          text: 'share'.tr,
          icon: CupertinoIcons.share,
          onPressed: onShare,
        ),
      if (onEdit != null)
        FastContextMenuAction(
          text: 'edit'.tr,
          icon: CupertinoIcons.pencil,
          onPressed: onEdit,
        ),
      if (onDelete != null)
        FastContextMenuAction(
          text: 'delete'.tr,
          icon: CupertinoIcons.delete,
          onPressed: onDelete,
          isDestructive: true,
        ),
    ];
  }
}
