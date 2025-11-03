import 'package:event_go/core/utils/format_price.dart';
import 'package:event_go/presentation/pages/home/event/widget/jagged_edge_clipper.dart';
import 'package:event_go/presentation/pages/home/event/widget/ticket_clipper.dart';
import 'package:flutter/material.dart';

class EventTicketCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String date;
  final String location;
  final String address;
  final double imageHeight;

  const EventTicketCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.date,
    required this.location,
    required this.address,
    this.imageHeight = 250.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: TicketClipper(notchCenterY: imageHeight),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF39383D),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [_buildImageSection(), _buildDetailsSection()],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipPath(
      clipper: JaggedEdgeClipper(),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: Image.network(
          imagePath,
          fit: BoxFit.cover,
          height: imageHeight,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => Container(
            height: imageHeight,
            color: Colors.grey[700],
            child: Icon(Icons.image_not_supported, color: Colors.white, size: 50),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            icon: Icons.calendar_today,
            iconColor: Color(0xFF6AFB92),
            primaryText: date,
            showSecondaryButton: true,
          ),
          const SizedBox(height: 15),
          _buildInfoRow(
            icon: Icons.location_on,
            iconColor: Color(0xFF6AFB92),
            primaryText: location,
            secondaryText: address,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String primaryText,
    String? secondaryText,
    bool showSecondaryButton = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[300], size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                FormatPrice.formatDate(primaryText),
                style: TextStyle(color: iconColor, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              if (secondaryText != null) ...[
                const SizedBox(height: 4),
                Text(
                  secondaryText,
                  style: TextStyle(color: Colors.grey[300], fontSize: 14, height: 1.4),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}


