import 'package:flutter/material.dart';
import 'dart:math';

class Raindrop {
  double x;
  double y;
  double size;
  double speed;

  Raindrop(this.x, this.y, this.size, this.speed);
}

class RainAnimation extends StatefulWidget {
  @override
  _RainAnimationState createState() => _RainAnimationState();
}

class _RainAnimationState extends State<RainAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Raindrop> _raindrops = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    for (int i = 0; i < 50; i++) {
      _raindrops.add(_createRaindrop());
    }

    _controller.addListener(() {
      setState(() {
        _updateRaindrops();
      });
    });
  }

  Raindrop _createRaindrop() {

    return Raindrop(
      _random.nextDouble() * MediaQuery.of(context).size.width,
      _random.nextDouble() * MediaQuery.of(context).size.height,
      _random.nextDouble() * 2 + 1,
      _random.nextDouble() * 5 + 2,
    );
  }

  void _updateRaindrops() {
    for (var raindrop in _raindrops) {
      raindrop.y += raindrop.speed;

      if (raindrop.y > MediaQuery.of(context).size.height) {
        raindrop.y = 0;
        raindrop.x = _random.nextDouble() * MediaQuery.of(context).size.width;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RainPainter(_raindrops),
    );
  }
}

class RainPainter extends CustomPainter {
  final List<Raindrop> raindrops;

  RainPainter(this.raindrops);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    for (var raindrop in raindrops) {
      canvas.drawCircle(
        Offset(raindrop.x, raindrop.y),
        raindrop.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}