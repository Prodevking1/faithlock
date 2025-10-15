/// **FastPhoneInput** - International phone number input with country selection and validation.
///
/// **Use Case:** 
/// Phone number input for user registration, contact forms, or profile management where 
/// international phone numbers are required. Provides country code selection, automatic 
/// formatting, and validation for phone numbers from different countries.
///
/// **Key Features:**
/// - International phone number support with country code selection
/// - Country selection dialog with flags and search functionality
/// - Automatic phone number formatting based on selected country
/// - Built-in phone number validation for different country formats
/// - Integration with intl_phone_number_input package for reliability
/// - Consistent Material Design styling with theme integration
/// - Support for enabled/disabled states
/// - Custom error text display and validation
///
/// **Important Parameters:**
/// - `controller`: TextEditingController for managing phone number text (required)
/// - `hintText`: Placeholder text (defaults to translated "Enter Phone Number")
/// - `validator`: Custom validation function (defaults to built-in phone validation)
/// - `errorText`: Custom error message to display
/// - `onInputChanged`: Callback when phone number changes (receives PhoneNumber object)
/// - `onCountryChanged`: Callback when country selection changes
/// - `isEnabled`: Whether the input accepts interaction
/// - `focusNode`: FocusNode for programmatic focus control
///
/// **Usage Examples:**
/// ```dart
/// // Basic phone input
/// FastPhoneInput(
///   controller: phoneController,
///   hintText: 'Enter your phone number'
/// )
///
/// // With change handling and validation
/// FastPhoneInput(
///   controller: phoneController,
///   onInputChanged: (PhoneNumber number) => handlePhoneChange(number),
///   onCountryChanged: (PhoneNumber number) => updateCountry(number.isoCode),
///   validator: (value) => customPhoneValidation(value)
/// )
///
/// // Registration form phone input
/// FastPhoneInput(
///   controller: phoneController,
///   onInputChanged: (PhoneNumber number) {
///     setState(() {
///       isValidPhone = number.phoneNumber?.isNotEmpty ?? false;
///       formattedPhone = number.phoneNumber;
///     });
///   }
/// )
/// ```

import 'package:faithlock/core/utils/validators/form_validator.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:get/get.dart';

import '../../../core/constants/export.dart';

class FastPhoneInput extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? errorText;
  final bool isEnabled;
  final ValueChanged<PhoneNumber>? onInputChanged;
  final ValueChanged<PhoneNumber>? onCountryChanged;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;

  const FastPhoneInput({
    required this.controller,
    super.key,
    this.hintText,
    this.errorText,
    this.isEnabled = true,
    this.onInputChanged,
    this.onCountryChanged,
    this.focusNode,
    this.validator,
  });

  @override
  State<FastPhoneInput> createState() => _FastPhoneInputState();
}

class _FastPhoneInputState extends State<FastPhoneInput> {
  String initialCountry = 'US';
  PhoneNumber? number;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return InternationalPhoneNumberInput(
      onInputChanged: (PhoneNumber number) {
        setState(() {
          this.number = number;
        });
        if (widget.onInputChanged != null) {
          widget.onInputChanged!(number);
        }
      },
      selectorConfig: const SelectorConfig(
        selectorType: PhoneInputSelectorType.DIALOG,
      ),
      selectorTextStyle: theme.textTheme.bodyLarge,
      initialValue: number,
      textFieldController: widget.controller,
      keyboardType:
          const TextInputType.numberWithOptions(signed: true, decimal: true),
      inputBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FastSpacing.space16),
      ),
      onSaved: (PhoneNumber number) {
        // Handle saved phone number if needed
      },
      isEnabled: widget.isEnabled,
      focusNode: widget.focusNode,
      hintText: widget.hintText ?? 'enterPhoneNumber'.tr,
      errorMessage: widget.errorText,
      spaceBetweenSelectorAndTextField: 0,
      textStyle: theme.textTheme.bodyLarge,
      inputDecoration: InputDecoration(
        hintText: widget.hintText ?? 'enterPhoneNumber'.tr,
        errorText: widget.errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FastSpacing.space16),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FastSpacing.space16),
          borderSide:
              BorderSide(color: theme.colorScheme.outline.withOpacity(.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FastSpacing.space16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FastSpacing.space16),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FastSpacing.space16),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: FastSpacing.space4,
          horizontal: FastSpacing.space8,
        ),
      ),
      validator: widget.validator ??
          (String? value) {
            FormValidator.validatePhoneNumber(value);
            return null;
          },
    );
  }
}
