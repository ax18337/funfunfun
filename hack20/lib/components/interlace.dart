import 'dart:math';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:hack20/components/background.dart';

import '../game_time.dart';

const BLACKISH = Color(0x99000000);
const BLUEISH = Color(0x99010b19);
const numOfStars = 200;

class Interlace {
  Interlace({
    @required this.gameTime,
    @required this.size,
  }) {
    _paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.bevel
      ..strokeWidth = size.toDouble()
      ..color = BLACKISH
      ..isAntiAlias = false;
    _path = _createPath();
  }

  final GameTime gameTime;
  final int size;
  Paint _paint;
  Path _path;

  void render(Canvas c) {
    switch (gameTime.mode) {
      case Mode.retro:
        _paint.color = BLACKISH;
        c.drawPath(_path, _paint);
        break;
      case Mode.future:
        _paint.color = BLUEISH;
        break;
    }
  }

  void update(double t) {}

  Path _createPath() {
    int lines = (gameTime.screenSize.height / size).ceil();
    double width = gameTime.screenSize.width;
    Path path = Path();
    for (var i = 0; i < lines; i++) {
      if (i % 2 == 1) {
        double y = (i + 0.5) * size;
        path.moveTo(0, y);
        path.lineTo(width, y);
      }
    }
    return path;
  }
}
