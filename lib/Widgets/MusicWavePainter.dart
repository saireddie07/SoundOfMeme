

import 'dart:math';
import 'package:flutter/cupertino.dart';

class MusicWavePainter extends CustomPainter {
  final Color color;
  final double animation;

  MusicWavePainter({required this.color, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    final width = size.width;
    final height = size.height;

    for (var i = 0; i < width; i++) {
      final x = i.toDouble();
      final y = height / 2 + sin((x / width * 2 * pi + animation * 2 * pi) * 3) * height / 4 * sin(animation * pi);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}