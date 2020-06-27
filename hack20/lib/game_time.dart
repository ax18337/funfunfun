import 'dart:ui';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/keyboard.dart';
import 'package:flutter/src/services/raw_keyboard.dart';
import 'components/background.dart';
import 'components/spaceship.dart';

class GameTime extends Game with KeyboardEvents {
  GameTime() {
    initialize;
  }

  Size screenSize;

  // components
  Background background;
  Spaceship spaceship;

  Future<void> get initialize async {
    final _size = await Flame.util.initialDimensions();
    resize(_size);

    background = Background(gameTime: this);
    spaceship = Spaceship(gameTime: this, center: Offset(_size.width/2, _size.width/2), size: 10);
  }

  @override
  void resize(Size size) {
    screenSize = size;
    super.resize(size);
  }

  @override
  void render(Canvas c) {
    if (background != null) {
      background.render(c);
    }
    if (spaceship != null) {
      spaceship.render(c);
    }
  }

  @override
  void update(double t) {
    if (background != null) {
      background.update(t);
    }
    if (spaceship != null) {
      spaceship.update(t);
    }
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
}
