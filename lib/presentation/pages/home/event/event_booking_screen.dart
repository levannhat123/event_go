import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/utils/format_price.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:event_go/data/models/event/event_detail_model.dart';
import 'package:event_go/injection/injection.dart';
import 'package:event_go/presentation/pages/home/event/widget/ticket_data.dart';
import 'package:event_go/presentation/pages/home/event/widget/ticket_expansion_item.dart';
import 'package:event_go/presentation/view_models/home_view_model.dart';
import 'package:event_go/routers/router_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class EventBookingScreen extends StatefulWidget {
  final EventDetailModel event;
  EventBookingScreen({super.key, required this.event});

  @override
  State<EventBookingScreen> createState() => _EventBookingScreenState();
}

class _EventBookingScreenState extends State<EventBookingScreen> {
  @override
  Widget build(BuildContext context) {
    return BaseView<HomeViewModel>(
      viewModelBuilder: () => getIt<HomeViewModel>(),
      padding: false,
      autoDispose: false,
      onModelReady: (viewModel) {
        viewModel.initBooking();
        viewModel.event = widget.event;
      },
      builder: (context, viewModel, child) {
        final vmReader = context.read<HomeViewModel>();
        return Scaffold(
          appBar: AppBar(
            title: SizedBox(
              height: 50,
              child: Marquee(
                text: 'Bấm vào khu vực để chọn vé   ',
                style: const TextStyle(fontSize: 18, color: Colors.white),
                velocity: 50.0,
                blankSpace: 30.0,
                pauseAfterRound: const Duration(seconds: 1),
                startPadding: 10.0,
              ),
            ),
            backgroundColor: const Color(0xFF1A1A1A),
            elevation: 0,
          ),
          body: SlidingUpPanel(
            controller: viewModel.panelController,
            minHeight: 140,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            parallaxEnabled: true,
            parallaxOffset: 0.5,
            color: Color(0xFF1A1A1A),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
            body: ListView.builder(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 20,
                bottom: 150,
              ),
              itemCount: widget.event.ticketType!.length,
              itemBuilder: (context, index) {
                final ticket = widget.event.ticketType![index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ChangeNotifierProvider.value(
                    value: viewModel,
                    child: TicketExpansionItem(ticket: ticket, index: index),
                  ),
                );
              },
            ),
            collapsed: _buildCollapsedPanel(context, viewModel, vmReader),
            panel: _buildPriceListPanel(context, viewModel, vmReader),
          ),
        );
      },
    );
  }

  Widget _buildCollapsedPanel(
    BuildContext context,
    HomeViewModel vm,
    HomeViewModel vmReader,
  ) {
    final bool hasTickets = vm.hasTickets;
    final String buttonText = hasTickets
        ? 'Thanh toán ${vm.currencyFormat.format(vm.grandTotal)}'
        : 'Vui lòng chọn vé';
    final Color buttonColor = hasTickets
        ? AppColors.green
        : const Color(0xFFDEE0E4);
    final Color textColor = hasTickets ? Colors.white : AppColors.grey;

    return GestureDetector(
      onTap: () => vm.panelController.open(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.keyboard_arrow_up, color: Colors.grey),
            const SizedBox(height: 4),
            Text(
              widget.event.title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              FormatPrice.formatDateTime(widget.event.startTime.toString()),
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            AppElevatedButton(
              text: buttonText,
              onPressed: () async {
                if (hasTickets) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return ChangeNotifierProvider.value(
                        value: vm,
                        child: Consumer<HomeViewModel>(
                          builder: (context, vm, child) => vm.isLoading
                              ? Center(child: CircularProgressIndicator())
                              : SizedBox.shrink(),
                        ),
                      );
                    },
                  );
                  final token = await vmReader.createPaymentOrder();
                  if (!mounted) return;
                  context.pop();

                  if (token != null) {
                    context.push(RouterPath.payment,  extra: {
                      'token': token,
                      'event': widget.event,
                    },);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(vmReader.zpTransToken)),
                    );
                  }
                }
              },
              height: 40,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              textColor: textColor,
              color: buttonColor,
              fontSize: 15.0,
              borderColor: AppColors.transparent,
              splashColor: AppColors.transparent,
              highlightColor: AppColors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceListPanel(
    BuildContext context,
    HomeViewModel vm,
    HomeViewModel vmReader,
  ) {
    final bool hasTickets = vm.hasTickets;
    final String buttonText = hasTickets
        ? 'Thanh toán ${vm.currencyFormat.format(vm.grandTotal)}'
        : 'Vui lòng chọn vé';
    final Color buttonColor = hasTickets
        ? AppColors.green
        : const Color(0xFFDEE0E4);
    final Color textColor = hasTickets ? Colors.white : AppColors.grey;

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.event.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFF27272E), thickness: 3),
          ListTile(
            leading: Icon(Icons.location_on, color: AppColors.green, size: 20),
            title: Text(
              widget.event.venue ?? '',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          ListTile(
            leading: Icon(Icons.calendar_today, color: AppColors.green, size: 20),
            title: Text(
              FormatPrice.formatDateTime(widget.event.startTime.toString()),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(color: Color(0xFF27272E), thickness: 3),
          Expanded(
            child: ListView.builder(
              itemCount: widget.event.ticketType!.length,
              itemBuilder: (context, index) {
                final ticket = widget.event.ticketType![index];
                return ListTile(
                  title: Text(
                    ticket.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: Text(
                    "${FormatPrice.format(double.tryParse(ticket.price.toString()) ?? 0)}",
                    style: const TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          AppElevatedButton(
            text: buttonText,
            onPressed: () async {
              if (hasTickets) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Consumer<HomeViewModel>(
                      builder: (context, vm, child) => vm.isLoading
                          ? Center(child: CircularProgressIndicator())
                          : SizedBox.shrink(),
                    );
                  },
                );

                final token = await vmReader.createPaymentOrder();

                if (!mounted) return;
                context.pop();

                if (token != null) {
                  context.push(RouterPath.payment, extra: token);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(vmReader.zpTransToken)),
                  );
                }
              }
            },
            height: 40,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            textColor: textColor,
            color: buttonColor,
            fontSize: 15.0,
            borderColor: AppColors.transparent,
            splashColor: AppColors.transparent,
            highlightColor: AppColors.white,
          ),
        ],
      ),
    );
  }
}
