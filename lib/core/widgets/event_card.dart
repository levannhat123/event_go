import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/utils/format_price.dart';
import 'package:flutter/material.dart';

// Widget Card có thể tái sử dụng
class EventCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final String date;
  final VoidCallback? onTap;
  final double width;
  final double height;


  const EventCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.date,
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
              child: Image.network(
                imageUrl,
                height: height,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 160,
                    color: Colors.grey[800],
                    child: const Icon(Icons.broken_image, color: Colors.white54, size: 48),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 45,
                    child: Align(
                      alignment: Alignment.topLeft,
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
                  ),
                  const SizedBox(height: 8),

                  // Giá vé
                  Text(
                    "Từ ${FormatPrice.format(double.tryParse(price) ?? 0)}",
                    style: const TextStyle(
                      color: Color(0xFF23D288),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: Colors.white70, size: 14),
                      const SizedBox(width: 6),
                      Text(FormatPrice.formatDate(date), style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
}
