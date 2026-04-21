import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_sizes.dart';
import 'package:event_go/core/constants/app_spacing.dart';
import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/core/constants/app_storage_key.dart';
import 'package:event_go/core/constants/app_svg.dart';
import 'package:event_go/core/utils/extension.dart';
import 'package:event_go/core/utils/format_price.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:event_go/data/models/event/event_detail_model.dart';
import 'package:event_go/injection/injection.dart';
import 'package:event_go/presentation/view_models/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class EventPaymentScreen extends StatefulWidget {
  final String token;
  final EventDetailModel event;

  const EventPaymentScreen({
    super.key,
    required this.token,
    required this.event,
  });

  @override
  State<EventPaymentScreen> createState() => _EventPaymentScreenState();
}

class _EventPaymentScreenState extends State<EventPaymentScreen> {
  @override
  void dispose() {
    getIt<HomeViewModel>().disposePaymentTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color cardColor = Color(0xFF2C2C2E);
    const Color backgroundColor = AppColors.background;

    return BaseView<HomeViewModel>(
      viewModelBuilder: () => getIt<HomeViewModel>(),
      padding: false,
      autoDispose: false,
      onModelReady: (viewModel) {
        viewModel.event = widget.event;
        viewModel.initPaymentScreen(widget.token, context);
      },
      builder: (context, viewModel, child) {
        final vmReader = context.read<HomeViewModel>();

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: _buildAppBar(),
          body: Stack(
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space12),
                    decoration: const BoxDecoration(color: AppColors.red),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.timer,
                          color: AppColors.white,
                          size: AppSizes.size20,
                        ),
                        const SizedBox(width: AppSizes.size8),
                        Text(
                          context.appLocaleLanguage.ticketHoldTimeRemaining(
                            viewModel.formattedTimeRemaining,
                          ),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: AppSizes.size14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildEventInfoCard(widget.event),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            context.appLocaleLanguage.recipientInfoTitle,
                          ),
                          const SizedBox(height: AppSpacing.space12),
                          _buildRecipientInfoCard(cardColor, viewModel),

                          const SizedBox(height: AppSpacing.space24),
                          _buildSectionHeader(
                            context.appLocaleLanguage.paymentMethodTitle,
                          ),
                          const SizedBox(height: AppSpacing.space12),
                          _buildPaymentMethodCard(
                            cardColor,
                            viewModel,
                            vmReader,
                          ),

                          const SizedBox(height: AppSpacing.space24),
                          _buildSectionHeader(
                            context.appLocaleLanguage.bookingInfoTitle,
                          ),
                          const SizedBox(height: AppSpacing.space12),
                          _buildOrderInfoCard(AppColors.white, vmReader),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              if (viewModel.isLoading)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: AppColors.black.withOpacity(0.85),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.green),
                        SizedBox(height: 20),
                        Text(
                          "Đang xử lý kết quả...",
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: viewModel.isLoading
              ? const SizedBox.shrink()
              : _buildStickyFooter(context, vmReader),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.homePrimaryBlue,
      elevation: 0,
      title: Text(context.appLocaleLanguage.paymentTitle),
      centerTitle: true,
    );
  }

  Widget _buildEventInfoCard(EventDetailModel event) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: const BoxDecoration(color: Color(0xFF1A1A1A)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.event.title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: AppSizes.size16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.space12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: AppColors.grey,
                size: AppSizes.size16,
              ),
              const SizedBox(width: AppSpacing.space8),
              Text(
                FormatPrice.formatDate(widget.event.startTime.toString()),
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: AppSizes.size14,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space8),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: AppColors.grey,
                size: AppSizes.size16,
              ),
              const SizedBox(width: AppSpacing.space8),
              Text(
                widget.event.venue ?? '',
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: AppSizes.size14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    Color? bgColor = AppColors.white,
    double fontSize = AppSizes.size18,
  }) {
    return Text(
      title,
      style: TextStyle(
        color: bgColor,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRecipientInfoCard(Color cardColor, HomeViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space12,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppSizes.size12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.appLocaleLanguage.electronicTicketInfo,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: AppSizes.size14,
            ),
          ),
          const SizedBox(height: AppSpacing.space8),
          Row(
            children: [
              Icon(
                Icons.email_outlined,
                color: Colors.grey[400],
                size: AppSizes.size20,
              ),
              const SizedBox(width: 12),
              Text(
                viewModel.userEmail ?? '',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: AppSizes.size14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    Color cardColor,
    HomeViewModel viewModel,
    HomeViewModel vmReader,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildPaymentOptionRow(
            value: AppStorageKey.zalopay,
            title: context.appLocaleLanguage.zalopay,
            icon: SvgPicture.asset(AppSvg.zalopay, width: 24, height: 24),
            viewModel: viewModel,
            vmReader: vmReader,
          ),

          Divider(color: AppColors.grey.withOpacity(0.2), height: 1),
          _buildPaymentOptionRow(
            value: AppStorageKey.vnpay,
            title: 'VNPAY',
            icon: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: AppColors.white,
              ),
              child: SvgPicture.asset(AppSvg.vnpay, width: 24, height: 24),
            ),
            viewModel: viewModel,
            vmReader: vmReader,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptionRow({
    required String value,
    required String title,
    required Widget icon,
    required HomeViewModel viewModel,
    required HomeViewModel vmReader,
  }) {
    return InkWell(
      onTap: () {
        vmReader.selectPaymentMethod(value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space10,
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: AppSizes.size14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: viewModel.selectedPaymentMethod,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  vmReader.selectPaymentMethod(newValue);
                }
              },
              activeColor: AppColors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard(Color cardColor, HomeViewModel vmReader) {
    final List<Widget> ticketWidgets = [];
    final tickets = vmReader.event?.ticketType;

    if (tickets != null) {
      for (int i = 0; i < tickets.length; i++) {
        final quantity = vmReader.getQuantity(i);
        if (quantity > 0) {
          final ticket = tickets[i];
          final price = ticket.price ?? 0;
          ticketWidgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.name,
                          style: const TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          FormatPrice.format(
                            double.tryParse(price.toString()) ?? 0,
                          ),
                          style: const TextStyle(
                            color: AppColors.black,
                            fontSize: AppSizes.size12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      quantity.toString(),
                      textAlign: TextAlign.end,
                      style: const TextStyle(color: AppColors.black),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppSizes.size12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.appLocaleLanguage.ticketType,
                style: const TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.size16,
                ),
              ),
              Text(
                context.appLocaleLanguage.quantity,
                style: const TextStyle(
                  fontSize: AppSizes.size16,
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space12),
          ...ticketWidgets,
          const SizedBox(height: AppSpacing.space10),
          const Divider(color: AppColors.grey, height: 0),
          const SizedBox(height: AppSpacing.space14),
          _buildSectionHeader(
            context.appLocaleLanguage.orderInfoTitle,
            bgColor: AppColors.black,
            fontSize: AppSizes.size16,
          ),
          const SizedBox(height: AppSpacing.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  context.appLocaleLanguage.subtotal,
                  style: const TextStyle(color: AppColors.black),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  FormatPrice.format(vmReader.grandTotal),
                  textAlign: TextAlign.end,
                  style: const TextStyle(color: AppColors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space10),
          const Divider(color: AppColors.grey, height: 0),
          const SizedBox(height: AppSpacing.space16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  context.appLocaleLanguage.totalAmount,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  FormatPrice.format(vmReader.grandTotal),
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizes.size16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter(BuildContext context, HomeViewModel vmReader) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space16,
        AppSpacing.space16,
        bottomPadding + AppSpacing.space16,
      ),
      margin: const EdgeInsets.only(top: AppSpacing.space10),
      decoration: const BoxDecoration(color: AppColors.surfaceDark),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.appLocaleLanguage.totalAmount,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: AppSizes.size14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                FormatPrice.format(vmReader.grandTotal),
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: AppSizes.size18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppElevatedButton(
            onPressed: () {
              vmReader.handlePayment(context);
            },
            text: context.appLocaleLanguage.paymentButton,
            height: AppSizes.size40,
            width: AppSizes.size125,
            textColor: AppColors.white,
            color: AppColors.green,
            fontSize: AppSizes.size15,
            borderRadius: const BorderRadius.all(
              Radius.circular(AppSizes.size4),
            ),
            borderColor: AppColors.green,
            splashColor: AppColors.transparent,
            highlightColor: AppColors.white,
          ),
        ],
      ),
    );
  }
}
