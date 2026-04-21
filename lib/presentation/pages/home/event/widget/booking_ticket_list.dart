import 'package:event_go/presentation/pages/home/event/widget/ticket_expansion_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/app_spacing.dart';
import '../../../../../data/models/event/event_detail_model.dart';
import '../../../../view_models/event_order_view_model.dart';

class BookingTicketList extends StatelessWidget {
  const BookingTicketList({
    super.key,
    required this.event,
    required this.viewModel,
  });

  final EventDetailModel event;
  final EventOrderViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final ticketTypes = event.ticketType ?? [];
    return ListView.builder(
      padding: const EdgeInsets.only(
        left: AppSpacing.space10,
        right: AppSpacing.space10,
        top: AppSpacing.space20,
        bottom: AppSpacing.space150,
      ),
      itemCount: ticketTypes.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.space10),
          child: ChangeNotifierProvider.value(
            value: viewModel,
            child: TicketExpansionItem(ticket: ticketTypes[index], index: index),
          ),
        );
      },
    );
  }
}