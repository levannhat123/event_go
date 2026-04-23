import 'package:event_go/core/utils/extension.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/utils/format_price.dart';
import '../../../../../core/widgets/app_elevated_button.dart';
import '../../../../../data/models/event/event_detail_model.dart';
import '../../ticket_item_row.dart';

class EventTicketInfoSection extends StatelessWidget {
  const EventTicketInfoSection({
    super.key,
    required this.event,
    required this.isEventCompleted,
    required this.getSoldQuantity,
    required this.onBuyNowPressed,
  });

  final EventDetailModel event;
  final bool isEventCompleted;
  final int Function(String name) getSoldQuantity;
  final VoidCallback onBuyNowPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.colorFF2A2D34,
        borderRadius: BorderRadius.circular(AppSizes.size12),
      ),
      margin: const EdgeInsets.all(AppSpacing.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space16,
              AppSpacing.space16,
              AppSpacing.space16,
              AppSpacing.space0,
            ),
            child: Text(
              context.appLocaleLanguage.ticketInfo,
              style: const TextStyle(
                fontSize: AppSizes.size16,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
          const Divider(color: AppColors.colorFF27272A),
          ExpansionTile(
            controlAffinity: ListTileControlAffinity.leading,
            shape: const Border(),
            collapsedShape: const Border(),
            iconColor: AppColors.white,
            collapsedIconColor: AppColors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  FormatPrice.formatDate(event.startTime.toString()),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizes.size12,
                    color: AppColors.white,
                  ),
                ),
                _BuyButton(
                  isEventCompleted: isEventCompleted,
                  onPressed: onBuyNowPressed,
                ),
              ],
            ),
            childrenPadding: const EdgeInsets.all(AppSpacing.space12),
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: event.ticketType?.length ?? 0,
                separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.space16),
                itemBuilder: (context, index) {
                  final ticket = event.ticketType![index];
                  return TicketItemRow(
                    ticketName: ticket.name,
                    price: ticket.price.toString(),
                    currentSold: getSoldQuantity(ticket.name),
                    totalQuantity: ticket.totalQuantity ?? 0,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class _BuyButton extends StatelessWidget {
  const _BuyButton({required this.isEventCompleted, required this.onPressed});

  final bool isEventCompleted;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppElevatedButton(
      text: isEventCompleted
          ? 'Sự kiện kết thúc'
          : context.appLocaleLanguage.buyTicketNow,
      onPressed: onPressed,
      height: AppSizes.size40,
      width: isEventCompleted ? AppSizes.size156 : AppSizes.size125,
      textColor: AppColors.white,
      color: isEventCompleted ? AppColors.transparent : AppColors.green,
      fontSize: AppSizes.size15,
      borderRadius: const BorderRadius.all(Radius.circular(AppSizes.size4)),
      borderColor: isEventCompleted ? AppColors.grey : AppColors.green,
      splashColor: AppColors.transparent,
      highlightColor: AppColors.white,
      isDisable: isEventCompleted,
    );
  }
}
