import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hack20/components/trash.dart';

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
  List<Trash> _trash = List<Trash>();
  Random _random = Random();

  Offset get center {
    return _rect.center;
  }

  void render(Canvas c) {
    _drawScoreboard(c);
  }

  void update(double t) {
    time += t;

    double progress = time / 20;
    if (progress > 1.5) {
      if (_random.nextDouble() <= 0.1) {
        _addTrash();
      }
    }
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

    double progress = time / 20;

    if (progress > 1.5) {
      TextSpan span = TextSpan(
          style: TextStyle(
            color: WHITE,
            fontSize: 64.0,
            fontFamily: 'Joystix',
          ),
          text: "GRAVITY BITES BACK");
      TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr);
      tp.layout(maxWidth: _rect.width - 80);
      tp.paint(c, Offset(_rect.left + 40, _rect.top + 40));

      double y = _rect.top + 40 + tp.size.height + 20;

      int step = (time * 2).floor();
      if (step % 2 == 0) {
        TextSpan span = TextSpan(
            style: TextStyle(
              color: WHITE,
              fontSize: 24.0,
              fontFamily: 'Joystix',
            ),
            text: "PRESS SPACE");
        TextPainter tp = TextPainter(
            text: span,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(c, Offset(_rect.center.dx - tp.width * 0.5, y));
      }

      for (var trash in _trash) {
        trash.render(c);
      }
    } else {
      c.translate(0, _rect.height * (1 - progress));

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
      Rect box = _rect.inflate(-40);
      tp.layout(maxWidth: box.width);
      tp.paint(c, box.topLeft);
    }

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

  void _addTrash() {
    Rect rect = _rect.inflate(-40);

    var dx = _random.nextDouble() * rect.width + rect.left;
    var dy = rect.bottom - _random.nextDouble() * rect.height * 0.5;
    var size = _random.nextDouble() * 80;

    Trash star = Trash(
      gameTime: gameTime,
      center: Offset(dx, dy),
      size: size,
      speed: Offset(0, 0),
    );

    _trash.add(star);
  }
}
