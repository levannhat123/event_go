import 'package:flutter/material.dart';
import 'package:event_go/core/constants/app_sizes.dart';

class LocationCard extends StatelessWidget {
  final String imageUrl;
  final String locationName;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const LocationCard({
    Key? key,
    required this.imageUrl,
    required this.locationName,
    this.onTap,
    this.width = 200,
    this.height = 260,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: Colors.grey[800],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image, color: Colors.white54, size: 40),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.size12),
                child: Text(
                  locationName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppSizes.size18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
