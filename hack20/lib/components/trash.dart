import 'dart:math';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'dart:developer' as dev;

import '../game_time.dart';

const WHITE = Color(0xffffffff);
const BLACK = Color(0xff000000);

const GREEN = Color(0xff7fff00);
const YELLOW = Color(0xffd9eb4b);
const ORANGE = Color(0xfffc6e22);
const RED = Color(0xffce0000);

const segments = 5;

class Trash {
  Trash(
      {@required this.gameTime,
      Offset center,
      double size,
      @required this.speed}) {
    _rect = Rect.fromCenter(
      center: center,
      width: size + 20,
      height: size + 20,
    );
    _backPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = BLACK
      ..isAntiAlias = false;
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
      ..isAntiAlias = false;
    _glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = GREEN.withOpacity(0.6)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3
      // ..maskFilter = MaskFilter.blur(BlurStyle.normal, 50)
      ..isAntiAlias = true;
    _center = center;
    _path = _createPath();
  }

  final GameTime gameTime;
  Rect _rect;
  Paint _backPaint;
  Paint _retroPaint;
  Paint _futurePaint;
  Paint _glowPaint;
  Offset speed;

  Path _path;
  Offset _center;

  Offset get center {
    return _rect.center;
  }

  int get size {
    return _rect.width.floor();
  }

  void render(Canvas c) {
    c.save();
    Offset translation = _rect.center - _center;
    c.translate(translation.dx, translation.dy);
    c.drawPath(_path, _backPaint);
    if (gameTime.mode == Mode.retro) {
      c.drawPath(_path, _retroPaint);
    } else {
      // neon blur
      _glowPaint.color = _futurePaint.color.withOpacity(0.1);
      _glowPaint.strokeWidth = 6;
      c.drawPath(_path, _glowPaint);
      _glowPaint.color = _futurePaint.color.withOpacity(0.2);
      _glowPaint.strokeWidth = 5;
      c.drawPath(_path, _glowPaint);
      _glowPaint.color = _futurePaint.color.withOpacity(0.3);
      _glowPaint.strokeWidth = 4;
      c.drawPath(_path, _glowPaint);
      _glowPaint.color = _futurePaint.color.withOpacity(0.35);
      _glowPaint.strokeWidth = 3;
      c.drawPath(_path, _glowPaint);

      c.drawPath(_path, _futurePaint);
    }
    c.restore();
  }

  void update(double t) {
    var gravity = gameTime.earth.gravityStrenght(center);

    _rect = Rect.fromCenter(
      center: Offset(
        _rect.center.dx + speed.dx * t + gravity.dx * t,
        _rect.center.dy + speed.dy * t + gravity.dy * t,
      ),
      width: _rect.width,
      height: _rect.height,
    );

    Color color = GREEN;
    double max = (min(gameTime.screenSize.width, gameTime.screenSize.height) -
            gameTime.earth.size.width) *
        0.5;
    double distance = gameTime.earth.distance(center);
    double position = distance / max * 4;
    int step = position.floor();
    double progress = position - step;
    switch (step) {
      case 0:
        color = Color.lerp(RED, ORANGE, progress);
        break;
      case 1:
        color = Color.lerp(ORANGE, YELLOW, progress);
        break;
      case 2:
        color = Color.lerp(YELLOW, GREEN, progress);
        break;
    }

    // if (distance < max * 0.25) {
    //   color = RED;
    // } else if (distance < max * 0.5) {
    //   color = ORANGE;
    // } else if (distance < max * 0.75) {
    //   color = YELLOW;
    // }
    _futurePaint.color = color;
    _glowPaint.color = color.withOpacity(0.6);
  }

  Path _createPath() {
    Random random = Random();

    // 1. background
    double radius = _rect.width * 0.5;

    List<Offset> leftPoints = List<Offset>();
    List<Offset> rightPoints = List<Offset>();

    double angle = 0;
    double angleSegment = pi / segments;
    for (var i = 0; i <= segments; i++) {
      double randomRadius = radius * (0.3 + 0.7 * random.nextDouble());
      double dx = sin(angle) * randomRadius;
      double dy = -cos(angle) * randomRadius;
      if (dx > 0) {
        leftPoints.add(Offset(_center.dx - dx, _center.dy + dy));
        rightPoints.add(Offset(_center.dx + dx, _center.dy + dy));
      } else {
        leftPoints.add(Offset(_center.dx, _center.dy + dy));
      }
      angle += angleSegment;
    }
    List<Offset> points = leftPoints + rightPoints.reversed.toList();

    Path path = Path();
    path.addPolygon(points, true);
    return path;
  }
}
