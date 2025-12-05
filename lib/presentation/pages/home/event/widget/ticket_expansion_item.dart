import 'package:event_go/core/utils/format_price.dart';
import 'package:event_go/presentation/pages/home/event/widget/ticket_data.dart';
import 'package:event_go/presentation/view_models/home_view_model.dart';
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
    final vm = context.watch<HomeViewModel>();
    final quantity = vm.getQuantity(index);
    final vmReader = context.read<HomeViewModel>();
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D34),
        borderRadius: BorderRadius.circular(AppSizes.size12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpansionTile(
            controlAffinity: ListTileControlAffinity.leading,
            shape: const Border(),
            collapsedShape: const Border(),
            iconColor: Colors.white,
            collapsedIconColor: Colors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppSizes.size12,
                        color: AppColors.green,
                      ),
                    ),
                    Text(
                      FormatPrice.format(double.tryParse(ticket.price.toString()) ?? 0),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppSizes.size12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                _buildQuantityStepper(
                  quantity,
                      () => vmReader.incrementTicket(index),
                      () => vmReader.decrementTicket(index),
                ),
              ],
            ),
            childrenPadding: const EdgeInsets.all(AppSpacing.space12),
            children: [
              Text(
                ticket.description??'',
                style: TextStyle(color: Colors.grey[400], fontSize: AppSizes.size12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityStepper(
      int quantity,
      VoidCallback onIncrement,
      VoidCallback onDecrement,
      ) {
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
              color: quantity > 0 ? Colors.black : Colors.grey,
            ),
            onPressed: onDecrement,
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
                color: Colors.black,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.btnError),
            onPressed: onIncrement,
            splashRadius: AppSizes.size20,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}