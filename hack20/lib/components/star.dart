import 'dart:ui';
import 'package:flutter/widgets.dart';

import '../game_time.dart';

const WHITE = Color(0xffffffff);
const LIGHTYELLOW = Color(0xfffeffe2);

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
    _glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = LIGHTYELLOW.withOpacity(0.6)
      ..isAntiAlias = true;
  }

  final GameTime gameTime;
  Rect _rect;
  Paint _paint;
  Paint _glowPaint;
  Offset speed;

  Offset get center {
    return _rect.center;
  }

  void render(Canvas c) {
    if (gameTime.mode == Mode.retro) {
      _paint.color = WHITE;
      c.drawRect(_rect, _paint);
    } else {
      _paint.color = LIGHTYELLOW;
      Path path = Path();
      path.addOval(_rect);

      _glowPaint.color = LIGHTYELLOW.withOpacity(0.1);
      c.drawOval(_rect.inflate(4), _glowPaint);
      _glowPaint.color = LIGHTYELLOW.withOpacity(0.2);
      c.drawOval(_rect.inflate(3), _glowPaint);
      _glowPaint.color = LIGHTYELLOW.withOpacity(0.3);
      c.drawOval(_rect.inflate(2), _glowPaint);
      _glowPaint.color = LIGHTYELLOW.withOpacity(0.35);
      c.drawOval(_rect.inflate(1), _glowPaint);

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
