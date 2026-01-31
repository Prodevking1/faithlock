// import 'package:get/get.dart';

// import '../errors/supabase_error_handler.dart';
// import '../helpers/ui_helper.dart';

// mixin AsyncStateHandlerMixin on GetxController {
//   final RxBool isLoading = false.obs;

//   Future<T?> executeWithErrorHandling<T>(Future<T> Function() action) async {
//     if (isLoading.value) {
//       return null;
//     }

//     try {
//       isLoading.value = true;
//       return await action();
//     } catch (e) {
//       handleResponseError(e);
//       return null;
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void handleResponseError(error) {
//     final String errorMessage =
//         SupabaseErrorHandler.handleException(error).message;
//     UIHelper.showErrorSnackBar(errorMessage);
//   }
// }
