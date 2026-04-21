import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_sizes.dart';
import 'package:event_go/core/constants/app_spacing.dart';
import 'package:event_go/core/utils/extension.dart';
import 'package:event_go/data/models/event/event_detail_model.dart';
import 'package:event_go/injection/injection.dart';
import 'package:event_go/presentation/pages/home/event/widget/booking_collapsed_panel.dart';
import 'package:event_go/presentation/pages/home/event/widget/booking_ticket_list.dart';
import 'package:event_go/presentation/pages/home/event/widget/event_booking_sections.dart';
import 'package:event_go/presentation/view_models/event_order_view_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class EventBookingScreen extends StatefulWidget {
  const EventBookingScreen({super.key, required this.event});

  final EventDetailModel event;

  @override
  State<EventBookingScreen> createState() => _EventBookingScreenState();
}

class _EventBookingScreenState extends State<EventBookingScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventOrderViewModel>().initBooking();
    });
  }
  @override
  Widget build(BuildContext context) {
    return BaseView<EventOrderViewModel>(
      viewModelBuilder: () => getIt<EventOrderViewModel>(),
      padding: false,
      autoDispose: false,
      onModelReady: (viewModel) {
        viewModel.event = widget.event;
        viewModel.initEventDetail(widget.event.id);
      },
      builder: (context, viewModel, child) {
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
            backgroundColor: AppColors.eventSurface,
            elevation: 0,
          ),
          body: SlidingUpPanel(
            controller: viewModel.panelController,
            minHeight: AppSizes.size140,
            maxHeight: MediaQuery.of(context).size.height * AppSizes.size0_8,
            parallaxEnabled: true,
            parallaxOffset: 0.5,
            color: AppColors.eventSurface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSizes.size24),
              topRight: Radius.circular(AppSizes.size24),
            ),
            body: BookingTicketList(event: widget.event, viewModel: viewModel),
            collapsed: BookingCollapsedPanel(
              event: widget.event,
              viewModel: viewModel,
              onProceedPayment: () => proceedToPayment(
                context,
                viewModel: viewModel,
                event: widget.event,
              ),
            ),
            panel: BookingPriceListPanel(
              event: widget.event,
              viewModel: viewModel,
              onProceedPayment: () => proceedToPayment(
                context,
                viewModel: viewModel,
                event: widget.event,
              ),
            ),
          ),
        );
      },
    );
  }
}
