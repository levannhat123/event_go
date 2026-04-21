import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_spacing.dart';

class RecipientInfoCard extends StatelessWidget {
  const RecipientInfoCard({
    super.key,
    required this.email,
    this.cardColor = AppColors.stock,
  });

  final String email;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space12,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppSizes.size12),
      ),
      child: Row(
        children: [
          Icon(Icons.email_outlined, color: Colors.grey[400], size: AppSizes.size20),
          const SizedBox(width: AppSizes.size12),
          Expanded(
            child: Text(
              email,
              style: const TextStyle(color: AppColors.white, fontSize: AppSizes.size14),
            ),
          ),
        ],
      ),
    );
  }
}