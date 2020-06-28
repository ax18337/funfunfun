import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../game_time.dart';

const WHITE = Color(0xffffffff);
const GREEN = Color(0xff44ff66);

class Entry {
  Entry(this.name, this.score);
  final String name;
  final int score;
}

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
  List<Entry> _data;
  Entry _latestScore;

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
        _data = List<Entry>();
        data.documents.forEach((element) {
          _data.add(Entry(element['user'], element['score']));
        });
        _data.sort((a, b) => b.score.compareTo(a.score));
      });
      _drawRetroLoading(c);
    } else {
      _drawRetroLoaded(c);
    }
    c.restore();
  }

  void _drawRetroLoading(Canvas c) {
    _drawRetroHeader(c);

    TextSpan span = TextSpan(
        style: TextStyle(
          color: WHITE,
          fontSize: 24.0,
          fontFamily: 'Joystix',
        ),
        text: "LOADING ...");
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
    tp.paint(c, box.topLeft);

    _drawRetroFooter(c);
  }

  void _drawRetroLoaded(Canvas c) {
    _drawRetroHeader(c);

    double y = 100;

    for (var i = 0; i < 20; i++) {
      String line;
      if (_data.length > i) {
        Entry entry = _data[i];
        if (entry.name.length >= 6) {
          line = entry.name.substring(0, 6);
        } else {
          line = entry.name;
          int missing = 6 - entry.name.length;
          for (var i = 0; i < missing; i++) {
            line += ".";
          }
        }
      } else {
        line = "......";
      }

      line += "......";

      int score = 0;
      if (_data.length > i) {
        Entry entry = _data[i];
        score = entry.score;
      }

      String scoreStr = score.toString();
      if (scoreStr.length >= 8) {
        line += scoreStr;
      } else {
        int missing = 8 - scoreStr.length;
        for (var i = 0; i < missing; i++) {
          line += ".";
        }
        line += scoreStr;
      }

      TextSpan span = TextSpan(
          style: TextStyle(
            color: WHITE,
            fontSize: 24.0,
            fontFamily: 'Joystix',
          ),
          text: line);
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
      tp.paint(c, box.topLeft);
      y += 6 + tp.size.height;
    }

    _drawRetroFooter(c);
  }

  void _drawRetroHeader(Canvas c) {
    double y = _rect.top + 20;
    TextSpan span = TextSpan(
        style: TextStyle(
          color: WHITE,
          fontSize: 32.0,
          fontFamily: 'Joystix',
        ),
        text: "HIGHSCORES");
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
    tp.paint(c, box.topLeft);

    y += tp.size.height;

    span = TextSpan(
        style: TextStyle(
          color: WHITE,
          fontSize: 32.0,
          fontFamily: 'Joystix',
        ),
        text: "----------");
    tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    box = Rect.fromLTWH(
      _rect.center.dx - tp.size.width * 0.5,
      y,
      tp.size.width,
      tp.size.height,
    );
    tp.paint(c, box.topLeft);
  }

  void _drawRetroFooter(Canvas c) {
    TextSpan span = TextSpan(
        style: TextStyle(
          color: WHITE,
          fontSize: 18.0,
          fontFamily: 'Joystix',
        ),
        text: "Copyright 2020");
    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    Rect box = Rect.fromLTWH(
      _rect.center.dx - tp.size.width * 0.5,
      _rect.bottom - tp.size.height - 20,
      tp.size.width,
      tp.size.height,
    );
    tp.paint(c, box.topLeft);
  }

  void _drawScoreboardFuture(Canvas c) {}

  void latestScore(String username, int score) {
    debugPrint("updating score: $username = $score");
    if (score > 0) {
      _latestScore = Entry(username, score);
      Firestore.instance.collection("scores").document().setData({
        'user': username, 'score': score
      });
    }
  }
}

