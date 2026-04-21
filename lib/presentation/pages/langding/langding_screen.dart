import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_image.dart';
import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/core/constants/app_text_styles.dart';
import 'package:event_go/core/utils/extension.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:event_go/routers/router_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:event_go/core/constants/app_sizes.dart';

class LangdingScreen extends StatefulWidget {
  const LangdingScreen({Key? key}) : super(key: key);

  @override
  State<LangdingScreen> createState() => _LangdingScreenState();
}

class _LangdingScreenState extends State<LangdingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppImage.langding_page, fit: BoxFit.cover),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSizes.size37,
                right: AppSizes.size37,
                bottom: AppSizes.size64,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.appLocaleLanguage.appName,
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    context.appLocaleLanguage.heading,
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppSizes.size12),
                  Text(
                    context.appLocaleLanguage.slogan,
                    style: AppTextStyles.content2,
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: AppSizes.size20),
                  AppElevatedButton(
                    text: context.appLocaleLanguage.getStarted,
                    textColor: AppColors.white,
                    color: AppColors.authOrange,
                    fontSize: AppSizes.size15,
                    borderColor: AppColors.authOrange,
                    splashColor: AppColors.transparent,
                    highlightColor: AppColors.white,
                    onPressed: () {
                      context.push(RouterPath.login);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
