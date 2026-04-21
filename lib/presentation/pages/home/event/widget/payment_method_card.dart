import 'package:event_go/core/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_storage_key.dart';
import '../../../../../core/constants/app_svg.dart';

class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
    this.cardColor = AppColors.stock,
  });

  final String selectedMethod;
  final ValueChanged<String> onChanged;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _PaymentOptionRow(
            value: AppStorageKey.zalopay,
            title: context.appLocaleLanguage.zalopay,
            icon: SvgPicture.asset(AppSvg.zalopay, width: AppSizes.size24, height: AppSizes.size24),
            selectedMethod: selectedMethod,
            onChanged: onChanged,
          ),
          Divider(color: AppColors.grey.withValues(alpha: 0.2), height: AppSizes.size1),
          _PaymentOptionRow(
            value: AppStorageKey.vnpay,
            title: 'VNPAY',
            icon: Container(
              width: AppSizes.size24,
              height: AppSizes.size24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: AppColors.white,
              ),
              child: SvgPicture.asset(AppSvg.vnpay, width: AppSizes.size24, height: AppSizes.size24),
            ),
            selectedMethod: selectedMethod,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}class _PaymentOptionRow extends StatelessWidget {
  const _PaymentOptionRow({
    required this.value,
    required this.title,
    required this.icon,
    required this.selectedMethod,
    required this.onChanged,
  });

  final String value;
  final String title;
  final Widget icon;
  final String selectedMethod;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space10,
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: AppSizes.size14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: selectedMethod,
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
              activeColor: AppColors.green,
            ),
          ],
        ),
      ),
    );
  }
}
