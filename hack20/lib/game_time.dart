import 'dart:ui';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/keyboard.dart';
import 'package:flutter/src/services/raw_keyboard.dart';
import 'package:hack20/components/interlace.dart';
import 'package:hack20/components/scoreboard.dart';
import 'package:hack20/components/trash_pile.dart';
import 'components/background.dart';
import 'components/earth.dart';
import 'components/spaceship.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  Spaceship spaceship;
  TrashPile trashPile;

  // scoreboard
  Scoreboard scoreboard;

  // effects
  Interlace interlace;

  // level
  int level;
  bool _gameEnded = false;

  Future<void> get initialize async {
    final _size = await Flame.util.initialDimensions();
    resize(_size);

    mode = Mode.future;

    // components
    background = Background(gameTime: this);
    earth = Earth(
      gameTime: this,
      speed: 0.1,
      segments: 10,
      gravity: 9.81 * 50,
    );
    spaceship = Spaceship(
        gameTime: this,
        center: Offset(_size.width / 2, _size.width / 2),
        size: 30);
    trashPile = TrashPile(gameTime: this);

    scoreboard = Scoreboard(gameTime: this);

    // effects
    interlace = Interlace(gameTime: this, size: 2);

    level = 1;
  }

  @override
  void resize(Size size) {
    screenSize = size;
    super.resize(size);
  }

  @override
  void render(Canvas c) {

    if (_gameEnded) {
      scoreboard?.render(c);
    } else {
      // components
      background?.render(c);
      earth?.render(c);
      trashPile?.render(c);
      spaceship?.render(c);
      // efffects
      interlace?.render(c);

      if (trashPile != null) {
        _drawScore(c);
      }
    }
  }

  @override
  void update(double t) {
    // components
    background?.update(t);
    earth?.update(t);
    trashPile?.update(t);
    spaceship?.update(t);
    // efffects
    interlace?.update(t);

    this._gameEnded = _isGameEnded();
  }

  @override
  void onKeyEvent(RawKeyEvent event) {
    if (!(event is RawKeyDownEvent)) {
      return;
    }

    if (event.data.keyLabel == "a") {
      spaceship.left();
    } else if (event.data.keyLabel == "d") {
      spaceship.right();
    } else if (event.data.keyLabel == "w") {
      spaceship.up();
    } else if (event.data.keyLabel == "s") {
      spaceship.down();
    }
  }

  void _drawScore(Canvas c) {
    c.save();

    var builder = ParagraphBuilder(
        ParagraphStyle(textAlign: TextAlign.left, fontSize: 18, maxLines: 1))
      ..addText("score = ${trashPile.score} pollution = ${trashPile.pollution} level = $level");

    c.drawColor(Color(0xffffffff), BlendMode.color);

    var paragraph = builder.build()..layout(ParagraphConstraints(width: 500));
    c.drawParagraph(paragraph, Offset(20, 20));

    c.restore();
  }

  bool _isGameEnded() {
    return trashPile != null ? trashPile.pollution > 500 : false;
  }
}
