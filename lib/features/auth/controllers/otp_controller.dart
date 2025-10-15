// import 'package:faithlock/core/mixins/error_handler_mixin.dart';
// import 'package:faithlock/services/export.dart';
// import 'package:get/get.dart';

// class OtpController extends GetxController with AsyncStateHandlerMixin {
//   OtpController({SupabaseAuthService? supabaseService})
//       : _supabaseService = supabaseService ?? SupabaseAuthService();

//   final SupabaseAuthService _supabaseService;
//   final RxBool isVerified = false.obs;

//   Future<bool> sendOtp(String phone) async {
//     return await executeWithErrorHandling(() async {
//           await _supabaseService.signInWithOtp(phone: phone);
//           return true;
//         }) ??
//         false;
//   }

//   Future<bool> verifyPhoneOtp(String phone, String token) async {
//     try {
//       final bool? result = await executeWithErrorHandling(() async {
//         final bool verified = await _supabaseService.verifyOtp(
//           phone: phone,
//           token: token,
//         );
//         isVerified.value = verified;
//         return verified;
//       });

//       return result ?? false;
//     } catch (e) {
//       handleError(e);
//       return false;
//     }
//   }

//   Future<bool> resendOtp(String phone) async {
//     return await executeWithErrorHandling(() async {
//           await _supabaseService.signInWithOtp(phone: phone);
//           return true;
//         }) ??
//         false;
//   }
// }
