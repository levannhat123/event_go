import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_image.dart';
import 'package:event_go/core/constants/app_sizes.dart';
import 'package:event_go/core/constants/app_spacing.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:event_go/core/widgets/showdialog.dart';
import 'package:event_go/injection/injection.dart';
import 'package:event_go/routers/router_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'dart:async';

import '../../../core/constants/app_strings.dart';
import '../../view_models/auth_view_model.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final viewModel = Provider.of<AuthViewModel>(context, listen: false);
      viewModel.startOtpCountdown();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }

    try {
      final viewModel = Provider.of<AuthViewModel>(context, listen: false);
      viewModel.stopOtpCountdown();
    } catch (e) {
      print("Error stopping OTP countdown: $e");
    }

    super.dispose();
  }

  String get _otpCode {
    return _controllers.map((controller) => controller.text).join();
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    if (_otpCode.length == 6) {
      final viewModel = Provider.of<AuthViewModel>(context, listen: false);
      if (!viewModel.isLoading) {
        _verifyOtp(viewModel);
      }
    }
  }

  void _verifyOtp(AuthViewModel viewModel) async {
    if (_otpCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.enterFullOtp),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await viewModel.sendEmailVerification(
      widget.email,
      _otpCode,
    );

    if (!mounted) return;

    if (success) {
      context.push(RouterPath.resetPassword);
    } else {
      await showCustomDialog(
        context: context,
        title: AppStrings.verificationFailedTitle,
        message:
            viewModel.errorMessage ?? AppStrings.invalidOtpMessage,
        buttonText: AppStrings.tryAgainButton,
        icon: Icons.error,
        iconColor: Colors.red,
        onPressed: () {
          for (var controller in _controllers) {
            controller.clear();
          }
          _focusNodes[0].requestFocus();
        },
      );
    }
  }

  @override
  Widget build(BuildContext mayhem) {
    return BaseView(
      padding: false,
      viewModelBuilder: () => getIt<AuthViewModel>(),
      builder: (context, viewModel, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              // Header với logo
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
                        const Text(
                          AppStrings.otpVerificationTitle,
                          style: TextStyle(
                            color: Color(0xFFf49415),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space10),
                        Text(
                          AppStrings.otpSentTo + widget.email,
                          style: const TextStyle(
                            color: Color(0xFFf49415),
                            fontSize: 12,
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: AppSpacing.space30),
                        const Text(
                          AppStrings.enterVerificationCode,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space30),

                        // OTP Input Fields
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: AppSizes.size45,
                              height: AppSizes.size55,
                              child: TextFormField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4257b4),
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.size10),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppSizes.size10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF4257b4),
                                      width: AppSizes.size2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppSizes.size10),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (value) =>
                                    _onOtpChanged(value, index),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: AppSpacing.space30),

                        AppElevatedButton(
                          text: viewModel.isLoading
                              ? AppStrings.verifying
                              : AppStrings.verifyButton,
                          borderColor: const Color(0xFFf49415),
                          color: const Color(0xFFf49415),
                          splashColor: AppColors.transparent,
                          highlightColor: AppColors.white,
                          onPressed: viewModel.isLoading
                              ? null
                              : () => _verifyOtp(viewModel),
                        ),

                        const SizedBox(height: AppSpacing.space20),

                        if (viewModel.canResend)
                          TextButton(
                            onPressed: () async {
                              // Gọi hàm resend từ VM
                              final success = await viewModel.resetPassword(
                                widget.email,
                              );
                              if (mounted) {
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(AppStrings.otpResentSuccess),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        viewModel.errorMessage ??
                                            AppStrings.resendFailed,
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text(
                              AppStrings.resendOtpButton,
                              style: TextStyle(
                                color: Color(0xFF4257b4),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        else
                          Text(
                            AppStrings.resendOtpAfter +
                                viewModel.countdown.toString() +
                                AppStrings.seconds,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),

                        const SizedBox(height: AppSpacing.space20),

                        TextButton(
                          onPressed: () => context.go(RouterPath.login),
                          child: const Text(
                            AppStrings.backToLoginButton,
                            style: TextStyle(
                              color: Color(0xFF4257b4),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
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
