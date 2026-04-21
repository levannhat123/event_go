import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routers/router_name.dart';

class PaymentResultScreen extends StatefulWidget {
  final String? code;
  final String? appTransID;
  final String? message;

  const PaymentResultScreen({
    Key? key,
    this.code,
    this.appTransID,
    this.message,
  }) : super(key: key);

  @override
  State<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends State<PaymentResultScreen>
    with SingleTickerProviderStateMixin {
  late final bool isSuccess;
  late final String decodedMessage;
  late final AnimationController _iconController;

  @override
  void initState() {
    super.initState();
    isSuccess = widget.code == '1';

    if (widget.message != null) {
      try {
        decodedMessage = Uri.decodeQueryComponent(widget.message!);
      } catch (e) {
        decodedMessage = widget.message!;
      }
    } else {
      decodedMessage = isSuccess
          ? AppStrings.paymentSuccess
          : AppStrings.paymentFailure;
    }

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _iconController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.homePrimaryBlue;
    final failColor = AppColors.redAccent;
    final successColor = AppColors.greenAccent;

    return Scaffold(
      // gradient background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.darkBlueBg, AppColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space20,
                vertical: AppSpacing.space24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Card chứa nội dung
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.darkGreyBg.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.6),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: AppColors.white.withOpacity(0.03)),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.space20),
                    child: Column(
                      children: [
                        // Animated icon inside circle
                        ScaleTransition(
                          scale: Tween<double>(begin: 0.96, end: 1.06).animate(
                            CurvedAnimation(
                              parent: _iconController,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: AppSizes.size60,
                            backgroundColor: isSuccess
                                ? successColor.withOpacity(0.12)
                                : failColor.withOpacity(0.12),
                            child: Icon(
                              isSuccess
                                  ? Icons.check_circle_rounded
                                  : Icons.error_outline,
                              size: AppSizes.size64,
                              color: isSuccess ? successColor : failColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space18),
                        Text(
                          isSuccess
                              ? AppStrings.paymentSuccessWithExclamation
                              : AppStrings.paymentFailure,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: AppSizes.size20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space8),
                        Text(
                          decodedMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: AppSizes.size14,
                          ),
                        ),
                        if (widget.appTransID != null) ...[
                          const SizedBox(height: AppSpacing.space18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.space12,
                                    vertical: AppSpacing.space8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withOpacity(0.03),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "${AppStrings.transactionCodeLabel}${widget.appTransID}",
                                    style: TextStyle(
                                      color: Colors.grey[200],
                                      fontSize: AppSizes.size13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.space8),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.space24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: AppColors.white.withOpacity(0.08),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: AppSizes.size14),
                            backgroundColor: AppColors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (isSuccess) {
                              context.go(RouterPath.ticket);
                            } else {
                              context.go(RouterPath.home);
                            }
                          },
                          child: Text(
                            isSuccess ? 'Xem vé' : 'Về trang chính',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: AppSizes.size16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSuccess
                                ? successColor
                                : failColor,
                            padding: const EdgeInsets.symmetric(vertical: AppSizes.size14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            context.go(RouterPath.home);
                          },
                          child: Text(
                            'Hoàn tất',
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: AppSizes.size16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
