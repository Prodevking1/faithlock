import 'package:faker/faker.dart';
import 'package:faithlock/core/constants/supabase_tables.dart';
import 'package:faithlock/core/mixins/error_handler_mixin.dart';
import 'package:faithlock/features/profile/models/user_model.dart';
import 'package:faithlock/services/export.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController extends GetxController with AsyncStateHandlerMixin {
  final SupabaseAuthService _supabaseAuthService;
  final SupabaseDbService _supabaseDbService;

  ProfileController({
    SupabaseAuthService? supabaseAuthService,
    SupabaseDbService? supabaseDbService,
  })  : _supabaseAuthService = supabaseAuthService ?? SupabaseAuthService(),
        _supabaseDbService = supabaseDbService ?? SupabaseDbService();

  final Rx<User?> _currentUser = Rx<User?>(null);
  User? get currentUser => _currentUser.value;


  final RxBool pushNotifications = true.obs;
  final RxBool smsNotifications = false.obs;

  final Faker _faker = Faker();
  late final Rx<UserModel> user;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
    _generateFakeUser();
  }

  Future<void> fetchUserProfile() async {
    try {
      if (_currentUser.value == null) {
        throw Exception('Current user is null');
      }

      final Map<String, dynamic>? userData = await _supabaseDbService
          .getDataById(table: Tables.profiles, id: _currentUser.value!.id);
      if (userData != null) {
        _currentUser.value = User.fromJson(userData);
      } else {
        throw Exception('User profile not found');
      }
    } catch (e) {
      handleResponseError(e);
    }
  }

  void _generateFakeUser() {
    user = Rx<UserModel>(UserModel(
      fullName: _faker.person.name(),
      email: _faker.internet.email(),
      phone: _faker.phoneNumber.us(),
      avatarUrl: _faker.image.loremPicsum(
        width: 100,
        height: 100,
      ),
      joinDate: 'August 17, 2023',
    ));
  }

  Future<bool> updateUserProfile(Map<String, dynamic> userData) async {
    return await executeWithErrorHandling(() async {
          await _supabaseDbService.updateData(
              table: Tables.profiles,
              data: userData,
              id: _currentUser.value!.id);
          return true;
        }) ??
        false;
  }

  Future<bool> updatePassword(String newPassword) async {
    return await executeWithErrorHandling(() async {
          await _supabaseAuthService.resetPassword(
            newPassword: newPassword,
          );
          return true;
        }) ??
        false;
  }

  void togglePushNotifications(bool value) {
    pushNotifications.value = value;
  }

  void toggleSmsNotifications(bool value) {
    smsNotifications.value = value;
  }

  Future<void> refreshProfile() async {
    await fetchUserProfile();
  }

  // Navigation methods
  void navigateToSettings() {
    Get.toNamed('/settings');
  }

  void navigateToEditProfile() {
    Get.toNamed('/edit-profile');
  }
}
