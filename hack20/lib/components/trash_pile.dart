import 'dart:math';
import 'dart:ui';
import 'package:flutter/widgets.dart';

import '../game_time.dart';
import 'trash.dart';

class TrashPile {
  TrashPile({
    @required this.gameTime,
  }) {
    _rect = Rect.fromLTWH(
      0.0,
      0.0,
      gameTime.screenSize.width,
      gameTime.screenSize.height,
    );
    _trash = List<Trash>();
    _pile = List<Trash>();
    _recycled = List<Trash>();
    _random = Random();
    pileCount = 0;
    recycledCount = 0;
  }

  final GameTime gameTime;
  Rect _rect;
  Random _random;

  List<Trash> _trash;
  List<Trash> _pile;
  List<Trash> _recycled;

  int pileCount;
  int recycledCount;

  void render(Canvas c) {
    for (var trash in _trash) {
      trash.render(c);
    }
  }

  void update(double t) {
    List<int> outOfScreen = List<int>();
    _trash.asMap().forEach((index, trash) {
      trash.update(t);
      if (!_rect.contains(trash.center)) {
        outOfScreen.add(index);
      } else if (gameTime.earth.distance(trash.center) <= 0) {
        outOfScreen.add(index);
        _pile.add(trash);
        pileCount += 1;
      } else if (gameTime.spaceship.distance(trash.center) <= 0) {
        outOfScreen.add(index);
        _recycled.add(trash);
        recycledCount += 1;
      }
    });
    for (var index in outOfScreen) {
      _trash.removeAt(index);
    }

    if (_trash.length < gameTime.level) {
      if (_random.nextDouble() <= 0.01 * gameTime.level) {
        _addTrash();
      }
    }
  }

  void _addTrash() {
    var distance = (_random.nextDouble() - 0.5) *
        (gameTime.screenSize.width - gameTime.earth.size.width) *
        0.05;
    var angle = _random.nextDouble() * pi;
    var radius = gameTime.screenSize.width * 0.4 + distance;

    var dx = sin(angle) * radius;
    var dy = cos(angle) * radius;

    if (angle > pi) {}

    var x = gameTime.earth.center.dx + dx;
    var y = gameTime.earth.center.dy + dy;
    var size = _random.nextDouble() * 10;

    Trash star = Trash(
      gameTime: gameTime,
      center: Offset(dx, dy),
      size: size,
      speed: Offset(0, 0),
    );

    _trash.add(star);
  }

  int get pollution {
    return _pile.fold(0, (previous, current) => previous + current.size);
  }

  int get score {
    return _recycled.fold(0, (previous, current) => previous + current.size);
  }
}
