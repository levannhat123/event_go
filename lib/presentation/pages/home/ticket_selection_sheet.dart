import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'zone_data.dart';

class TicketSelectionSheet extends StatefulWidget {
  final ZoneData zone;

  const TicketSelectionSheet({super.key, required this.zone});

  @override
  State<TicketSelectionSheet> createState() => _TicketSelectionSheetState();
}

class _TicketSelectionSheetState extends State<TicketSelectionSheet> {
  int _quantity = 0;
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  void _increment() {
    setState(() {
      _quantity++;
    });
  }

  void _decrement() {
    if (_quantity > 0) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        color: const Color(0xFF323138),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Wrap(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Khu: ${widget.zone.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  "Lưu ý: Bạn chỉ có thể chọn vé trong 1 khu vực",
                  style: const TextStyle(
                    color: Color(0xFFA75D24),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Khu: ${widget.zone.name}',
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        currencyFormatter.format(widget.zone.price),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  // Nút trừ
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 16,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                        ),
                        onPressed: _decrement,
                      ),
                      Container(
                        width: 60,
                        alignment: Alignment.center,
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Color(0xFF2dc275),
                        ),
                        onPressed: _increment,
                      ),
                    ],
                  ),
                ],
              ),

              TextButton(
                onPressed: () {
              context.pop();
                },
                child: const Center(
                  child: Text(
                    'Chọn khu vực khác',
                    style: TextStyle(color: Colors.greenAccent, fontSize: 16),
                  ),
                ),
              ),
              AppElevatedButton(
                text: 'Vui lòng chọn vé',
                onPressed: () {},
                height: 40,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                textColor: AppColors.grey,
                color: Color(0xFFDEE0E4),
                fontSize: 15.0,
                borderColor: AppColors.transparent,
                splashColor: AppColors.transparent,
                highlightColor: AppColors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
