import 'package:event_go/data/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Stream<AuthState> get authStateChanges;
  User? get currentUser;
  bool get isLoggedIn;

  Future<AuthResult> signInWithEmailAndPassword(String email, String password);
  Future<ProfileModel> getProfile(String userId);

  Future<AuthResult> createUserWithEmailAndPassword(String email, String password);
  Future<AuthResult> signOut();
  Future<AuthResult> resetPassword(String email);
  Future<AuthResult> deleteAccount();
  Future<AuthResult> updatePassword(String newPassword);
  Future<AuthResult> sendEmailVerification(String email, String otpCode);
}

class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? errorMessage;

  AuthResult._({required this.isSuccess, this.user, this.errorMessage});

  factory AuthResult.success(User? user) => AuthResult._(isSuccess: true, user: user);
  factory AuthResult.failure(String errorMessage) => AuthResult._(isSuccess: false, errorMessage: errorMessage);
}