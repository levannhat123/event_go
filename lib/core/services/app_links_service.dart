import 'dart:async';
import 'dart:developer';
import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';

class AppLinksService {
  static final AppLinksService _instance = AppLinksService._internal();
  factory AppLinksService() => _instance;
  AppLinksService._internal();

  AppLinks? _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  void initAppLinks(GoRouter router) {
    _appLinks = AppLinks();

    // Handle initial link when app is opened from a cold start
    _handleInitialLink(router);

    // Handle links when app is already running
    _handleIncomingLinks(router);
  }

  void _handleInitialLink(GoRouter router) async {
    try {
      final initialLink = await _appLinks?.getInitialLink();
      if (initialLink != null) {
        log('🔗 Initial link received: $initialLink');
        _processLink(initialLink, router);
      }
    } catch (e) {
      log('❌ Error handling initial link: $e');
    }
  }

  void _handleIncomingLinks(GoRouter router) {
    _linkSubscription = _appLinks?.uriLinkStream.listen(
      (Uri uri) {
        log('🔗 Incoming link received: $uri');
        _processLink(uri, router);
      },
      onError: (err) {
        log('❌ Error handling incoming link: $err');
      },
    );
  }

  void _processLink(Uri uri, GoRouter router) {
    log('🔄 Processing link: $uri');

    // Check if this is a Firebase Auth action link
    if (uri.host == 'event-go-c36f9.firebaseapp.com' &&
        uri.path == '/__/auth/action') {

      final mode = uri.queryParameters['mode'];
      final oobCode = uri.queryParameters['oobCode'];

      log('📧 Firebase Auth link detected - Mode: $mode, OobCode: $oobCode');

      if (mode == 'resetPassword' && oobCode != null) {
        // Navigate to reset password screen with oobCode
        router.go('/reset-password?oobCode=$oobCode');
        log('✅ Navigated to reset password screen');
      } else if (mode == 'verifyEmail' && oobCode != null) {
        // Handle email verification if needed
        router.go('/verify-email?oobCode=$oobCode');
        log('✅ Navigated to verify email screen');
      } else {
        log('⚠️ Unknown Firebase Auth mode: $mode');
      }
    }
    // Handle custom scheme links (eventgo://)
    else if (uri.scheme == 'eventgo') {
      final path = uri.path;
      final queryParams = uri.queryParameters;

      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${e.value}')
            .join('&');
        router.go('$path?$queryString');
      } else {
        router.go(path);
      }
      log('✅ Navigated to custom route: $path');
    }
    else {
      log('⚠️ Unhandled link: $uri');
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
