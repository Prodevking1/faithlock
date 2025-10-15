/// **FastPasswordInput** - Secure password input field with visibility toggle and platform styling.
///
/// **Use Case:** 
/// Password input for login, registration, password change forms, or any secure text entry.
/// Provides password-specific features like visibility toggle, secure text entry, and 
/// built-in validation. Essential for authentication flows and security-sensitive forms.
///
/// **Key Features:**
/// - Platform-adaptive styling (CupertinoTextField on iOS, TextFormField on Android)
/// - Built-in password visibility toggle with platform-appropriate icons
/// - Secure text entry with obscureText functionality
/// - Built-in password validation with customizable validator
/// - Optional password icon prefix for visual clarity
/// - Haptic feedback on iOS for better user experience
/// - Support for biometric suggestions on iOS
/// - Custom error text display with proper styling
///
/// **Important Parameters:**
/// - `controller`: TextEditingController for managing password text (required)
/// - `hintText`: Placeholder text (defaults to translated "Enter Password")
/// - `validator`: Custom validation function (defaults to built-in password validation)
/// - `errorText`: Custom error message to display
/// - `onChanged`: Callback when password text changes
/// - `isEnabled`: Whether the input accepts interaction
/// - `showPasswordIcon`: Display lock icon prefix (default true)
/// - `useIOSNativeStyling`: Use iOS native styling on iOS (default true)
/// - `enableBiometricSuggestions`: Enable Face ID/Touch ID suggestions on iOS
/// - `focusNode`: FocusNode for programmatic focus control
///
/// **Usage Examples:**
/// ```dart
/// // Basic password input
/// FastPasswordInput(
///   controller: passwordController,
///   hintText: 'Enter your password'
/// )
///
/// // Registration password with validation
/// FastPasswordInput(
///   controller: passwordController,
///   validator: (value) => validateStrongPassword(value),
///   onChanged: (password) => checkPasswordStrength(password),
///   errorText: passwordError
/// )
///
/// // Login password with biometric support
/// FastPasswordInput(
///   controller: passwordController,
///   hintText: 'Password',
///   enableBiometricSuggestions: true,
///   showPasswordIcon: true
/// )
/// ```

import 'package:faithlock/core/utils/validators/form_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../core/constants/export.dart';

class FastPasswordInput extends StatefulWidget {
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
  
  /// Whether to show password icon prefix
  final bool showPasswordIcon;
  
  /// Whether to support Face ID/Touch ID suggestions (iOS)
  final bool enableBiometricSuggestions;

  const FastPasswordInput({
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
    this.showPasswordIcon = true,
    this.enableBiometricSuggestions = true,
  });

  @override
  _FastPasswordInputState createState() => _FastPasswordInputState();
}

class _FastPasswordInputState extends State<FastPasswordInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    
    if (isIOS && widget.useIOSNativeStyling) {
      return _buildIOSPasswordInput(context);
    } else {
      return _buildMaterialPasswordInput(context);
    }
  }

  Widget _buildIOSPasswordInput(BuildContext context) {
    // Create custom password field for iOS with visibility toggle
    final Widget passwordField = CupertinoTextField(
      controller: widget.controller,
      placeholder: widget.hintText ?? 'enterYourPassword'.tr,
      enabled: widget.isEnabled,
      onChanged: _handleIOSChange,
      onTap: _handleIOSTap,
      focusNode: widget.focusNode,
      obscureText: _obscureText,
      keyboardType: TextInputType.visiblePassword,
      decoration: _getIOSDecoration(context),
      padding: EdgeInsets.only(
        left: widget.showPasswordIcon ? 40.0 : 16.0, // Reduced space for icon
        right: 48.0, // Space for visibility toggle
        top: 12.0,
        bottom: 12.0,
      ),
      prefix: widget.showPasswordIcon ? Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Icon(
          CupertinoIcons.lock,
          color: CupertinoColors.systemGrey,
          size: 20,
        ),
      ) : null,
      suffix: CupertinoButton(
        padding: const EdgeInsets.only(right: 8),
        minimumSize: Size.zero,
        onPressed: _togglePasswordVisibility,
        child: Icon(
          _obscureText ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
          color: CupertinoColors.systemGrey,
          size: 20,
        ),
      ),
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
    if (widget.errorText != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          passwordField,
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.errorText!,
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

    return passwordField;
  }

  Widget _buildMaterialPasswordInput(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return TextFormField(
      obscureText: _obscureText,
      enabled: widget.isEnabled,
      onChanged: widget.onChanged,
      controller: widget.controller,
      onTap: widget.onTap,
      focusNode: widget.focusNode,
      decoration: InputDecoration(
        hintText: widget.hintText ?? 'enterYourPassword'.tr,
        prefixIcon: widget.showPasswordIcon 
          ? Icon(FontAwesomeIcons.lock, color: theme.hintColor)
          : null,
        suffixIcon: GestureDetector(
          child: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: theme.hintColor,
          ),
          onTap: _togglePasswordVisibility,
        ),
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
      validator: widget.validator ?? FormValidator.validatePassword,
    );
  }

  BoxDecoration _getIOSDecoration(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    
    if (!widget.isEnabled) {
      backgroundColor = CupertinoColors.systemGrey6;
      borderColor = CupertinoColors.systemGrey4;
    } else if (widget.errorText != null) {
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

  void _togglePasswordVisibility() {
    HapticFeedback.selectionClick();
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _handleIOSChange(String value) {
    HapticFeedback.selectionClick();
    widget.onChanged?.call(value);
  }

  void _handleIOSTap() {
    HapticFeedback.selectionClick();
    widget.onTap?.call();
  }
}
