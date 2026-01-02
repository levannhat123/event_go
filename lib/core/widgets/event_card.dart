import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/core/utils/format_price.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final String date;
  final String? status;

  final VoidCallback? onTap;
  final double width;
  final double height;

  const EventCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.date,
    this.status,
    this.onTap,
    this.height = 160,
    this.width = 250,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Stack(
                children: [
                  Image.network(
                    imageUrl,
                    height: height,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: height,
                        color: Colors.grey[800],
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.white54,
                          size: 48,
                        ),
                      );
                    },
                  ),
                  if (status == 'COMPLETED')
                    Positioned(
                      right: 0,

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status!),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          getEventStatusLabel(status!),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 45,
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${AppStrings.fromPrice}${FormatPrice.format(double.tryParse(price) ?? 0)}",
                    style: const TextStyle(
                      color: Color(0xFF23D288),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        FormatPrice.formatDate(date),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
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
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green; // Đang mở bán
      case 'INACTIVE':
        return Colors.blue; // Sắp diễn ra
      case 'COMPLETED':
        return Colors.orange; // Đã diễn ra
      default:
        return Colors.black54;
    }
  }

  String getEventStatusLabel(String status) {
    switch (status) {
      case 'ACTIVE':
        return 'Đang mở bán'; //
      case 'INACTIVE':
        return 'Sắp diễn ra'; // Sắp diễn ra
      case 'COMPLETED':
        return 'Đã diễn ra'; // Đã diễn ra
      default:
        return status;
    }
  }
}
