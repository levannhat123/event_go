import 'package:event_go/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Cần thêm package intl: ^0.18.1 vào pubspec.yaml

class TicketCard extends StatefulWidget {
  final String title;
  final String statusText;
  final Color statusColor;
  final double price;
  final Function(int) onQuantityChanged;
  final VoidCallback onDetailsPressed;
  final int initialQuantity;

  const TicketCard({
    Key? key,
    required this.title,
    required this.statusText,
    this.statusColor = const Color(0xFFE0F7E0),
    required this.price,
    required this.onQuantityChanged,
    required this.onDetailsPressed,
    this.initialQuantity = 0,
  }) : super(key: key);

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  late int _quantity;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
  );

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  void _increment() {
    setState(() {
      _quantity++;
    });
    widget.onQuantityChanged(_quantity);
  }

  void _decrement() {
    if (_quantity > 0) {
      setState(() {
        _quantity--;
      });
      widget.onQuantityChanged(_quantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 130, // Chiều cao cố định cho card
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.8),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          // Nội dung chính của card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),
                                // Chip "Còn vé"
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.statusColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    widget.statusText,
                                    style: TextStyle(
                                      color: Colors.green[800],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            _buildQuantityStepper(),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _currencyFormat.format(widget.price),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8),
                            // Nút "Chi tiết"
                            InkWell(
                              onTap: widget.onDetailsPressed,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Chi tiết",
                                    style: TextStyle(
                                      color: AppColors.btnError,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: AppColors.btnError,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget riêng cho bộ đếm số lượng
  Widget _buildQuantityStepper() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nút trừ
          IconButton(
            icon: Icon(
              Icons.remove,
              color: _quantity > 0 ? Colors.black : Colors.grey,
            ),
            onPressed: _decrement,
            splashRadius: 20,
            constraints: BoxConstraints(),
          ),
          // Số lượng
          Container(
            width: 30, // Đảm bảo số 0 ở giữa
            alignment: Alignment.center,
            child: Text(
              '$_quantity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          // Nút cộng
          IconButton(
            icon: Icon(Icons.add, color: AppColors.btnError),
            onPressed: _increment,
            splashRadius: 20,
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
