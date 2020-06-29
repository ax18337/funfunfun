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

  static Path randomPolygon(Rect rect, int segments) {
    Random random = Random();

    // 1. background
    double radius = min(rect.width, rect.height) * 0.5;

    List<Offset> leftPoints = List<Offset>();
    List<Offset> rightPoints = List<Offset>();

    double angle = 0;
    double angleSegment = pi / segments;
    for (var i = 0; i <= segments; i++) {
      double randomRadius = radius * (0.3 + 0.7 * random.nextDouble());
      double dx = sin(angle) * randomRadius;
      double dy = -cos(angle) * randomRadius;
      leftPoints.add(Offset(rect.center.dx - dx, rect.center.dy + dy));
      if (dx > 0) {
        randomRadius = radius * (0.3 + 0.7 * random.nextDouble());
        dx = sin(angle) * randomRadius;
        dy = -cos(angle) * randomRadius;
        rightPoints.add(Offset(rect.center.dx + dx, rect.center.dy + dy));
      }
      angle += angleSegment;
    }
    List<Offset> points = leftPoints + rightPoints.reversed.toList();

    Path path = Path();
    path.addPolygon(points, true);
    return path;
  }

  static Path spaceship(Rect rect) {
    double width = rect.width * 0.6;
    Path path = Path();
    path.moveTo(rect.center.dx, rect.top);
    path.lineTo(rect.center.dx + width / 2, rect.bottom);
    path.lineTo(rect.center.dx, rect.bottom - width * 0.4);
    path.lineTo(rect.center.dx - width / 2, rect.bottom);
    path.close();
    return path;
  }

  static Path spaceshipThrust(Rect rect) {
    double width = rect.width * 0.25;
    Path path = Path();
    path.moveTo(rect.center.dx - width * 0.4, rect.bottom - width * 0.5);
    path.lineTo(rect.center.dx - width * 0.5, rect.bottom + width);
    path.lineTo(rect.center.dx - width * 0.25, rect.bottom);
    path.lineTo(rect.center.dx, rect.bottom + width);
    path.lineTo(rect.center.dx + width * 0.25, rect.bottom);
    path.lineTo(rect.center.dx + width * 0.5, rect.bottom + width);
    path.lineTo(rect.center.dx + width * 0.4, rect.bottom - width * 0.5);
    return path;
  }
}
