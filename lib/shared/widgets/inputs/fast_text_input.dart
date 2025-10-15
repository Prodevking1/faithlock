/// **FastTextInput** - Versatile text input field with extensive customization and platform styling.
///
/// **Use Case:** 
/// General-purpose text input for forms, user profiles, settings, and data entry where you need 
/// flexible text input with various keyboard types and validation. Supports single-line and 
/// multiline text entry with comprehensive customization options for any text input scenario.
///
/// **Key Features:**
/// - Platform-adaptive styling (CupertinoTextField on iOS, TextFormField on Android)
/// - Support for all keyboard types (text, email, number, phone, etc.)
/// - Text capitalization options (none, words, sentences, characters)
/// - Character length limits and line count control
/// - Built-in validation support with custom validators
/// - Haptic feedback on iOS for enhanced user experience
/// - Custom text and placeholder styling
/// - Enabled/disabled state management with proper visual feedback
/// - Error text display with platform-appropriate styling
/// - Focus management and interaction callbacks
///
/// **Important Parameters:**
/// - `controller`: TextEditingController for managing input text (required)
/// - `hintText`: Placeholder text to guide user input
/// - `keyboardType`: Keyboard type (text, email, number, phone, etc.)
/// - `textCapitalization`: How to capitalize text (none, words, sentences, characters)
/// - `maxLines`: Maximum number of lines (1 for single-line, null for unlimited)
/// - `maxLength`: Maximum character count limit
/// - `validator`: Custom validation function for form validation
/// - `errorText`: Error message to display below the field
/// - `onChanged`: Callback when text changes
/// - `isEnabled`: Whether the input accepts interaction
/// - `useIOSNativeStyling`: Use iOS native styling on iOS (default true)
/// - `focusNode`: FocusNode for programmatic focus control
///
/// **Usage Examples:**
/// ```dart
/// // Basic text input
/// FastTextInput(
///   controller: nameController,
///   hintText: 'Enter your name',
///   textCapitalization: TextCapitalization.words
/// )
///
/// // Multiline text input with character limit
/// FastTextInput(
///   controller: descriptionController,
///   hintText: 'Description',
///   maxLines: 5,
///   maxLength: 500,
///   onChanged: (text) => updateCharacterCount(text.length)
/// )
///
/// // Number input with validation
/// FastTextInput(
///   controller: ageController,
///   hintText: 'Age',
///   keyboardType: TextInputType.number,
///   validator: (value) => value?.isEmpty == true ? 'Age required' : null,
///   errorText: ageError
/// )
///
/// // Custom styled input
/// FastTextInput(
///   controller: messageController,
///   hintText: 'Your message',
///   textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
///   placeholderStyle: TextStyle(color: Colors.grey),
///   hapticFeedback: false
/// )
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/export.dart';
import '../../../core/utils/validators/form_validator.dart';

class FastTextInput extends StatelessWidget {
  final TextEditingController controller;

  final String? hintText;

  final String? errorText;

  final bool isEnabled;

  final ValueChanged<String>? onChanged;

  final VoidCallback? onTap;

  final FocusNode? focusNode;

  final TextInputType keyboardType;

  final TextCapitalization textCapitalization;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  
  /// Whether to use iOS native styling with system colors
  final bool useIOSNativeStyling;
  
  /// Whether to show error text below the field (iOS style)
  final bool showErrorBelowField;
  
  /// Custom text style
  final TextStyle? textStyle;
  
  /// Custom placeholder style
  final TextStyle? placeholderStyle;
  
  /// Whether to add haptic feedback on interaction
  final bool hapticFeedback;

  const FastTextInput({
    required this.controller,
    super.key,
    this.hintText,
    this.errorText,
    this.isEnabled = true,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.useIOSNativeStyling = true,
    this.showErrorBelowField = true,
    this.textStyle,
    this.placeholderStyle,
    this.hapticFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    
    if (isIOS && useIOSNativeStyling) {
      return _buildIOSTextField(context);
    } else {
      return _buildMaterialTextField(context);
    }
  }

  Widget _buildIOSTextField(BuildContext context) {
    // If custom styles are provided, use them; otherwise use iOS defaults
    final TextStyle defaultTextStyle = TextStyle(
      color: CupertinoColors.label.resolveFrom(context),
      fontSize: 17,
      fontWeight: FontWeight.w400,
    );

    final TextStyle defaultPlaceholderStyle = TextStyle(
      color: CupertinoColors.placeholderText.resolveFrom(context),
      fontSize: 17,
      fontWeight: FontWeight.w400,
    );

    final Widget textField = CupertinoTextField(
      controller: controller,
      placeholder: hintText,
      enabled: isEnabled,
      onChanged: _handleIOSChange,
      onTap: _handleIOSTap,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: textStyle != null ? BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: textStyle?.color?.withValues(alpha: 0.3) ?? CupertinoColors.separator.resolveFrom(context),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ) : _getIOSDecoration(context),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      style: textStyle ?? defaultTextStyle,
      placeholderStyle: placeholderStyle ?? (textStyle != null ? TextStyle(
        color: (textStyle?.color ?? CupertinoColors.label.resolveFrom(context)).withValues(alpha: 0.5),
        fontSize: textStyle?.fontSize ?? 17,
        fontWeight: textStyle?.fontWeight ?? FontWeight.w400,
      ) : defaultPlaceholderStyle),
      cursorColor: textStyle?.color ?? CupertinoColors.systemBlue.resolveFrom(context),
    );

    // Wrap with error text if needed
    if (showErrorBelowField && errorText != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textField,
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              errorText!,
              style: TextStyle(
                color: CupertinoColors.systemRed.resolveFrom(context), // iOS system red for errors
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      );
    }

    return textField;
  }

  Widget _buildMaterialTextField(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: isEnabled,
      onChanged: onChanged,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hintText,
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FastSpacing.space16),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FastSpacing.space16),
          borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: .2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FastSpacing.space16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FastSpacing.space16),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FastSpacing.space16),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: FastSpacing.space4,
          horizontal: FastSpacing.space8,
        ),
      ),
      style: theme.textTheme.bodyLarge,
      validator: validator ??
          (String? value) {
            FormValidator.validateEmail(value);
            return null;
          },
    );
  }

  BoxDecoration _getIOSDecoration(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    
    if (!isEnabled) {
      // Disabled state with native iOS appearance
      backgroundColor = CupertinoColors.systemGrey6.resolveFrom(context);
      borderColor = CupertinoColors.systemGrey4.resolveFrom(context);
    } else if (errorText != null) {
      // Error state with system red
      backgroundColor = CupertinoColors.secondarySystemBackground.resolveFrom(context);
      borderColor = CupertinoColors.systemRed.resolveFrom(context);
    } else {
      // Normal state
      backgroundColor = CupertinoColors.secondarySystemBackground.resolveFrom(context);
      borderColor = CupertinoColors.separator.resolveFrom(context);
    }
    
    return BoxDecoration(
      color: backgroundColor,
      border: Border.all(
        color: borderColor,
        width: 0.5,
      ),
      borderRadius: BorderRadius.circular(10), // iOS standard border radius
    );
  }

  void _handleIOSChange(String value) {
    if (hapticFeedback) {
      HapticFeedback.selectionClick(); // Subtle feedback for text input
    }
    onChanged?.call(value);
  }

  void _handleIOSTap() {
    if (hapticFeedback) {
      HapticFeedback.selectionClick();
    }
    onTap?.call();
  }
}
