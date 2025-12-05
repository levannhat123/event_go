import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/utils/format_price.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';

class TicketItemRow extends StatelessWidget {
  final String ticketName;
  final String price;
  final bool isSoldOut;

  const TicketItemRow({
    Key? key,
    required this.ticketName,
    required this.price,
    this.isSoldOut = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.chevron_right,
                color: Colors.grey[600],
                size: AppSizes.size20,
              ),
              SizedBox(width: AppSizes.size8),
              Flexible(
                child: Text(
                  ticketName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizes.size12,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        isSoldOut
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    FormatPrice.format(double.tryParse(price) ?? 0),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                      fontSize: AppSizes.size12,
                    ),
                  ),
                  SizedBox(height: AppSizes.size4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFCDD2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Hết vé',
                      style: TextStyle(
                        color: Color(0xFFD32F2F),
                        fontWeight: FontWeight.w600,
                        fontSize: AppSizes.size12,
                      ),
                    ),
                  ),
                ],
              )
            : Text(
                FormatPrice.format(double.tryParse(price) ?? 0),
                style: TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.size12,
                ),
              ),
      ],
    );
  }
}
