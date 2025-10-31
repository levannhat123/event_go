import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:event_go/presentation/pages/home/ticket_card.dart';
import 'package:event_go/presentation/pages/home/ticket_item_row.dart';
import 'package:event_go/presentation/pages/home/zone_data.dart';
import 'package:event_go/routers/router_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../core/config/zalo_pay_config.dart';

class TicketData {
  final String title;
  final String price;
  final double priceValue; // THÊM MỚI: Để tính toán
  final String description;
  final Color titleColor;

  TicketData({
    required this.title,
    required this.price,
    required this.priceValue, // THÊM MỚI
    required this.description,
    required this.titleColor,
  });
}

class EventBookingScreen extends StatefulWidget {
  const EventBookingScreen({super.key});

  @override
  State<EventBookingScreen> createState() => _EventBookingScreenState();
}

class _EventBookingScreenState extends State<EventBookingScreen> {
  String zpTransToken = "";
  String payResult = "";

  bool showResult = false;
  final PanelController _panelController = PanelController();

  // THÊM MỚI: State để quản lý tổng tiền
  final Map<int, double> _itemTotals =
      {}; // Map<ticket_index, item_total_price>
  double _grandTotal = 0;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
  );

  // Cập nhật danh sách với `priceValue`
  final List<TicketData> ticketList = [
    TicketData(
      title: 'Ga-Vé Thường',
      price: '299.000đ',
      priceValue: 299000, // Giá trị số
      description:
          'Vé bao gồm: \n- Vé vào cổng sự kiện\n- Quà tặng từ ban tổ chức\n- Voucher ưu đãi từ các đối tác',
      titleColor: Colors.green,
    ),
    TicketData(
      title: 'Ga-Vé VIP',
      price: '599.000đ',
      priceValue: 599000, // Giá trị số
      description:
          'Vé bao gồm: \n- Vé vào cổng sự kiện\n- Quà tặng VIP\n- Lối đi riêng\n- Voucher ưu đãi từ các đối tác',
      titleColor: Colors.orange,
    ),
    TicketData(
      title: 'Ga-Vé VVIP',
      price: '999.000đ',
      priceValue: 999000, // Giá trị số
      description:
          'Vé bao gồm: \n- Vé vào cổng sự kiện\n- Quà tặng VVIP\n- Lối đi riêng\n- Gặp gỡ nghệ sĩ\n- Voucher ưu đãi từ các đối tác',
      titleColor: Colors.purpleAccent,
    ),
    TicketData(
      title: 'Vé Sinh Viên',
      price: '199.000đ',
      priceValue: 199000, // Giá trị số
      description:
          'Vé bao gồm: \n- Vé vào cổng sự kiện\n- (Yêu cầu xuất trình thẻ sinh viên)',
      titleColor: Colors.blueAccent,
    ),
  ];

  // THÊM MỚI: Hàm callback để cập nhật tổng tiền
  void _updateTotal(int index, double itemTotal) {
    setState(() {
      _itemTotals[index] = itemTotal;
      // Tính lại tổng tiền
      _grandTotal = 0;
      print('_itemTotals: $_grandTotal');
      _itemTotals.forEach((key, value) {
        _grandTotal += value;
      });
      print('_itemTotals: $_grandTotal');
    });
  }

  @override
  Widget build(BuildContext context) {
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
        controller: _panelController,
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
          itemCount: ticketList.length,
          itemBuilder: (context, index) {
            final ticket = ticketList[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TicketExpansionItem(
                title: ticket.title,
                price: ticket.price,
                description: ticket.description,
                titleColor: ticket.titleColor,
                priceValue: ticket.priceValue, // Truyền giá trị số
                onItemTotalChanged: (itemTotal) {
                  // Truyền hàm callback
                  _updateTotal(index, itemTotal);
                },
              ),
            );
          },
        ),
        // Cả 2 panel `collapsed` và `panel` đều gọi hàm _buildPaymentButton
        // nhưng tôi sẽ cập nhật logic trực tiếp trong từng hàm cho rõ ràng
        collapsed: _buildCollapsedPanel(),
        panel: _buildPriceListPanel(),
      ),
    );
  }

  // CẬP NHẬT: _buildCollapsedPanel
  Widget _buildCollapsedPanel() {
    final bool hasTickets = _grandTotal > 0;
    final String buttonText = hasTickets
        ? 'Thanh toán ${_currencyFormat.format(_grandTotal)}'
        : 'Vui lòng chọn vé';
    final Color buttonColor = hasTickets
        ? Colors.green
        : const Color(0xFFDEE0E4);
    final Color textColor = hasTickets ? Colors.white : AppColors.grey;

    return GestureDetector(
      onTap: () => _panelController.open(),
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
            const Text(
              "Y-CONCERT BY YEAH1",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const Text(
              "14:00, 20 Tháng 12, 2025",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            AppElevatedButton(
              text: buttonText, // Cập nhật
              onPressed: () async {
                if (hasTickets) {
                  int amount = _grandTotal.toInt();
                  if (amount < 1000 || amount > 1000000) {
                    setState(() {
                      zpTransToken = "Invalid Amount";
                    });
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        });
                    var result = await createOrder(amount);
                    if (result != null) {
                    context.pop();
                      zpTransToken = result.zptranstoken;
                      print("zpTransToken $zpTransToken'.");
                      setState(() {
                        zpTransToken = result.zptranstoken;
                        showResult = true;
                      });
                    }
                  }
                  context.push(RouterPath.payment,extra: zpTransToken,);
                }
              },
              height: 40,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              textColor: textColor, // Cập nhật
              color: buttonColor, // Cập nhật
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

  // CẬP NHẬT: _buildPriceListPanel
  Widget _buildPriceListPanel() {
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
    );
    // Logic cho nút bấm
    final bool hasTickets = _grandTotal > 0;
    final String buttonText = 'Vui lòng chọn vé';
    final Color buttonColor = const Color(0xFFDEE0E4);
    final Color textColor = AppColors.grey;

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
          const Text(
            "Y-CONCERT BY YEAH1 Y-CONCERT BY YEAH1 Y-CONCERT BY YEAH1 Y-CONCERT BY YEAH1",
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
          const ListTile(
            leading: Icon(Icons.location_on, color: Colors.green, size: 20),
            title: Text(
              "VINHOMES OCEAN PARK 3",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          const ListTile(
            leading: Icon(Icons.calendar_today, color: Colors.green, size: 20),
            title: Text(
              "14:00 - 23:59, 20 Tháng 12, 2025",
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
              itemCount: ticketList.length,
              itemBuilder: (context, index) {
                final zone = ticketList[index];
                return ListTile(
                  title: Text(
                    zone.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: Text(
                    "${zone.price}",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          AppElevatedButton(
            text: buttonText, // Cập nhật
            onPressed: () {
              if (hasTickets) {
                // Xử lý logic thanh toán
                context.push(RouterPath.payment);
              }
            },
            height: 40,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            textColor: textColor, // Cập nhật
            color: buttonColor, // Cập nhật
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

// =======================================================================
// CẬP NHẬT: TicketExpansionItem
// =======================================================================

class TicketExpansionItem extends StatefulWidget {
  const TicketExpansionItem({
    super.key,
    required this.title,
    required this.price,
    required this.description,
    this.titleColor = Colors.green,
    required this.priceValue, // THÊM MỚI
    required this.onItemTotalChanged, // THÊM MỚI
  });

  final String title;
  final String price;
  final String description;
  final Color titleColor;
  final double priceValue; // THÊM MỚI
  final Function(double itemTotalPrice) onItemTotalChanged; // THÊM MỚI

  @override
  State<TicketExpansionItem> createState() => _TicketExpansionItemState();
}

class _TicketExpansionItemState extends State<TicketExpansionItem> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = 0;
  }

  void _increment() {
    setState(() {
      _quantity++;
    });
    // Gọi callback báo cho cha về tổng tiền CỦA RIÊNG MỤC NÀY
    widget.onItemTotalChanged(widget.priceValue * _quantity);
  }

  void _decrement() {
    if (_quantity > 0) {
      setState(() {
        _quantity--;
      });
      // Gọi callback báo cho cha về tổng tiền CỦA RIÊNG MỤC NÀY
      widget.onItemTotalChanged(widget.priceValue * _quantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    // (Build method giữ nguyên, không thay đổi)
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
                      widget.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: widget.titleColor,
                      ),
                    ),
                    Text(
                      widget.price,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                _buildQuantityStepper(),
              ],
            ),
            childrenPadding: const EdgeInsets.all(12),
            children: [
              Text(
                widget.description,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityStepper() {
    // (Widget này giữ nguyên, không thay đổi)
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
              color: _quantity > 0 ? Colors.black : Colors.grey,
            ),
            onPressed: _decrement,
            splashRadius: 20,
            constraints: const BoxConstraints(),
          ),
          Container(
            width: 30,
            alignment: Alignment.center,
            child: Text(
              '$_quantity',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.btnError),
            onPressed: _increment,
            splashRadius: 20,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
