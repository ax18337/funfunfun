import 'dart:developer';
import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/keyboard.dart';
import 'package:flutter/cupertino.dart';
// ignore: implementation_imports
import 'package:flutter/src/services/raw_keyboard.dart';
import 'package:hack20/components/input-box.dart';

import 'package:hack20/components/interlace.dart';
import 'package:hack20/components/intro.dart';
import 'package:hack20/components/moon.dart';
import 'package:hack20/components/scoreboard.dart';
import 'package:hack20/components/status.dart';
import 'package:hack20/components/trash_pile.dart';
import 'package:hack20/data/user.dart';
import 'package:hack20/utils/sounds.dart';

import 'components/background.dart';
import 'components/earth.dart';
import 'components/level.dart';
import 'components/spaceship.dart';

enum Mode { retro, future }

class GameTime extends Game with KeyboardEvents {
  GameTime() {
    initialize;
  }

  InputBox _nameDialog; // when updating name

  Size screenSize;
  Mode mode;

  // intro
  Intro intro;
  bool _showIntro = true;

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
  User user;

  static const int MAX_NAME_SIZE = 10;

  Future<void> get initialize async {
    final _size = await Flame.util.initialDimensions();
    resize(_size);

    // init audio SFX
    Flame.audio.loadAll(Sounds.all);

    mode = Mode.retro;

    // intro
    intro = Intro(gameTime: this);

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

    user = User(
        deathCallback: () =>
            scoreboard?.latestScore(user.name, trashPile.score));

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
    background?.render(c);

    if (_nameDialog != null) {
      _nameDialog.render(c);
      return; // modal
    }

    if (_showIntro) {
      intro?.render(c);
    } else if (_isGameEnded()) {
      scoreboard?.render(c);
    } else {
      // components
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
    background?.update(t);

    // intro
    if (_showIntro) {
      intro?.update(t);
    }

    // components
    if (_gameRunning()) {
      earth?.update(t);
      moon?.update(t);
      trashPile?.update(t);
      spaceship?.update(t);
      status?.update(t);
      level?.update(t);

      // efffects
      interlace?.update(t);
    }

    if (!_isGameEnded()) {
      _checkLevelCompleted();
    }
    if (_increasedLevelTicks > 0) {
      _increasedLevelTicks -= t;
    }
  }

  @override
  void onKeyEvent(RawKeyEvent event) {
    if (_nameDialog != null) {
      if (event is RawKeyUpEvent) {
        if (event.data.keyLabel == 'Enter' || event.data.keyLabel == 'Escape') {
          _nameDialog = null;
        } else if (event.data.keyLabel == 'Backspace') {
          user.name = user.name.substring(0, user.name.length - 1);
        } else if (user.name.length < MAX_NAME_SIZE &&
            _isNameChar(event.data.keyLabel)) {
          user.name += event.data.keyLabel;
        }
      }
      return;
    }

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
    } else if (event.data.keyLabel == "s") {
      spaceship.down(keyDown);
    } else if (event.data.keyLabel == " ") {
      if (!keyDown && (_showIntro || _isGameEnded())) {
        _showIntro = false;
        startGame();
      }
    } else if (event.data.keyLabel == "f") {
      if (keyDown) {
        mode = Mode.future;
      }
    } else if (event.data.keyLabel == "r") {
      if (keyDown) {
        mode = Mode.retro;
      }
    }
  }

  bool _isGameEnded() {
    if (user != null) {
      if (user.lives <= 0) {
        return true;
      }
    }
    return false;
  }

  void _checkLevelCompleted() {
    if (trashPile != null ? trashPile.score > user.level * 10 : false) {
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
    _updateName();
    _increasedLevelTicks = 5;
    user.reset();
    trashPile.reset();
    spaceship.reset();
  }

  void _updateName() {
    _nameDialog = new InputBox(gameTime: this);
  }

  // perhaps filter for ASCII? or readable?
  bool _isNameChar(String keyLabel) => keyLabel.length == 1;

  bool _gameRunning() =>
      !_isGameEnded() &&
      _increasedLevelTicks <= 0 &&
      !_showIntro &&
      _nameDialog == null;

  void userLostLife() {
    user.lostLife();
  }
}
