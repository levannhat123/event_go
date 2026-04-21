import 'package:event_go/core/utils/extension.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_spacing.dart';

class EventDescriptionSection extends StatelessWidget {
  const EventDescriptionSection({
    super.key,
    required this.description,
    required this.isExpanded,
    required this.onToggle,
  });

  final String description;
  final bool isExpanded;
  final VoidCallback onToggle;

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
              context.appLocaleLanguage.introduction,
              style: const TextStyle(
                fontSize: AppSizes.size17,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const Divider(color: AppColors.grey),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              firstChild: Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: AppSizes.size15,
                  height: AppSizes.size1_4,
                  color: AppColors.black,
                ),
              ),
              secondChild: Text(
                description,
                style: const TextStyle(
                  fontSize: AppSizes.size15,
                  height: AppSizes.size1_4,
                  color: AppColors.black,
                ),
              ),
              crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            ),
            Align(
              alignment: Alignment.center,
              child: IconButton(
                onPressed: onToggle,
                icon: AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.keyboard_arrow_down, size: 26),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}