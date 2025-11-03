import 'package:event_go/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class RankedEventCard extends StatelessWidget {
  final int rank;
  final String imageUrl;
  final VoidCallback? onTap;
  final double imageWidth;
  final double imageHeight;

  const RankedEventCard({
    Key? key,
    required this.rank,
    required this.imageUrl,
    this.onTap,
    this.imageWidth = 200,
    this.imageHeight = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$rank',
            style: TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              height: 0.8,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3
                ..color = AppColors.primary,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: imageWidth,
              height: imageHeight,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.grey[800],
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.error, color: Colors.white54));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
