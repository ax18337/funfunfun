import 'dart:ui';
import 'package:flutter/widgets.dart';

import '../game_time.dart';

const WHITE = Color(0xffffffff);

class Star {
  Star(
      {@required this.gameTime,
      Offset center,
      double size,
      @required this.speed}) {
    _rect = Rect.fromCenter(
      center: center,
      width: size,
      height: size,
    );
    _paint = Paint()
      ..style = PaintingStyle.fill
      ..color = WHITE
      ..isAntiAlias = true;
  }

  final GameTime gameTime;
  Rect _rect;
  Paint _paint;
  Offset speed;

  Offset get center {
    return _rect.center;
  }

  void render(Canvas c) {
    if (gameTime.mode == Mode.retro) {
      Path path = Path();
      path.addRect(_rect);
      c.drawRect(_rect, _paint);
    } else {
      Path path = Path();
      path.addOval(_rect);
      c.drawShadow(path, WHITE, 0.0, false);
      c.drawOval(_rect, _paint);
    }
  }

  void update(double t) {
    _rect = Rect.fromCenter(
      center: Offset(
          _rect.center.dx + speed.dx * t, _rect.center.dy + speed.dy * t),
      width: _rect.width,
      height: _rect.height,
    );
  }
}
