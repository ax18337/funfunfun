class User {
  int _lives = 3;
  int _level = 1;

  void lostLife() {
    _lives -= 1;
  }

  void nextLevel() {
    _level += 1;
  }

  void reset() {
    _level = 1;
    _lives = 3;
  }

  int get lives {
    return _lives;
  }

  int get level {
    return _level;
  }
}
