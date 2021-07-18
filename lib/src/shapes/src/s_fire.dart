import 'package:flutter/material.dart';

/// Fire shape
class SFirePainter extends CustomPainter {
  ///
  SFirePainter({this.color = Colors.black});

  ///
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.7211211, size.height * 0.3121367)
      ..cubicTo(
          size.width * 0.5426270,
          size.height * 0.2035410,
          size.width * 0.6263301,
          size.height * 0.05026562,
          size.width * 0.6299238,
          size.height * 0.04389453)
      ..cubicTo(
          size.width * 0.6351348,
          size.height * 0.03482812,
          size.width * 0.6351172,
          size.height * 0.02367383,
          size.width * 0.6298789,
          size.height * 0.01462305)
      ..cubicTo(size.width * 0.6246426, size.height * 0.005572266,
          size.width * 0.6149785, 0, size.width * 0.6045215, 0)
      ..cubicTo(
          size.width * 0.5126406,
          0,
          size.width * 0.4406914,
          size.height * 0.02610547,
          size.width * 0.3906738,
          size.height * 0.07759570)
      ..cubicTo(
          size.width * 0.3052070,
          size.height * 0.1655723,
          size.width * 0.3091719,
          size.height * 0.3025000,
          size.width * 0.3108652,
          size.height * 0.3609707)
      ..cubicTo(
          size.width * 0.3110547,
          size.height * 0.3674492,
          size.width * 0.3112148,
          size.height * 0.3730449,
          size.width * 0.3112148,
          size.height * 0.3772031)
      ..cubicTo(
          size.width * 0.3112148,
          size.height * 0.4206172,
          size.width * 0.3181797,
          size.height * 0.4606953,
          size.width * 0.3243262,
          size.height * 0.4960586)
      ..cubicTo(
          size.width * 0.3282871,
          size.height * 0.5188477,
          size.width * 0.3317070,
          size.height * 0.5385273,
          size.width * 0.3323164,
          size.height * 0.5539961)
      ..cubicTo(
          size.width * 0.3329668,
          size.height * 0.5705625,
          size.width * 0.3299414,
          size.height * 0.5743555,
          size.width * 0.3298145,
          size.height * 0.5745098)
      ..cubicTo(
          size.width * 0.3293828,
          size.height * 0.5750234,
          size.width * 0.3257871,
          size.height * 0.5769336,
          size.width * 0.3160723,
          size.height * 0.5769336)
      ..cubicTo(
          size.width * 0.3049902,
          size.height * 0.5769336,
          size.width * 0.2968223,
          size.height * 0.5733125,
          size.width * 0.2895820,
          size.height * 0.5651973)
      ..cubicTo(
          size.width * 0.2613086,
          size.height * 0.5334922,
          size.width * 0.2593535,
          size.height * 0.4469277,
          size.width * 0.2647598,
          size.height * 0.3998320)
      ..cubicTo(
          size.width * 0.2657266,
          size.height * 0.3915273,
          size.width * 0.2630996,
          size.height * 0.3832070,
          size.width * 0.2575391,
          size.height * 0.3769648)
      ..cubicTo(
          size.width * 0.2519805,
          size.height * 0.3707227,
          size.width * 0.2440195,
          size.height * 0.3671523,
          size.width * 0.2356621,
          size.height * 0.3671523)
      ..cubicTo(
          size.width * 0.1595977,
          size.height * 0.3671523,
          size.width * 0.1027578,
          size.height * 0.4915430,
          size.width * 0.1027578,
          size.height * 0.6027617)
      ..cubicTo(
          size.width * 0.1027578,
          size.height * 0.6550449,
          size.width * 0.1132754,
          size.height * 0.7062598,
          size.width * 0.1340156,
          size.height * 0.7549883)
      ..cubicTo(
          size.width * 0.1540664,
          size.height * 0.8020957,
          size.width * 0.1826562,
          size.height * 0.8446074,
          size.width * 0.2190000,
          size.height * 0.8813477)
      ..cubicTo(
          size.width * 0.2946816,
          size.height * 0.9578613,
          size.width * 0.3944727,
          size.height,
          size.width * 0.4999863,
          size.height)
      ..cubicTo(
          size.width * 0.6059277,
          size.height,
          size.width * 0.7056914,
          size.height * 0.9584570,
          size.width * 0.7809062,
          size.height * 0.8830293)
      ..cubicTo(
          size.width * 0.8559258,
          size.height * 0.8077930,
          size.width * 0.8972422,
          size.height * 0.7082598,
          size.width * 0.8972422,
          size.height * 0.6027578)
      ..cubicTo(
          size.width * 0.8972422,
          size.height * 0.4681465,
          size.width * 0.7919160,
          size.height * 0.3552070,
          size.width * 0.7211211,
          size.height * 0.3121367)
      ..close();

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
