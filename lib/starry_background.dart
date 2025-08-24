import 'dart:math';
import 'package:flutter/material.dart';

class Star {
  final double x, y;
  final double radius;
  final double phase;

  Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.phase,
  });
}

class StarryBackground extends StatefulWidget {
  final Widget child;

  const StarryBackground({super.key, required this.child});

  @override
  State<StarryBackground> createState() => _StarryBackgroundState();
}

class _StarryBackgroundState extends State<StarryBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Star> stars;
  final int numStars = 120;
  final Random rand = Random();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat();

    stars = List.generate(
      numStars,
      (_) => Star(
        x: rand.nextDouble(),
        y: rand.nextDouble(),
        radius: rand.nextDouble() * 2 + 1, // 👈 your original range
        phase: rand.nextDouble() * 2 * pi,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: StarPainter(stars: stars, animation: _controller),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class StarPainter extends CustomPainter {
  final List<Star> stars;
  final Animation<double> animation;

  StarPainter({required this.stars, required this.animation})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw black background
    final bgPaint = Paint()..color = Colors.black;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final paint = Paint()..color = Colors.white;
    final t = animation.value * 2 * pi;

    for (final star in stars) {
      final dx = cos(t + star.phase) * 5; // drift
      final dy = sin(t + star.phase) * 5;

      final offset = Offset(
        star.x * size.width + dx,
        star.y * size.height + dy,
      );

      canvas.drawCircle(offset, star.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarPainter oldDelegate) => true;
}