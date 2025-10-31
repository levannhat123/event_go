import 'package:event_go/presentation/pages/home/event/widget/ticket_data.dart';
import 'package:event_go/presentation/view_models/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/app_colors.dart';

class TicketExpansionItem extends StatelessWidget {
  const TicketExpansionItem({
    super.key,
    required this.ticket,
    required this.index,
  });

  final TicketData ticket;
  final int index;


  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final quantity = vm.getQuantity(index);
    final vmReader = context.read<HomeViewModel>();
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D34),
        borderRadius: BorderRadius.circular(12),
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
                      ticket.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: ticket.titleColor,
                      ),
                    ),
                    Text(
                      ticket.price,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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
            childrenPadding: const EdgeInsets.all(12),
            children: [
              Text(
                ticket.description,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
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
        borderRadius: BorderRadius.circular(30),
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
            splashRadius: 20,
            constraints: const BoxConstraints(),
          ),
          Container(
            width: 30,
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.btnError),
            onPressed: onIncrement,
            splashRadius: 20,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}