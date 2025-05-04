import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'pen_renderer/pen_renderer.dart';

class ClippedPathCanvasProxy implements Canvas {
  final double progressFactor;
  final Canvas canvas;

  double drawnPathLength = 0;

  final PenRenderer? penRenderer;

  ClippedPathCanvasProxy(this.canvas, {required this.progressFactor, this.penRenderer});

  @override
  void drawPath(Path path, Paint paint) {
    var limit = _computeLimit(path);

    for (final contourMetrics in path.computeMetrics()) {
      // Compute how much we're allowed to draw.
      final lengthToDraw = min(limit * progressFactor - drawnPathLength, contourMetrics.length);

      // If we can't draw anymore, abort.
      if (lengthToDraw == 0) {
        break;
      }

      // Pass-through draw.
      final pathToDraw = contourMetrics.extractPath(0, lengthToDraw);
      canvas.drawPath(pathToDraw, paint);
      drawnPathLength += lengthToDraw;

      // If we drew less than the full contour length, it means we've reached
      // [pathLengthLimit] and the end of the current contour is where the "pen"
      // is.
      if (penRenderer == null) continue;

      final isFinalStroke = lengthToDraw < contourMetrics.length;
      if (isFinalStroke) {
        final pathEndPoint =
            contourMetrics.extractPath(lengthToDraw, lengthToDraw, startWithMoveTo: true);
        final penPosition = pathEndPoint.getBounds().center;
        // Render the pen's tip.
        penRenderer!.draw(canvas, penPosition, paint);
      }
    }
  }

  @override
  void transform(Float64List matrix4) {
    return canvas.transform(matrix4);
  }

  @override
  getTransform() {
    return canvas.getTransform();
  }

  @override
  void save() {
    return canvas.save();
  }

  @override
  void restore() {
    return canvas.restore();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Ignore missing implementations.
    // super.noSuchMethod(invocation);
  }

  double _computeLimit(Path path) {
    var ret = 0.0;
    for (final contourMetrics in path.computeMetrics()) {
      ret += contourMetrics.length;
    }

    return ret;
  }
}
