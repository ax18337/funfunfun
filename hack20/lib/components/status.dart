import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hack20/utils/geometry.dart';

import '../game_time.dart';

const WHITE = Color(0xffffffff);
const GREEN = Color(0xff44ff66);

class Status {
  Status({@required this.gameTime}) {
    _rect = Rect.fromLTWH(
      2,
      2,
      300,
      50,
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
  }

  final GameTime gameTime;
  Rect _rect;
  Paint _retroPaint;
  Paint _futurePaint;
  Map<String, int> _data;

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
    // 1st block - lives

    double y = 10;

    TextSpan span = TextSpan(
        style: TextStyle(
          color: WHITE,
          fontSize: 24.0,
          fontFamily: 'Joystix',
        ),
        text: "SHIPS");
    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(c, Offset(y, (50 - tp.size.height) / 2));
    y += 10 + tp.size.width;

    for (var i = 0; i < 3; i++) {
      Path path = Geometry.spaceship(Rect.fromLTWH(y, 10, 30, 30));
      _retroPaint.style =
          gameTime.user.lives > i ? PaintingStyle.fill : PaintingStyle.stroke;
      c.drawPath(path, _retroPaint);
      y += 40;
    }

    _retroPaint.style = PaintingStyle.stroke;
    c.drawRect(Rect.fromLTRB(2, 2, y - 2, 48), _retroPaint);

    // 2nd block - earth

    double yStart = y;

    y += 10;

    span = TextSpan(
        style: TextStyle(
          color: WHITE,
          fontSize: 24.0,
          fontFamily: 'Joystix',
        ),
        text: "EARTH");
    tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(c, Offset(y, (50 - tp.size.height) / 2));
    y += 10 + tp.size.width;

    _retroPaint.style = PaintingStyle.stroke;
    c.drawRect(Rect.fromLTWH(y, 10, 150, 30), _retroPaint);
    _retroPaint.style = PaintingStyle.fill;
    c.drawRect(
        Rect.fromLTWH(y, 10, 150 * gameTime.trashPile.status, 30), _retroPaint);
    y += 160;

    _retroPaint.style = PaintingStyle.stroke;
    c.drawRect(Rect.fromLTRB(yStart + 2, 2, y - 2, 48), _retroPaint);

    // 3rd block - score

    yStart = y;

    y += 10;

    span = TextSpan(
        style: TextStyle(
          color: WHITE,
          fontSize: 24.0,
          fontFamily: 'Joystix',
        ),
        text: "SCORE");
    tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(c, Offset(y, (50 - tp.size.height) / 2));
    y += 10 + tp.size.width;

    span = TextSpan(
        style: TextStyle(
          color: WHITE,
          fontSize: 24.0,
          fontFamily: 'Joystix',
        ),
        text: "${gameTime.trashPile.score}");
    tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(c, Offset(y, (50 - tp.size.height) / 2));
    y += 10 + 100;

    _retroPaint.style = PaintingStyle.stroke;
    c.drawRect(Rect.fromLTRB(yStart + 2, 2, y - 2, 48), _retroPaint);

    // c.drawRect(_rect, _retroPaint);
  }

  void _drawFuture(Canvas c) {}
}
