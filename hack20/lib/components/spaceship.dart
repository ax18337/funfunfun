import 'dart:ui';
import 'package:flutter/widgets.dart';

import '../game_time.dart';

const COLOR = Color(0xff44ff66);

class Spaceship {
  Spaceship({@required this.gameTime, Offset center, double size}) {
    _rect = Rect.fromCenter(
      center: center,
      width: size,
      height: size,
    );
    _paint = Paint()
      ..style = PaintingStyle.fill
      ..color = COLOR
      ..isAntiAlias = true;
    speed = Offset.zero;
  }

  final GameTime gameTime;
  Rect _rect;
  Paint _paint;
  Offset speed;

  Offset get center {
    return _rect.center;
  }

  void render(Canvas c) {
    Path path = Path();
    path.addRect(_rect);
    c.drawShadow(path, COLOR, 0.0, false);
    c.drawRect(_rect, _paint);

    var builder = ParagraphBuilder(
        ParagraphStyle(textAlign: TextAlign.center, fontSize: 24, maxLines: 1))
      ..addText("speed x = ${speed.dx} y = ${speed.dy}");

    var paragraph = builder.build()..layout(ParagraphConstraints(width: 200));
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
        _rect.center.dy > gameTime.screenSize.height
    ) {
      _reset();
    }
  }

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
      center: Offset(gameTime.screenSize.width/2, gameTime.screenSize.height/2),
      width: _rect.width,
      height: _rect.height,
    );
    speed = Offset.zero;
  }
}
