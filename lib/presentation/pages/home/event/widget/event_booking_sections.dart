import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_sizes.dart';
import 'package:event_go/core/constants/app_spacing.dart';
import 'package:event_go/core/utils/extension.dart';
import 'package:event_go/core/utils/format_price.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:event_go/data/models/event/event_detail_model.dart';
import 'package:event_go/presentation/pages/home/event/widget/ticket_expansion_item.dart';
import 'package:event_go/presentation/view_models/event_order_view_model.dart';
import 'package:event_go/routers/router_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BookingPriceListPanel extends StatelessWidget {
  const BookingPriceListPanel({
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

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: AppSizes.size40,
              height: AppSizes.size4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(AppSizes.size12),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space16),
          Text(
            event.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: AppSizes.size16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.space10),
          const Divider(color: AppColors.colorFF27272E, thickness: 3),
          _EventMetaRow(icon: Icons.location_on, text: event.venue ?? ''),
          _EventMetaRow(
            icon: Icons.calendar_today,
            text: FormatPrice.formatDateTime(event.startTime.toString()),
          ),
          const Divider(color: AppColors.colorFF27272E, thickness: 3),
          Expanded(
            child: ListView.builder(
              itemCount: event.ticketType?.length ?? 0,
              itemBuilder: (context, index) {
                final ticket = event.ticketType![index];
                return ListTile(
                  title: Text(
                    ticket.name,
                    style: const TextStyle(color: AppColors.white),
                  ),
                  trailing: Text(
                    FormatPrice.format(
                      double.tryParse(ticket.price.toString()) ?? 0,
                    ),
                    style: const TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.space16),
          AppElevatedButton(
            text: buttonText,
            onPressed: hasTickets ? onProceedPayment : null,
            height: AppSizes.size40,
            borderRadius: const BorderRadius.all(
              Radius.circular(AppSizes.size4),
            ),
            textColor: hasTickets ? AppColors.white : AppColors.grey,
            color: hasTickets ? AppColors.green : AppColors.colorFFDEE0E4,
            fontSize: AppSizes.size15,
            borderColor: AppColors.transparent,
            splashColor: AppColors.transparent,
            highlightColor: AppColors.white,
          ),
        ],
      ),
    );
  }
}

Future<void> proceedToPayment(
  BuildContext context, {
  required EventOrderViewModel viewModel,
  required EventDetailModel event,
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<EventOrderViewModel>(
        builder: (_, vm, __) => vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : const SizedBox.shrink(),
      ),
    ),
  );

  final token = await viewModel.createPaymentOrder();
  if (context.mounted) {
    context.pop();
    if (token != null) {
      context.push(RouterPath.payment, extra: {'token': token, 'event': event});
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(viewModel.zpTransToken)));
    }
  }
}

class _EventMetaRow extends StatelessWidget {
  const _EventMetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.green, size: AppSizes.size20),
      title: Text(
        text,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: AppSizes.size12,
          fontWeight: FontWeight.w600,
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
