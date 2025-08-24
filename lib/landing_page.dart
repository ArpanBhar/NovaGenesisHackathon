import 'dart:math';

import 'package:celestia/login.dart';
import 'package:celestia/signup.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Star> stars;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    final rand = Random();
    stars = List.generate(
      120,
      (_) => Star(
        x: rand.nextDouble(),
        y: rand.nextDouble(),
        radius: rand.nextDouble() * 2 + 1,
        phase: rand.nextDouble() * 2 * pi, // randomize motion phase
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Star field background
          SizedBox.expand(
            child: CustomPaint(
              painter: StarPainter(stars: stars, animation: _controller),
            ),
          ),
          // Foreground UI
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Celestia",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Text(
                    "A constellation recognition system powered by machine learning.\n"
                    "Upload a picture and let Celestia recognize the stars.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> SignUpPage()));
                      },
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), foregroundColor: Colors.white, backgroundColor: Colors.black),
                      child: const Text("Sign Up"),
                    ),
                    const SizedBox(width: 18,),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> const LoginPage()));
                      },
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), foregroundColor: Colors.white, backgroundColor: Colors.black),
                      child: const Text("Log In"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

class StarPainter extends CustomPainter {
  final List<Star> stars;
  final Animation<double> animation;

  StarPainter({required this.stars, required this.animation})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    final t = animation.value * 2 * pi;

    for (final star in stars) {
      // Slight circular drifting around original position
      final dx = cos(t + star.phase) * 5; // max drift = 5px
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