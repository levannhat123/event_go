import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/data/models/profile_model.dart';
import 'package:event_go/data/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  @override
  User? get currentUser => _supabase.auth.currentUser;

  @override
  bool get isLoggedIn => _supabase.auth.currentUser != null;

  @override
  Future<AuthResult> signInWithEmailAndPassword(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(email: email, password: password);
      return AuthResult.success(response.user);
    } on AuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.message));
    } catch (e) {
      return AuthResult.failure(AppStrings.unknownErrorWithDetails + e.toString());
    }
  }

  @override
  Future<AuthResult> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(email: email, password: password);
      if (response.user != null) {
        await _supabase.from('profiles').insert({
          'id': response.user!.id,
          'full_name': null,
          'avatar_url': null,
          'phone': null,
          'created_at': DateTime.now().toIso8601String(),
          'email': email,
        });
      }

      return AuthResult.success(response.user);
    } on AuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.message));
    } catch (e) {
      return AuthResult.failure(AppStrings.unknownErrorWithDetails + e.toString());
    }
  }

  @override
  Future<AuthResult> signOut() async {
    try {
      await _supabase.auth.signOut();
      return AuthResult.success(null);
    } catch (e) {
      return AuthResult.failure(AppStrings.logoutErrorWithDetails + e.toString());
    }
  }

  @override
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _supabase.auth.signInWithOtp(email: email, shouldCreateUser: false);
      return AuthResult.success(null);
    } on AuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.message));
    } catch (e) {
      return AuthResult.failure(AppStrings.unknownErrorWithDetails + e.toString());
    }
  }

  @override
  Future<AuthResult> deleteAccount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.rpc('delete_user');
        return AuthResult.success(null);
      } else {
        return AuthResult.failure(AppStrings.noUserToDelete);
      }
    } catch (e) {
      return AuthResult.failure(AppStrings.deleteAccountError + e.toString());
    }
  }

  @override
  Future<AuthResult> updatePassword(String newPassword) async {
    try {
      final response = await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      return AuthResult.success(response.user);
    } on AuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.message));
    } catch (e) {
      return AuthResult.failure(AppStrings.unknownErrorWithDetails + e.toString());
    }
  }

  @override
  Future<AuthResult> sendEmailVerification(String email, String otpCode) async {
    try {
      await _supabase.auth.verifyOTP(type: OtpType.email, email: email, token: otpCode);
      return AuthResult.success(null);
    } on AuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.message));
    } catch (e) {
      return AuthResult.failure(AppStrings.unknownErrorWithDetails + e.toString());
    }
  }

  String _getErrorMessage(String errorMessage) {
    if (errorMessage.toLowerCase().contains('invalid login credentials')) {
      return AppStrings.wrongEmailOrPassword;
    } else if (errorMessage.toLowerCase().contains('email not confirmed')) {
      return AppStrings.pleaseVerifyEmail;
    } else if (errorMessage.toLowerCase().contains('email already registered')) {
      return AppStrings.emailAlreadyRegistered;
    } else if (errorMessage.toLowerCase().contains('password should be at least')) {
      return AppStrings.passwordTooShort;
    } else if (errorMessage.toLowerCase().contains('invalid email')) {
      return AppStrings.invalidEmail;
    } else if (errorMessage.toLowerCase().contains('user not found')) {
      return AppStrings.accountNotFound;
    } else if (errorMessage.toLowerCase().contains('too many requests')) {
      return AppStrings.tooManyRequests;
    } else {
      return AppStrings.errorOccurred + errorMessage;
    }
  }

  @override
  Future<ProfileModel> getProfile(String userId) async{
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      return ProfileModel(
        id: userId,
        fullName: null,
        avatarUrl: null,
        createdAt: DateTime.now(),
        email: currentUser?.email,
        phone: null,
      );
    }
    return ProfileModel.fromJson(response);
  }
}
