import 'dart:math';

import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_image.dart';
import 'package:event_go/core/constants/app_sizes.dart';
import 'package:event_go/core/constants/app_spacing.dart';
import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/core/utils/extension.dart';
import 'package:event_go/core/utils/format_price.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:event_go/core/widgets/event_card.dart';
import 'package:event_go/data/models/event/event_detail_model.dart';
import 'package:event_go/injection/injection.dart';
import 'package:event_go/presentation/pages/home/event/widget/event_ticket_card.dart';
import 'package:event_go/presentation/pages/home/location_card.dart';
import 'package:event_go/presentation/pages/home/ticket_item_row.dart';
import 'package:event_go/presentation/view_models/home_view_model.dart';
import 'package:event_go/routers/router_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:slider_captcha/slider_captcha.dart';

class EventDetailScreen extends StatefulWidget {
  final EventDetailModel event;
  EventDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {


  @override
  Widget build(BuildContext context) {
    return BaseView<HomeViewModel>(
      viewModelBuilder: () => getIt<HomeViewModel>(),
      padding: false,
      autoDispose: false,
      onModelReady: (viewModel) {
        viewModel.initEventDetail(widget.event.id);
        viewModel.watchAll();
      },
      builder: (context, viewModel, child) {
        final String fullAddress = widget.event.address ?? '';
        final int lastCommaIndex = fullAddress.lastIndexOf(',');
        final bool isEventCompleted = widget.event.status == 'COMPLETED';
        debugPrint(
          'Event: ${widget.event.title} | status=${widget.event.status} | start=${widget.event.startTime} | end=${widget.event.endTime}',
        );

        String line1 = '';
        String line2 = '';
        if (lastCommaIndex != -1) {
          line1 = fullAddress.substring(0, lastCommaIndex).trim();
          line2 = fullAddress.substring(lastCommaIndex + 1).trim();
        } else {
          line1 = fullAddress;
        }
        return Scaffold(
          backgroundColor: Color(0xFFE6EAF5),
          appBar: AppBar(
            title: Text(
              context.appLocaleLanguage.eventDetailTitle,
              style: TextStyle(
                fontSize: AppSizes.size20,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: const Color(0xFF596DC3),
            centerTitle: true,
            actions: [IconButton(onPressed: () {}, icon: Icon(Icons.share))],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space20,
              vertical: AppSpacing.space12,
            ),
            decoration: const BoxDecoration(color: Colors.black),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppSizes.size16,
                    ),
                    children: [
                      TextSpan(text: context.appLocaleLanguage.priceFrom),
                      WidgetSpan(child: SizedBox(width: AppSizes.size4)),
                      TextSpan(
                        text: FormatPrice.format(
                          double.tryParse(
                            widget.event.minTicketPrice.toString(),
                          ) ??
                              0,
                        ),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                AppElevatedButton(
                  text:!isEventCompleted? context.appLocaleLanguage.buyTicketNow:'Sự kiện kết thúc',
                  onPressed: () {
                    if (viewModel.isLockedOut) {
                      final remainingSeconds =
                          viewModel.lockoutRemainingSeconds;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context.appLocaleLanguage
                                .captchaLockoutMessage(remainingSeconds)
                                .replaceAll(
                              '{seconds}',
                              remainingSeconds.toString(),
                            ),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    viewModel.refreshCaptchaImage();

                    showDialog(
                      context: context,
                      builder: (dialogContext) {
                        final SliderController controller = SliderController();

                        return ChangeNotifierProvider.value(
                          value: viewModel,
                          child: Consumer<HomeViewModel>(
                            builder: (context, vm, _) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.size12,
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    AppSpacing.space16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.size12,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            context
                                                .appLocaleLanguage
                                                .captchaTitle,
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              dialogContext.pop();
                                            },
                                            child: Icon(
                                              Icons.close,
                                              size: AppSizes.size20,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: AppSpacing.space20,
                                      ),
                                      Text(
                                        context
                                            .appLocaleLanguage
                                            .captchaDescription,
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      const SizedBox(
                                        height: AppSpacing.space10,
                                      ),
                                      Text(
                                        context
                                            .appLocaleLanguage
                                            .captchaInstruction,
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      const SizedBox(
                                        height: AppSpacing.space20,
                                      ),
                                      SliderCaptcha(
                                        controller: controller,
                                        image: Image.asset(
                                          vm.currentCaptchaImage,
                                          fit: BoxFit.cover,
                                        ),
                                        colorBar: Colors.blue,
                                        colorCaptChar: Colors.blue,
                                        onConfirm: (success) async {
                                          final result = vm.onCaptchaConfirm(
                                            success,
                                          );

                                          if (result == CaptchaResult.success) {
                                            dialogContext.pop();
                                            context.push(
                                              RouterPath.booking,
                                              extra: widget.event,
                                            );
                                          } else if (result ==
                                              CaptchaResult.lockedOut) {
                                            dialogContext.pop();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  context
                                                      .appLocaleLanguage
                                                      .captchaLockoutMessage1Min,
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          } else {
                                            await Future.delayed(
                                              const Duration(milliseconds: 500),
                                            );
                                            controller.create();
                                            vm.refreshCaptchaImage();
                                            vm.clearCaptchaError();
                                          }
                                        },
                                      ),
                                      const SizedBox(
                                        height: AppSpacing.space20,
                                      ),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              controller.create();
                                              vm.refreshCaptchaImage();
                                              vm.clearCaptchaError();
                                            },
                                            child: Icon(
                                              Icons.refresh,
                                              size: AppSizes.size16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(width: AppSizes.size8),
                                          Text(
                                            context
                                                .appLocaleLanguage
                                                .captchaReload,
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (vm.captchaErrorText != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: AppSpacing.space8,
                                          ),
                                          child: Text(
                                            vm.captchaErrorText!,
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        )
                                      else
                                        SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                  height: AppSizes.size40,
                  width: !isEventCompleted? AppSizes.size125:AppSizes.size156,
                  textColor: AppColors.white,
                  color: !isEventCompleted?AppColors.green:AppColors.transparent,
                  fontSize: AppSizes.size15,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppSizes.size4),
                  ),
                  borderColor: !isEventCompleted? AppColors.green: AppColors.grey,
                  splashColor: AppColors.transparent,
                  highlightColor: AppColors.white,
                  isDisable: isEventCompleted,
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * AppSizes.size0_6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        widget.event.bannerURL ?? AppImage.banner_1,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.space20),
                        child: EventTicketCard(
                          imagePath:
                          widget.event.bannerURL ?? AppImage.banner_1,
                          title: widget.event.title,
                          date: widget.event.startTime.toString(),
                          location: widget.event.venue ?? '',
                          address: widget.event.address ?? '',
                        ),
                      ),
                    ],
                  ),
                ),
                ImprovedLocationCard(
                  title: widget.event.venue ?? '',
                  line1: line1,
                  line2: line2,
                ),
                Container(
                  margin: const EdgeInsets.all(AppSpacing.space12),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(AppSizes.size12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space16,
                      vertical: AppSpacing.space12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.appLocaleLanguage.introduction,
                          style: TextStyle(
                            fontSize: AppSizes.size17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const Divider(color: Colors.grey),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          firstChild: Text(
                            widget.event.description ?? '',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: AppSizes.size15,
                              height: 1.4,
                              color: Colors.black,
                            ),
                          ),
                          secondChild: Text(
                            widget.event.description ?? '',
                            style: const TextStyle(
                              fontSize: AppSizes.size15,
                              height: 1.4,
                              color: Colors.black,
                            ),
                          ),
                          crossFadeState: viewModel.isExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: IconButton(
                            icon: AnimatedRotation(
                              turns: viewModel.isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: const Icon(
                                Icons.keyboard_arrow_down,
                                size: 26,
                              ),
                            ),
                            onPressed: () {
                              viewModel.toggleDescriptionExpanded();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF2A2D34),
                    borderRadius: BorderRadius.circular(AppSizes.size12),
                  ),
                  margin: const EdgeInsets.all(AppSpacing.space20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.space16,
                          AppSpacing.space16,
                          AppSpacing.space16,
                          AppSpacing.space0,
                        ),
                        child: Text(
                          context.appLocaleLanguage.ticketInfo,
                          style: TextStyle(
                            fontSize: AppSizes.size16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Divider(color: Color(0xFF27272A)),
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
                                  FormatPrice.formatDate(
                                    widget.event.startTime.toString(),
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppSizes.size12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            AppElevatedButton(
                              text:!isEventCompleted? context.appLocaleLanguage.buyTicketNow:'Sự kiện kết thúc',
                              onPressed: () {
                                if (viewModel.isLockedOut) {
                                  final remainingSeconds =
                                      viewModel.lockoutRemainingSeconds;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.appLocaleLanguage
                                            .captchaLockoutMessage(remainingSeconds)
                                            .replaceAll(
                                          '{seconds}',
                                          remainingSeconds.toString(),
                                        ),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                viewModel.refreshCaptchaImage();

                                showDialog(
                                  context: context,
                                  builder: (dialogContext) {
                                    final SliderController controller = SliderController();

                                    return ChangeNotifierProvider.value(
                                      value: viewModel,
                                      child: Consumer<HomeViewModel>(
                                        builder: (context, vm, _) {
                                          return Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                AppSizes.size12,
                                              ),
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(
                                                AppSpacing.space16,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(
                                                  AppSizes.size12,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        context
                                                            .appLocaleLanguage
                                                            .captchaTitle,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          dialogContext.pop();
                                                        },
                                                        child: Icon(
                                                          Icons.close,
                                                          size: AppSizes.size20,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: AppSpacing.space20,
                                                  ),
                                                  Text(
                                                    context
                                                        .appLocaleLanguage
                                                        .captchaDescription,
                                                    style: TextStyle(color: Colors.black),
                                                  ),
                                                  const SizedBox(
                                                    height: AppSpacing.space10,
                                                  ),
                                                  Text(
                                                    context
                                                        .appLocaleLanguage
                                                        .captchaInstruction,
                                                    style: TextStyle(color: Colors.black),
                                                  ),
                                                  const SizedBox(
                                                    height: AppSpacing.space20,
                                                  ),
                                                  SliderCaptcha(
                                                    controller: controller,
                                                    image: Image.asset(
                                                      vm.currentCaptchaImage,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    colorBar: Colors.blue,
                                                    colorCaptChar: Colors.blue,
                                                    onConfirm: (success) async {
                                                      final result = vm.onCaptchaConfirm(
                                                        success,
                                                      );

                                                      if (result == CaptchaResult.success) {
                                                        dialogContext.pop();
                                                        context.push(
                                                          RouterPath.booking,
                                                          extra: widget.event,
                                                        );
                                                      } else if (result ==
                                                          CaptchaResult.lockedOut) {
                                                        dialogContext.pop();
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              context
                                                                  .appLocaleLanguage
                                                                  .captchaLockoutMessage1Min,
                                                            ),
                                                            backgroundColor: Colors.red,
                                                          ),
                                                        );
                                                      } else {
                                                        await Future.delayed(
                                                          const Duration(milliseconds: 500),
                                                        );
                                                        controller.create();
                                                        vm.refreshCaptchaImage();
                                                        vm.clearCaptchaError();
                                                      }
                                                    },
                                                  ),
                                                  const SizedBox(
                                                    height: AppSpacing.space20,
                                                  ),
                                                  Row(
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          controller.create();
                                                          vm.refreshCaptchaImage();
                                                          vm.clearCaptchaError();
                                                        },
                                                        child: Icon(
                                                          Icons.refresh,
                                                          size: AppSizes.size16,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      SizedBox(width: AppSizes.size8),
                                                      Text(
                                                        context
                                                            .appLocaleLanguage
                                                            .captchaReload,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (vm.captchaErrorText != null)
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                        top: AppSpacing.space8,
                                                      ),
                                                      child: Text(
                                                        vm.captchaErrorText!,
                                                        style: TextStyle(color: Colors.red),
                                                      ),
                                                    )
                                                  else
                                                    SizedBox.shrink(),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                              height: AppSizes.size40,
                              width:!isEventCompleted? AppSizes.size125:AppSizes.size156,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(AppSizes.size4),
                              ),
                              textColor: AppColors.white,
                              color:!isEventCompleted?AppColors.green:AppColors.transparent,
                              fontSize: AppSizes.size15,
                              borderColor: !isEventCompleted? AppColors.green: AppColors.grey,
                              splashColor: AppColors.transparent,
                              highlightColor: AppColors.white,
                              isDisable: isEventCompleted,
                            ),
                          ],
                        ),
                        childrenPadding: const EdgeInsets.all(
                          AppSpacing.space12,
                        ),
                        children: [
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.event.ticketType!.length,
                            separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.space16),
                            itemBuilder: (context, index) {
                              final ticket = widget.event.ticketType![index];

                              return TicketItemRow(
                                ticketName: ticket.name,
                                price: ticket.price.toString(),
                                currentSold: viewModel.getSoldQuantity(ticket.name),
                                totalQuantity: ticket.totalQuantity ?? 0,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(AppSpacing.space12),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(AppSizes.size12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space16,
                      vertical: AppSpacing.space12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.appLocaleLanguage.organizer,
                          style: TextStyle(
                            fontSize: AppSizes.size16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const Divider(color: Colors.grey),
                        Image.network(
                          widget.event.orgLogoURL ?? AppImage.banner_1,
                          height: AppSizes.size50,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: AppSizes.size50,
                                color: Colors.grey[700],
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                        ),
                        const SizedBox(height: AppSpacing.space12),
                        Text(
                          widget.event.orgName ?? '',
                          style: TextStyle(
                            fontSize: AppSizes.size15,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space12),
                        Text(
                          widget.event.orgDescription ?? '',
                          style: TextStyle(
                            fontSize: AppSizes.size14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space10,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: AppSpacing.space25),
                      Center(
                        child: Text(
                          context.appLocaleLanguage.youMayAlsoLike,
                          style: TextStyle(
                            fontSize: AppSizes.size16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.space25),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: viewModel.events.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.8,
                        ),
                        itemBuilder: (context, index) {
                          final event = viewModel.events[index];
                          return EventCard(
                            height: AppSizes.size100,
                            width: AppSizes.size200,
                            imageUrl: event.bannerURL ?? AppImage.banner_1,
                            title: event.title,
                            status: event.status,
                            price: event.minTicketPrice != null
                                ? event.minTicketPrice.toString()
                                : 'Miễn phí',
                            date: event.startTime.toString(),
                            onTap: () {
                              context.push(
                                RouterPath.event_detail,
                                extra: event,
                              );
                            },
                          );
                        },
                      ),
                      SizedBox(height: AppSpacing.space10),
                      Align(
                        alignment: Alignment.center,
                        child: AppElevatedButton(
                          text: context.appLocaleLanguage.seeMore,
                          onPressed: () {
                            context.push(RouterPath.search);
                          },
                          height: AppSizes.size40,
                          width: AppSizes.size120,
                          textColor: AppColors.white,
                          color: Color(0xFFf49415),
                          fontSize: AppSizes.size15,
                          borderColor: Color(0xFFf49415),
                          splashColor: AppColors.transparent,
                          highlightColor: AppColors.white,
                        ),
                      ),
                      SizedBox(height: AppSpacing.space20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}