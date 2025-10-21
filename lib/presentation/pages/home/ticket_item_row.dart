import 'package:event_go/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

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
              Icon(Icons.chevron_right, color: Colors.grey[600], size: 20),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  ticketName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
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
              price,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: Color(0xFFFFCDD2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Hết vé',
                style: TextStyle(
                  color: Color(0xFFD32F2F),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        )
            : Text(
          price,
          style: TextStyle(
            color: AppColors.green,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}