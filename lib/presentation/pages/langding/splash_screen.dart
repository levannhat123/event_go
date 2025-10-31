import 'package:event_go/presentation/view_models/auth_view_model.dart';
import 'package:event_go/routers/router_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Đảm bảo import thư viện này

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      await authViewModel.checkAuthState();
      await Future.delayed(Duration(seconds: 2));
      if (!mounted) return;
      final isFirstLaunch = await authViewModel.isFirstLaunch();
      if (isFirstLaunch) {
        context.go(RouterPath.langding_page);
      } else if (authViewModel.isLoggedIn &&
          authViewModel.currentUser != null) {
        context.go(RouterPath.home);
      } else {
        context.go(RouterPath.login);
      }
    } catch (e) {
      if (mounted) {
        context.go(RouterPath.langding_page);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 100),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Đang tải...'),
          ],
        ),
      ),
    );
  }
}
