import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_image.dart';
import 'package:event_go/core/constants/app_sizes.dart';
import 'package:event_go/core/constants/app_spacing.dart';
import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/core/constants/app_svg.dart';
import 'package:event_go/core/utils/extension.dart';
import 'package:event_go/core/utils/validator.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:event_go/core/widgets/showdialog.dart';
import 'package:event_go/core/widgets/text_field.dart';
import 'package:event_go/core/widgets/text_field_password.dart';
import 'package:event_go/injection/injection.dart';
import 'package:event_go/presentation/view_models/auth_view_model.dart';
import 'package:event_go/routers/router_name.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController configpasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BaseView(
      padding: false,
      viewModelBuilder: () => getIt<AuthViewModel>(),
      builder: (context, viewModel, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space30,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.authPrimaryBlue,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(AppSizes.size40),
                      bottomRight: Radius.circular(AppSizes.size40),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.space60),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(AppImage.logo),
                          radius: AppSizes.size40,
                        ),
                        const SizedBox(height: AppSpacing.space10),
                        Text(
                          context.appLocaleLanguage.signUpTitle,
                          style: TextStyle(
                            color: AppColors.authOrange,
                            fontSize: AppSizes.size24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space10),
                        Text(
                          context.appLocaleLanguage.signUpDescription,
                          style: TextStyle(
                            color: AppColors.authOrange,
                            fontSize: AppSizes.size12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.space20),
                  height: MediaQuery.of(context).size.height * AppSizes.size0_7,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppSizes.size30),
                      topRight: Radius.circular(AppSizes.size30),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: emailController,
                          hintText: context.appLocaleLanguage.emailHint,
                          borderColor: AppColors.grey300,
                          validator: Validator.email,
                          fillColor: AppColors.white,
                          suffixIcon: IconButton(
                            onPressed: () {
                              emailController.clear();
                            },
                            icon: SvgPicture.asset(
                              AppSvg.close,
                              width: AppSizes.size24,
                              height: AppSizes.size24,
                              color: AppColors.grey,
                            ),
                          ),
                          focusedBorderColor: AppColors.authPrimaryBlue,
                          enabledBorderColor: AppColors.grey300,
                          prefixIcon: const Icon(Icons.email),
                          shadowColor: AppColors.transparent,
                        ),
                        const SizedBox(height: AppSpacing.space20),
                        AppTextFieldPassword(
                          controller: passwordController,
                          validator: Validator.password,
                          hintText: context.appLocaleLanguage.passwordLabel,
                          borderColor: AppColors.grey300,
                          fillColor: AppColors.white,
                          focusedBorderColor: AppColors.authPrimaryBlue,
                          enabledBorderColor: AppColors.grey300,
                          shadowColor: AppColors.transparent,
                        ),
                        const SizedBox(height: AppSpacing.space20),
                        AppTextFieldPassword(
                          controller: configpasswordController,
                          hintText:
                              context.appLocaleLanguage.confirmPasswordHint,
                          borderColor: AppColors.grey300,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return context
                                  .appLocaleLanguage
                                  .pleaseReenterPassword;
                            } else if (value != passwordController.text) {
                              return context.appLocaleLanguage.passwordMismatch;
                            }
                            return null;
                          },
                          fillColor: AppColors.white,
                          focusedBorderColor: AppColors.authPrimaryBlue,
                          enabledBorderColor: AppColors.grey300,
                          shadowColor: AppColors.transparent,
                        ),
                        const SizedBox(height: AppSpacing.space20),
                        viewModel.isLoading
                            ? Center(
                                child: LoadingAnimationWidget.hexagonDots(
                                  color: AppColors.authOrange,
                                  size: AppSizes.size50,
                                ),
                              )
                            : AppElevatedButton(
                                text: context.appLocaleLanguage.register,
                                textColor: AppColors.textPrimary,
                                color: AppColors.authOrange,
                                fontSize: AppSizes.size15,
                                borderColor: AppColors.authOrange,
                                splashColor: AppColors.transparent,
                                highlightColor: AppColors.white,
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final success = await viewModel.register(
                                      emailController.text.trim(),
                                      passwordController.text,
                                    );

                                    if (success) {
                                      await showCustomDialog(
                                        context: context,
                                        title: context
                                            .appLocaleLanguage
                                            .signUpSuccessTitle,
                                        message: context
                                            .appLocaleLanguage
                                            .signUpSuccessMessage,
                                        buttonText: context
                                            .appLocaleLanguage
                                            .okayButton,
                                        icon: Icons.check_circle,
                                        iconColor: AppColors.green,
                                        onPressed: () {
                                          context.go(RouterPath.login);
                                        },
                                      );
                                    } else {
                                      await showCustomDialog(
                                        context: context,
                                        title: context
                                            .appLocaleLanguage
                                            .signUpFailedTitle,
                                        message:
                                            viewModel.errorMessage ??
                                            context
                                                .appLocaleLanguage
                                                .errorOccurredMessage,
                                        buttonText: context
                                            .appLocaleLanguage
                                            .okayButton,
                                        icon: Icons.error,
                                        iconColor: AppColors.red,
                                        onPressed: () {},
                                      );
                                    }
                                  }
                                },
                              ),
                        const SizedBox(height: AppSpacing.space20),
                        RichText(
                          text: TextSpan(
                            text: context.appLocaleLanguage.hasAccount,
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: AppSizes.size14,
                            ),
                            children: [
                              TextSpan(
                                text: context.appLocaleLanguage.login,
                                style: TextStyle(
                                  color: AppColors.authOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    context.push(RouterPath.login);
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
