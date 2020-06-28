import 'dart:developer';
import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/keyboard.dart';
import 'package:flutter/cupertino.dart';
// ignore: implementation_imports
import 'package:flutter/src/services/raw_keyboard.dart';

import 'package:hack20/components/interlace.dart';
import 'package:hack20/components/moon.dart';
import 'package:hack20/components/scoreboard.dart';
import 'package:hack20/components/status.dart';
import 'package:hack20/components/trash_pile.dart';
import 'package:hack20/data/user.dart';

import 'components/background.dart';
import 'components/earth.dart';
import 'components/level.dart';
import 'components/spaceship.dart';

enum Mode { retro, future }

class GameTime extends Game with KeyboardEvents {
  GameTime() {
    initialize;
  }

  Size screenSize;
  Mode mode;

  // components
  Background background;
  Earth earth;
  Moon moon;
  Spaceship spaceship;
  TrashPile trashPile;
  Status status;
  Level level;

  // scoreboard
  Scoreboard scoreboard;

  // effects
  Interlace interlace;

  // level
  double _increasedLevelTicks = 5;
  User user = User();

  Future<void> get initialize async {
    final _size = await Flame.util.initialDimensions();
    resize(_size);

    mode = Mode.retro;

    // components
    background = Background(gameTime: this);
    earth = Earth(
      gameTime: this,
      speed: 0.1,
      segments: 10,
      gravity: 9.81 * 30,
    );
    moon = Moon(
      gameTime: this,
      speed: 0.1,
      segments: 8,
      gravity: 9.81 * 10,
    );
    spaceship = Spaceship(
        gameTime: this,
        center: Offset(_size.width * 0.1, _size.width * 0.1),
        size: 30);
    trashPile = TrashPile(gameTime: this);
    status = Status(gameTime: this);
    level = Level(gameTime: this);

    scoreboard = Scoreboard(gameTime: this);

    // effects
    interlace = Interlace(gameTime: this, size: 2);
  }

  @override
  void resize(Size size) {
    screenSize = size;
    // background?.updateSize(size);
    // earth?.updateSize(size);
    // moon?.updateSize(size);
    // trashPile?.updateSize(size);
    // spaceship?.updateSize(tsize);
    // status?.updateSize(size);
    // level?.updateSize(size);
    super.resize(size);
  }

  @override
  void render(Canvas c) {
    if (_isGameEnded()) {
      scoreboard?.render(c);
    } else {
      // components
      background?.render(c);
      earth?.render(c);
      moon?.render(c);
      trashPile?.render(c);
      spaceship?.render(c);
      if (_increasedLevelTicks > 0) {
        level?.render(c);
      }
      status?.render(c);
    }

    // efffects
    interlace?.render(c);
  }

  @override
  void update(double t) {
    // components
    background?.update(t);
    if (_isGameEnded() || _increasedLevelTicks <= 0) {
      earth?.update(t);
      moon?.update(t);
      trashPile?.update(t);
      spaceship?.update(t);
    }
    status?.update(t);
    level?.update(t);

    // efffects
    interlace?.update(t);

    if (_isGameEnded()) {
      _checkLevelCompleted();
    }
    if (_increasedLevelTicks > 0) {
      _increasedLevelTicks -= t;
    }
  }

  @override
  void onKeyEvent(RawKeyEvent event) {
    bool keyDown = true;
    if (event is RawKeyUpEvent) {
      keyDown = false;
    } else if (!(event is RawKeyDownEvent)) {
      return;
    }

    if (event.data.keyLabel == "a") {
      spaceship.left(keyDown);
    } else if (event.data.keyLabel == "d") {
      spaceship.right(keyDown);
    } else if (event.data.keyLabel == "w") {
      spaceship.up(keyDown);
      log('isDown: $keyDown');
    } else if (event.data.keyLabel == "s") {
      spaceship.down(keyDown);
    }
  }

  bool _isGameEnded() {
    if (trashPile != null && user != null) {
      if (trashPile.status <= 0 || user.lives <= 0) {
        return true;
      }
    }
    return false;
  }

  void _checkLevelCompleted() {
    if (trashPile != null ? trashPile.score > user.level * 10 : false) {
      debugPrint("increasing level: ${trashPile?.score}");
      _increasedLevelTicks = 4;
      user.nextLevel();
    }
  }

  bool isInside(Offset point) {
    return point.dx >= 0 &&
        point.dx <= screenSize.width &&
        point.dy >= 0 &&
        point.dy <= screenSize.height;
  }

  void startGame() {
    _increasedLevelTicks = 5;
    user.reset();
  }
}
