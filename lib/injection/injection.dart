import 'package:event_go/data/repositories/auth/auth_repository.dart';
import 'package:event_go/data/repositories/auth/auth_repository_impl.dart';
import 'package:event_go/data/repositories/event/event_repository.dart';
import 'package:event_go/data/repositories/event/event_repository_impl.dart';
import 'package:event_go/domain/usecase/auth/login_usecase.dart';
import 'package:event_go/domain/usecase/auth/logout_usecase.dart';
import 'package:event_go/domain/usecase/auth/register_usecase.dart';
import 'package:event_go/domain/usecase/auth/reset_password_usecase.dart';
import 'package:event_go/domain/usecase/auth/send_email_usecase.dart';
import 'package:event_go/domain/usecase/auth/update_password_use_case.dart';
import 'package:event_go/domain/usecase/event/watch_all_events_usecase.dart';
import 'package:event_go/presentation/view_models/auth_change_notifier.dart';
import 'package:event_go/presentation/view_models/auth_view_model.dart';
import 'package:event_go/presentation/view_models/home_view_model.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

final getIt = GetIt.instance;

void setupDependencies(GoRouter router) {
  getIt.registerSingleton<AuthChangeNotifier>(AuthChangeNotifier());
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  getIt.registerLazySingleton<EventRepository>(() => EventRepositoryImpl());
  // UseCases
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
    () => ResetPasswordUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(
    () => SendEmailVerificationUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdatePasswordUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(() => WatchAllEventsUsecase(getIt<EventRepository>()));

  // ViewModel
  getIt.registerFactory(
    () => AuthViewModel(
      loginUseCase: getIt<LoginUseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      resetPasswordUseCase: getIt<ResetPasswordUseCase>(),
      authRepository: getIt<AuthRepository>(),
      sendEmailVerificationUseCase: getIt<SendEmailVerificationUseCase>(),
      updatePasswordUseCase: getIt<UpdatePasswordUseCase>(),
    ),
  );
  getIt.registerLazySingleton(() => HomeViewModel(getIt<WatchAllEventsUsecase>()));
}
