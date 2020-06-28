import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../game_time.dart';

const WHITE = Color(0xffffffff);
const GREEN = Color(0xff44ff66);

class Entry {
  Entry({@required this.name, this.score});
  final String name;
  final int score;
}

class Intro {
  Intro({@required this.gameTime}) {
    _rect = Rect.fromLTWH(
      100,
      50,
      gameTime.screenSize.width - 200,
      gameTime.screenSize.height - 100,
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
  double time = 0;

  Offset get center {
    return _rect.center;
  }

  void render(Canvas c) {
    _drawScoreboard(c);
  }

  void update(double t) {
    time += t;
  }

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
    c.drawRect(_rect, _retroPaint);
    c.clipRect(_rect.inflate(-20));

    c.translate(0, _rect.height * (1 - time / 20));

    TextSpan span = TextSpan(
        style: TextStyle(
          color: WHITE,
          fontSize: 24.0,
          fontFamily: 'Joystix',
        ),
        text: _text);
    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    Rect box = _rect.inflate(-40);
    tp.paint(c, box.topLeft);

    c.restore();
  }

  void _drawScoreboardFuture(Canvas c) {}

  String _text =
      """In the 22nd century the human kind became overrun by trash of their own making.
There was no place on Earth to manage the vastness of greed induced and man produced garbage.
The powers at be came to a brilliant idea,they thought, to launch the trash off of the planet and into outer space...
but their calculations were wrong...
and gravity has slowly been pulling the waste back to Earth causing catastrophic fiery re-entry showers burning the atmosphere.
Now a team of brave space captains is putting their lives on the line to protect the Earth from these trash meteors.
GRAVITY BITES BACK""";
}
