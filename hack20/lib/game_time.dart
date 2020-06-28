import 'dart:developer';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/keyboard.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/services/raw_keyboard.dart';
import 'package:hack20/components/interlace.dart';
import 'package:hack20/components/moon.dart';
import 'package:hack20/components/scoreboard.dart';
import 'package:hack20/components/status.dart';
import 'package:hack20/components/trash_pile.dart';
import 'package:hack20/data/user.dart';
import 'components/background.dart';
import 'components/earth.dart';
import 'components/spaceship.dart';
import 'dart:developer';

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

  // scoreboard
  Scoreboard scoreboard;

  // effects
  Interlace interlace;

  // level
  int level;
  bool _gameEnded = false;
  double _increasedLevelTicks = 0;
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
        center: Offset(_size.width / 2, _size.width / 2),
        size: 30);
    trashPile = TrashPile(gameTime: this);
    status = Status(gameTime: this);

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
    super.resize(size);
  }

  @override
  void render(Canvas c) {
    if (user.lives == 0) {
      scoreboard?.render(c);
    } else {
      if (_increasedLevelTicks > 0) {
        _renderLevelUpdated(c);
      }
      // components
      background?.render(c);
      earth?.render(c);
      moon?.render(c);
      trashPile?.render(c);
      spaceship?.render(c);
      status?.render(c);

      if (trashPile != null) {
        // _drawScore(c);
      }
    }

    // efffects
    interlace?.render(c);
  }

  @override
  void update(double t) {
    // components
    background?.update(t);
    earth?.update(t);
    moon?.update(t);
    trashPile?.update(t);
    spaceship?.update(t);
    status?.update(t);

    // efffects
    interlace?.update(t);

    this._gameEnded = _isGameEnded();
    if (!_gameEnded) {
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

  void _drawScore(Canvas c) {
    c.save();

    var builder = ParagraphBuilder(
        ParagraphStyle(textAlign: TextAlign.left, fontSize: 18, maxLines: 1))
      ..addText(
          "score = ${trashPile.score} pollution = ${trashPile.pollution} level = ${user.level}");
    var paragraph = builder.build()..layout(ParagraphConstraints(width: 500));
    c.drawParagraph(paragraph, Offset(20, 20));

    c.restore();
  }

  bool _isGameEnded() {
    return trashPile != null ? trashPile.pollution > 500 : false;
  }

  void _checkLevelCompleted() {
    if (trashPile != null ? trashPile.score > level * 10 : false) {
      debugPrint("increasing level: ${trashPile?.score}");
      _increasedLevelTicks = 2000;
      level += 1;
    }
  }

  void _renderLevelUpdated(Canvas c) {
    c.save();

    debugPrint("we try");

    var builder = ParagraphBuilder(
        ParagraphStyle(textAlign: TextAlign.left, fontSize: 48, maxLines: 1))
      ..addText("Now @Level $level");
    var paragraph = builder.build()..layout(ParagraphConstraints(width: 500));
    c.drawParagraph(paragraph, Offset(20, 80));
    c.restore();
  }
}
