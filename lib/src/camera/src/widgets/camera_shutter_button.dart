import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../controllers/cam_controller.dart';
import '../entities/camera_type.dart';
import 'camera_builder.dart';

///
class CameraShutterButton extends StatelessWidget {
  ///
  const CameraShutterButton({
    Key? key,
    required this.videoDuration,
    required this.controller,
  }) : super(key: key);

  ///
  final Duration videoDuration;

  ///
  final CamController controller;

  @override
  Widget build(BuildContext context) {
    return CameraBuilder(
      controller: controller,
      builder: (value, child) {
        if (value.hideCameraShutterButton) {
          return const SizedBox();
        }
        return child!;
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ShutterButton(
            videoDuration: videoDuration,
            controller: controller,
          ),
        ],
      ),
    );
  }
}

class _ShutterButton extends StatefulWidget {
  const _ShutterButton({
    Key? key,
    required this.videoDuration,
    required this.controller,
    this.size = 70.0,
  }) : super(key: key);

  final Duration videoDuration;
  final double size;
  final CamController controller;

  @override
  _ShutterButtonState createState() => _ShutterButtonState();
}

class _ShutterButtonState extends State<_ShutterButton>
    with TickerProviderStateMixin {
  late CamController _camController;
  late final AnimationController _controller;
  late final AnimationController _pulseController;
  late final Animation<double> _animation;

  var margin = 0.0;
  var strokeWidth = 6.0;
  var _videoIconRadius = 10.0;

  @override
  void initState() {
    super.initState();
    _camController = widget.controller;
    // Progress bar animation controller
    _controller = AnimationController(
      vsync: this,
      duration: widget.videoDuration,
    )..addStatusListener((status) {
        if (_controller.status == AnimationStatus.completed) {
          _stopRecording();
        }
      });

    // Splash animation controller
    _pulseController = (AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    ))
      ..addStatusListener((status) {
        if (_pulseController.status == AnimationStatus.completed) {
          if (_camController.value.cameraType == CameraType.video) {
            _controller.forward();
          } else {
            _pulseController.reverse();
          }
        }
      });

    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
  }

  void _startRecording() {
    _camController.startVideoRecording();
    _pulseController.forward(from: 0.2);
    setState(() {
      strokeWidth = 3;
      margin = 1.0;
      _videoIconRadius = 4.0;
    });
  }

  void _stopRecording() {
    _camController.stopVideoRecording();
    _pulseController.reverse();
    _controller.reset();
    setState(() {
      strokeWidth = 5;
      margin = 0.0;
      _videoIconRadius = 10.0;
    });
  }

  void _videoButtonPressed() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  void _cameraButtonPressed() {
    _camController.takePicture();
    _pulseController.forward(from: 0.2);
  }

  bool get _isRecording => _controller.status == AnimationStatus.forward;

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isRecording) {
          _stopRecording();
        }
        return false;
      },
      child: SizedBox(
        height: widget.size,
        width: widget.size,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.all(margin),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: _CustomPainter(
                  progress: _animation.value,
                  strokeWidth: strokeWidth,
                ),
                child: child,
              );
            },
            child: GestureDetector(
              onTap: () {
                _camController.value.cameraType == CameraType.video
                    ? _videoButtonPressed()
                    : _cameraButtonPressed();
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background
                  Container(
                    margin: const EdgeInsets.all(7.0),
                    decoration: const BoxDecoration(
                      color: Colors.white70,
                      shape: BoxShape.circle,
                    ),
                  ),

                  // Pulse animation
                  _Pulse(
                    controller: _pulseController,
                    size: widget.size - strokeWidth - margin - 4,
                  ),

                  // Icon
                  CameraBuilder(
                    controller: widget.controller,
                    builder: (value, child) {
                      switch (value.cameraType) {
                        case CameraType.selfi:
                          return const Icon(
                            CupertinoIcons.person_fill,
                            color: Colors.blue,
                          );
                        case CameraType.video:
                          return _VideoIcon(radius: _videoIconRadius);
                        default:
                          return const SizedBox();
                      }
                    },
                  ),

                  //
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoIcon extends StatelessWidget {
  const _VideoIcon({
    Key? key,
    this.size = 20.0,
    this.radius = 10.0,
  }) : super(key: key);

  final double radius;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _CustomPainter extends CustomPainter {
  _CustomPainter({
    this.progress = 0.0,
    this.strokeWidth = 7.0,
    this.strokeColor = Colors.white,
    this.progressColor = Colors.blue,
  });

  final double progress;
  final double strokeWidth;
  final Color strokeColor;
  final Color progressColor;

  double _degToRad(double deg) => deg * (pi / 180.0);

  // double _radToDeg(double rad) => rad * (180.0 / pi);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.height * 0.5;
    final center = Offset(radius, radius);

    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paint);

    if (progress != 1.0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;

      final rect = Rect.fromCircle(center: center, radius: radius);
      final sweepAngle = _degToRad(360.0 * progress);
      canvas.drawArc(rect, -pi / 2, sweepAngle, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Pulse extends StatefulWidget {
  const _Pulse({
    Key? key,
    required this.controller,
    this.size = 50.0,
  }) : super(key: key);

  final double size;
  final AnimationController controller;

  @override
  _PulseState createState() => _PulseState();
}

class _PulseState extends State<_Pulse> {
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: widget.controller, curve: Curves.easeIn),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Center(
          child: Opacity(
            opacity: _animation.value,
            child: Transform.scale(
              scale: widget.controller.status == AnimationStatus.reverse
                  ? 1.0
                  : _animation.value,
              child: SizedBox.fromSize(
                size: Size.square(widget.size),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
