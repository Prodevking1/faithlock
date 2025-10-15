import 'package:get/get.dart';

class FormValidator {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'pleaseEnterEmail'.tr;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'pleaseEnterValidEmail'.tr;
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'pleaseEnterPassword'.tr;
    }
    if (value.length < 6) {
      return 'passwordMin6Chars'.tr;
    }
    if (!value.contains(RegExp(r'[A-Za-z]')) ||
        !value.contains(RegExp(r'[0-9]'))) {
      return 'passwordMustContainLettersNumbers'.tr;
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'pleaseConfirmPassword'.tr;
    }
    if (value != password) {
      return 'passwordsDoNotMatch'.tr;
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'pleaseEnterName'.tr;
    }
    if (value.length < 2) {
      return 'nameMin2Chars'.tr;
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'pleaseEnterPhoneNumber'.tr;
    }
    if (!RegExp(r'^\+?[0-9]{10,14}$').hasMatch(value)) {
      return 'pleaseEnterValidPhoneNumber'.tr;
    }
    return null;
  }
}
