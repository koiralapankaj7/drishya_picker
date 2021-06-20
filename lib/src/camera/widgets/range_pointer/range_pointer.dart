import 'dart:math';

import 'package:flutter/material.dart';

///
class CircularProgressView extends StatelessWidget {
  ///
  const CircularProgressView({
    Key? key,
    required this.child,
    this.margin,
    this.padding,
    this.stroke = 3.0,
    this.background,
    this.size = 100.0,
    this.progress = 1.0,
    this.loading = false,
    this.onPressed,
  }) : super(key: key);

  ///
  final EdgeInsetsGeometry? margin;

  ///
  final EdgeInsetsGeometry? padding;

  /// Gradient stroke
  final double stroke;

  ///
  final Color? background;

  ///
  final Widget child;

  ///
  final double size;

  ///
  final double progress;

  ///
  final bool loading;

  ///
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.0,
      width: 200.0,
      child: CustomPaint(
        foregroundPainter: _CustomPainter(),
        child: Container(
          margin: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

///
double degToRad(double deg) => deg * (pi / 180.0);

///
double radToDeg(double rad) => rad * (180.0 / pi);

class _CustomPainter extends CustomPainter {
  _CustomPainter({
    this.progress = 0.2,
  });

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.height * 0.5;
    final center = Offset(radius, radius);

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paint);

    final progressPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepAngle = degToRad(360.0 * progress);
    canvas.drawArc(rect, -pi / 2, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
