import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_image.dart';
import 'package:event_go/core/constants/app_sizes.dart';
import 'package:event_go/core/constants/app_spacing.dart';
import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/core/constants/app_svg.dart';
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
                    color: Color(0xFF4257b4),
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
                          AppStrings.signUpTitle,
                          style: TextStyle(
                            color: Color(0xFFf49415),
                            fontSize: AppSizes.size24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space10),
                        Text(
                          AppStrings.signUpDescription,
                          style: TextStyle(
                            color: Color(0xFFf49415),
                            fontSize: AppSizes.size12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Nội dung form
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.space20),
                  height: MediaQuery.of(context).size.height * AppSizes.size0_7,
                  decoration: const BoxDecoration(
                    color: Colors.white,
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
                          hintText: AppStrings.emailHint,
                          borderColor: Colors.grey.shade300,
                          validator: Validator.email,
                          fillColor: Colors.white,
                          suffixIcon: IconButton(
                            onPressed: () {
                              emailController.clear();
                            },
                            icon: SvgPicture.asset(
                              AppSvg.close,
                              width: AppSizes.size24,
                              height: AppSizes.size24,
                              color: Colors.grey,
                            ),
                          ),
                          focusedBorderColor: const Color(0xFF4257b4),
                          enabledBorderColor: Colors.grey.shade300,
                          prefixIcon: const Icon(Icons.email),
                          shadowColor: AppColors.transparent,
                        ),
                        const SizedBox(height: AppSpacing.space20),
                        AppTextFieldPassword(
                          controller: passwordController,
                          validator: Validator.password,
                          hintText: AppStrings.passwordLabel,
                          borderColor: Colors.grey.shade300,
                          fillColor: Colors.white,
                          focusedBorderColor: const Color(0xFF4257b4),
                          enabledBorderColor: Colors.grey.shade300,
                          shadowColor: AppColors.transparent,
                        ),
                        const SizedBox(height: AppSpacing.space20),
                        AppTextFieldPassword(
                          controller: configpasswordController,
                          hintText: AppStrings.confirmPasswordHint,
                          borderColor: Colors.grey.shade300,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.pleaseReenterPassword;
                            } else if (value != passwordController.text) {
                              return AppStrings.passwordMismatch;
                            }
                            return null;
                          },
                          fillColor: Colors.white,
                          focusedBorderColor: const Color(0xFF4257b4),
                          enabledBorderColor: Colors.grey.shade300,
                          shadowColor: AppColors.transparent,
                        ),
                        const SizedBox(height: AppSpacing.space20),
                        viewModel.isLoading
                            ? Center(
                                child: LoadingAnimationWidget.hexagonDots(
                                  color: Color(0xFFf49415),
                                  size: AppSizes.size50,
                                ),
                              )
                            : AppElevatedButton(
                                text: AppStrings.register,
                                textColor: AppColors.textPrimary,
                                color: Color(0xFFf49415),
                                fontSize: AppSizes.size15,
                                borderColor: Color(0xFFf49415),
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
                                        title: AppStrings.signUpSuccessTitle,
                                        message:
                                            AppStrings.signUpSuccessMessage,
                                        buttonText: AppStrings.okayButton,
                                        icon: Icons.check_circle,
                                        iconColor: Colors.green,
                                        onPressed: () {
                                          context.go(RouterPath.login);
                                        },
                                      );
                                    } else {
                                      await showCustomDialog(
                                        context: context,
                                        title: AppStrings.signUpFailedTitle,
                                        message:
                                            viewModel.errorMessage ??
                                            AppStrings.errorOccurredMessage,
                                        buttonText: AppStrings.okayButton,
                                        icon: Icons.error,
                                        iconColor: Colors.red,
                                        onPressed: () {},
                                      );
                                    }
                                  }
                                },
                              ),
                        const SizedBox(height: AppSpacing.space20),
                        RichText(
                          text: TextSpan(
                            text: AppStrings.hasAccount,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: AppSizes.size14,
                            ),
                            children: [
                              TextSpan(
                                text: AppStrings.login,
                                style: TextStyle(
                                  color: Color(0xFFf49415),
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
