/// **FastFormRow** - Platform-adaptive form row container for consistent form layouts.
///
/// **Use Case:** 
/// Create structured form layouts with labels, helper text, and error states. Perfect for 
/// settings screens, user profiles, or any form that needs consistent spacing and styling 
/// across platforms. Handles the visual structure so you can focus on the input content.
///
/// **Key Features:**
/// - Platform-adaptive styling (CupertinoFormRow on iOS, custom Material layout on Android)
/// - Flexible prefix/suffix widget support for icons or additional controls
/// - Built-in helper and error text display with proper styling
/// - Consistent spacing and alignment across platforms
/// - Enable/disable state handling
/// - Optional tap handling for custom interactions
///
/// **Important Parameters:**
/// - `child`: The main form input widget (required)
/// - `label`: Row label text displayed on the left
/// - `prefix`: Optional widget displayed before the label
/// - `suffix`: Optional widget displayed after the input
/// - `helper`: Helper text shown below the row
/// - `error`: Error text shown below the row (styled in red)
/// - `enabled`: Whether the row accepts interaction
/// - `onTap`: Optional tap handler for the entire row
/// - `padding`: Custom padding around the row content
///
/// **Usage Examples:**
/// ```dart
/// // Basic form row with text input
/// FastFormRow(
///   label: 'Name',
///   child: TextField(decoration: InputDecoration.collapsed(hintText: 'Enter name'))
/// )
///
/// // With helper and error text
/// FastFormRow(
///   label: 'Email',
///   helper: 'We will never share your email',
///   error: hasError ? 'Invalid email format' : null,
///   child: TextField(decoration: InputDecoration.collapsed(hintText: 'name@example.com'))
/// )
///
/// // With prefix icon and suffix action
/// FastFormRow(
///   label: 'Password',
///   prefix: Icon(Icons.lock),
///   suffix: IconButton(icon: Icon(Icons.visibility), onPressed: () => toggleVisibility()),
///   child: TextField(obscureText: true)
/// )
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/export.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FastFormRow extends StatelessWidget {
  final String? label;
  final Widget? prefix;
  final Widget? suffix;
  final Widget child;
  final String? helper;
  final String? error;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool enabled;

  const FastFormRow({
    super.key,
    this.label,
    this.prefix,
    this.suffix,
    required this.child,
    this.helper,
    this.error,
    this.padding,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return _buildCupertinoFormRow(context);
    } else {
      return _buildMaterialFormRow(context);
    }
  }

  Widget _buildCupertinoFormRow(BuildContext context) {
    return CupertinoFormRow(
      prefix: prefix ?? (label != null ? _buildIOSLabel(context) : null),
      helper: helper != null ? _buildIOSHelper(context) : null,
      error: error != null ? _buildIOSError(context) : null,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: child,
    );
  }

  Widget _buildMaterialFormRow(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (prefix != null) ...[
                  prefix!,
                  const SizedBox(width: 12),
                ],
                if (label != null) ...[
                  Expanded(
                    flex: 2,
                    child: Text(
                      label!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: enabled ? null : FastColors.disabled(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  flex: 3,
                  child: child,
                ),
                if (suffix != null) ...[
                  const SizedBox(width: 12),
                  suffix!,
                ],
              ],
            ),
            if (helper != null) ...[
              const SizedBox(height: 4),
              Text(
                helper!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: FastColors.secondaryText(context),
                ),
              ),
            ],
            if (error != null) ...[
              const SizedBox(height: 4),
              Text(
                error!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIOSLabel(BuildContext context) {
    return Text(
      label!,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: CupertinoColors.label.resolveFrom(context),
      ),
    );
  }

  Widget _buildIOSHelper(BuildContext context) {
    return Text(
      helper!,
      style: TextStyle(
        fontSize: 13,
        color: CupertinoColors.secondaryLabel.resolveFrom(context),
      ),
    );
  }

  Widget _buildIOSError(BuildContext context) {
    return Text(
      error!,
      style: TextStyle(
        fontSize: 13,
        color: CupertinoColors.destructiveRed.resolveFrom(context),
      ),
    );
  }
}

/// **FastFormTextField** - Complete form text input with integrated validation and styling.
///
/// **Use Case:** 
/// Ready-to-use text input field for forms with built-in label, validation, and error handling.
/// Perfect for user registration, profile editing, or any form requiring text input with 
/// consistent styling and behavior across platforms.
///
/// **Important Parameters:**
/// - `label`: Field label text
/// - `placeholder`: Placeholder text shown in the input
/// - `controller`: TextEditingController for programmatic control
/// - `initialValue`: Initial text value (alternative to controller)
/// - `obscureText`: Hide input text for passwords
/// - `keyboardType`: Keyboard type optimization
/// - `validator`: Form validation function
/// - `onChanged`: Callback when text changes
/// - `helper`: Helper text displayed below input
/// - `error`: Error text displayed below input

class FastFormTextField extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final String? initialValue;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool enabled;
  final String? helper;
  final String? error;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const FastFormTextField({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.initialValue,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
    this.helper,
    this.error,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return FastFormRow(
        label: label,
        helper: helper,
        error: error,
        enabled: enabled,
        child: CupertinoTextFormFieldRow(
          controller: controller,
          initialValue: initialValue,
          placeholder: placeholder,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          onChanged: onChanged,
          validator: validator,
          style: TextStyle(
            fontSize: 17,
            color: CupertinoColors.label.resolveFrom(context),
          ),
          decoration: const BoxDecoration(),
          padding: EdgeInsets.zero,
        ),
      );
    } else {
      return FastFormRow(
        label: label,
        helper: helper,
        error: error,
        enabled: enabled,
        child: TextFormField(
          controller: controller,
          initialValue: initialValue,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: placeholder,
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      );
    }
  }
}

/// **FastFormPicker** - Generic picker field for selecting from a list of options.
///
/// **Use Case:** 
/// Create dropdown-style pickers for selecting from predefined options like countries, 
/// categories, or any enumerated values. Shows platform-appropriate picker UI (CupertinoPicker 
/// on iOS, BottomSheet with ListView on Android) with consistent form integration.
///
/// **Important Parameters:**
/// - `items`: List of selectable options (required)
/// - `itemBuilder`: Function to convert option to display string (required)
/// - `value`: Currently selected item
/// - `onChanged`: Callback when selection changes
/// - `label`: Field label text
/// - `placeholder`: Placeholder when no option is selected
/// - `helper`: Helper text displayed below field
/// - `error`: Error text displayed below field

class FastFormPicker<T> extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final T? value;
  final List<T> items;
  final String Function(T) itemBuilder;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final String? helper;
  final String? error;

  const FastFormPicker({
    super.key,
    this.label,
    this.placeholder,
    this.value,
    required this.items,
    required this.itemBuilder,
    this.onChanged,
    this.enabled = true,
    this.helper,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final String displayText = value != null 
        ? itemBuilder(value!)
        : (placeholder ?? 'select'.tr);

    return FastFormRow(
      label: label,
      helper: helper,
      error: error,
      enabled: enabled,
      onTap: enabled ? () => _showPicker(context) : null,
      suffix: Icon(
        CupertinoIcons.chevron_right,
        size: 16,
        color: CupertinoColors.tertiaryLabel.resolveFrom(context),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 17,
          color: value != null 
              ? (Theme.of(context).platform == TargetPlatform.iOS
                  ? CupertinoColors.label
                  : Theme.of(context).textTheme.bodyLarge?.color)
              : (Theme.of(context).platform == TargetPlatform.iOS
                  ? CupertinoColors.placeholderText
                  : FastColors.disabled(context)),
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    HapticFeedback.selectionClick();
    
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 200,
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: CupertinoPicker(
              itemExtent: 32,
              onSelectedItemChanged: (int index) {
                onChanged?.call(items[index]);
              },
              children: items.map((item) => Text(itemBuilder(item))).toList(),
            ),
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(itemBuilder(item)),
                onTap: () {
                  onChanged?.call(item);
                  Navigator.of(context).pop();
                },
              );
            },
          );
        },
      );
    }
  }
}