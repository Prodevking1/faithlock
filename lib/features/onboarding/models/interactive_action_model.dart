import 'package:flutter/material.dart';

enum InteractiveActionType {
  toggle,
  textInput,
  selection,
  demo,
  permission,
  setup,
}

/// Enum for different permission types - more stable than string parsing
enum PermissionType {
  pushNotifications,
  microphone,
  camera,
  photos,
  location,
  contacts,
  storage,
  calendar,
}

class ActionOption {
  final String id;
  final String label;
  final IconData? icon;
  final Color? color;

  const ActionOption({
    required this.id,
    required this.label,
    this.icon,
    this.color,
  });
}

class InteractiveAction {
  final String id;
  final InteractiveActionType type;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? color;

  final bool? defaultValue;
  final String? toggleDescription;

  final String? placeholder;
  final String? helperText;
  final TextInputType? inputType;
  final int? maxLength;

  final List<ActionOption>? options;
  final bool? multiSelect;
  final int? minSelection;
  final int? maxSelection;
  final String? demoDescription;
  final Widget? demoWidget;

  final String? permissionRationale;
  final List<String>? requiredPermissions; // Deprecated - use permissionTypes instead
  final List<PermissionType>? permissionTypes; // New enum-based approach

  final bool isRequired;
  final String? validationError;

  const InteractiveAction({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.defaultValue,
    this.toggleDescription,
    this.placeholder,
    this.helperText,
    this.inputType,
    this.maxLength,
    this.options,
    this.multiSelect,
    this.minSelection,
    this.maxSelection,
    this.demoDescription,
    this.demoWidget,
    this.permissionRationale,
    this.requiredPermissions,
    this.permissionTypes,
    this.isRequired = false,
    this.validationError,
  });
}

class ActionResult {
  final String actionId;
  final dynamic value;
  final bool isCompleted;
  final DateTime? completedAt;

  const ActionResult({
    required this.actionId,
    required this.value,
    required this.isCompleted,
    this.completedAt,
  });

  /// Convenience getter for accessing action data
  /// Returns value as Map<String, dynamic> if possible, otherwise returns the raw value
  Map<String, dynamic>? get data {
    if (value is Map<String, dynamic>) {
      return value as Map<String, dynamic>;
    } else if (value != null) {
      // For simple values, wrap them in a map
      return {'value': value};
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'actionId': actionId,
    'value': value,
    'isCompleted': isCompleted,
    'completedAt': completedAt?.toIso8601String(),
  };
}
