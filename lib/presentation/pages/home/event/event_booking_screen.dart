import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_sizes.dart';
import 'package:event_go/core/constants/app_spacing.dart';
import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/core/utils/extension.dart';
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
        viewModel.initEventDetail(widget.event.id);
      },
      builder: (context, viewModel, child) {
        final vmReader = context.read<HomeViewModel>();
        return Scaffold(
          appBar: AppBar(
            title: SizedBox(
              height: AppSizes.size50,
              child: Marquee(
                text: context.appLocaleLanguage.clickToSelectTicket,
                style: const TextStyle(
                  fontSize: AppSizes.size18,
                  color: AppColors.white,
                ),
                velocity: AppSizes.size50,
                blankSpace: AppSizes.size30,
                pauseAfterRound: const Duration(seconds: 1),
                startPadding: AppSpacing.space10,
              ),
            ),
            backgroundColor: const Color(0xFF1A1A1A),
            elevation: 0,
          ),
          body: SlidingUpPanel(
            controller: viewModel.panelController,
            minHeight: AppSizes.size140,
            maxHeight: MediaQuery.of(context).size.height * AppSizes.size0_8,
            parallaxEnabled: true,
            parallaxOffset: 0.5,
            color: Color(0xFF1A1A1A),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSizes.size24),
              topRight: Radius.circular(AppSizes.size24),
            ),
            body: ListView.builder(
              padding: const EdgeInsets.only(
                left: AppSpacing.space10,
                right: AppSpacing.space10,
                top: AppSpacing.space20,
                bottom: AppSpacing.space150,
              ),
              itemCount: widget.event.ticketType!.length,
              itemBuilder: (context, index) {
                final ticket = widget.event.ticketType![index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.space10),
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
        ? context.appLocaleLanguage.paymentFormat(
      vm.currencyFormat.format(vm.grandTotal),
    )
        : context.appLocaleLanguage.pleaseSelectTicket;
    final Color buttonColor = hasTickets
        ? AppColors.green
        : const Color(0xFFDEE0E4);
    final Color textColor = hasTickets ? AppColors.white : AppColors.grey;

    return GestureDetector(
      onTap: () => vm.panelController.open(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSizes.size10),
            topRight: Radius.circular(AppSizes.size10),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.keyboard_arrow_up, color: AppColors.grey),
            SizedBox(height: AppSpacing.space4),
            Text(
              widget.event.title,
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: AppSizes.size14,
              ),
            ),
            Text(
              FormatPrice.formatDateTime(widget.event.startTime.toString()),
              style: TextStyle(color: AppColors.grey, fontSize: AppSizes.size12),
            ),
            const SizedBox(height: AppSpacing.space8),
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
                    context.push(
                      RouterPath.payment,
                      extra: {'token': token, 'event': widget.event},
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(vmReader.zpTransToken)),
                    );
                  }
                }
              },
              height: AppSizes.size40,
              borderRadius: const BorderRadius.all(
                Radius.circular(AppSizes.size4),
              ),
              textColor: textColor,
              color: buttonColor,
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

  Widget _buildPriceListPanel(
      BuildContext context,
      HomeViewModel vm,
      HomeViewModel vmReader,
      ) {
    final bool hasTickets = vm.hasTickets;
    final String buttonText = hasTickets
        ? context.appLocaleLanguage.paymentFormat(
      vm.currencyFormat.format(vm.grandTotal),
    )
        : context.appLocaleLanguage.pleaseSelectTicket;
    final Color buttonColor = hasTickets
        ? AppColors.green
        : const Color(0xFFDEE0E4);
    final Color textColor = hasTickets ? AppColors.white : AppColors.grey;

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
            widget.event.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.white,
              fontSize: AppSizes.size16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.space10),
          const Divider(color: Color(0xFF27272E), thickness: 3),
          ListTile(
            leading: Icon(
              Icons.location_on,
              color: AppColors.green,
              size: AppSizes.size20,
            ),
            title: Text(
              widget.event.venue ?? '',
              style: TextStyle(
                color: AppColors.white,
                fontSize: AppSizes.size12,
                fontWeight: FontWeight.w600,
              ),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          ListTile(
            leading: Icon(
              Icons.calendar_today,
              color: AppColors.green,
              size: AppSizes.size20,
            ),
            title: Text(
              FormatPrice.formatDateTime(widget.event.startTime.toString()),
              style: TextStyle(
                color: AppColors.white,
                fontSize: AppSizes.size12,
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
                    style: const TextStyle(color: AppColors.white),
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
          const SizedBox(height: AppSpacing.space16),
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
                  context.push(RouterPath.payment, extra: {'token': token, 'event': widget.event},);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(vmReader.zpTransToken)),
                  );
                }
              }
            },
            height: AppSizes.size40,
            borderRadius: const BorderRadius.all(
              Radius.circular(AppSizes.size4),
            ),
            textColor: textColor,
            color: buttonColor,
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