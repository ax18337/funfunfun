import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hack20/utils/neon.dart';

import '../game_time.dart';

const WHITE = Color(0xffffffff);
const GREEN = Color(0xff44ff66);

const BLACK = Color(0xfff000000);
const DEEPBLUE = Color(0xff010b19);

class Welcome {
  Welcome({@required this.gameTime}) {
    _rect = Rect.fromLTWH(
      0,
      0,
      gameTime.screenSize.width,
      gameTime.screenSize.height,
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
    // instructions
    double y = _drawInstructions(c, WHITE, 'Joystix') + 30;

    // name input
    TextSpan span = TextSpan(
        style: TextStyle(
          color: WHITE,
          fontSize: 24.0,
          fontFamily: 'Joystix',
        ),
        text: "Name: ${gameTime.user.name}");
    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    Rect box = Rect.fromLTWH(
      _rect.center.dx - tp.size.width * 0.5,
      y,
      tp.size.width,
      tp.size.height,
    );

    c.drawRect(box.inflate(4), _backPaint);
    _retroPaint.style = PaintingStyle.stroke;
    c.drawRect(box.inflate(4), _retroPaint);

    tp.paint(c, box.topLeft);
  }

  void _drawFuture(Canvas c) {
    // instructions
    double y = _drawInstructions(c, GREEN, 'Library-3-am-soft') + 30;

    TextSpan span = TextSpan(
        style: TextStyle(
          color: GREEN,
          fontSize: 24.0,
          fontFamily: 'Library-3-am-soft',
        ),
        text: "Name: ${gameTime.user.name}");
    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    Rect box = Rect.fromLTWH(
      _rect.center.dx - tp.size.width * 0.5,
      y,
      tp.size.width,
      tp.size.height,
    );

    c.drawRect(box.inflate(4), _backPaint);
    Path path = Path()..addRect(box.inflate(4));
    Neon.render(c, path, _futurePaint, 1);

    tp.paint(c, box.topLeft);
  }

  double _drawInstructions(Canvas c, Color textColor, String fontFamily) {
    TextSpan span = TextSpan(
        style: TextStyle(
          color: textColor,
          fontSize: 24.0,
          fontFamily: fontFamily,
        ),
        text: _text);
    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout(maxWidth: _rect.width * 0.8);
    Rect box = Rect.fromLTWH(
      _rect.center.dx - tp.size.width * 0.5,
      30,
      tp.size.width,
      tp.size.height,
    );
    tp.paint(c, box.topLeft);

    return 30 + tp.height;
  }

  String _text = """Controls
w - forward thrust
s - bacward thrust
a - rotate left
b - rotate right

Options
r - retro mode
f - neon mode

Enter your name in case you end up in the hall of fame.""";
}
