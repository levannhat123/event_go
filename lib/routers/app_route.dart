import 'package:event_go/presentation/pages/auth/forgot_password_screen.dart';
import 'package:event_go/presentation/pages/auth/login_screen.dart';
import 'package:event_go/presentation/pages/auth/new_password_screen.dart';
import 'package:event_go/presentation/pages/auth/sign_up_screen.dart';
import 'package:event_go/presentation/pages/auth/reset_password_screen.dart';
import 'package:event_go/presentation/pages/auth/otp_verification_screen.dart';
import 'package:event_go/presentation/pages/home/event_booking_screen.dart';
import 'package:event_go/presentation/pages/home/event_detail_screen.dart';
import 'package:event_go/presentation/pages/home/home_screen.dart';
import 'package:event_go/presentation/pages/home/search_screen.dart';
import 'package:event_go/presentation/pages/langding/langding_screen.dart';
import 'package:event_go/presentation/pages/main/main_screen.dart';
import 'package:event_go/presentation/pages/ticket/ticket_screen.dart';
import 'package:event_go/presentation/pages/user/user_screen.dart';
import 'package:event_go/presentation/view_models/auth_change_notifier.dart';
import 'package:event_go/routers/router_name.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final GoRouter router;
  AppRouter(AuthChangeNotifier authNotifier)
    : router = GoRouter(
        initialLocation: RouterPath.home,
        debugLogDiagnostics: true,
        routes: [
          GoRoute(path: RouterPath.login, builder: (context, state) => LoginScreen()),
          GoRoute(path: RouterPath.sign_up, builder: (context, state) => SignUpScreen()),
          GoRoute(
            path: RouterPath.forgotPassword,
            builder: (context, state) => ForgotPasswordScreen(),
          ),
          GoRoute(path: RouterPath.langding_page, builder: (context, state) => LangdingScreen()),
          GoRoute(path: RouterPath.search, builder: (context, state) => SearchScreen()),
          GoRoute(path: RouterPath.booking, builder: (context, state) => EventBookingScreen()),
          GoRoute(
            path: RouterPath.resetPassword,
            builder: (context, state) {
              return NewPasswordScreen();
            },
          ),
          GoRoute(
            path: RouterPath.verifyEmail,
            builder: (context, state) {
              return LangdingScreen();
            },
          ),
          GoRoute(path: RouterPath.event_detail, builder: (context, state) => EventDetailScreen()),
          ShellRoute(
            routes: [
              GoRoute(
                path: RouterPath.home,
                name: RouterName.home,
                builder: (context, state) => HomeScreen(),
              ),
              GoRoute(
                path: RouterPath.ticket,
                name: RouterName.ticket,
                builder: (context, state) => TicketScreen(),
              ),
              GoRoute(
                path: RouterPath.user,
                name: RouterName.user,
                builder: (context, state) {
                  return UserScreen();
                },
              ),
            ],
            builder: (context, state, child) => MainScreen(child: child),
          ),
        ],
        redirect: (context, state) async {},
        refreshListenable: authNotifier,
      ) {}
}
