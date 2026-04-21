
import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_sizes.dart';
import 'package:event_go/core/constants/app_storage_key.dart';
import 'package:event_go/core/utils/extension.dart';
import 'package:event_go/data/models/event/event_detail_model.dart';
import 'package:event_go/injection/injection.dart';
import 'package:event_go/presentation/pages/home/event/widget/captcha_dialog.dart';
import 'package:event_go/presentation/pages/home/event/widget/event_description_section.dart';
import 'package:event_go/presentation/pages/home/event/widget/event_detail_bottom_bar.dart';
import 'package:event_go/presentation/pages/home/event/widget/event_detail_sections.dart';
import 'package:event_go/presentation/pages/home/event/widget/event_hero_section.dart';
import 'package:event_go/presentation/pages/home/event/widget/event_ticket_info_section.dart';
import 'package:event_go/presentation/pages/home/event/widget/organizer_section.dart';
import 'package:event_go/presentation/pages/home/location_card.dart';
import 'package:event_go/presentation/view_models/event_order_view_model.dart';
import 'package:event_go/routers/router_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EventDetailScreen extends StatefulWidget {
  final EventDetailModel event;
  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return BaseView<EventOrderViewModel>(
      viewModelBuilder: () => getIt<EventOrderViewModel>(),
      padding: false,
      autoDispose: false,
      onModelReady: (viewModel) {
        viewModel.initEventDetail(widget.event.id);
        viewModel.watchAll();
      },
      builder: (context, viewModel, child) {
        final isEventCompleted =
            widget.event.status == AppStorageKey.completed.toUpperCase();
        final address = splitAddressLines(widget.event.address);
        return Scaffold(
          backgroundColor: AppColors.colorFFE6EAF5,
          appBar: AppBar(
            title: Text(
              context.appLocaleLanguage.eventDetailTitle,
              style: const TextStyle(
                fontSize: AppSizes.size20,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.homePrimaryBlue,
            centerTitle: true,
            actions: const [IconButton(onPressed: null, icon: Icon(Icons.share))],
          ),
          bottomNavigationBar: EventDetailBottomBar(
            event: widget.event,
            isEventCompleted: isEventCompleted,
            onBuyNowPressed: () => showBookingCaptchaDialog(
                      context: context,
              viewModel: viewModel,
              event: widget.event,
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                EventHeroSection(event: widget.event),
                ImprovedLocationCard(
                  title: widget.event.venue ?? '',
                  line1: address.line1,
                  line2: address.line2,
                ),
                EventDescriptionSection(
                  description: widget.event.description ?? '',
                  isExpanded: viewModel.isExpanded,
                  onToggle: viewModel.toggleDescriptionExpanded,
                ),
                EventTicketInfoSection(
                  event: widget.event,
                  isEventCompleted: isEventCompleted,
                  getSoldQuantity: viewModel.getSoldQuantity,
                  onBuyNowPressed: () => showBookingCaptchaDialog(
                                  context: context,
                    viewModel: viewModel,
                    event: widget.event,
                  ),
                ),
                OrganizerSection(event: widget.event),
                RelatedEventsSection(
                  events: viewModel.events,
                  onOpenDetail: (event) =>
                      context.push(RouterPath.event_detail, extra: event),
                  onSeeMore: () => context.push(RouterPath.search),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
