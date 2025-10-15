/// **FastEmailInput** - Specialized email input field with built-in validation and platform styling.
///
/// **Use Case:** 
/// Email input for registration, login, profile forms, or any scenario requiring email addresses.
/// Provides email-specific keyboard, automatic validation, and consistent styling across platforms.
/// Perfect for authentication flows and user profile management.
///
/// **Key Features:**
/// - Platform-adaptive styling (CupertinoTextField on iOS, TextFormField on Android)
/// - Built-in email validation with proper error handling
/// - Email-optimized keyboard type and text capitalization
/// - Optional email icon prefix for visual clarity
/// - Support for enabled/disabled states with proper visual feedback
/// - Internationalization support for placeholder and error text
/// - Custom error text display with platform-appropriate styling
///
/// **Important Parameters:**
/// - `controller`: TextEditingController for managing input text (required)
/// - `hintText`: Placeholder text (defaults to translated "Enter Email")
/// - `validator`: Custom validation function (defaults to built-in email validation)
/// - `errorText`: Custom error message to display
/// - `onChanged`: Callback when text changes
/// - `isEnabled`: Whether the input accepts interaction
/// - `showEmailIcon`: Display email icon prefix (default true)
/// - `useIOSNativeStyling`: Use iOS native styling on iOS (default true)
/// - `focusNode`: FocusNode for programmatic focus control
///
/// **Usage Examples:**
/// ```dart
/// // Basic email input
/// FastEmailInput(
///   controller: emailController,
///   hintText: 'Enter your email address'
/// )
///
/// // With validation and change handling
/// FastEmailInput(
///   controller: emailController,
///   onChanged: (email) => validateEmailInRealTime(email),
///   validator: (value) => customEmailValidation(value),
///   errorText: emailError
/// )
///
/// // Login form email input
/// FastEmailInput(
///   controller: emailController,
///   hintText: 'Email',
///   showEmailIcon: true,
///   onChanged: (value) => setState(() => loginEnabled = value.isNotEmpty)
/// )
/// ```

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../core/constants/export.dart';
import '../../../core/utils/validators/form_validator.dart';
import 'fast_text_input.dart';

class FastEmailInput extends StatelessWidget {
  final String? hintText;
  final bool isEnabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String? errorText;

  /// Whether to use iOS native styling
  final bool useIOSNativeStyling;

  /// Whether to show email icon prefix
  final bool showEmailIcon;

  const FastEmailInput({
    required this.controller,
    super.key,
    this.hintText,
    this.isEnabled = true,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.validator,
    this.errorText,
    this.useIOSNativeStyling = true,
    this.showEmailIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS && useIOSNativeStyling) {
      return _buildIOSEmailInput(context);
    } else {
      return _buildMaterialEmailInput(context);
    }
  }

  Widget _buildIOSEmailInput(BuildContext context) {
    final Widget textField = CupertinoTextField(
      controller: controller!,
      placeholder: hintText ?? 'enterEmail'.tr,
      enabled: isEnabled,
      onChanged: onChanged,
      onTap: onTap,
      focusNode: focusNode,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      decoration: _getIOSDecoration(context),
      padding: EdgeInsets.only(
        left: showEmailIcon ? 40.0 : 16.0, // Reduced space for icon
        right: 16.0,
        top: 12.0,
        bottom: 12.0,
      ),
      prefix: showEmailIcon ? Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Icon(
          CupertinoIcons.mail,
          color: CupertinoColors.systemGrey,
          size: 20,
        ),
      ) : null,
      style: const TextStyle(
        color: CupertinoColors.label,
        fontSize: 17,
        fontWeight: FontWeight.w400,
      ),
      placeholderStyle: const TextStyle(
        color: CupertinoColors.placeholderText,
        fontSize: 17,
        fontWeight: FontWeight.w400,
      ),
      cursorColor: CupertinoColors.systemBlue,
    );

    // Wrap with error text if needed
    if (errorText != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textField,
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: CupertinoColors.systemRed,
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

  BoxDecoration _getIOSDecoration(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    
    if (!isEnabled) {
      backgroundColor = CupertinoColors.systemGrey6;
      borderColor = CupertinoColors.systemGrey4;
    } else if (errorText != null) {
      backgroundColor = CupertinoColors.secondarySystemBackground;
      borderColor = CupertinoColors.systemRed;
    } else {
      backgroundColor = CupertinoColors.secondarySystemBackground;
      borderColor = CupertinoColors.separator;
    }
    
    return BoxDecoration(
      color: backgroundColor,
      border: Border.all(
        color: borderColor,
        width: 0.5,
      ),
      borderRadius: BorderRadius.circular(10),
    );
  }

  Widget _buildMaterialEmailInput(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      enabled: isEnabled,
      onChanged: onChanged,
      controller: controller,
      onTap: onTap,
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: hintText ?? 'enterEmail'.tr,
        prefixIcon: showEmailIcon
          ? Icon(FontAwesomeIcons.envelopeOpen, color: theme.hintColor)
          : null,
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
      validator: validator ?? _validateEmail,
    );
  }

  String? _validateEmail(String? value) {
    return FormValidator.validateEmail(value);
  }
}
