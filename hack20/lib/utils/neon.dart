import 'dart:ui';
import 'package:flutter/widgets.dart';

const WHITE = Color(0xffffffff);

const double step = 1.5;

class Neon {
  static Paint _glowPaint = Paint();
  static render(Canvas c, Path path, Paint paint, double scale) {
    switch (paint.style) {
      case PaintingStyle.fill:
        // _renderFill(c, path, paint, scale);
        _renderStroke(c, path, paint, scale);
        break;
      case PaintingStyle.stroke:
        _renderStroke(c, path, paint, scale);
        break;
    }
  }

  static _renderFill(Canvas c, Path path, Paint paint, double scale) {
    _glowPaint.style = PaintingStyle.fill;
    _glowPaint.color = paint.color.withOpacity(0.1);
    _glowPaint.strokeWidth = 6 / scale;
    c.drawPath(path, _glowPaint);
    _glowPaint.color = paint.color.withOpacity(0.2);
    _glowPaint.strokeWidth = 5 / scale;
    c.drawPath(path, _glowPaint);
    _glowPaint.color = paint.color.withOpacity(0.3);
    _glowPaint.strokeWidth = 4 / scale;
    c.drawPath(path, _glowPaint);
    _glowPaint.color = paint.color.withOpacity(0.35);
    _glowPaint.strokeWidth = 3 / scale;
    c.drawPath(path, _glowPaint);

    _glowPaint.color = paint.color.withOpacity(0.35);
    _glowPaint.strokeWidth = 3;

    c.drawPath(path, paint);
  }

  static _renderStroke(Canvas c, Path path, Paint paint, double scale) {
    c.drawPath(path,
        _strokePaint(paint.color, 0.1, (paint.strokeWidth + 4 * step) / scale));
    c.drawPath(path,
        _strokePaint(paint.color, 0.2, (paint.strokeWidth + 3 * step) / scale));
    c.drawPath(path,
        _strokePaint(paint.color, 0.3, (paint.strokeWidth + 2 * step) / scale));
    c.drawPath(path,
        _strokePaint(paint.color, 0.35, (paint.strokeWidth + step) / scale));

    c.drawPath(path, _strokePaint(paint.color, 1, paint.strokeWidth / scale));

    c.drawPath(path, _strokePaint(WHITE, 1, (paint.strokeWidth - 1) / scale));
  }

  static Paint _strokePaint(Color c, double opacity, double width) {
    Paint p = Paint()
      ..style = PaintingStyle.stroke
      ..color = c.withOpacity(opacity)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = width
      ..isAntiAlias = true;
    return p;
  }
}
