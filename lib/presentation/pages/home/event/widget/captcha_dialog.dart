import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:slider_captcha/slider_captcha.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/utils/extension.dart';
import '../../../../../data/models/event/event_detail_model.dart';
import '../../../../../routers/router_name.dart';
import '../../../../view_models/event_order_view_model.dart';

class CaptchaDialog extends StatelessWidget {
  final EventOrderViewModel viewModel;
  final EventDetailModel event;

  const CaptchaDialog({
    super.key,
    required this.viewModel,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final controller = SliderController();

    return Consumer<EventOrderViewModel>(
      builder: (_, vm, __) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.size12),
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.space16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.size12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.appLocaleLanguage.captchaTitle,
                      style: const TextStyle(color: AppColors.black),
                    ),
                    InkWell(
                      onTap: () => context.pop(),
                      child: const Icon(
                        Icons.close,
                        size: AppSizes.size20,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space20),
                Text(
                  context.appLocaleLanguage.captchaDescription,
                  style: const TextStyle(color: AppColors.black),
                ),
                const SizedBox(height: AppSpacing.space10),
                Text(
                  context.appLocaleLanguage.captchaInstruction,
                  style: const TextStyle(color: AppColors.black),
                ),
                const SizedBox(height: AppSpacing.space20),
                SliderCaptcha(
                  controller: controller,
                  image: Image.asset(vm.currentCaptchaImage, fit: BoxFit.cover),
                  colorBar: Colors.blue,
                  colorCaptChar: Colors.blue,
                  onConfirm: (success) async {
                    final result = vm.onCaptchaConfirm(success);
                    if (result == CaptchaResult.success) {
                      context.pop();
                      context.push(RouterPath.booking, extra: event);
                      return;
                    }
                    if (result == CaptchaResult.lockedOut) {
                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context.appLocaleLanguage.captchaLockoutMessage1Min,
                          ),
                          backgroundColor: AppColors.red,
                        ),
                      );
                      return;
                    }
                    await Future.delayed(const Duration(milliseconds: 500));
                    controller.create();
                    vm.refreshCaptchaImage();
                    vm.clearCaptchaError();
                  },
                ),
                const SizedBox(height: AppSpacing.space20),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        controller.create();
                        vm.refreshCaptchaImage();
                        vm.clearCaptchaError();
                      },
                      child: const Icon(
                        Icons.refresh,
                        size: AppSizes.size16,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(width: AppSizes.size8),
                    Text(
                      context.appLocaleLanguage.captchaReload,
                      style: const TextStyle(color: AppColors.black),
                    ),
                  ],
                ),
                if (vm.captchaErrorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.space8),
                    child: Text(
                      vm.captchaErrorText!,
                      style: const TextStyle(color: AppColors.red),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<void> showBookingCaptchaDialog({
  required BuildContext context,
  required EventOrderViewModel viewModel,
  required EventDetailModel event,
}) async {
  if (viewModel.isLockedOut) {
    final remainingSeconds = viewModel.lockoutRemainingSeconds;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.appLocaleLanguage
              .captchaLockoutMessage(remainingSeconds)
              .replaceAll('{seconds}', remainingSeconds.toString()),
        ),
        backgroundColor: AppColors.red,
      ),
    );
    return;
  }

  viewModel.refreshCaptchaImage();
  await showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(
      value: viewModel,
      child: CaptchaDialog(viewModel: viewModel, event: event),
    ),
  );
}
