import 'package:event_go/core/utils/format_price.dart';
import 'package:event_go/presentation/view_models/event_order_view_model.dart';
import 'package:event_go/core/constants/app_sizes.dart';
import 'package:event_go/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/event/ticket_type_model.dart';

class TicketExpansionItem extends StatelessWidget {
  const TicketExpansionItem({
    super.key,
    required this.ticket,
    required this.index,
  });

  final TicketTypeModel ticket;
  final int index;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventOrderViewModel>();
    final quantity = vm.getQuantity(index);
    final vmReader = context.read<EventOrderViewModel>();
    final int currentSold = vm.getSoldQuantity(ticket.name);
    final int totalQuantity = ticket.totalQuantity ?? 0;
    final int remaining = (totalQuantity > 0) ? (totalQuantity - currentSold) : 9999;
    final bool isSoldOut = remaining <= 0;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.colorFF2A2D34,
        borderRadius: BorderRadius.circular(AppSizes.size12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpansionTile(
            controlAffinity: ListTileControlAffinity.leading,
            shape: const Border(),
            collapsedShape: const Border(),
            iconColor: AppColors.white,
            collapsedIconColor: AppColors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          ticket.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizes.size12,
                            color: AppColors.green,
                          ),
                        ),
                        if (isSoldOut) ...[
                          const SizedBox(width: AppSizes.size8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.size6,
                              vertical: AppSizes.size2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.colorFFFFCDD2,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Hết vé',
                              style: TextStyle(
                                color: AppColors.colorFFD32F2F,
                                fontWeight: FontWeight.bold,
                                fontSize: AppSizes.size10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      FormatPrice.format(double.tryParse(ticket.price.toString()) ?? 0),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppSizes.size12,
                        color: AppColors.white,
                        decoration: isSoldOut ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.white,
                      ),
                    ),
                  ],
                ),
                _buildQuantityStepper(
                  quantity: quantity,
                  remaining: remaining,
                  isSoldOut: isSoldOut,
                  onIncrement: () => vmReader.incrementTicket(index),
                  onDecrement: () => vmReader.decrementTicket(index),
                ),
              ],
            ),
            childrenPadding: const EdgeInsets.all(AppSpacing.space12),
            children: [
              Text(
                ticket.description ?? '',
                style: TextStyle(color: Colors.grey[400], fontSize: AppSizes.size12),
              ),
              if (!isSoldOut && remaining < 10)
                Padding(
                  padding: const EdgeInsets.only(top: AppSizes.size8),
                  child: Text(
                    "Chỉ còn lại $remaining vé",
                    style: const TextStyle(color: Colors.orange, fontSize: AppSizes.size11, fontStyle: FontStyle.italic),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityStepper({
    required int quantity,
    required int remaining,
    required bool isSoldOut,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    final bool canIncrement = !isSoldOut && quantity < remaining;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppSizes.size30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.remove,
              color: quantity > 0 ? AppColors.black : AppColors.grey,
            ),
            onPressed: quantity > 0 ? onDecrement : null,
            splashRadius: AppSizes.size20,
            constraints: const BoxConstraints(),
          ),
          Container(
            width: AppSizes.size30,
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: AppSizes.size16,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              color: canIncrement ? AppColors.btnError : AppColors.grey,
            ),
            onPressed: canIncrement ? onIncrement : null,
            splashRadius: AppSizes.size20,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
