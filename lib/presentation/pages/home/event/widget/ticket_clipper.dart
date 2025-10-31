import 'package:flutter/material.dart';

class TicketClipper extends CustomClipper<Path> {
  final double notchCenterY;
  TicketClipper({required this.notchCenterY});

  @override
  Path getClip(Size size) {
    final path = Path();
    const double notchRadius = 16.0;
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, notchCenterY - notchRadius);
    path.arcToPoint(
      Offset(size.width, notchCenterY + notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, notchCenterY + notchRadius);
    path.arcToPoint(
      Offset(0, notchCenterY - notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant TicketClipper oldClipper) {
    return oldClipper.notchCenterY != notchCenterY;
  }
}
