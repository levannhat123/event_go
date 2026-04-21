import 'package:event_go/core/utils/extension.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_image.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../data/models/event/event_detail_model.dart';

class OrganizerSection extends StatelessWidget {
  const OrganizerSection({super.key, required this.event});

  final EventDetailModel event;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.space12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.size12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.appLocaleLanguage.organizer,
              style: const TextStyle(
                fontSize: AppSizes.size16,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const Divider(color: AppColors.grey),
            Image.network(
              event.orgLogoURL ?? AppImage.banner_1,
              height: AppSizes.size50,
              errorBuilder: (_, __, ___) => Container(
                height: AppSizes.size50,
                color: Colors.grey[700],
                child: const Icon(
                  Icons.image_not_supported,
                  color: AppColors.white,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            Text(
              event.orgName ?? '',
              style: const TextStyle(
                fontSize: AppSizes.size15,
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            Text(
              event.orgDescription ?? '',
              style: const TextStyle(fontSize: AppSizes.size14, color: AppColors.black),
            ),
          ],
        ),
      ),
    );
  }
}