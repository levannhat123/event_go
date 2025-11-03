import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_svg.dart';
import 'package:event_go/core/utils/format_price.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:event_go/data/models/event/event_detail_model.dart';
import 'package:event_go/injection/injection.dart';
import 'package:event_go/presentation/view_models/home_view_model.dart';
import 'package:event_go/routers/router_name.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_zalopay_sdk/flutter_zalopay_sdk.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EventPaymentScreen extends StatefulWidget {
  String token;
  final EventDetailModel event;
  EventPaymentScreen({super.key, required this.token, required this.event});

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
    const Color backgroundColor = Color(0xFF121212);
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
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Thời gian giữ vé còn lại: ${viewModel.formattedTimeRemaining}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _buildEventInfoCard(widget.event),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("Thông tin nhận vé"),
                      const SizedBox(height: 12),
                      _buildRecipientInfoCard(cardColor, viewModel),
                      const SizedBox(height: 24),
                      _buildSectionHeader("Phương thức thanh toán"),
                      const SizedBox(height: 12),
                      _buildPaymentMethodCard(cardColor, viewModel, vmReader),
                      const SizedBox(height: 24),
                      _buildSectionHeader("Thông tin đặt vé"),
                      const SizedBox(height: 12),
                      _buildOrderInfoCard(Colors.white, vmReader),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildStickyFooter(context, vmReader),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF596DC3),
      elevation: 0,
      title: Text("Thanh toán"),
      centerTitle: true,
    );
  }

  Widget _buildEventInfoCard(EventDetailModel event) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.event.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey[300], size: 16),
              const SizedBox(width: 8),
              Text(
                FormatPrice.formatDate(widget.event.startTime.toString()),
                style: TextStyle(color: Colors.grey[300], fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey[300], size: 16),
              const SizedBox(width: 8),
              Text(
                widget.event.venue ?? '',
                style: TextStyle(color: Colors.grey[300], fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    Color? bgColor = Colors.white,
    double fontSize = 18,
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

  Widget _buildRecipientInfoCard(Color cardColor,HomeViewModel viewModel,) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Vé điện tử sẽ được hiển thị trong mục \"Vé của tôi\" của tài khoản",
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.email_outlined, color: Colors.grey[400], size: 20),
              const SizedBox(width: 12),
              Text(
                viewModel.userEmail??'',
                style: const TextStyle(color: Colors.white, fontSize: 14),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildPaymentOptionRow(
            value: 'zalopay',
            title: 'Zalopay',
            icon: SvgPicture.asset(AppSvg.zalopay, width: 20, height: 20),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: viewModel.selectedPaymentMethod,
              onChanged: (String? newValue) {
                vmReader.selectPaymentMethod(newValue!);
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
              padding: const EdgeInsets.only(bottom: 8.0),
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
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          FormatPrice.format(
                            double.tryParse(price.toString()) ?? 0,
                          ), // Lấy giá vé động
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
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
                      style: const TextStyle(color: Colors.black),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Loại vé",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                "Số lượng",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...ticketWidgets,
          const SizedBox(height: 10),
          const Divider(color: Colors.grey, height: 0),
          const SizedBox(height: 14),
          _buildSectionHeader(
            "Thông tin đơn hàng",
            bgColor: Colors.black,
            fontSize: 16,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                flex: 3,
                child: Text("Tạm tính", style: TextStyle(color: Colors.black)),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  FormatPrice.format(vmReader.grandTotal),
                  textAlign: TextAlign.end,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.grey, height: 0),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                flex: 3,
                child: Text(
                  "Tổng tiền",
                  style: TextStyle(
                    color: Colors.black,
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
                    fontSize: 16,
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
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 16),
      margin: EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(color: Color(0xFF1C1C1E)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Tổng tiền",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                FormatPrice.format(vmReader.grandTotal),
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppElevatedButton(
            onPressed: () {
              vmReader.handlePayment();
            },
            text: 'Thanh toán',
            height: 40,
            width: 125,
            textColor: AppColors.white,
            color: AppColors.green,
            fontSize: 15.0,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            borderColor: AppColors.green,
            splashColor: AppColors.transparent,
            highlightColor: AppColors.white,
          ),
        ],
      ),
    );
  }
}
