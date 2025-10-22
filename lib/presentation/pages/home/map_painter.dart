import 'package:event_go/presentation/pages/home/zone_data.dart';
import 'package:flutter/material.dart';

class MapPainter extends CustomPainter {
  final Map<String, ZoneData> zones;
  final String? selectedZoneName;

  MapPainter({
    required this.zones,
    this.selectedZoneName,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final bool isASelectionActive = selectedZoneName != null;

    for (final zone in zones.values) {
      final bool isSelected = zone.name == selectedZoneName;
      Color zoneColor =
      zone.isAvailable ? zone.color : const Color(0xFF3A3A3C);
      Color strokeColor = Colors.white.withOpacity(0.5);
      Color textColor = Colors.white;
      double strokeWidth = 1.0;
      if (isASelectionActive && !isSelected) {
        paint.color = zoneColor.withOpacity(0.2);
        strokePaint.color = strokeColor.withOpacity(0.1);
        strokePaint.strokeWidth = strokeWidth;
        textColor = textColor.withOpacity(0.2);
      } else if (isSelected) {
        paint.color = zoneColor; // Giữ nguyên màu
        strokePaint.color = Colors.white; // Viền trắng sáng
        strokePaint.strokeWidth = 2.5; // Viền dày hơn
        textColor = Colors.white;
      } else {
        paint.color = zoneColor;
        strokePaint.color = strokeColor;
        strokePaint.strokeWidth = strokeWidth;
        textColor = Colors.white;
      }

      canvas.drawPath(zone.path, paint);
      canvas.drawPath(zone.path, strokePaint);

      final textStyle = TextStyle(
        color: textColor,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      );

      final textSpan = TextSpan(text: zone.name, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: zone.path.getBounds().width);

      final bounds = zone.path.getBounds();
      final offset = Offset(
        bounds.center.dx - (textPainter.width / 2),
        bounds.center.dy - (textPainter.height / 2),
      );
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) {
    return oldDelegate.selectedZoneName != selectedZoneName ||
        oldDelegate.zones != zones;
  }
}