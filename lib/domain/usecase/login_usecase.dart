import 'package:event_go/data/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  Future<AuthResult> call(String email, String password) async {
    return await _authRepository.signInWithEmailAndPassword(email, password);
  }
}

// lib/domain/usecase/auth/register_usecase.dart
class RegisterUseCase {
  final AuthRepository _authRepository;

  RegisterUseCase(this._authRepository);

  Future<AuthResult> call(String email, String password) async {
    return await _authRepository.createUserWithEmailAndPassword(email, password);
  }
}

// lib/domain/usecase/auth/logout_usecase.dart
class LogoutUseCase {
  final AuthRepository _authRepository;

  LogoutUseCase(this._authRepository);

  Future<AuthResult> call() async {
    return await _authRepository.signOut();
  }
}

// lib/domain/usecase/auth/reset_password_usecase.dart
class ResetPasswordUseCase {
  final AuthRepository _authRepository;

  ResetPasswordUseCase(this._authRepository);

  Future<AuthResult> call(String email) async {
    return await _authRepository.resetPassword(email);
  }
}

class SendEmailVerificationUseCase {
  final AuthRepository _authRepository;

  SendEmailVerificationUseCase(this._authRepository);

  Future<AuthResult> call(String email, String otpCode) async {
    return await _authRepository.sendEmailVerification(email, otpCode);
  }
}
class UpdatePasswordUseCase {
  final AuthRepository _authRepository;

  UpdatePasswordUseCase(this._authRepository);

  Future<AuthResult> call(String newPassword) async {
    return await _authRepository.updatePassword(newPassword);
  }
}