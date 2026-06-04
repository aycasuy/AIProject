import 'package:flutter/material.dart';
import 'dart:math' as math;

class BubblePainter extends CustomPainter {
  final double animValue;
  BubblePainter(this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    final bubbles = [
      _Bubble(0.12, 0.10, 75, const Color(0xFFFFD166)),
      _Bubble(0.88, 0.07, 50, const Color(0xFF06D6A0)),
      _Bubble(0.04, 0.68, 42, const Color(0xFFEF476F)),
      _Bubble(0.92, 0.78, 65, const Color(0xFF118AB2)),
      _Bubble(0.50, 0.94, 30, const Color(0xFFFFD166)),
    ];

    for (final b in bubbles) {
      final dy = math.sin(animValue * 2 * math.pi + b.x * 6.28) * 10;

      // YENİ NESİL RENK SAYDAMLIKLARI EKLENDİ ✨
      final fill = Paint()
        ..color = b.color.withValues(alpha: 0.15)
        ..style = PaintingStyle.fill;

      final stroke = Paint()
        ..color = b.color.withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      final center = Offset(size.width * b.x, size.height * b.y + dy);
      canvas.drawCircle(center, b.r, fill);
      canvas.drawCircle(center, b.r, stroke);
    }
  }

  @override
  bool shouldRepaint(BubblePainter old) => old.animValue != animValue;
}

class _Bubble {
  final double x, y, r;
  final Color color;
  const _Bubble(this.x, this.y, this.r, this.color);
}
