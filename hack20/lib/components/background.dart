import 'dart:math';
import 'dart:ui';
import 'package:flutter/widgets.dart';

import '../game_time.dart';
import 'star.dart';

const BLACK = Color(0xff000000);
const numOfStars = 200;

class Background {
  Background({
    @required this.gameTime,
  }) {
    _bgRect = Rect.fromLTWH(
      0.0,
      0.0,
      gameTime.screenSize.width,
      gameTime.screenSize.height,
    );
    _paint = Paint()
      ..style = PaintingStyle.fill
      ..color = BLACK;
    _stars = List<Star>();
    _random = Random();
    _setupStars();
  }

  final GameTime gameTime;
  Rect _bgRect;
  Paint _paint;
  Random _random;

  List<Star> _stars;

  void render(Canvas c) {
    c.drawRect(_bgRect, _paint);
    for (var star in _stars) {
      star.render(c);
    }
  }

  void update(double t) {
    List<int> outOfScreen = List<int>();
    _stars.asMap().forEach((index, star) {
      star.update(t);
      if (!_bgRect.contains(star.center)) {
        outOfScreen.add(index);
      }
    });
    for (var index in outOfScreen) {
      _stars.removeAt(index);
      _addStar();
    }
  }

  void _setupStars() {
    for (var i = 0; i < numOfStars; i++) {
      _addStar();
    }
  }

  void _addStar() {
    var x = _random.nextDouble() * gameTime.screenSize.width;
    var y = _random.nextDouble() * gameTime.screenSize.height;
    var dx = _random.nextDouble() * 0.001;
    var dy = _random.nextDouble() * 0.001;
    var size = _random.nextDouble() * 5;

    Star star = Star(
      gameTime: gameTime,
      center: Offset(x, y),
      size: size,
      speed: Offset(dx, dy),
    );

    _stars.add(star);
  }
}
