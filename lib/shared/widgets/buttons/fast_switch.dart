/// **FastSwitch** - Cross-platform toggle switch for boolean settings.
///
/// **Use Case:** 
/// For binary settings and preferences like "Enable Notifications", "Dark Mode", 
/// or "Auto-Save". Provides native platform appearance and behavior while maintaining 
/// consistent API across iOS and Android.
///
/// **Key Features:**
/// - Platform-adaptive styling (CupertinoSwitch on iOS, Switch on Android)
/// - Customizable colors for active/inactive states
/// - Built-in haptic feedback on toggle
/// - Disabled state support
/// - Consistent callback handling
///
/// **Important Parameters:**
/// - `value`: Current switch state (true/false) (required)
/// - `onChanged`: Callback when switch is toggled (ValueChanged<bool>)
/// - `enabled`: Whether the switch can be interacted with
/// - `activeColor`: Color when switch is ON
/// - `trackColor`: Background track color
/// - `thumbColor`: Color of the switch thumb/handle
/// - `hapticFeedback`: Enable tactile feedback on toggle
///
/// **Usage Examples:**
/// ```dart
/// // Basic settings toggle
/// FastSwitch(
///   value: notificationsEnabled,
///   onChanged: (value) => setState(() => notificationsEnabled = value)
/// )
///
/// // Custom colored switch
/// FastSwitch(
///   value: darkMode,
///   activeColor: Colors.purple,
///   onChanged: (value) => toggleDarkMode(value)
/// )
///
/// // Disabled state
/// FastSwitch(
///   value: premiumFeature,
///   enabled: isPremiumUser,
///   onChanged: isPremiumUser ? (value) => toggleFeature(value) : null
/// )
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FastSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? trackColor;
  final Color? thumbColor;
  
  /// Whether to add haptic feedback on iOS (default: true)
  final bool hapticFeedback;
  
  /// Whether the switch is enabled (default: true)
  final bool enabled;

  const FastSwitch({
    required this.value,
    this.onChanged,
    super.key,
    this.activeColor,
    this.trackColor,
    this.thumbColor,
    this.hapticFeedback = true,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final bool isEnabled = enabled && onChanged != null;

    if (isIOS) {
      return CupertinoSwitch(
        value: value,
        onChanged: isEnabled ? _handleIOSChange : null,
        activeColor: activeColor ?? CupertinoColors.activeGreen,
        trackColor: trackColor,
        thumbColor: thumbColor,
      );
    } else {
      return Switch(
        value: value,
        onChanged: isEnabled ? _handleMaterialChange : null,
        activeColor: activeColor,
        activeTrackColor: trackColor,
        inactiveThumbColor: thumbColor,
        thumbColor: thumbColor != null 
          ? WidgetStateProperty.all(thumbColor) 
          : null,
      );
    }
  }

  void _handleIOSChange(bool newValue) {
    if (hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    onChanged?.call(newValue);
  }

  void _handleMaterialChange(bool newValue) {
    if (hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    onChanged?.call(newValue);
  }
}
