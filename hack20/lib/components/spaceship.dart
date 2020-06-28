import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:hack20/utils/geometry.dart';
import 'package:hack20/utils/neon.dart';

import '../game_time.dart';

const WHITE = Color(0xffffffff);
const PURPLE = Color(0xff7d12ff);

const BLACK = Color(0xff000000);

class Spaceship {
  Spaceship({@required this.gameTime, Offset center, double size}) {
    _rect = Rect.fromCenter(
      center: center,
      width: size,
      height: size,
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
      ..color = PURPLE
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2
      ..isAntiAlias = true;
    _center = center;
    _path = _createPath();
    speed = Offset.zero;
    direction = _radians(270);
  }

  final GameTime gameTime;
  Rect _rect;
  Paint _backPaint;
  Paint _retroPaint;
  Paint _futurePaint;
  Offset speed;
  double direction;

  Offset _center;
  Path _path;

  double _thrust = 0;
  double _directionAngle = 0;

  Offset get center {
    return _rect.center;
  }

  void render(Canvas c) {
    _drawShip(c);
  }

  void update(double t) {
    // direction
    direction += _radians(_directionAngle);
    if (direction > _radians(360)) {
      direction = direction - _radians(360);
    }
    if (direction < 0) {
      direction = _radians(360) + direction;
    }

    // force
    Offset gravity = Offset.zero;
    if (gameTime.earth.distance(_rect.center) > 0 &&
        gameTime.moon.distance(_rect.center) > 0) {
      gravity = gameTime.earth.gravityStrenght(_rect.center) +
          gameTime.moon.gravityStrenght(_rect.center);
    }
    Offset thrust = Offset.fromDirection(direction, _thrust);
    Offset force = gravity + thrust;
    speed = speed.translate(force.dx * t, force.dy * t);

    _rect = Rect.fromCenter(
      center: Offset(
          _rect.center.dx + speed.dx * t, _rect.center.dy + speed.dy * t),
      width: _rect.width,
      height: _rect.height,
    );

    if (_rect.center.dx < 0 ||
        _rect.center.dx > gameTime.screenSize.width ||
        _rect.center.dy < 0 ||
        _rect.center.dy > gameTime.screenSize.height) {
      _reset();
    }
  }

  void _drawShip(Canvas c) {
    switch (gameTime.mode) {
      case Mode.retro:
        _drawShipRetro(c);
        break;
      case Mode.future:
        _drawShipFuture(c);
        break;
    }
  }

  static double _radians(double angle) {
    return angle * math.pi / 180;
  }

  void _drawShipRetro(Canvas c) {
    c.save();

    var translate = _rect.center - _center;
    c.translate(translate.dx, translate.dy);
    if (direction != _radians(270)) {
      c.translate(_center.dx, _center.dy);
      c.rotate(direction + _radians(90));
      c.translate(-_center.dx, -_center.dy);
    }
    c.drawPath(_path, _backPaint);
    c.drawPath(_path, _retroPaint);
    c.restore();
  }

  void _drawShipFuture(Canvas c) {
    c.save();

    var translate = _rect.center - _center;
    c.translate(translate.dx, translate.dy);
    if (direction != _radians(270)) {
      c.translate(_center.dx, _center.dy);
      c.rotate(direction + _radians(90));
      c.translate(-_center.dx, -_center.dy);
    }
    c.drawPath(_path, _backPaint);

    Neon.render(c, _path, _futurePaint, 1);

    c.restore();
  }

  Path _createPath() {
    return Geometry.spaceship(_rect);
  }

  static const double SPEED_BOOST = 350;
  static const double ROTATION_ANGLE = 5;
  static const double MAX_SPEED = 150;

  void right(bool keyDown) {
    _directionAngle = keyDown ? ROTATION_ANGLE : 0;
  }

  void left(bool keyDown) {
    _directionAngle = keyDown ? -ROTATION_ANGLE : 0;
  }

  void down(bool keyDown) {
    _thrust = keyDown ? -SPEED_BOOST : 0;
  }

  void up(bool keyDown) {
    _thrust = keyDown ? SPEED_BOOST : 0;
  }

  void _reset() {
    _rect = Rect.fromCenter(
      center:
          Offset(gameTime.screenSize.width / 2, gameTime.screenSize.height / 2),
      width: _rect.width,
      height: _rect.height,
    );
    speed = Offset.zero;
  }

  double distance(Offset point) {
    return (point - _rect.center).distance - _rect.width;
  }
}
