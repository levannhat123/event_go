import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/utils/format_price.dart';
import '../../../../../data/models/event/event_detail_model.dart';

class PaymentEventInfoCard extends StatelessWidget {
  const PaymentEventInfoCard({super.key, required this.event});

  final EventDetailModel event;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: const BoxDecoration(color: AppColors.eventSurface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: AppSizes.size16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.space12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: AppColors.grey,
                size: AppSizes.size16,
              ),
              const SizedBox(width: AppSpacing.space8),
              Text(
                FormatPrice.formatDate(event.startTime.toString()),
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: AppSizes.size14,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space8),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: AppColors.grey,
                size: AppSizes.size16,
              ),
              const SizedBox(width: AppSpacing.space8),
              Text(
                event.venue ?? '',
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: AppSizes.size14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
