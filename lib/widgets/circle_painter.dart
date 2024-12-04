import 'dart:ui';

import 'package:flutter/material.dart';

class ScatteredBallsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    final circles = [
      Circle(const Offset(100, 100), 25, const Color.fromRGBO(185, 246, 202, 1),),
      Circle(const Offset(100, 400), 28, const Color.fromRGBO(185, 246, 202, 1),),
      Circle(const Offset(350, 450), 10, const Color.fromRGBO(185, 246, 202, 1),),
      Circle(const Offset(150, 550), 20, const Color.fromARGB(255, 246, 228, 185),),
      Circle(const Offset(350, 80), 27, const Color.fromARGB(255, 246, 228, 185)),
      Circle(const Offset(120, 200), 12, const Color.fromARGB(255, 246, 228, 185),),
      Circle(const Offset(290, 250), 22, const Color.fromRGBO(185, 246, 202, 1),),
      Circle(const Offset(50, 500), 15, const Color.fromARGB(255, 246, 228, 185),),
      Circle(const Offset(280, 350), 29, const Color.fromRGBO(185, 246, 202, 1),),
      Circle(const Offset(300, 500), 14, const Color.fromARGB(255, 246, 228, 185),),
      Circle(const Offset(100, 620), 20, const Color.fromRGBO(185, 246, 202, 1),),
    ];

    for (final circle in circles) {
      paint.color = circle.color;
      canvas.drawCircle(circle.position, circle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; 
  }
}


class Circle {
  final Offset position;
  final double radius;
  final Color color;

  Circle(this.position, this.radius, this.color);
}