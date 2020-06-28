import 'dart:math';
import 'dart:ui';
import 'package:flutter/widgets.dart';

class Geometry {
  static Path simpleCircle(Rect rect, int segments) {
    double radius = min(rect.width, rect.height) * 0.5;

    List<Offset> leftPoints = List<Offset>();
    List<Offset> rightPoints = List<Offset>();

    double angle = 0;
    double angleSegment = pi / segments;
    for (var i = 0; i <= segments; i++) {
      double dx = sin(angle) * radius;
      double dy = -cos(angle) * radius;
      if (dx > 0) {
        leftPoints.add(Offset(rect.center.dx - dx, rect.center.dy + dy));
        rightPoints.add(Offset(rect.center.dx + dx, rect.center.dy + dy));
      } else {
        leftPoints.add(Offset(rect.center.dx, rect.center.dy + dy));
      }
      angle += angleSegment;
    }
    List<Offset> points = leftPoints + rightPoints.reversed.toList();

    Path path = Path();
    path.addPolygon(points, true);
    return path;
  }
}
