class User {
  String name = "anon";
  int _lives = 3;
  int _level = 1;

  Function deathCallback;

  User({this.deathCallback});

  void lostLife() {
    _lives -= 1;
    if (_lives == 0) {
      deathCallback();
    }
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
