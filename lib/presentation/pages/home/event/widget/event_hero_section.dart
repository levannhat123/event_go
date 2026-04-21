import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_image.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../data/models/event/event_detail_model.dart';
import 'event_ticket_card.dart';

class EventHeroSection extends StatelessWidget {
  const EventHeroSection({super.key, required this.event});

  final EventDetailModel event;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * AppSizes.size0_6,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(event.bannerURL ?? AppImage.banner_1),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(color: AppColors.black.withValues(alpha: 0.5)),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space20),
            child: EventTicketCard(
              imagePath: event.bannerURL ?? AppImage.banner_1,
              title: event.title,
              date: event.startTime.toString(),
              location: event.venue ?? '',
              address: event.address ?? '',
            ),
          ),
        ],
      ),
    );
  }
}
