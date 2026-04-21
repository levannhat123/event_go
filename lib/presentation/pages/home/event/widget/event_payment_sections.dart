import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_sizes.dart';
import 'package:event_go/core/constants/app_spacing.dart';
import 'package:event_go/core/constants/app_storage_key.dart';
import 'package:event_go/core/constants/app_svg.dart';
import 'package:event_go/core/utils/extension.dart';
import 'package:event_go/core/utils/format_price.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:event_go/data/models/event/event_detail_model.dart';
import 'package:event_go/presentation/view_models/event_order_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OrderInfoCard extends StatelessWidget {
  const OrderInfoCard({super.key, required this.viewModel});

  final EventOrderViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final tickets = viewModel.event?.ticketType ?? [];
    final rows = <Widget>[];
    for (var i = 0; i < tickets.length; i++) {
      final quantity = viewModel.getQuantity(i);
      if (quantity <= 0) continue;
      final ticket = tickets[i];
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.space8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${ticket.name} - ${FormatPrice.format((ticket.price ?? 0).toDouble())}',
                  style: const TextStyle(color: AppColors.black),
                ),
              ),
              Text(
                quantity.toString(),
                style: const TextStyle(color: AppColors.black),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.size12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...rows,
          const Divider(color: AppColors.grey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.appLocaleLanguage.totalAmount),
              Text(
                FormatPrice.format(viewModel.grandTotal),
                style: const TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
