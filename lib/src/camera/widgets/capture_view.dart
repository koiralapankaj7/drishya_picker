import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'camera_type.dart';

///
class CaptureView extends StatelessWidget {
  ///
  const CaptureView({
    Key? key,
    required this.controller,
    required this.cameraTypeNotifier,
    required this.onImageCapture,
    required this.onRecordingStart,
    required this.onRecordingStop,
    required this.videoDuration,
  }) : super(key: key);

  ///
  final CameraController controller;

  ///
  final ValueNotifier<CameraType> cameraTypeNotifier;

  ///
  final void Function() onImageCapture;

  ///
  final void Function() onRecordingStart;

  ///
  final void Function() onRecordingStop;

  ///
  final Duration videoDuration;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CaptureButton(
          cameraTypeNotifier: cameraTypeNotifier,
          onImageCapture: onImageCapture,
          onRecordingStart: onRecordingStart,
          onRecordingStop: onRecordingStop,
          videoDuration: videoDuration,
        ),
      ],
    );
  }
}

class _CaptureButton extends StatefulWidget {
  const _CaptureButton({
    Key? key,
    required this.cameraTypeNotifier,
    required this.onImageCapture,
    required this.onRecordingStart,
    required this.onRecordingStop,
    required this.videoDuration,
    this.size = 70.0,
  }) : super(key: key);

  final ValueNotifier<CameraType> cameraTypeNotifier;
  final Duration videoDuration;
  final void Function() onImageCapture;
  final void Function() onRecordingStart;
  final void Function() onRecordingStop;
  final double size;

  @override
  _CaptureButtonState createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<_CaptureButton>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _pulseController;
  late final Animation<double> _animation;
  late CameraType _cameraType;

  var margin = 0.0;
  var strokeWidth = 6.0;
  var _videoIconRadius = 10.0;

  @override
  void initState() {
    super.initState();

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
          if (_cameraType == CameraType.video) {
            _controller.forward();
          } else {
            _pulseController.reverse();
          }
        }
      });

    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
  }

  void _startRecording() {
    widget.onRecordingStart();
    _pulseController.forward(from: 0.2);
    setState(() {
      strokeWidth = 3;
      margin = 1.0;
      _videoIconRadius = 4.0;
    });
  }

  void _stopRecording() {
    widget.onRecordingStop();
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
    _pulseController.forward(from: 0.2);
    widget.onImageCapture();
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
    return SizedBox(
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
              _cameraType == CameraType.video
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
                CameraTypeBuilder(
                  notifier: widget.cameraTypeNotifier,
                  builder: (context, type, child) {
                    _cameraType = type;
                    return Builder(
                      builder: (context) {
                        switch (type) {
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
                    );
                  },
                ),

                //
              ],
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
