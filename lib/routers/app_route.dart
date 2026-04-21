import 'package:event_go/data/models/event/event_detail_model.dart';
import 'package:event_go/presentation/pages/auth/forgot_password_screen.dart';
import 'package:event_go/presentation/pages/auth/login_screen.dart';
import 'package:event_go/presentation/pages/auth/new_password_screen.dart';
import 'package:event_go/presentation/pages/auth/sign_up_screen.dart';
import 'package:event_go/presentation/pages/home/event/event_booking_screen.dart';
import 'package:event_go/presentation/pages/home/event/event_detail_screen.dart';
import 'package:event_go/presentation/pages/home/event/event_payment_screen.dart';
import 'package:event_go/presentation/pages/home/event/payment_result_screen.dart';
import 'package:event_go/presentation/pages/home/home_screen.dart';
import 'package:event_go/presentation/pages/home/payment_result_screen.dart';
import 'package:event_go/presentation/pages/home/search/search_screen.dart';
import 'package:event_go/presentation/pages/langding/langding_screen.dart';
import 'package:event_go/presentation/pages/main/main_screen.dart';
import 'package:event_go/presentation/pages/ticket/ticket_screen.dart';
import 'package:event_go/presentation/pages/user/profile_screen.dart';
import 'package:event_go/presentation/pages/user/user_screen.dart';
import 'package:event_go/presentation/view_models/auth_change_notifier.dart';
import 'package:event_go/routers/router_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/pages/langding/splash_screen.dart';

class AppRouter {
  final GoRouter router;
  AppRouter(AuthChangeNotifier authNotifier)
    : router = GoRouter(
        initialLocation: RouterPath.splash,
        debugLogDiagnostics: true,
        errorBuilder: (context, state) => Scaffold(
          body: Center(child: Text('Page not found2: ${state.uri.toString()}')),
        ),
        routes: [
          GoRoute(
            path: RouterPath.splash,
            builder: (context, state) => SplashScreen(),
          ),
          GoRoute(
            path: RouterPath.login,
            builder: (context, state) => LoginScreen(),
          ),

          GoRoute(
            path: '/',
            name: RouterName.payment_callback,
            builder: (BuildContext context, GoRouterState state) {
              final code = state.uri.queryParameters['code'];
              final appTransID = state.uri.queryParameters['appTransID'];
              final message = state.uri.queryParameters['message'];
              return PaymentResultScreen(
                code: code,
                appTransID: appTransID,
                message: message,
              );
            },
          ),
          GoRoute(
            path: RouterPath.sign_up,
            builder: (context, state) => SignUpScreen(),
          ),
          GoRoute(
            path: RouterPath.forgotPassword,
            builder: (context, state) => ForgotPasswordScreen(),
          ),
          GoRoute(
            path: RouterPath.langding_page,
            builder: (context, state) => LangdingScreen(),
          ),
          GoRoute(
            path: RouterPath.search,
            builder: (context, state) => SearchScreen(),
          ),
          GoRoute(
            path: RouterPath.profile,
            builder: (context, state) => ProfileScreen(),
          ),
          GoRoute(
            path: RouterPath.booking,
            builder: (context, state) {
              final event = state.extra as EventDetailModel;
              return EventBookingScreen(event: event);
            },
          ),
          GoRoute(
            path: RouterPath.payment_result,
            builder: (context, state) {
              final map = state.extra as Map<String, dynamic>;
              return PaymentResultVnPlayScreen(
                isSuccess: map['isSuccess'] as bool,
                message: map['message'] as String,
                transactionId: map['transactionId'] as String,
              );
            },
          ),
          GoRoute(
            path: RouterPath.payment,
            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>;
              final String token = data['token'];
              final EventDetailModel event = data['event'];
              return EventPaymentScreen(token: token, event: event);
            },
          ),
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
          GoRoute(
            path: RouterPath.event_detail,
            builder: (context, state) {
              final event = state.extra as EventDetailModel;
              return EventDetailScreen(event: event);
            },
          ),
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
