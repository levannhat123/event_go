import 'package:flutter/material.dart';

class JaggedEdgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height);
    double toothHeight = 4.0;
    double toothWidth = 8.0;
    double gapWidth = 10.0;
    double cornerRadius = 1.0;
    if (cornerRadius > toothHeight / 2) {
      cornerRadius = toothHeight / 2;
    }
    if (cornerRadius > gapWidth / 2) {
      cornerRadius = gapWidth / 2;
    }
    double currentX = 0;
    while (currentX < size.width) {
      currentX += toothWidth;
      if (currentX > size.width) {
        path.lineTo(size.width, size.height);
        break;
      }
      path.lineTo(currentX, size.height);
      if (currentX + gapWidth > size.width) {
        path.lineTo(size.width, size.height);
        break;
      }
      path.lineTo(currentX, size.height - toothHeight + cornerRadius);
      path.arcToPoint(
        Offset(currentX + cornerRadius, size.height - toothHeight),
        radius: Radius.circular(cornerRadius),
        clockwise: false,
      );
      path.lineTo(currentX + gapWidth - cornerRadius, size.height - toothHeight);
      path.arcToPoint(
        Offset(currentX + gapWidth, size.height - toothHeight + cornerRadius),
        radius: Radius.circular(cornerRadius),
        clockwise: false,
      );
      path.lineTo(currentX + gapWidth, size.height);
      currentX += gapWidth;
    }
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
