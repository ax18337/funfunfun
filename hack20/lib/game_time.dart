import 'dart:ui';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'components/background.dart';

class GameTime extends Game {
  GameTime() {
    initialize;
  }

  Size screenSize;

  // components
  Background background;

  Future<void> get initialize async {
    final _size = await Flame.util.initialDimensions();
    resize(_size);

    background = Background(gameTime: this);
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
  }

  @override
  void update(double t) {
    if (background != null) {
      background.update(t);
    }
  }
}
