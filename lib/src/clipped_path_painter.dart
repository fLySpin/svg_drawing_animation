import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'clipped_path_canvas_proxy.dart';
import 'pen_renderer/pen_renderer.dart';

class ClippedPathPainter extends CustomPainter {
  ClippedPathPainter(this.drawableRoot, {required this.progressFactor, this.penRenderer});

  final DrawableRoot drawableRoot;
  final double progressFactor;
  final PenRenderer? penRenderer;

  @override
  void paint(Canvas canvas, Size size) {
    drawableRoot.draw(
        ClippedPathCanvasProxy(canvas, progressFactor: progressFactor, penRenderer: penRenderer),
        // `bounds` are not used according to [DrawableRoot.draw].
        Rect.zero);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: optimize?
    return true;
  }
}
