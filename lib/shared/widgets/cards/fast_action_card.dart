/// **FastActionCard** - Interactive card with built-in action button for enhanced content display.
///
/// **Use Case:** 
/// Perfect for content that requires user interaction like promotional offers, feature highlights, 
/// or informational blocks that need a clear call-to-action. Ideal for dashboards, feature 
/// showcases, or onboarding flows where you need to combine information with actionable elements.
///
/// **Key Features:**
/// - Platform-adaptive styling (Cupertino design on iOS, Material on Android)
/// - Flexible content layout with title, subtitle, and custom content
/// - Built-in action button positioned at bottom-right
/// - Optional leading icon or image for visual enhancement
/// - Full card tap interaction separate from action button
/// - Haptic feedback for better user experience
/// - Customizable elevation and border radius
///
/// **Important Parameters:**
/// - `title`: Primary heading text for the card
/// - `subtitle`: Secondary descriptive text
/// - `content`: Custom widget for main card content
/// - `leadingIcon`: Optional icon displayed before title
/// - `leadingImage`: Optional image widget for visual context
/// - `actionText`: Text for the action button
/// - `onActionPressed`: Callback for action button tap
/// - `onTap`: Callback for full card tap (separate from action)
/// - `elevation`: Shadow depth for Material design
/// - `borderRadius`: Custom corner rounding
///
/// **Usage Examples:**
/// ```dart
/// // Feature highlight with action
/// FastActionCard(
///   title: 'Premium Features',
///   subtitle: 'Unlock advanced capabilities',
///   leadingIcon: Icons.star,
///   actionText: 'Upgrade',
///   onActionPressed: () => showUpgradeDialog(),
///   onTap: () => showFeatureDetails()
/// )
///
/// // Promotional card with custom content
/// FastActionCard(
///   title: 'Special Offer',
///   content: Column(children: [
///     Text('50% off premium subscription'),
///     Text('Limited time only', style: TextStyle(color: Colors.red))
///   ]),
///   actionText: 'Claim Now',
///   onActionPressed: () => claimOffer()
/// )
/// ```
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FastActionCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? content;
  final IconData? leadingIcon;
  final Widget? leadingImage;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final VoidCallback? onTap;
  final double elevation;
  final BorderRadius? borderRadius;
  final bool enableHapticFeedback;
  final bool isHorizontal;
  final IconData? trailingIcon;

  const FastActionCard({
    super.key,
    this.title,
    this.subtitle,
    this.content,
    this.leadingIcon,
    this.leadingImage,
    this.actionText,
    this.onActionPressed,
    this.onTap,
    this.elevation = 1.0,
    this.borderRadius,
    this.enableHapticFeedback = true,
    this.isHorizontal = false,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return _buildCupertinoCard(context);
    } else {
      return _buildMaterialCard(context);
    }
  }

  Widget _buildCupertinoCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground
            .resolveFrom(context),
        borderRadius: borderRadius ?? BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey
                .resolveFrom(context)
                .withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap != null
            ? () {
                if (enableHapticFeedback) {
                  HapticFeedback.lightImpact();
                }
                onTap!();
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leading icon and title row
              if (leadingIcon != null || title != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (leadingIcon != null) ...[
                      Icon(
                        leadingIcon,
                        size: 24.0,
                        color: CupertinoColors.activeBlue.resolveFrom(context),
                      ),
                      const SizedBox(width: 12.0),
                    ],
                    if (title != null)
                      Expanded(
                        child: Text(
                          title!,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.label.resolveFrom(context),
                          ),
                        ),
                      ),
                  ],
                ),
              
              // Subtitle
              if (subtitle != null) ...[
                const SizedBox(height: 4.0),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 15,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
              ],
              
              // Content
              if (content != null) ...[
                const SizedBox(height: 12.0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: content!,
                ),
              ],
              
              // Action button (aligned right)
              if (actionText != null && onActionPressed != null) ...[
                const SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onPressed: onActionPressed,
                    child: Text(
                      actionText!,
                      style: TextStyle(
                        color: CupertinoColors.activeBlue.resolveFrom(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap != null
            ? () {
                if (enableHapticFeedback) {
                  HapticFeedback.lightImpact();
                }
                onTap!();
              }
            : null,
        borderRadius: borderRadius ?? BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leading icon and title row
              if (leadingIcon != null || leadingImage != null || title != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (leadingIcon != null || leadingImage != null) ...[
                      leadingImage ?? Icon(leadingIcon, size: 24.0),
                      const SizedBox(width: 12.0),
                    ],
                    if (title != null)
                      Expanded(
                        child: Text(
                          title!,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                  ],
                ),
              
              // Subtitle
              if (subtitle != null) ...[
                const SizedBox(height: 4.0),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              
              // Content
              if (content != null) ...[
                const SizedBox(height: 12.0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: content!,
                ),
              ],
              
              // Action button (aligned right)
              if (actionText != null && onActionPressed != null) ...[
                const SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onActionPressed,
                    child: Text(actionText!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
