import 'dart:math';
import 'dart:ui';
import 'package:flutter/widgets.dart';

import '../game_time.dart';

const GREEN = Color(0xff7fff00);
const YELLOW = Color(0xffd9eb4b);
const ORANGE = Color(0xfffc6e22);
const RED = Color(0xffce0000);

const BLACK = Color(0xfff000000);
const DEEPBLUE = Color(0xff010b19);
const WHITE = Color(0xfffffffff);

const numOfStars = 200;

class Earth {
  Earth({
    @required this.gameTime,
    @required this.speed,
    @required this.segments,
    @required this.gravity,
  }) {
    _rect = Rect.fromCircle(
      center: Offset(
          gameTime.screenSize.width * 0.5, gameTime.screenSize.height * 0.5),
      radius: min(gameTime.screenSize.width, gameTime.screenSize.height) * 0.1,
    );
    _areaPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = BLACK;
    _retroPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = WHITE
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.bevel
      ..strokeWidth = 2
      ..isAntiAlias = false;
    _futurePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = GREEN
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2
      ..isAntiAlias = true;
    _glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = GREEN.withOpacity(0.6)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3
      ..isAntiAlias = true;
    _angle = 0;
    _pitch = 0;
  }

  final GameTime gameTime;
  double speed;
  int segments;
  double gravity;
  Rect _rect;
  Paint _areaPaint;
  Paint _retroPaint;
  Paint _futurePaint;
  Paint _glowPaint;
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

    _areaPaint.color = BLACK;
    c.drawPath(area, _areaPaint);
    c.drawPath(area, _retroPaint);

    // meridians
  }

  void _renderFuture(Canvas c) {
    // 1. background
    Path area = Path();
    area.addOval(_rect);
    _areaPaint.color = DEEPBLUE;
    c.drawPath(area, _areaPaint);

    // neon blur
    _glowPaint.color = _futurePaint.color.withOpacity(0.1);
    _glowPaint.strokeWidth = 6;
    c.drawPath(area, _glowPaint);
    _glowPaint.color = _futurePaint.color.withOpacity(0.2);
    _glowPaint.strokeWidth = 5;
    c.drawPath(area, _glowPaint);
    _glowPaint.color = _futurePaint.color.withOpacity(0.3);
    _glowPaint.strokeWidth = 4;
    c.drawPath(area, _glowPaint);
    _glowPaint.color = _futurePaint.color.withOpacity(0.35);
    _glowPaint.strokeWidth = 3;
    c.drawPath(area, _glowPaint);

    c.drawPath(area, _futurePaint);
  }

  Offset gravityStrenght(Offset point) {
    Offset direction = _rect.center - point;
    double relativeDistance = direction.distance / _rect.width / 0.5;
    double strength = gravity / (relativeDistance * relativeDistance);
    var norm = 1 / direction.distance;
    direction = direction.scale(norm, norm);
    direction = direction.scale(strength, strength);
    return direction;
  }

  double distance(Offset point) {
    return (point - _rect.center).distance - _rect.width * 0.5;
  }

  Offset get center {
    return _rect.center;
  }

  Size get size {
    return _rect.size;
  }
}
