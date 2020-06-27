import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/widgets.dart';

import '../game_time.dart';

const WHITE = Color(0xffffffff);
const GREEN = Color(0xff44ff66);

class Spaceship {
  Spaceship({@required this.gameTime, Offset center, double size}) {
    _rect = Rect.fromCenter(
      center: center,
      width: size,
      height: size,
    );
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
      ..isAntiAlias = false;
    speed = Offset.zero;
  }

  final GameTime gameTime;
  Rect _rect;
  Paint _retroPaint;
  Paint _futurePaint;

  Offset speed;

  Offset get center {
    return _rect.center;
  }

  void render(Canvas c) {
    _drawShip(c);

    var builder = ParagraphBuilder(
        ParagraphStyle(textAlign: TextAlign.center, fontSize: 24, maxLines: 1))
      ..addText("speed x = ${speed.dx.round()} y = ${speed.dy.round()} direction = ${speed.direction.round()}");

    var paragraph = builder.build()..layout(ParagraphConstraints(width: 500));
    c.drawParagraph(paragraph, Offset(20, 20));
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

  void _drawShipRetro(Canvas c) {
    c.save();

    double width = _rect.width * 0.4;
    Path path = Path();
    path.moveTo(_rect.center.dx, _rect.top);
    path.lineTo(_rect.center.dx + width / 2, _rect.bottom);
    path.lineTo(_rect.center.dx, _rect.bottom - width * 0.5);
    path.lineTo(_rect.center.dx - width / 2, _rect.bottom);
    path.close();

    if (speed.dx != 0 || speed.dy != 0) {
      c.translate(_rect.center.dx, _rect.center.dy);
      c.rotate(speed.direction+(90 * math.pi / 180));
      c.translate(-_rect.center.dx, -_rect.center.dy);
    }
    c.drawPath(path, _retroPaint);

    c.restore();
  }

  void _drawShipFuture(Canvas c) {}

  static const double SPEED_INCREASE_FACTOR = .4;
  static const double SPEED_BOOST = 20;
  static const double MAX_SPEED = 150;

  void right() {
    if (speed.dx == 0) {
      speed = speed.translate(SPEED_BOOST, 0);
    } else if (speed.dx > 0) {
      speed = speed.scale(1 + SPEED_INCREASE_FACTOR, 1);
      if (speed.dx > MAX_SPEED) {
        speed = Offset(MAX_SPEED, speed.dy);
      }
    } else {
      if (speed.dx > -SPEED_BOOST) {
        speed = speed.translate(-speed.dx, 0);
      } else {
        speed = speed.scale(1 - SPEED_INCREASE_FACTOR, 1);
      }
    }
  }

  void left() {
    if (speed.dx == 0) {
      speed = speed.translate(-SPEED_BOOST, 0);
    } else if (speed.dx < 0) {
      speed = speed.scale(1 + SPEED_INCREASE_FACTOR, 1);
      if (speed.dx < -MAX_SPEED) {
        speed = Offset(-MAX_SPEED, speed.dy);
      }
    } else {
      if (speed.dx < SPEED_BOOST) {
        speed = speed.translate(-speed.dx, 0);
      } else {
        speed = speed.scale(1 - SPEED_INCREASE_FACTOR, 1);
      }
    }
  }

  void down() {
    if (speed.dy == 0) {
      speed = speed.translate(0, SPEED_BOOST);
    } else if (speed.dy > 0) {
      speed = speed.scale(1, 1 + SPEED_INCREASE_FACTOR);
      if (speed.dy > MAX_SPEED) {
        speed = Offset(speed.dx, MAX_SPEED);
      }
    } else {
      if (speed.dy > -SPEED_BOOST) {
        speed = speed.translate(0, -speed.dy);
      } else {
        speed = speed.scale(1, 1 - SPEED_INCREASE_FACTOR);
      }
    }
  }

  void up() {
    if (speed.dy == 0) {
      speed = speed.translate(0, -SPEED_BOOST);
    } else if (speed.dy < 0) {
      speed = speed.scale(1, 1 + SPEED_INCREASE_FACTOR);
      if (speed.dy < -MAX_SPEED) {
        speed = Offset(speed.dx, -MAX_SPEED);
      }
    } else {
      if (speed.dy < SPEED_BOOST) {
        speed = speed.translate(0, -speed.dy);
      } else {
        speed = speed.scale(1, 1 - SPEED_INCREASE_FACTOR);
      }
    }
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
}
