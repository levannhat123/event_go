import 'package:event_go/core/constants/app_image.dart';
import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/presentation/view_models/auth_view_model.dart';
import 'package:event_go/routers/router_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Đảm bảo import thư viện này
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_sizes.dart';

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
      backgroundColor: AppColors.colorFF011836,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Image.asset(AppImage.logo, width: AppSizes.size200, height: AppSizes.size200)],
        ),
      ),
    );
  }
}
