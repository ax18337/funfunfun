import 'package:flutter/material.dart';
import 'game_time.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key key}) : super(key: key);
  static final _game = GameTime();

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => GameScreen._game.widget;

  @override
  void dispose() {
    super.dispose();
  }
}