import 'package:flutter/material.dart';

class CustomHalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();

    // Rounded top-left start
    path.moveTo(0, 30);

    // Top-left radius
    path.arcToPoint(
      const Offset(30, 0),
      radius: const Radius.circular(30),
      clockwise: false,
    );

    // Top line
    path.lineTo(size.width, 0);

    // Right curved side
    path.quadraticBezierTo(
      size.width,
      size.height * 0.45,
      size.width * 0.85,
      size.height / 2,
    );

    // Bottom line
    path.lineTo(
      size.width * 0.15,
      size.height / 2,
    );

    // Left curved side
    path.quadraticBezierTo(
      0,
      size.height * 0.45,
      0,
      30,
    );

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}