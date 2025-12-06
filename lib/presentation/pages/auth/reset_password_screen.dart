import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_image.dart';
import 'package:event_go/core/constants/app_sizes.dart';
import 'package:event_go/core/constants/app_spacing.dart';
import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/core/utils/extension.dart';
import 'package:event_go/core/utils/validator.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:event_go/core/widgets/text_field.dart';
import 'package:event_go/injection/injection.dart';
import 'package:event_go/presentation/view_models/auth_view_model.dart';
import 'package:event_go/routers/router_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String oobCode;
  final String? email;

  const ResetPasswordScreen({super.key, required this.oobCode, this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _verifiedEmail;
  bool _isVerifying = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    try {
      final viewModel = Provider.of<AuthViewModel>(context, listen: false);
      viewModel.resetNewPasswordScreenState();
    } catch (e) {
      print("Error resetting state on dispose: $e");
    }
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isVerifying) {
      return  Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: AppSpacing.space16),
              Text(context.appLocaleLanguage.verifyingLink),
            ],
          ),
        ),
      );
    }

    if (_verifiedEmail == null) {
      return  Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: AppSizes.size64, color: Colors.red),
              SizedBox(height: AppSpacing.space16),
              Text(context.appLocaleLanguage.invalidLink),
              Text(context.appLocaleLanguage.tryAgainOrRequestNew),
            ],
          ),
        ),
      );
    }

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
                          context.appLocaleLanguage.resetPasswordTitle,
                          style: TextStyle(
                            color: Color(0xFFf49415),
                            fontSize: AppSizes.size24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space10),
                        Text(
                          context.appLocaleLanguage.resetPasswordDescription +
                              '\n' +
                              _verifiedEmail!,
                          style: const TextStyle(
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

              // Form content
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.space30),

                         Text(
                          context.appLocaleLanguage.newPasswordLabel,
                          style: TextStyle(
                            fontSize: AppSizes.size16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space10),
                        AppTextField(
                          controller: passwordController,
                          hintText: context.appLocaleLanguage.newPasswordHint,
                          borderColor: Colors.grey.shade300,
                          fillColor: Colors.grey.shade100,
                          validator: Validator.password,
                          focusedBorderColor: const Color(0xFF4257b4),
                          enabledBorderColor: Colors.grey.shade300,
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              viewModel.obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () =>
                                viewModel.togglePasswordVisibility(),
                          ),
                          shadowColor: AppColors.transparent,
                        ),

                        const SizedBox(height: AppSpacing.space20),
                         Text(
                          context.appLocaleLanguage.confirmPasswordLabel,
                          style: TextStyle(
                            fontSize: AppSizes.size16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space10),
                        AppTextField(
                          controller: confirmPasswordController,
                          hintText: context.appLocaleLanguage.confirmNewPasswordHint,
                          borderColor: Colors.grey.shade300,
                          fillColor: Colors.grey.shade100,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return context.appLocaleLanguage.pleaseConfirmPassword;
                            }
                            if (value != passwordController.text) {
                              return context.appLocaleLanguage.passwordMismatch;
                            }
                            return null;
                          },
                          focusedBorderColor: const Color(0xFF4257b4),
                          enabledBorderColor: Colors.grey.shade300,
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              viewModel.obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () =>
                                viewModel.toggleConfirmPasswordVisibility(),
                          ),
                          shadowColor: AppColors.transparent,
                        ),

                        const SizedBox(height: AppSpacing.space30),

                        AppElevatedButton(
                          text: viewModel.isLoading
                              ? context.appLocaleLanguage.updating
                              : context.appLocaleLanguage.updatePasswordButton,
                          borderColor: const Color(0xFFf49415),
                          color: const Color(0xFFf49415),
                          splashColor: AppColors.transparent,
                          highlightColor: AppColors.white,
                          onPressed: viewModel.isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {}
                                },
                        ),

                        const SizedBox(height: AppSpacing.space20),

                        Center(
                          child: TextButton(
                            onPressed: () => context.go(RouterPath.login),
                            child:  Text(
                              context.appLocaleLanguage.loginButton,
                              style: TextStyle(
                                color: Color(0xFF4257b4),
                                fontSize: AppSizes.size14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
