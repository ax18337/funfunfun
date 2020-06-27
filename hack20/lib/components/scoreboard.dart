import 'dart:ui';
import 'package:flutter/widgets.dart';

import '../game_time.dart';

const WHITE = Color(0xffffffff);
const GREEN = Color(0xff44ff66);

class Scoreboard {
  Scoreboard({@required this.gameTime}) {
    _rect = Rect.fromLTWH(
      0,
      0,
      gameTime.screenSize.width,
      gameTime.screenSize.height,
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
    _drawScoreboard(c);
  }

  void update(double t) {}

  void _drawScoreboard(Canvas c) {
    switch (gameTime.mode) {
      case Mode.retro:
        _drawScoreboardRetro(c);
        break;
      case Mode.future:
        _drawScoreboardFuture(c);
        break;
    }
  }

  void _drawScoreboardRetro(Canvas c) {
    c.save();

    double width = _rect.width * 0.4;
    Path path = Path();
    path.moveTo(_rect.center.dx, _rect.top);
    path.lineTo(_rect.center.dx + width / 2, _rect.bottom);
    path.lineTo(_rect.center.dx, _rect.bottom - width * 0.5);
    path.lineTo(_rect.center.dx - width / 2, _rect.bottom);
    path.close();
    c.drawPath(path, _retroPaint);

    c.restore();

    var builder = ParagraphBuilder(
        ParagraphStyle(textAlign: TextAlign.center, fontSize: 24, maxLines: 1))
      ..addText("speed x = ${speed.dx} y = ${speed.dy}");

    var paragraph = builder.build()..layout(ParagraphConstraints(width: 200));
    c.drawParagraph(paragraph, Offset(20, 20));
  }

  void _drawScoreboardFuture(Canvas c) {}
}
