import 'package:faithlock/core/mixins/error_handler_mixin.dart';
import 'package:faithlock/services/export.dart';
import 'package:get/get.dart';

class PasswordController extends GetxController with AsyncStateHandlerMixin {
  PasswordController({SupabaseAuthService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseAuthService();

  final SupabaseAuthService _supabaseService;

  final RxBool isCodeSent = false.obs;
  final RxBool isCodeVerified = false.obs;

  bool setCodeSent(bool value) => isCodeSent.value = value;
  bool setCodeVerified(bool value) => isCodeVerified.value = value;

  /// Sends a password reset email to the specified email address
  Future<bool> sendResetPasswordEmail(String email) async {
    try {
      isLoading.value = true;
      
      await _supabaseService.sendPasswordResetEmail(email: email);
      isCodeSent.value = true;
      return true;
    } catch (e) {
      handleResponseError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Verifies the OTP code sent via email or SMS
  Future<bool> verifyCode(String token, {String? email, String? phone}) async {
    try {
      isLoading.value = true;
      
      final result = await _supabaseService.verifyOtp(
        token: token,
        email: email,
        phone: phone,
      );

      if (result == true) {
        isCodeVerified.value = true;
        return true;
      }
      return false;
    } catch (e) {
      handleResponseError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Resets the password with a new password
  Future<bool> resetPassword(String newPassword, {String? email}) async {
    try {
      isLoading.value = true;
      
      await _supabaseService.resetPassword(
        newPassword: newPassword,
        email: email,
      );
      
      // Return true if no exception was thrown
      return true;
    } catch (e) {
      handleResponseError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Updates the current user's password (for logged-in users)
  Future<bool> updatePassword(String newPassword) async {
    return await executeWithErrorHandling(() async {
          await _supabaseService.resetPassword(
            newPassword: newPassword,
          );
          return true;
        }) ??
        false;
  }

  /// Resets the controller state
  void resetState() {
    isCodeSent.value = false;
    isCodeVerified.value = false;
    isLoading.value = false;
  }

  @override
  void onClose() {
    resetState();
    super.onClose();
  }
}
