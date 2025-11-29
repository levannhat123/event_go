import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_image.dart';
import 'package:event_go/core/constants/app_sizes.dart';
import 'package:event_go/core/constants/app_spacing.dart';
import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/core/utils/validator.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:event_go/core/widgets/showdialog.dart';
import 'package:event_go/core/widgets/text_field.dart';
import 'package:event_go/injection/injection.dart';
import 'package:event_go/presentation/view_models/auth_view_model.dart';
import 'package:event_go/routers/router_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.pleaseConfirmPassword;
    }
    if (value != passwordController.text) {
      return AppStrings.confirmPasswordMismatch;
    }
    return null;
  }

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
                        CircleAvatar(backgroundImage: AssetImage(AppImage.logo), radius: AppSizes.size40),
                        const SizedBox(height: AppSpacing.space10),
                        const Text(
                          AppStrings.newPasswordTitle,
                          style: TextStyle(
                            color: Color(0xFFf49415),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space10),
                        Text(
                          AppStrings.newPasswordDescription,
                          style: const TextStyle(color: Color(0xFFf49415), fontSize: 12),
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
                  height: MediaQuery.of(context).size.height * 0.70,
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

                        // Password field
                        const Text(
                          AppStrings.newPasswordLabel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space10),
                        AppTextField(
                          controller: passwordController,
                          hintText: AppStrings.newPasswordHint,
                          borderColor: Colors.grey.shade300,
                          fillColor: Colors.grey.shade100,
                          validator: Validator.password,
                          focusedBorderColor: const Color(0xFF4257b4),
                          enabledBorderColor: Colors.grey.shade300,
                          prefixIcon: const Icon(Icons.lock),
                          shadowColor: AppColors.transparent,
                          suffixIcon: IconButton(
                            icon: Icon(
                              viewModel.obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              viewModel.togglePasswordVisibility();
                            },
                          ),
                        ),

                        const SizedBox(height: AppSpacing.space20),

                        // Confirm password field
                        const Text(
                          AppStrings.confirmPasswordLabel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space10),
                        AppTextField(
                          controller: confirmPasswordController,
                          hintText: AppStrings.confirmNewPasswordHint,
                          borderColor: Colors.grey.shade300,
                          fillColor: Colors.grey.shade100,
                          validator: _validateConfirmPassword,
                          focusedBorderColor: const Color(0xFF4257b4),
                          enabledBorderColor: Colors.grey.shade300,
                          prefixIcon: const Icon(Icons.lock_outline),
                          shadowColor: AppColors.transparent,
                          suffixIcon: IconButton(
                            icon: Icon(
                              viewModel.obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              viewModel.toggleConfirmPasswordVisibility();
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space30),
                        viewModel.isLoading
                            ? Center(
                          child: LoadingAnimationWidget.hexagonDots(
                            color:Color(0xFFf49415),
                            size: AppSizes.size50,
                          ),
                        )
                            :    AppElevatedButton(
                          text: viewModel.isLoading ? AppStrings.updating : AppStrings.resetPasswordButton,
                          borderColor: const Color(0xFFf49415),
                          color: const Color(0xFFf49415),
                          splashColor: AppColors.transparent,
                          highlightColor: AppColors.white,
                          onPressed: viewModel.isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    final success = await viewModel.updatePassword(
                                      passwordController.text,
                                    );
                                    if (success) {
                                      await showCustomDialog(
                                        context: context,
                                        title: AppStrings.resetPasswordSuccessTitle,
                                        message: AppStrings.passwordUpdatedMessage,
                                        buttonText: AppStrings.loginButton,
                                        icon: Icons.check_circle,
                                        iconColor: Colors.green,
                                        onPressed: () {
                                          context.push(RouterPath.login);
                                        },
                                      );
                                    } else {
                                      await showCustomDialog(
                                        context: context,
                                        title: AppStrings.resetPasswordFailedTitle,
                                        message: viewModel.errorMessage ?? AppStrings.errorOccurredTryAgain,
                                        buttonText: AppStrings.okayButton,
                                        icon: Icons.error,
                                        iconColor: Colors.red,
                                        onPressed: () {
                                        },
                                      );
                                    }

                                  }
                                },
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
