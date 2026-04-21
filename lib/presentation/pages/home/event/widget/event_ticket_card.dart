import 'package:event_go/core/constants/app_sizes.dart';
import 'package:event_go/core/constants/app_spacing.dart';
import 'package:event_go/core/utils/format_price.dart';
import 'package:event_go/presentation/pages/home/event/widget/jagged_edge_clipper.dart';
import 'package:event_go/presentation/pages/home/event/widget/ticket_clipper.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class EventTicketCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String date;
  final String location;
  final String address;
  final double imageHeight;

  const EventTicketCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.date,
    required this.location,
    required this.address,
    this.imageHeight = AppSizes.size250,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: TicketClipper(notchCenterY: imageHeight),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.colorFF39383D,
          borderRadius: BorderRadius.circular(AppSizes.size16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [_buildImageSection(), _buildDetailsSection()],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipPath(
      clipper: JaggedEdgeClipper(),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.size12),
          topRight: Radius.circular(AppSizes.size12),
        ),
        child: Image.network(
          imagePath,
          fit: BoxFit.cover,
          height: imageHeight,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => Container(
            height: imageHeight,
            color: Colors.grey[700],
            child: Icon(
              Icons.image_not_supported,
              color: AppColors.white,
              size: AppSizes.size50,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space20,
        AppSpacing.space25,
        AppSpacing.space20,
        AppSpacing.space20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.white,
              fontSize: AppSizes.size16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.space20),
          _buildInfoRow(
            icon: Icons.calendar_today,
            iconColor: AppColors.colorFF6AFB92,
            primaryText: date,
            showSecondaryButton: true,
          ),
          const SizedBox(height: AppSpacing.space15),
          _buildInfoRow(
            icon: Icons.location_on,
            iconColor: AppColors.colorFF6AFB92,
            primaryText: location,
            secondaryText: address,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String primaryText,
    String? secondaryText,
    bool showSecondaryButton = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[300], size: AppSizes.size24),
        const SizedBox(width: AppSpacing.space16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                FormatPrice.formatDate(primaryText),
                style: TextStyle(
                  color: iconColor,
                  fontSize: AppSizes.size12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (secondaryText != null) ...[
                const SizedBox(height: AppSpacing.space4),
                Text(
                  secondaryText,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: AppSizes.size14,
                    height: AppSizes.size1_4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
