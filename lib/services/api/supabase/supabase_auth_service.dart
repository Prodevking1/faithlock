import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // Current user getter
  User? get currentUser => _client.auth.currentUser;
  
  // Auth state stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign in anonymously
  Future<AuthResponse> signInAnonymously() async {
    final AuthResponse res = await _client.auth.signInAnonymously();
    return res;
  }

  /// Check if current user is anonymous
  bool get isAnonymous => currentUser?.isAnonymous ?? false;

  /// Convert anonymous user to registered user
  Future<UserResponse> linkEmailPassword({
    required String email,
    required String password,
  }) async {
    final UserResponse response = await _client.auth.updateUser(
      UserAttributes(
        email: email,
        password: password,
      ),
    );
    return response;
  }

  Future<void> signInWithOtp({required String phone}) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    final AuthResponse res = await _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
    return res;
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final AuthResponse res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return res;
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<UserResponse> resetPassword({
    required String newPassword,
    String? phone,
    String? email,
  }) async {
    final UserResponse response = await _client.auth.updateUser(
      UserAttributes(
        phone: phone,
        email: email,
        password: newPassword,
      ),
    );
    return response;
  }

  Future<bool> resendOtp({
    required String phone,
    OtpType type = OtpType.signup,
  }) async {
    await _client.auth.resend(phone: phone, type: type);
    return true;
  }

  Future<bool> verifyOtp({
    required String token,
    OtpType type = OtpType.recovery,
    String? email,
    String? phone,
  }) async {
    await _client.auth.verifyOTP(
      token: token,
      type: type,
      email: email,
      phone: phone,
    );
    return true;
  }
}
