import 'package:event_go/core/utils/extension.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/utils/format_price.dart';
import '../../../../../core/widgets/app_elevated_button.dart';

class PaymentFooter extends StatelessWidget {
  const PaymentFooter({super.key, required this.total, required this.onSubmit});

  final double total;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space16,
        AppSpacing.space16,
        bottomPadding + AppSpacing.space16,
      ),
      decoration: const BoxDecoration(color: AppColors.surfaceDark),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            FormatPrice.format(total),
            style: const TextStyle(
              color: AppColors.green,
              fontSize: AppSizes.size18,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppElevatedButton(
            onPressed: onSubmit,
            text: context.appLocaleLanguage.paymentButton,
            height: AppSizes.size40,
            width: AppSizes.size125,
            textColor: AppColors.white,
            color: AppColors.green,
            fontSize: AppSizes.size15,
            borderRadius: const BorderRadius.all(
              Radius.circular(AppSizes.size4),
            ),
            borderColor: AppColors.green,
            splashColor: AppColors.transparent,
            highlightColor: AppColors.white,
          ),
        ],
      ),
    );
  }
}
