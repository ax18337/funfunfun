import 'dart:math';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:hack20/utils/geometry.dart';
import 'package:hack20/utils/neon.dart';
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
      Neon.render(c, _path, _futurePaint, 1);
    }
    c.restore();
  }

  void update(double t) {
    var gravity = gameTime.earth.gravityStrenght(center) +
        gameTime.moon.gravityStrenght(center);

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

    _futurePaint.color = color;
    _glowPaint.color = color.withOpacity(0.6);
  }

  Path _createPath() {
    return Geometry.randomPolygon(_rect, segments);
  }
}
