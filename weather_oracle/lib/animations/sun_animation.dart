import 'package:flutter/material.dart';
import 'dart:math';

class SunAnimation extends StatefulWidget {
  @override
  _SunAnimationState createState() => _SunAnimationState();
}

class _SunAnimationState extends State<SunAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: CustomPaint(
            painter: SunPainter(),
          ),
        );
      },
    );
  }
}

class SunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 4;

    final sunPaint = Paint()..color = Colors.yellow;
    canvas.drawCircle(center, radius, sunPaint);

    final rayPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 12; i++) {
      final angle = 2 * pi * i / 12;
      final startPoint = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      final endPoint = Offset(
        center.dx + (radius * 1.5) * cos(angle),
        center.dy + (radius * 1.5) * sin(angle),
      );
      canvas.drawLine(startPoint, endPoint, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}