import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../utils/neon.dart';
import '../game_time.dart';

const WHITE = Color(0xffffffff);
const GREEN = Color(0xff44ff66);

const BLACK = Color(0xfff000000);
const DEEPBLUE = Color(0xff010b19);

class Level {
  Level({@required this.gameTime}) {
    _rect = Rect.fromCenter(
      center: Offset(
          gameTime.screenSize.width * 0.5, gameTime.screenSize.height * 0.5),
      width: 100,
      height: 100,
    );
    _backPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = BLACK;
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
  }

  final GameTime gameTime;
  Rect _rect;
  Paint _backPaint;
  Paint _retroPaint;
  Paint _futurePaint;

  Offset get center {
    return _rect.center;
  }

  void render(Canvas c) {
    switch (gameTime.mode) {
      case Mode.retro:
        _drawRetro(c);
        break;
      case Mode.future:
        _drawFuture(c);
        break;
    }
  }

  void update(double t) {}

  void _drawRetro(Canvas c) {
    TextSpan span = TextSpan(
        style: TextStyle(
          color: WHITE,
          fontSize: 24.0,
          fontFamily: 'Joystix',
        ),
        text: "LEVEL ${gameTime.user.level}");
    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    Rect box = Rect.fromLTWH(
      _rect.center.dx - tp.size.width * 0.5,
      _rect.center.dy - tp.size.height * 0.5,
      tp.size.width,
      tp.size.height,
    );

    c.drawRect(box.inflate(4), _backPaint);
    _retroPaint.style = PaintingStyle.stroke;
    c.drawRect(box.inflate(4), _retroPaint);

    tp.paint(c, box.topLeft);
  }

  void _drawFuture(Canvas c) {
    TextSpan span = TextSpan(
        style: TextStyle(
          color: WHITE,
          fontSize: 24.0,
          fontFamily: 'Library-3-am-soft',
        ),
        text: "LEVEL ${gameTime.user.level}");
    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    Rect box = Rect.fromLTWH(
      _rect.center.dx - tp.size.width * 0.5,
      _rect.center.dy - tp.size.height * 0.5,
      tp.size.width,
      tp.size.height,
    );

    c.drawRect(box.inflate(4), _backPaint);
    Path path = Path()..addRect(box.inflate(4));
    Neon.render(c, path, _futurePaint, 1);

    c.drawRect(box.inflate(4), _backPaint);
    _retroPaint.style = PaintingStyle.stroke;
    c.drawRect(box.inflate(4), _retroPaint);

    tp.paint(c, box.topLeft);
  }
}
