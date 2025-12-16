import 'package:flutter/material.dart';
import 'dart:math' as math;

class DashedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final double gap;

  const DashedBorder({
    Key? key,
    required this.child,
    this.color = Colors.grey, // اللون الافتراضي (تم تغييره إلى أسود في الكود أعلاه)
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedBorderPainter(
        color: color,
        strokeWidth: strokeWidth,
        gap: gap,
      ),
      child: child,
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const dashLength = 5.0;
    double x = 0.0;
    double y = 0.0;

    // الخط العلوي
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(math.min(x + dashLength, size.width), 0),
        paint,
      );
      x += dashLength + gap;
    }

    // الخط الأيمن
    while (y < size.height) {
      canvas.drawLine(
        Offset(size.width, y),
        Offset(size.width, math.min(y + dashLength, size.height)),
        paint,
      );
      y += dashLength + gap;
    }

    // الخط السفلي
    x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(math.min(x + dashLength, size.width), size.height),
        paint,
      );
      x += dashLength + gap;
    }

    // الخط الأيسر
    y = 0.0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(0, y),
        Offset(0, math.min(y + dashLength, size.height)),
        paint,
      );
      y += dashLength + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}