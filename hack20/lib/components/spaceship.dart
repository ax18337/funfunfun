import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/widgets.dart';

import '../game_time.dart';

const WHITE = Color(0xffffffff);
const GREEN = Color(0xff44ff66);

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
      ..color = GREEN
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3
      ..isAntiAlias = true;
    _glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = GREEN.withOpacity(0.6)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 4
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 50)
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
  Paint _glowPaint;
  Offset speed;
  double direction;

  Offset _center;
  Path _path;

  Offset get center {
    return _rect.center;
  }

  void render(Canvas c) {
    _drawShip(c);
  }

  void update(double t) {
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
      c.translate(_rect.center.dx, _rect.center.dy);
      c.rotate(direction + _radians(90));
      c.translate(-_rect.center.dx, -_rect.center.dy);
    }
    c.drawPath(_path, _backPaint);
    c.drawPath(_path, _glowPaint);
    c.drawPath(_path, _futurePaint);
    c.restore();
  }

  Path _createPath() {
    double width = _rect.width * 0.5;
    Path path = Path();
    path.moveTo(_rect.center.dx, _rect.top);
    path.lineTo(_rect.center.dx + width / 2, _rect.bottom);
    path.lineTo(_rect.center.dx, _rect.bottom - width * 0.4);
    path.lineTo(_rect.center.dx - width / 2, _rect.bottom);
    path.close();
    return path;
  }

  static const double SPEED_BOOST = 20;
  static const double ROTATION_ANGLE = 10;

  void right() {
    direction += _radians(ROTATION_ANGLE);
    if (direction > _radians(360)) {
      direction = direction - _radians(360);
    }
  }

  void left() {
    direction += _radians(-ROTATION_ANGLE);
    if (direction < 0) {
      direction = _radians(360) + direction;
    }
  }

  void down() {
    speed = speed.translate(-math.cos(direction) * SPEED_BOOST, -math.sin(direction) * SPEED_BOOST);
  }

  void up() {
    speed = speed.translate(math.cos(direction) * SPEED_BOOST, math.sin(direction) * SPEED_BOOST);
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
