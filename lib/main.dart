import 'dart:async';

import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/config/supabase_config.dart';
import 'package:event_go/firebase_options.dart';
import 'package:event_go/injection/injection.dart';
import 'package:event_go/presentation/view_models/auth_change_notifier.dart';
import 'package:event_go/presentation/view_models/auth_view_model.dart';
import 'package:event_go/presentation/view_models/locale_langue/locale_language_view_model.dart';
import 'package:event_go/routers/app_route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/utils/lang/config/app_locale_language.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/utils/lang/language.dart';

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await initializeDateFormatting('vi_VN', null);
      await Hive.initFlutter();
      await Hive.openBox('settings');
      await dotenv.load(fileName: '.env');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      final appRouter = AppRouter(AuthChangeNotifier());

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: AppColors.background,
          statusBarIconBrightness: Brightness.dark,
        ),
      );

      setupDependencies(appRouter.router);

      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthChangeNotifier()),
            ChangeNotifierProvider(create: (_) => getIt<AuthViewModel>()),
            ChangeNotifierProvider.value(value: getIt<LocaleNotifier>()),
          ],
          child: ScreenUtilInit(
            designSize: const Size(428, 926),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MyApp(router: appRouter.router);
            },
          ),
        ),
      );
    },
    (error, stack) {
      debugPrint('Error: $error');
      debugPrint('Stack: $stack');
    },
  );
}

class MyApp extends StatelessWidget {
  final GoRouter router;

  const MyApp({super.key, required this.router});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      supportedLocales: Language.all,
      locale: context.watch<LocaleNotifier>().locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'IBMPlexSans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.background,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textPrimary),
          bodySmall: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
