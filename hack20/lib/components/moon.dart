import 'dart:math';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:hack20/utils/geometry.dart';
import 'package:hack20/utils/neon.dart';

import '../game_time.dart';

const GREEN = Color(0xff7fff00);
const YELLOW = Color(0xffd9eb4b);
const ORANGE = Color(0xfffc6e22);
const RED = Color(0xffce0000);

const BLUE = Color(0xff002eff);

const BLACK = Color(0xfff000000);
const DEEPBLUE = Color(0xff010b19);
const WHITE = Color(0xfffffffff);

const numOfStars = 200;

class Moon {
  Moon({
    @required this.gameTime,
    @required this.speed,
    @required this.segments,
    @required this.gravity,
  }) {
    _rect = Rect.fromCircle(
      center: Offset(
          gameTime.screenSize.width * 0.5, gameTime.screenSize.height * 0.5),
      radius: min(gameTime.screenSize.width, gameTime.screenSize.height) * 0.02,
    );
    _areaPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = BLACK;
    _retroPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = WHITE
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.bevel
      ..strokeWidth = 2
      ..isAntiAlias = false;
    _futurePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = BLUE
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2
      ..isAntiAlias = true;
    _holeRects = List<Rect>();
    _holes = List<Path>();
    _createPaths();
  }

  final GameTime gameTime;
  double speed;
  int segments;
  double gravity;
  double _angle = 0;
  Rect _rect;
  Paint _areaPaint;
  Paint _retroPaint;
  Paint _futurePaint;

  Path _outline;
  List<Rect> _holeRects;
  List<Path> _holes;

  void render(Canvas c) {
    switch (gameTime.mode) {
      case Mode.retro:
        _renderRetro(c);
        break;
      case Mode.future:
        _renderFuture(c);
        break;
    }
  }

  void update(double t) {
    _angle += speed * t;

    double radius = gameTime.earth.size.width * 2;
    double dx = sin(_angle) * radius;
    double dy = cos(_angle) * radius;

    var x = gameTime.earth.center.dx + dx;
    var y = gameTime.earth.center.dy + dy;
    var size = gameTime.earth.size.width / 10;

    _rect = Rect.fromCircle(
      center: Offset(x, y),
      radius: size,
    );
  }

  void _renderRetro(Canvas c) {
    c.save();

    double scale = _rect.width / 100;
    Offset translation =
        Offset(_rect.center.dx - 50 * scale, _rect.center.dy - 50 * scale);
    c.translate(translation.dx, translation.dy);
    c.scale(scale);

    c.drawPath(_outline, _areaPaint);
    _retroPaint.strokeWidth = 2 / scale;
    c.drawPath(_outline, _retroPaint);
    for (var hole in _holes) {
      c.drawPath(hole, _retroPaint);
    }

    c.restore();
  }

  void _renderFuture(Canvas c) {
    c.save();

    double scale = _rect.width / 100;
    Offset translation =
        Offset(_rect.center.dx - 50 * scale, _rect.center.dy - 50 * scale);
    c.translate(translation.dx, translation.dy);
    c.scale(scale);

    Path outline = Path()..addOval(Rect.fromLTWH(0, 0, 100, 100));

    c.drawPath(outline, _areaPaint);
    Neon.render(c, outline, _futurePaint, scale);

    c.drawPath(outline, _futurePaint);
    for (var holeRect in _holeRects) {
      Path hole = Path()..addOval(holeRect);
      Neon.render(c, hole, _futurePaint, scale);
    }

    c.restore();
  }

  Offset gravityStrenght(Offset point) {
    Offset direction = _rect.center - point;
    double relativeDistance = direction.distance / _rect.width / 0.5;
    double strength = gravity / (relativeDistance * relativeDistance);
    var norm = 1 / direction.distance;
    direction = direction.scale(norm, norm);
    direction = direction.scale(strength, strength);
    return direction;
  }

  double distance(Offset point) {
    return (point - _rect.center).distance - _rect.width * 0.5;
  }

  Offset get center {
    return _rect.center;
  }

  Size get size {
    return _rect.size;
  }

  void _createPaths() {
    _outline = Geometry.simpleCircle(Rect.fromLTWH(0, 0, 100, 100), 6);

    _holeRects.clear();
    _holes.clear();
    Rect rect = Rect.fromLTWH(60, 20, 20, 20);
    _holeRects.add(rect);
    _holes.add(Geometry.simpleCircle(rect, 4));

    rect = Rect.fromLTWH(40, 50, 10, 10);
    _holeRects.add(rect);
    _holes.add(Geometry.simpleCircle(rect, 4));

    rect = Rect.fromLTWH(70, 60, 16, 16);
    _holeRects.add(rect);
    _holes.add(Geometry.simpleCircle(rect, 4));
  }
}
