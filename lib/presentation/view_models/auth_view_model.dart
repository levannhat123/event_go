import 'package:event_go/core/base/base_view_model.dart';
import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/data/models/profile_model.dart';
import 'package:event_go/data/repositories/auth_repository.dart';
import 'package:event_go/domain/usecase/login_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends BaseViewModel {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final SendEmailVerificationUseCase _sendEmailVerificationUseCase;
  final AuthRepository _authRepository;
  final UpdatePasswordUseCase _updatePasswordUseCase;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthViewModel(
   {
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required AuthRepository authRepository,
    required SendEmailVerificationUseCase sendEmailVerificationUseCase,
    required UpdatePasswordUseCase updatePasswordUseCase,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _logoutUseCase = logoutUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
        _sendEmailVerificationUseCase = sendEmailVerificationUseCase,
        _updatePasswordUseCase = updatePasswordUseCase,
       _authRepository = authRepository {
    _authRepository.authStateChanges.listen((authState) {
      _currentUser = authState.session?.user;
      notifyListeners();
    });
  }
  ProfileModel? _currentProfile;
  ProfileModel? get currentProfile => _currentProfile;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _authRepository.isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _loginUseCase(email, password);

      if (result.isSuccess && result.user != null) {
        _currentUser = result.user;
        final profile = await _authRepository.getProfile(result.user!.id);
        _currentProfile = profile;
        _setLoading(false);
        return true;
      } else {
        _setLoading(false);
        _setError(result.errorMessage ?? AppStrings.loginFailed);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError(AppStrings.unknownError);
      return false;
    }
  }
  Future<bool> register(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _registerUseCase(email, password);

      if (result.isSuccess) {
        _currentUser = result.user;
        _setLoading(false);
        return true;
      } else {
        _setLoading(false);
        _setError(result.errorMessage ?? AppStrings.signUpFailed);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError(AppStrings.unknownError);
      return false;
    }
  }
  Future<void> logout() async {
    try {
      final result = await _logoutUseCase();
      if (result.isSuccess) {
        _currentUser = null;
        notifyListeners();
      } else {
        _setError(result.errorMessage ?? AppStrings.logoutFailed);
      }
    } catch (e) {
      _setError(AppStrings.logoutError);
    }
  }
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _resetPasswordUseCase(email);

      if (result.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setLoading(false);
        _setError(result.errorMessage ?? AppStrings.sendEmailFailed);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError(AppStrings.unknownError);
      return false;
    }
  }
  Future<bool> sendEmailVerification(String email, String otpCode) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _sendEmailVerificationUseCase(email, otpCode);

      if (result.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setLoading(false);
        _setError(result.errorMessage ?? AppStrings.sendVerificationFailed);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError(AppStrings.unknownError);
      return false;
    }
  }
  Future<bool> updatePassword(String newPassword) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _updatePasswordUseCase(newPassword);

      if (result.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setLoading(false);
        _setError(result.errorMessage ?? AppStrings.updatePasswordFailed);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError(AppStrings.unknownError);
      return false;
    }
  }
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
