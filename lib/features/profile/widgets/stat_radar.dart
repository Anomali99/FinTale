import 'dart:math' show pi, cos, sin;

import 'package:flutter/material.dart';

class StatRadar extends StatelessWidget {
  final List<double> stats;
  final Color color;

  const StatRadar({super.key, required this.stats, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: CustomPaint(
        painter: StatRadarPainter(stats: stats, color: color),
      ),
    );
  }
}

class StatRadarPainter extends CustomPainter {
  final List<double> stats;
  final Color color;

  StatRadarPainter({required this.stats, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paintWeb = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final paintAura = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final paintLine = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    int sides = stats.length;
    double angle = (2 * pi) / sides;

    for (int j = 1; j <= 3; j++) {
      Path webPath = Path();
      double r = radius * (j / 3);
      for (int i = 0; i < sides; i++) {
        double a = i * angle - pi / 2;
        double x = center.dx + r * cos(a);
        double y = center.dy + r * sin(a);
        if (i == 0) {
          webPath.moveTo(x, y);
        } else {
          webPath.lineTo(x, y);
        }
      }
      webPath.close();
      canvas.drawPath(webPath, paintWeb);
    }

    for (int i = 0; i < sides; i++) {
      double a = i * angle - pi / 2;
      canvas.drawLine(
        center,
        Offset(center.dx + radius * cos(a), center.dy + radius * sin(a)),
        paintWeb,
      );
    }

    Path statPath = Path();
    for (int i = 0; i < sides; i++) {
      double a = i * angle - pi / 2;
      double r = radius * stats[i];
      double x = center.dx + r * cos(a);
      double y = center.dy + r * sin(a);
      if (i == 0) {
        statPath.moveTo(x, y);
      } else {
        statPath.lineTo(x, y);
      }
    }
    statPath.close();

    canvas.drawPath(statPath, paintAura);
    canvas.drawPath(statPath, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
