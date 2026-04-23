import 'package:event_go/core/utils/extension.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/utils/format_price.dart';
import '../../../../../core/widgets/app_elevated_button.dart';
import '../../../../../data/models/event/event_detail_model.dart';

class EventDetailBottomBar extends StatelessWidget {
  const EventDetailBottomBar({
    super.key,
    required this.event,
    required this.isEventCompleted,
    required this.onBuyNowPressed,
  });

  final EventDetailModel event;
  final bool isEventCompleted;
  final VoidCallback onBuyNowPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space20,
        vertical: AppSpacing.space12,
      ),
      decoration: const BoxDecoration(color: AppColors.black),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: AppColors.white,
                fontSize: AppSizes.size16,
              ),
              children: [
                TextSpan(text: context.appLocaleLanguage.priceFrom),
                const WidgetSpan(child: SizedBox(width: AppSizes.size4)),
                TextSpan(
                  text: FormatPrice.format(
                    double.tryParse(event.minTicketPrice.toString()) ?? 0,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _BuyButton(
            isEventCompleted: isEventCompleted,
            onPressed: onBuyNowPressed,
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
