import 'package:faithlock/core/mixins/export.dart';
import 'package:faithlock/services/export.dart';
import 'package:get/get.dart';

class SignOutController extends GetxController with AsyncStateHandlerMixin {
  final SupabaseAuthService _supabaseService;

  SignOutController({
    SupabaseAuthService? supabaseService,
  }) : _supabaseService = supabaseService ?? SupabaseAuthService();

  Future<void> signOut() async {
    await executeWithErrorHandling(() async {
      await _supabaseService.signOut();
    });
  }
}
