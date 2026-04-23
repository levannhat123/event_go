import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_sizes.dart';
import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/core/constants/app_text_styles.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:event_go/core/widgets/handle_bar.dart';
import 'package:event_go/core/widgets/input_verification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Verification2FAWidget extends StatefulWidget {
  final bool autoFocus;
  final Function(String code) onSubmit;
  final String? title;
  final String? subtitle;
  final String? buttonText;

  const Verification2FAWidget({
    super.key,
    this.autoFocus = false,
    required this.onSubmit,
    this.title,
    this.subtitle,
    this.buttonText,
  });

  @override
  State<Verification2FAWidget> createState() => _Verification2FAWidgetState();
}

class _Verification2FAWidgetState extends State<Verification2FAWidget> {
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final ValueNotifier<String?> _errorText = ValueNotifier(null);
  final ValueNotifier<int> _attempts = ValueNotifier(0);

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    for (final controller in _controllers) {
      controller.dispose();
    }
    _errorText.dispose();
    _attempts.dispose();
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    _errorText.value = null;
  }

  String get code => _controllers.map((controller) => controller.text).join();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Material(
        color: AppColors.background,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.size20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.otpInputTitle,
                  style: AppTextStyles.title2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSizes.size20.h),

                InputVerification(
                  controllers: _controllers,
                  focusNodes: _focusNodes,
                  onChanged: _onChanged,
                  autoFocus: widget.autoFocus,
                ),

                ValueListenableBuilder<String?>(
                  valueListenable: _errorText,
                  builder: (context, error, _) {
                    if (error == null) return SizedBox.shrink();
                    return Padding(
                      padding: EdgeInsets.only(top: AppSizes.size8.h),
                      child: Text(
                        error,
                        style: TextStyle(color: Colors.red, fontSize: AppSizes.size14.sp),
                      ),
                    );
                  },
                ),

                SizedBox(height: AppSizes.size25.h),

                AppElevatedButton(
                  text: widget.buttonText ?? AppStrings.verify,
                  borderColor: AppColors.authOrange,
                  color: AppColors.authOrange,
                  splashColor: AppColors.transparent,
                  highlightColor: AppColors.white,
                  onPressed: () async {
                    if (code.length < 6) {
                      _errorText.value = AppStrings.enterFullOtp;
                      return;
                    }
                    final result = await widget.onSubmit(code);
                    if (result == false) {
                      _attempts.value++;
                      if (_attempts.value >= 4) {
                        Navigator.pop(context);
                      } else {
                        _errorText.value = AppStrings.otpIncorrectAttempts
                            .replaceFirst(
                              '{remaining}',
                              (4 - _attempts.value).toString(),
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
    );
  }
}
