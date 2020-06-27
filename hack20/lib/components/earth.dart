import 'dart:math';
import 'dart:ui';
import 'package:flutter/widgets.dart';

import '../game_time.dart';

const GREEN = Color(0xff7fff00);
const YELLOW = Color(0xffd9eb4b);
const ORANGE = Color(0xfffc6e22);
const RED = Color(0xff02b8a2);

const BLACK = Color(0xfff000000);
const WHITE = Color(0xfffffffff);

const numOfStars = 200;

class Earth {
  Earth({
    @required this.gameTime,
    @required this.speed,
    @required this.segments,
  }) {
    _rect = Rect.fromCircle(
      center: Offset(
          gameTime.screenSize.width * 0.5, gameTime.screenSize.height * 0.5),
      radius: min(gameTime.screenSize.width, gameTime.screenSize.height) * 0.2,
    );
    _areaPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = BLACK;
    _retroPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = WHITE
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.bevel
      ..strokeWidth = 1
      ..isAntiAlias = false;
    _futurePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = GREEN
      ..isAntiAlias = true;
    _angle = 0;
    _pitch = 0;
  }

  final GameTime gameTime;
  double speed;
  int segments;
  Rect _rect;
  Paint _areaPaint;
  Paint _retroPaint;
  Paint _futurePaint;
  double _angle;
  double _pitch;

  void render(Canvas c) {
    switch (gameTime.mode) {
      case Mode.retro:
        _renderRetro(c);
        break;
      case Mode.future:
        _renderFuture(c);
        break;
    }
  }

  void update(double t) {
    _angle = _angle + speed * t;
  }

  void _renderRetro(Canvas c) {
    // 1. background
    Offset center = _rect.center;
    double radius = _rect.width * 0.5;

    List<Offset> leftPoints = List<Offset>();
    List<Offset> rightPoints = List<Offset>();
    int mid = (segments / 2).floor();
    double segment = radius * 2 / segments;
    double y = _rect.top;

    double angle = 0;
    double angleSegment = pi / segments;
    for (var i = 0; i <= segments; i++) {
      double dx = sin(angle) * radius;
      double dy = -cos(angle) * radius;
      if (dx > 0) {
        leftPoints.add(Offset(_rect.center.dx - dx, _rect.center.dy + dy));
        rightPoints.add(Offset(_rect.center.dx + dx, _rect.center.dy + dy));
      } else {
        leftPoints.add(Offset(_rect.center.dx, _rect.center.dy + dy));
      }
      angle += angleSegment;
    }
    List<Offset> points = leftPoints + rightPoints.reversed.toList();

    Path area = Path();
    area.addPolygon(points, true);

    c.drawPath(area, _areaPaint);
    c.drawPath(area, _retroPaint);

    // meridians
  }

  void _renderFuture(Canvas c) {
    // 1. background
    Path area = Path();
    area.addOval(_rect);
    c.drawPath(area, _areaPaint);
    c.drawPath(area, _futurePaint);
  }
}
