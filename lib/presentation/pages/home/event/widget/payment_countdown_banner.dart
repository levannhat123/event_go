import 'package:event_go/core/utils/extension.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_spacing.dart';

class PaymentCountdownBanner extends StatelessWidget {
  const PaymentCountdownBanner({super.key, required this.formattedTime});

  final String formattedTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space12),
      decoration: const BoxDecoration(color: AppColors.red),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer, color: AppColors.white, size: AppSizes.size20),
          const SizedBox(width: AppSizes.size8),
          Text(
            context.appLocaleLanguage.ticketHoldTimeRemaining(formattedTime),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: AppSizes.size14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}