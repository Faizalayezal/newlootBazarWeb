import 'package:flutter/material.dart';

class CategoryCurveClipper extends CustomClipper<Path> {
  final double startXRatio;
  final double endYRatio;

  CategoryCurveClipper({
    this.startXRatio = 0.45,
    this.endYRatio = 0.15,
  });

  @override
  Path getClip(Size size) {
    Path path = Path();

    // 1. Move to the curve start point on the bottom edge
    path.moveTo(size.width * startXRatio, size.height);

    // 2. Draw a smooth Quadratic Bezier Curve to the right edge.
    // By setting the control point X to match start X, and control point Y to match end Y,
    // we guarantee perfect perpendicular tangents (smooth entry and exit curves)!
    path.quadraticBezierTo(
      size.width * startXRatio,  // Control Point X
      size.height * endYRatio,   // Control Point Y
      size.width,                // End Point X (right edge)
      size.height * endYRatio,   // End Point Y
    );

    // 3. Draw a line to the bottom-right corner to close the shape
    path.lineTo(size.width, size.height);

    // 4. Close path back to the starting point
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CategoryCurveClipper oldClipper) {
    return oldClipper.startXRatio != startXRatio ||
        oldClipper.endYRatio != endYRatio;
  }
}