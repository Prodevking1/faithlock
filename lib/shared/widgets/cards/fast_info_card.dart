/// **FastInfoCard** - Clean informational card for displaying structured data.
///
/// **Use Case:** 
/// Perfect for displaying informational content like user profiles, statistics, 
/// notifications, or any structured data that needs clear visual hierarchy. 
/// Great for dashboards, settings screens, or content lists where information 
/// needs to be easily scannable.
///
/// **Key Features:**
/// - Platform-adaptive design (Cupertino on iOS, Material on Android)
/// - Clean layout with title and content sections
/// - Optional leading icon for visual context
/// - Customizable background color
/// - Optional tap interaction with chevron indicator
/// - Consistent spacing and typography
/// - Native platform styling and interactions
///
/// **Important Parameters:**
/// - `title`: Primary heading text (required)
/// - `content`: Descriptive content text (required)
/// - `icon`: Optional leading icon for visual context
/// - `backgroundColor`: Custom background color (uses platform default if null)
/// - `onTap`: Optional callback for card interaction
///
/// **Usage Examples:**
/// ```dart
/// // Basic info display
/// FastInfoCard(
///   title: 'Account Status',
///   content: 'Your account is verified and active'
/// )
///
/// // With icon and interaction
/// FastInfoCard(
///   title: 'Storage Usage',
///   content: '2.3 GB of 5 GB used',
///   icon: Icons.storage,
///   onTap: () => showStorageDetails()
/// )
///
/// // Custom styling
/// FastInfoCard(
///   title: 'Premium Member',
///   content: 'Enjoy unlimited access to all features',
///   backgroundColor: Colors.blue[50],
///   icon: Icons.star,
///   onTap: () => showPremiumBenefits()
/// )
/// ```
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FastInfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData? icon;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const FastInfoCard({
    required this.title,
    required this.content,
    super.key,
    this.icon,
    this.backgroundColor,
    this.onTap,
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
        color: backgroundColor ??
            CupertinoColors.secondarySystemGroupedBackground
                .resolveFrom(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: CupertinoColors.activeBlue.resolveFrom(context),
                  size: 24,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label.resolveFrom(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.secondaryLabel.resolveFrom(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  CupertinoIcons.chevron_right,
                  color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 24),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(content, style: textTheme.bodyMedium),
                  ],
                ),
              ),
              if (onTap != null) const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
