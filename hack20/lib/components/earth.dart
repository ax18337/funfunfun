import 'dart:math';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:hack20/utils/neon.dart';

import '../game_time.dart';
import 'geography.dart';

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
  }

  final GameTime gameTime;
  double speed;
  int segments;
  double gravity;
  Rect _rect;
  Paint _areaPaint;
  Paint _retroPaint;
  Paint _futurePaint;

  Americas _americas = Americas();
  AfricaAsiaEurope _africaAsiaEurope = AfricaAsiaEurope();
  Arctic _arctic = Arctic();
  Greenland _greenland = Greenland();
  Brittain _brittain = Brittain();
  Cuba _cuba = Cuba();
  Caribbeans _caribbeans = Caribbeans();

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

  void update(double t) {}

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
    _retroPaint.strokeWidth = 2;
    c.drawPath(area, _retroPaint);

    // continents

    c.save();

    double scale = _rect.width / _americas.size.width;
    Offset translation = Offset(
        _rect.center.dx - _americas.size.width * 0.5 * scale,
        _rect.center.dy - _americas.size.height * 0.5 * scale);
    c.translate(translation.dx, translation.dy);
    c.scale(scale);

    _retroPaint.strokeWidth = 2 / scale;
    c.drawPath(_americas.path, _retroPaint);
    c.drawPath(_africaAsiaEurope.path, _retroPaint);
    c.drawPath(_arctic.path, _retroPaint);
    c.drawPath(_greenland.path, _retroPaint);
    c.drawPath(_brittain.path, _retroPaint);
    c.drawPath(_cuba.path, _retroPaint);
    c.drawPath(_caribbeans.path, _retroPaint);

    c.restore();
  }

  void _renderFuture(Canvas c) {
    // 1. background
    Path area = Path();
    area.addOval(_rect);
    _areaPaint.color = DEEPBLUE;
    c.drawPath(area, _areaPaint);

    // outline
    Neon.render(c, area, _futurePaint, 1);

    // continents
    c.save();

    double scale = _rect.width / _americas.size.width;
    Offset translation = Offset(
        _rect.center.dx - _americas.size.width * 0.5 * scale,
        _rect.center.dy - _americas.size.height * 0.5 * scale);
    c.translate(translation.dx, translation.dy);
    c.scale(scale);

    Neon.render(c, _americas.path, _futurePaint, scale);
    Neon.render(c, _africaAsiaEurope.path, _futurePaint, scale);
    Neon.render(c, _arctic.path, _futurePaint, scale);
    Neon.render(c, _greenland.path, _futurePaint, scale);
    Neon.render(c, _brittain.path, _futurePaint, scale);
    Neon.render(c, _cuba.path, _futurePaint, scale);
    Neon.render(c, _caribbeans.path, _futurePaint, scale);

    c.restore();
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
