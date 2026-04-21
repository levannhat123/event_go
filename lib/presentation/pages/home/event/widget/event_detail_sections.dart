import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_image.dart';
import 'package:event_go/core/constants/app_sizes.dart';
import 'package:event_go/core/constants/app_spacing.dart';
import 'package:event_go/core/utils/extension.dart';
import 'package:event_go/core/utils/format_price.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:event_go/core/widgets/event_card.dart';
import 'package:event_go/data/models/event/event_detail_model.dart';
import 'package:event_go/presentation/pages/home/event/widget/event_ticket_card.dart';
import 'package:event_go/presentation/pages/home/ticket_item_row.dart';
import 'package:flutter/material.dart';

({String line1, String line2}) splitAddressLines(String? address) {
  final fullAddress = address ?? '';
  final lastCommaIndex = fullAddress.lastIndexOf(',');
  if (lastCommaIndex == -1) {
    return (line1: fullAddress, line2: '');
  }
  return (
    line1: fullAddress.substring(0, lastCommaIndex).trim(),
    line2: fullAddress.substring(lastCommaIndex + 1).trim(),
  );
}

class RelatedEventsSection extends StatelessWidget {
  const RelatedEventsSection({
    super.key,
    required this.events,
    required this.onOpenDetail,
    required this.onSeeMore,
  });

  final List<EventDetailModel> events;
  final ValueChanged<EventDetailModel> onOpenDetail;
  final VoidCallback onSeeMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.black,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space10),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.space25),
          Text(
            context.appLocaleLanguage.youMayAlsoLike,
            style: const TextStyle(
              fontSize: AppSizes.size16,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.space25),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final event = events[index];
              return EventCard(
                height: AppSizes.size100,
                width: AppSizes.size200,
                imageUrl: event.bannerURL ?? AppImage.banner_1,
                title: event.title,
                status: event.status,
                price: event.minTicketPrice?.toString() ?? 'Miễn phí',
                date: event.startTime.toString(),
                onTap: () => onOpenDetail(event),
              );
            },
          ),
          const SizedBox(height: AppSpacing.space10),
          AppElevatedButton(
            text: context.appLocaleLanguage.seeMore,
            onPressed: onSeeMore,
            height: AppSizes.size40,
            width: AppSizes.size120,
            textColor: AppColors.white,
            color: AppColors.authOrange,
            fontSize: AppSizes.size15,
            borderColor: AppColors.authOrange,
            splashColor: AppColors.transparent,
            highlightColor: AppColors.white,
          ),
          const SizedBox(height: AppSpacing.space20),
        ],
      ),
    );
  }
}
