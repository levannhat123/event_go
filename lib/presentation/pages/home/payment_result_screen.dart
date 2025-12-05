import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/routers/router_name.dart'; // Đảm bảo bạn có RouterPath.home
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_spacing.dart';

class PaymentResultScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final bool isSuccess = code == '1';

    String decodedMessage;
    if (message != null) {
      try {
        decodedMessage = Uri.decodeQueryComponent(message!);
      } catch (e) {
        decodedMessage = message!;
      }
    } else {
      decodedMessage = isSuccess
          ? AppStrings.paymentSuccess
          : AppStrings.paymentFailure;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(AppStrings.transactionResultTitle),
        backgroundColor: const Color(0xFF596DC3),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSuccess ? Icons.check_circle_outline : Icons.highlight_off,
                color: isSuccess ? Colors.green : Colors.red,
                size: AppSizes.size100,
              ),
              const SizedBox(height: AppSpacing.space24),
              Text(
                isSuccess
                    ? AppStrings.paymentSuccessWithExclamation
                    : AppStrings.paymentFailure,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppSizes.size22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.space12),
              Text(
                decodedMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: AppSizes.size16,
                ),
              ),
              if (appTransID != null) ...[
                const SizedBox(height: AppSpacing.space16),
                Text(
                  "${AppStrings.transactionCodeLabel}$appTransID",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: AppSizes.size14,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.space40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF596DC3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  context.go(RouterPath.ticket);
                },
                child: Text(
                  AppStrings.backToHomeButton,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppSizes.size16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
