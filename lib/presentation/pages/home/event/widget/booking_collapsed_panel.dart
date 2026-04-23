import 'package:event_go/core/utils/extension.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/utils/format_price.dart';
import '../../../../../core/widgets/app_elevated_button.dart';
import '../../../../../data/models/event/event_detail_model.dart';
import '../../../../view_models/event_order_view_model.dart';

class BookingCollapsedPanel extends StatelessWidget {
  const BookingCollapsedPanel({
    super.key,
    required this.event,
    required this.viewModel,
    required this.onProceedPayment,
  });

  final EventDetailModel event;
  final EventOrderViewModel viewModel;
  final Future<void> Function() onProceedPayment;

  @override
  Widget build(BuildContext context) {
    final hasTickets = viewModel.hasTickets;
    final buttonText = hasTickets
        ? context.appLocaleLanguage.paymentFormat(
      viewModel.currencyFormat.format(viewModel.grandTotal),
    )
        : context.appLocaleLanguage.pleaseSelectTicket;

    return GestureDetector(
      onTap: () => viewModel.panelController.open(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
        decoration: const BoxDecoration(
          color: AppColors.eventSurface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSizes.size10),
            topRight: Radius.circular(AppSizes.size10),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.keyboard_arrow_up, color: AppColors.grey),
            const SizedBox(height: AppSpacing.space4),
            Text(
              event.title,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: AppSizes.size14,
              ),
            ),
            Text(
              FormatPrice.formatDateTime(event.startTime.toString()),
              style: const TextStyle(
                color: AppColors.grey,
                fontSize: AppSizes.size12,
              ),
            ),
            const SizedBox(height: AppSpacing.space8),
            AppElevatedButton(
              text: buttonText,
              onPressed: hasTickets ? onProceedPayment : null,
              height: AppSizes.size40,
              borderRadius: const BorderRadius.all(Radius.circular(AppSizes.size4)),
              textColor: hasTickets ? AppColors.white : AppColors.grey,
              color: hasTickets ? AppColors.green : AppColors.colorFFDEE0E4,
              fontSize: AppSizes.size15,
              borderColor: AppColors.transparent,
              splashColor: AppColors.transparent,
              highlightColor: AppColors.white,
            ),
          ],
        ),
      ),
    );
  }
}
