import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../game_time.dart';

const WHITE = Color(0xffffffff);
const GREEN = Color(0xff44ff66);

class Scoreboard {
  Scoreboard({@required this.gameTime}) {
    _rect = Rect.fromLTWH(
      0,
      0,
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
  Map<String, int> _data;

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
    var translate =
        Offset(gameTime.screenSize.width / 2, gameTime.screenSize.height / 2) -
            _rect.center;
    c.translate(translate.dx, translate.dy);
    c.drawRect(_rect, _retroPaint);

    if (_data == null) {
      Firestore.instance.collection("scores").snapshots().listen((data) {
        _data = Map<String, int>();
        data.documents.forEach((element) {
          debugPrint("user = ${element['user']} score = ${element['score']}");
          _data[element['user']] = element['score'];
        });
      });
      var builder = ParagraphBuilder(ParagraphStyle(
          textAlign: TextAlign.center, fontSize: 40, maxLines: 1))
        ..addText("Loading high scores...");

      var paragraph = builder.build()..layout(ParagraphConstraints(width: 500));
      c.drawParagraph(paragraph, Offset(20, 20));
    } else {
      double space = 20;
      _data.forEach((key, value) {
        var builder = ParagraphBuilder(ParagraphStyle(
            textAlign: TextAlign.center, fontSize: 24, maxLines: 1))
          ..addText("$key --- $value");

        var paragraph = builder.build()
          ..layout(ParagraphConstraints(width: 500));
        c.drawParagraph(paragraph, Offset(20, space));
        space += 40;
      });
    }
    c.restore();
  }

  void _drawScoreboardFuture(Canvas c) {}
}
